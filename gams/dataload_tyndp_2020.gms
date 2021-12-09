
$ontext
Upload of TYNDP 2020 data
JSA 110120
$offtext

*#####################################################################
*@                          DEFINITIONS
*#####################################################################
set
tyndpscenario            scenario according to tynpd 2020 data
climateyear              climateyear according to tynpd 2020 data
runyear                  runyear according to tynpd 2020 data
;

parameter
tyndp_cap(tyndpscenario,runyear,climateyear,c,tech)              conventional capacitiy according to tynpd 2020 data [MW]
tyndp_cap_dsm(tyndpscenario,runyear,climateyear,c)               DSM capacity [MW]
tyndp_demand(tyndpscenario,runyear,c,t)                          hourly demand according to tynpd 2020 data [MWh]
tyndp_gen_annual(tyndpscenario,runyear,climateyear,c,tech)       annual res generation according to tynpd 2020 data [MWh]
tyndp_chp(tyndpscenario,runyear,climateyear,c,tech)              annual chp generation according to tynpd 2020 data [MWh]
tyndp_renS(climateyear,c,tech,t)                                 hourly res profiles for tyndp 2020 weather years from res ninja [%]
tyndp_ntc(tyndpscenario,runyear,climateyear,c,cc)                ntc values according to tynpd 2020 data [MW]
tyndp_ror(climateyear,c,t)                                       hourly ror profiles for tyndp 2020 weather years from JRC data [MWh]
tyndp_co2price(tyndpscenario,runyear)                            CO2 price according to tynpd 2020 data [EUR per t]
tyndp_emissionfactor(tyndpscenario,runyear,climateyear,c,tech)   emission factor from tyndp 2020 runs [t per MWh]

tyndp_s_lev_ntc_on(s,c,t)                                        storage level from ntc on run
;


*#####################################################################
*@                   DATA UPLOAD
*#####################################################################
* load data
$gdxin %datadir%scenario_data_tyndp.gdx
$load climateyear runyear tyndpscenario
$load tyndp_cap tyndp_ntc
$loaddc tyndp_cap_dsm
$load tyndp_gen_annual tyndp_chp
$load tyndp_demand tyndp_renS tyndp_ror
$loaddc tyndp_co2price
$gdxin

$if %ntc_off% == "ntc_off" $gdxin %reportdir%%scenario%%modeltype%%runno%%suffix%%tyndpscenario%%climateyear%%runyear%.gdx
$if %ntc_off% == "ntc_off" $loaddc tyndp_s_lev_ntc_on=S_LEV.l
$if %ntc_off% == "ntc_off" $gdxin



