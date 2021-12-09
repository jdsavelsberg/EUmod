$ontext
Runfile for European Electricity Market Model
$offtext

$setglobal basicparams "--baseData=data_EU_2017_all"

*first run LP
$setglobal scenarioparams "--scenario=base --modeltype=LP  --loadlpprices=no  --loadqcpprices=no"
$call =gams main.gms %basicparams% %scenarioparams%

*then run qcp and set pref to LP result
*$setglobal scenarioparams "--scenario=base --modeltype=QCP --loadlpprices=yes --loadqcpprices=no"
*$call =gams main.gms %basicparams% %scenarioparams%

*then run qcp and set pref to first qcp result
*$setglobal scenarioparams "--scenario=base --modeltype=QCP --loadlpprices=no --loadqcpprices=yes --runno=2"
*$call =gams main.gms %basicparams% %scenarioparams%




