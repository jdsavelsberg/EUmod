$ontext
Reporting of base model parameters and derived quantities.

JSA 14.10.2020
$offtext

*#########################################################################
*@                   REPORT PARAMETERS
*#########################################################################
* this list includes LP and QCP report parameters so they do not have to be defined twice
parameter
* report parameter of model statistics
    r_modelstatistics(*)
* report parameters regarding generation
    r_generation(*,c,t)                  report generation (accounted with duration)[MWh]
    r_storage_inj(*,c,t)                 report injection into storage
    r_generation_total(*,c)              report generation per year [TWh]
    r_generation_share(*,c)              report generation per year shares [%]
    r_share_renewables                   report share of renewables in demand [%]
    r_curtailment(r,c,t)                 report curtailment for RES [MWh]
    r_curtailment_total(r,c)             report total curtailment per year for RES [TWh]
    r_chp_gen(i,c,t)                     report CHP-related electricity generation [MWh]
    r_chp_gen_y(i,c)                     report yearly CHP-related electricity generation [TWh]

    rd_generation(tech,c,d)              report daily generation (accounted with duration)[MWh]
    rd_storage_inj(tech,c,d)             report daily injection into storage
    rd_curtailment(r,c,d)                report daily curtailment for RES [MWh]
    rd_chp_gen(i,c,d)                    report daily CHP-related electricity generation [MWh]

* report parameters regarding emissions
    r_emissions(*,c)                     report total emissions per year per country and technology [Mt CO2]

* report parameters regarding fuel input
    r_fuel_input(*,c)                    report total fuel input per technology and country [MWh]

* report parameters regarding investment and installed capacity
    r_investment(*,c)                    report investment into RES [TWh]
    r_cost_subsidy(q)                    subsidy cost by q
    r_subsidy_res(c)                     subsidy level per country
    r_capacity(*,tech,c)                 report installed capacities [MW]

* report parameters regarding electricty prices
    r_price(c,t)                         report price [Euro per MWh]
    r_hyd_price(c,t)                     report hydrogen price [Euro per MWh]
    r_price_avg(c)                       report yearly average price [Euro per MWh]
    r_price_avgII(c)                     report yearly average price based on demand function  [Euro per MWh]
    rd_price_avg(c,d)                    report daily price [Euro per MWh]

* report parameters regarding transmission and trade
    r_exports(c,t)                       report hourly exports [MWh]
    r_imports(c,t)                       report hourly imports [MWh]
    r_net_imports(c,t)                   report hourly net-imports [MWh]
    r_trade(c,cc)                        report aggregated trade [TWh]
    r_netTrade(c)                        report net exports [TWh]
    r_ntc_price                          report ntc prices
    r_ntc_price_avg                      report average ntc price (trade weighted)
    r_ntc_price_avgII                    report average ntc price
    r_congestionRent                     report congestion rents
    r_netTradeRevenue(c)                 report net trade revenue per country [EUR]

    rd_exports(c,d)                      report daily exports [MWh]
    rd_imports(c,d)                      report daily imports [MWh]
    rd_trade(c,cc,d)                     report daily trade [MWh]
    rd_net_imports(c,d)                  report hourly net-imports [MWh]
    rd_ntc_price(c,cc,d)                 report ntc prices

* report parameters regarding demand
    r_demand_total(c)                    report total demand [TWh]
    r_demand(c,t)                        report demand [MWh]
    rd_demand(c,d)                       report daily demand [MWh]

* report parameters regarding cost
    r_cost(c)                            report regional cost [10**6 Euro]
    r_cost_vom(i,c)                      report variable OM cost [10**6 Euro]
    r_cost_vom_total(c)                  report total variable OM cost [10**6 Euro]
    r_cost_carbon(f,c)                   report total carbon costs per fuel and country [10**6 Euro]
    r_cost_carbon_tech(i,c)              report total carbon costs per technology and country [10**6 Euro]
    r_cost_fuel(f,c)                     report total fuel costs per fuel and country [10**6 Euro]
    r_cost_fuel_tech(i,c)                report total fuel costs per technology and country [10**6 Euro]
    r_cost_tot(*)                        report total system cost (as defined in the objective) [10**6 Euro]
    r_cost_tech(*,c)                     report cost by technology and country
    r_cost_test1(*,c)                    report test parameter to check if r_cost_tech is equal to sum of r_cost_carbon and r_cost_fuel
    r_cost_test2(*,c)                    report test parameter to check if r_cost_tech is equal to sum of r_cost_carbon and r_cost_fuel
    r_cost_unit(*,c,t)                   report marginal unit cost by technology and country and period
    r_investment_cost(*,c)               report total investment cost for RES per country and technology [EUR]
    rd_cost_unit(*,c,d)                  report daily marginal unit cost by technology and country and period

* report parameters regarding welfare
    r_surplus(c)                         report area under demand function
    r_cSurplus(c)                        report consumer surplus i.e. integral under demand
    r_pSurplus(c)                        report producer surplus
    r_welfare(c)                         report regional welfare [TWh]

;

*#########################################################################
*@                            Generation
*#########################################################################
$ondotl
* hourly generation from conventionals, storage, and renewables
r_generation(i,c,t)         = GEN(i,c,t)*dur_d(t) + eps;
r_generation(s,c,t)         = S_DISCHAR(s,c,t)*dur_d(t) + eps;
r_generation(r,c,t)         = betaRen(r,c,t)*dur_d(t)*(renTotal(r,c) + RESGEN(r,c)) - CURT(r,c,t);
r_generation("Pump",c,t)    = S_DISCHAR("PumpOpen",c,t)*dur_d(t) + S_DISCHAR("PumpClosed",c,t)*dur_d(t)
                              - S_CHAR("PumpOpen",c,t)*dur_d(t) - S_CHAR("PumpClosed",c,t)*dur_d(t);
r_generation("LostLoad",c,t)= SLACK(c,t)*dur_d(t) + eps;
* hourly injection into storage
r_storage_inj(s,c,t)        = S_CHAR(s,c,t)*dur_d(t) + eps;
r_storage_inj("Pump",c,t)   = (S_CHAR("PumpOpen",c,t) + S_CHAR("PumpClosed",c,t))*dur_d(t) + eps;

* total yearly generation for each country and technology
r_generation_total(tech,c)  = sum(t, r_generation(tech,c,t))/10**6 + eps;

* percentage values of gross production shares (including storage losses) of technologies for each country
r_generation_share(tech,c)  = (r_generation_total(tech,c))/(sum(techtech,r_generation_total(techtech,c))) + eps;

* hourly curtailment of renewable generation per country and technology
r_curtailment(r,c,t)        = CURT(r,c,t) + eps;

* total yearly curtailment of renewable generation per country and technology
r_curtailment_total(r,c)    = sum(t, CURT(r,c,t) * dur_d(t))/10**6 + eps;

* hourly generation due to CHP-demand
r_chp_gen(i,c,t)             = chp_dem(i,c,t) + eps;

* yearly generation due to CHP-demand
r_chp_gen_y(i,c)             = sum(t, r_chp_gen(i,c,t) * dur_d(t))/10**6 + eps;

* daily generation from conventionals, storage, and renewables
rd_generation(i,c,d)         = sum(map_t_d(t,d), GEN(i,c,t)) + eps;
rd_generation(s,c,d)         = sum(map_t_d(t,d), S_DISCHAR(s,c,t)) + eps;
rd_generation(r,c,d)         = sum(map_t_d(t,d), (betaRen(r,c,t)*(renTotal(r,c) + RESGEN(r,c)) - CURT(r,c,t)));
*rd_generation("Pump",c,d)    = sum(map_t_d(t,d), (S_DISCHAR("PumpOpen",c,t) + S_DISCHAR("PumpClosed",c,t)));

* daily injection into storage
rd_storage_inj(s,c,d)        = sum(map_t_d(t,d), S_CHAR(s,c,t)) + eps;
*rd_storage_inj("Pump",c,d)   = sum(map_t_d(t,d), (S_CHAR("PumpOpen",c,t) + S_CHAR("PumpClosed",c,t))) + eps;

* daily curtailment of renewable generation per country and technology
rd_curtailment(r,c,d)        = sum(map_t_d(t,d), CURT(r,c,t)) + eps;

* daily generation due to CHP-demand
rd_chp_gen(i,c,d)            = sum(map_t_d(t,d), chp_dem(i,c,t)) + eps;

*#########################################################################
*@                            Emissions
*#########################################################################
* Emissions per technology and country in million tons CO2
r_emissions(i,c)            = sum(t, sum(mapTF(i,f), carb_coef(f)) * (1-CCScapturerate(i)) * GEN(i,c,t)/eta(i,c) * dur_d(t))/10**6 + eps;

*#########################################################################
*@                            FUEL
*#########################################################################
* Input per fuel and country in MWh
r_fuel_input(f,c)            = sum(t, sum(mapTF(i,f), GEN(i,c,t)/eta(i,c)) * dur_d(t)) + eps;

*#########################################################################
*@                  Investment and Installed Capacity
*#########################################################################

* total investment into renewable capacity per country and technology
r_investment(r,c)           = (RESGEN(r,c))/10**6 + eps;

* total installed capacity for each country and technology
r_capacity("gross",tech,c)  = cap(tech,c) + eps;

*#########################################################################
*@                              Trade
*#########################################################################
* hourly exports from region c to all other regions in MWh
r_exports(c,t)                = sum(cc, TRADE(c,cc,t));

* hourly imports from all other regions to region c in MWh
r_imports(c,t)                = sum(cc, (1-line_loss(cc,c))*TRADE(cc,c,t));

* hourly net-imports from all other regions to region c in MWh
r_net_imports(c,t)            = r_imports(c,t) - r_exports(c,t);

* total yearly gross trade from region c to region cc in TWh
r_trade(c,cc)               = sum(t,  TRADE(c,cc,t))/10**6;

* total yearly net exports (exp - imp) from region c net of line losses
r_netTrade(c)               = sum((t,cc),  (TRADE(c,cc,t) - (1 - line_loss(cc,c))*TRADE(cc,c,t)))/10**6;

* daily exports from region c to all other regions in MWh
rd_exports(c,d)              = sum(map_t_d(t,d), sum(cc, TRADE(c,cc,t)));

* daily imports from all other regions to region c in MWh
rd_imports(c,d)              = sum(map_t_d(t,d), sum(cc, (1-line_loss(cc,c))*TRADE(cc,c,t)));

* daily trade from region c to region cc in TWh
rd_trade(c,cc,d)             = sum(map_t_d(t,d),  TRADE(c,cc,t))/10**6 + eps;

* daily net-imports from all other regions to region c in MWh
rd_net_imports(c,d)          = sum(map_t_d(t,d), r_imports(c,t) - r_exports(c,t));

*#########################################################################
*q                              COST
*#########################################################################
* generation cost per country for conventional technologies
r_cost_tech(i,c)           = sum(t, GEN(i,c,t) * (1/eta(i,c) * dur_d(t))
                              *( sum(f$mapTF(i,f), pf(f,c)) + sum(f$mapTF(i,f), carb_coef(f)*p_carb(c))*(1-CCScapturerate(i)))
                              + c_vom(i,c)
                              )/10**6 + eps;

* carbon costs per fuel and country [mio. EUR]
r_cost_carbon_tech(i,c)     = sum(t, sum(mapTF(i,f), p_carb(c) * carb_coef(f)) * (1-CCScapturerate(i)) * GEN(i,c,t)/eta(i,c) * dur_d(t))/10**6 + eps;
r_cost_carbon(f,c)          = sum(t, sum(mapTF(i,f), (1-CCScapturerate(i)) * GEN(i,c,t)/eta(i,c) * dur_d(t)) * p_carb(c) * carb_coef(f))/10**6 + eps;

* Fuel costs per technology and year [mio. EUR]
r_cost_fuel(f,c)             = sum(t, sum(mapTF(i,f), GEN(i,c,t)/eta(i,c) * pf(f,c)) * dur_d(t))/10**6 + eps;
r_cost_fuel_tech(i,c)        = sum(t, sum(mapTF(i,f), GEN(i,c,t)/eta(i,c) * pf(f,c)) * dur_d(t))/10**6 + eps;

* Variable OM cost
r_cost_vom(i,c)              = sum(t, dur_d(t)*GEN(i,c,t)*c_vom(i,c))/10**6 + eps;
r_cost_vom_total(c)          = sum(i, r_cost_vom(i,c));

* marginal generation cost per technology, country, and period:
r_cost_unit(i,c,t)$cap(i,c)
                              = (1/eta(i,c))
                                * (sum(f$mapTF(i,f), pf(f,c)) + sum(f$mapTF(i,f), carb_coef(f)*p_carb(c))*(1-CCScapturerate(i)))
                                + c_vom(i,c) + eps;

r_cost_test1(i,c)            = sum(mapTF(i,f), r_cost_fuel(f,c)) + r_cost_carbon_tech(i,c);
r_cost_test2(i,c)            = r_cost_tech(i,c) - sum(t, GEN(i,c,t) * (1/eta(i,c) * dur_d(t)) * c_vom(i,c));

* investment cost per country for renewable technologies
r_investment_cost(r,c)     = cinv_0(r,c)*RESGEN(r,c)/10**6 + eps;

* subsidy cost
r_cost_subsidy(q)          = (res_quota_supply.M(q) * sum(map_q(r,c,q), RESGEN(r,c)))$(min_sh_renewables(q) and sum(map_q(r,c,q), 1) > 0)
;


r_subsidy_res(c)           =  sum(map_q(r,c,q), res_quota_supply.M(q));

* total cost per country
r_cost(c)                  = sum(i, r_cost_tech(i,c)) + sum(t, penalty(c) * SLACK(c,t) * dur_d(t))
                              + sum((r,t), curtPenalty(c) * CURT(r,c,t) * dur_d(t))
                              + sum(r, r_investment_cost(r,c));

* marginal generation cost per technology, country, and day:
rd_cost_unit(i,c,d)$cap(i,c)
                             = sum(map_t_d(t,d), (1/eta(i,c))*(sum(f$mapTF(i,f), pf(f,c)) + sum(f$mapTF(i,f), carb_coef(f)*p_carb(c))*(1-CCScapturerate(i)))
                                + c_vom(i,c)) + eps;



$offdotl
