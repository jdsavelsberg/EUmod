$ontext
Initital values and variable bounds
$offtext


*############################################################
*                    LOWER BOUNDS
*############################################################
DEM.LO(c) = 1;

*############################################################
*                    FIXED VARIABLES
*############################################################
* Fix variables with no capacity
GEN.FX(i,c,t)$(not avail(i,c,t)*cap(i,c)) = 0;
S_GEN.FX(s,c,t)$(not cap(s,c)) = 0;
S_WIT.FX(s,c,t)$(not cap_P(s,c)) = 0;
S_LEV.FX(s,c,t)$(not cap_L(s,c) and not cap(s,c)) = 0;
TRADE.FX(c,cc,t)$(not ntc(c,cc,t)) = 0;

* Curtailment has to be zero if no renewable supply
*CURT.FX(r,c,t)$(not(betaRen(r,c,t)*(renTotal(r,c) + RESGEN.L(r,c)))) = 0;

* if linear term of investment cost is zero, fix RES investment to zero
RESGEN.FX(r,c) = 0;
$iftheni %renewable_investment% == yes
RESGEN.UP(r,c) = + inf;
RESGEN.FX(r,c)$(not cinv_0(r,c)) = 0;
RESGEN.FX(r,c)$(not pot_ren_mwh(r,c)) = 0;
$endif

* Fix slack if we do not allow lost load:
SLACK.FX(c,t)$(not penalty(c)) = 0;

$if %privatetransport%=="on" S_TRANSPORT.fx(c,"EV")$(not c_transport(c)) = 0;



