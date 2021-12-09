$ontext
Reporting of LP specific model parameters and derived quantities.

JSA 14.10.2020
$offtext

*#########################################################################
*                   REPORT PARAMETERS
*#########################################################################
*parameter definitions in report_base

*#########################################################################
*                                Model status
*#########################################################################
r_modelstatistics('solvestat') = cepeem_LP.solvestat;
r_modelstatistics('modelstat') = cepeem_LP.modelstat;
*r_modelstatistics('SolverTime') = cepeem_LP.SolverTime;
r_modelstatistics('objval') = cepeem_LP.objval;

$ondotl
*#########################################################################
*                                Renewable share in demand
*#########################################################################
r_share_renewables = sum((r,c), renTotal(r,c) + RESGEN(r,c) - sum(t, CURT(r,c,t)))
                     / sum((c,t),dur_d(t)*demand(c,t));

*#########################################################################
*                                Prices LP
*#########################################################################
* hourly electricity prices
r_price(c,t)      = mkt_G_LP.M(c,t)/dur_d(t) * (1/scale_obj);

* yearly average electricity price
r_price_avg(c)    = sum(t, demand(c,t) * r_price(c,t) * dur_d(t))/sum(t, demand(c,t) * dur_d(t));

* alternative calculation for yearly average electricity price
r_price_avgII(c)  = r_price_avg(c);

* daily average electricity price
rd_price_avg(c,d)$(sum(map_t_d(t,d), demand(c,t)) > 0)
                 = sum(map_t_d(t,d), demand(c,t)*mkt_G_LP.M(c,t) / dur_d(t)*(1/scale_obj))/sum(map_t_d(t,d), demand(c,t));

*#########################################################################
*                               Demand LP
*#########################################################################
* total yearly demand for each country
r_demand_total(c)   = sum(t, demand(c,t) * dur_d(t))/10**6;

* hourly demand for each country
r_demand(c,t)  = demand(c,t);

* daily demand for each country
rd_demand(c,d)            = sum(map_t_d(t,d), demand(c,t));

*#########################################################################
*                          Transmission LP specific
*#########################################################################
* hourly shadow price of net transfer capacity
r_ntc_price(c,cc,t) = mkt_ntc.M(c,cc,t)/dur_d(t) * (1/scale_obj);

* average shadow price of net transfer capacity (trade weighted)
r_ntc_price_avg(c,cc)$(sum(t, r_ntc_price(c,cc,t)) gt 0.0001) = sum(t, TRADE(c,cc,t) * r_ntc_price(c,cc,t) * dur_d(t))/sum(t, TRADE(c,cc,t) * dur_d(t));
r_ntc_price_avgII(c,cc)$(sum(t, r_ntc_price(c,cc,t)) gt 0.0001) = sum(t, r_ntc_price(c,cc,t));

* income from renting out scarce net transfer capacity
r_congestionRent(c,cc) =  round(sum(t, TRADE(c,cc,t) * r_ntc_price(c,cc,t)  * dur_d(t)), 8);

* total yearly net export revenues (pexp*exp - pimp*imp) for region c net of line losses [EUR]
r_netTradeRevenue(c)        = sum((t,cc), (r_price(c,t) * TRADE(c,cc,t) - (1 - line_loss(cc,c)) * r_price(cc,t) * TRADE(cc,c,t)) * dur_d(t));

* daily shadow price of net transfer capacity
rd_ntc_price(c,cc,d) = sum(map_t_d(t,d), mkt_ntc.M(c,cc,t)*(1/scale_obj)) / 24;

$offdotl
$exit
