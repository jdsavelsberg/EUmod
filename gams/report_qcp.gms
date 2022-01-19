$ontext
Reporting of QCP specific model parameters and derived quantities.

JSA 14.10.2020
$offtext

*#########################################################################
*                   REPORT PARAMETERS
*#########################################################################
*parameter definitions in report_base

*#########################################################################
*                                Model status
*#########################################################################
r_modelstatistics('solvestat') = cepeem_QCP.solvestat;
r_modelstatistics('modelstat') = cepeem_QCP.modelstat;
*r_modelstatistics('SolverTime') = cepeem_LP.SolverTime;
r_modelstatistics('objval') = cepeem_QCP.objval;

$ondotl

*#########################################################################
*                                Renewable share in demand
*#########################################################################
r_share_renewables = sum((r,c), renTotal(r,c) + RESGEN(r,c) - sum(t, CURT(r,c,t)))
                     / sum(c,DEM(c));


*#########################################################################
*                                Prices QCP
*#########################################################################
* hourly electricity prices
r_price(c,t) = mkt_G_QCP.M(c,t)/dur_d(t)*(-1/scale_obj);

* yearly average electricity price
r_price_avg(c) = sum(t, beta(c,t) * DEM.L(c) * r_price(c,t) * dur_d(t)) / (sum(t, beta(c,t) * DEM.L(c) * dur_d(t)));

* alternative calculation for yearly average electricity price
r_price_avgII(c) = (DEM.L(c) - dem_a(c))/(dem_b(c));

* daily average electricity price
rd_price_avg(c,d) = sum(map_t_d(t,d), beta(c,t)*DEM.L(c) * mkt_G_QCP.M(c,t) / dur_d(t) *(-1/scale_obj))/(sum(map_t_d(t,d), beta(c,t)*DEM.L(c)));

*#########################################################################
*                               Demand QCP
*#########################################################################
* total yearly demand for each country
r_demand_total(c)   = (DEM.L(c))/10**6;

* hourly demand for each country
r_demand(c,t)  = beta(c,t) * DEM.L(c);

* daily demand for each country
rd_demand(c,d)  = sum(map_t_d(t,d), beta(c,t)*DEM.L(c));

*#########################################################################
*                          Transmission QCP specific
*#########################################################################

* hourly shadow price of net transfer capacity
r_ntc_price(c,cc,t) = mkt_ntc.M(c,cc,t) / dur_d(t) * (1/scale_obj);

* average shadow price of net transfer capacity (trade weighted)
r_ntc_price_avg(c,cc)$(sum(t, r_ntc_price(c,cc,t)) gt 0.0001) = sum(t, TRADE(c,cc,t) * r_ntc_price(c,cc,t) * dur_d(t))/sum(t, TRADE(c,cc,t) * dur_d(t));
r_ntc_price_avgII(c,cc)$(sum(t, r_ntc_price(c,cc,t)) gt 0.0001) = sum(t, r_ntc_price(c,cc,t));

* income from renting out scarce net transfer capacity
r_congestionRent(c,cc) =  round(sum(t, TRADE(c,cc,t) * r_ntc_price(c,cc,t)  * dur_d(t)), 8);

* total yearly net export revenues (pexp*exp - pimp*imp) for region c net of line losses [EUR]
r_netTradeRevenue(c)        = sum((t,cc), (r_price(c,t) * TRADE(c,cc,t) - (1 - line_loss(cc,c)) * r_price(cc,t) * TRADE(cc,c,t)) * dur_d(t));

* daily shadow price of net transfer capacity
rd_ntc_price(c,cc,d) = sum(map_t_d(t,d), mkt_ntc.M(c,cc,t)*(1/scale_obj)) / 24;

*#########################################################################
*                          Welfare QCP specific
*#########################################################################

* consumer surplus
r_cSurplus(c)  =  1/(2*dem_b(c)) * sqr(DEM(c)) - dem_a(c)*DEM(c) - r_price_avg(c)*DEM(c);

* producer surplus
r_pSurplus(c)  = sum{t,
*                   income
                    dur_d(t) * r_price(c,t) * (
                                     sum(i, GEN(i,c,t))
                                   + sum(s, S_DISCHAR(s,c,t) - S_CHAR(s,c,t))
                                   + sum(r, betaRen(r,c,t) * (renTotal(r,c) + RESGEN(r,c)) - CURT(r,c,t)) )
                   }
*                   Cost conventional fuel and startup
                    - sum(i, r_cost_tech(i,c))
*                   Investment cost RES
                    - sum(r, r_investment_cost(r,c))
;

* total surplus, sum of consumer surplus and producer surplus
r_surplus(c)   = 1/(2*dem_b(c)) * (DEM(c))**2 - dem_a(c) * DEM(c);

* welfare
r_welfare(c)   = r_surplus(c) - r_cost(c);

$offdotl
