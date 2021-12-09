$ontext
Definition and assignment of default policy values
$offtext

*############################################################
*@         DEFINITION OF POLICY PARAMETERS AND SETS
*############################################################
set
         q                       quota systems
         /q1*q100/
         ets                     emissions trading system
         /ets1*ets100/
         map_q(tech,c,q)         mapping: resource r in country c under quota sytem q
;

parameter
         ren_target(q)           renewable target in quota system q [MWh]
         min_sh_renewables(q)    renewable share in total generation [%]
;

*############################################################
*@                 ASSIGN DEFAULT POLICIES
*############################################################
* By default no quota system
map_q(r,c,q) = no;
ren_target(q) = 0;
min_sh_renewables(q) = 0;

