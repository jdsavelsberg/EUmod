$ontext
Scenario for test runs
$offtext

*###############################################################################
*                             POLICY OPTIONS
*###############################################################################
* no investment in RES

cinv_0(r,c) = 0;

*avail("Reservoir",c,t) = 1;


* Switch non-linear generation cost off by setting c_vom_1 to zero:
* what to do with slope of mariginal cost of conventionals?
*c_vom_1(p_all) = 0.01;

* switch off chp
*chp_dem(i,c,t) = 0;

*###############################################################################
*                             SET POLICIES
*###############################################################################
