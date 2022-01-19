$ontext
Main file for European Electricity Market Model
$offtext

*############################################################
*@                OPTIONS
*############################################################
* You can either run the LP or QCP model
* If you want to run the QCP, you have to run the LP first
* in order to get prices. Also set base price create equal to
* yes
* the file with prices for calibration will be located in data
* directory

* set modeltype here, not in scenario file
$if not set modeltype $set modeltype LP

* switch for selecting if calibration factors should be used (yes / no)
$if not set calibrated $set calibrated yes

* set scenario (e.g. base for base case)
$if not set scenario $set scenario invest
*base

* switch for activating renewable investments (yes or no)
$if not set renewable_investment $set renewable_investment yes

* datafile to use (here short version with 15 days)
$if not set baseData $setglobal baseData "data_EU_2017_15"
$if %baseData%=="data_EU_2017_15" $setglobal suffix "_15"
$if not set suffix $set suffix
$if not set suffix_scenario $set suffix_scenario

* datafile with scaled cost coefficients for investment cost
* missing file will skip cost scaling
$if not set costData $setglobal costData "cost_parameters"

*@@ ------------------- PATH SETTINGS -----------------------
$if not set datadir $setglobal datadir "..\data\"
$if not set scendir $setglobal scendir "..\scenarios\%scenario%\"
$if not set reportdir $setglobal reportdir "%scendir%\results\"

*@@ -------- FILE TO OWERWRITE REFERENCE PRICES -------------
* file to overwrite reference prices
* the baseprice gdx file has to
*    - to be provided with full path
*    - contain a parameter r_price
*      which is used to overwrite existing references prices
* Only set the option, if reference prices should be updated
* if not set, prices will not be updated
* for testing could, e.g., use:
$if %modeltype%=="QCP" $if not set baseprices $set baseprices ..\scenarios\base\results\baseLP%suffix%

* flag to also adjust demand
* only active if baseprice is set
* by default deactivated, only use to calibrate qcp model
* to replicate to a given point, i.e., previous qcp run
$if not set adjustDemand $set adjustDemand no

*@@ ------------------- FILE SETTINGS ------------------------
$set scenfile "%scendir%%scenario%.gms"
$set reportfile "%reportdir%%scenario%%modeltype%%suffix%.gdx"
*does not exist

*@@ ------------------ MODEL OPTIONS ------------------------
* scaling of objective function
$setglobal scale_obj 1

* assumption on line losses
$if not set linelosses $setglobal linelosses 0.001
*used to be 0.03

*@@ ------------------ OPTIONS CHECK ------------------------
* A bit ugly: testing on correct model type (does there exits an AND for $ifi)
$iftheni not %modeltype% == LP
$  ifi not %modeltype% == QCP $abort "#### INVALID MODELTYPE SPECIFIED; VALID ARE: LP OR QCP ####"
$endif

*############################################################
*@                 DATA UPLOAD AND CALIBRATION
*############################################################
$include dataload.gms

$if %calibrated%=="yes" $include calibration.gms

$include policies.gms

$if %privatetransport%=="on" $include dataload_transport.gms
*############################################################
*@                         MODELS
*############################################################
$include models.gms
$if %DSM_switch%=="on" $include module_DSM

*############################################################
*@                  SCENARIO SETTINGS
*############################################################
* include scenario file
$include %scenfile%

*############################################################
*@                      MODEL SOLVE
*############################################################
$if defined solvestatsBU $exit
parameter
    solvestatsBU   report of solution statistics
;

$include init.gms

option resLim = 10000;
$iftheni %modelType% == LP
solve cepeem_LP  using LP minimizing COST;
* modeltype 0 as indicator for LP
solvestatsBU("modeltype") = 0;
$else
solve cepeem_QCP using QCP maximizing CSURP;
* modeltype 1 as indicator for QCP
solvestatsBU("modeltype") = 1;
$endif

* report solution statistics
solvestatsBU("solve") = cepeem_%modeltype%.solvestat;
solvestatsBU("model") = cepeem_%modeltype%.modelstat;

*############################################################
*@                    REPORTING AND EXPORTING
*############################################################
$include report_base.gms
$include report_%modeltype%.gms



*Dump everything to gdx
execute_unload "%reportfile%";
*execute '=gdx2xls "%reportfile%"';