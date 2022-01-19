
$ontext
Upload of original data
and derivation of all relevant data
jab 24042013
$offtext

*#####################################################################
*@                          DEFINITIONS
*#####################################################################
set
   t                        periods
   d                        days
   m                        months
   tfirst(t)                first period
   c                        countries in simulation
   eu(c)                    european union countries in simulation
   c_transport(c)           set of countries for which transport data is available
   f                        fuels
   tech                     technologies
   i(tech)                  conventional technologies
   ra(tech)                 all renewable sources
   ro(ra)                   old = conventional renewable sources
   r(ra)                    new renewables
   s(tech)                  storage facilities
   baseload(tech)           baseload technologies
   fixed(tech)              fixed feed-in technologies
   peak(tech)               peak load technologies
   transport_tech           transport technologies   /ICE, EV/
   
   hst                      hydrogen storage technologies /SaltCaverns/
   hdem                     hydrogen demand sector
   hdem_tech                technologies for hydrogen demand sectors with market clearing
   inv                      technologies and infrastructure to be expanded by the model

*  mappings
   mapTF(tech,f)            mapping technology to fuel
   map_fuel_price_as(c,c,f) mapping to fill fuel prices
   map_om_cost_as(c,c,tech) mapping to fill O&M costs
   map_t_d(t,d)             mapping of periods to days
   map_t_m(t,m)             mapping of periods to months
;
alias(t,tt), (c, cc), (r,rr),  (tech, techtech), (i, ii), (ra, rra), (ro,rro);

parameter
*  time related
   dur_d(t)                       duration of days
   hours_per_month(m)             hours per month

*  country parameters - upload
   penalty(c)                     price cap on hourly electricity price [Euro per MWh]
   curtPenalty(c)                 renewable curtailment penality
   epsilon(c)                     price elasticity of demand
   p_carb(c)                      carbon price [Euro per tonne]
   demand(c,t)                    hourly demand [MWh]
   demand_temp(c,t)               hourly demand (tempory for overwriting)[MWh]
   pRef(c,t)                      hourly reference price [Euro per MWh]
   pRef_temp(c,t)                 hourly reference price from LP model [Euro per MWh]
   pRef_annual(c)                 annual average price (demand weighted) [Euro per MWh]


*  country parameters - derived
   dem_a(c)                       demand intercept [MWh]
   dem_b(c)                       demand slope [MWh per Euro]
   qRef(c)                        aggregated annual demand [MWh]
   beta(c,t)                      conversion aggregated to hourly demand (excluding duration) [%]

*  plant related - upload
   eta(tech,c)                    plant efficiency [%]
   availUp(tech,c)                plant availability [%]
   availpeakUp(c,peak,m)          plant availability [%]
   CCScapturerate(tech)           CCS Capture Rate [%]
   cap(tech,c)                    upload installed capacities [MW]
   cap_pump(tech,c)               upload pump capacities [MW]
   c_vom(tech,c)                  variable O&M cost [Euro per MW]
   cinv_0(r,c)                    RES investment cost linear [Euro per MWh]
   cinv_1(r,c)                    RES investment cost quadratic [Euro per MWh^2]
   gen_annual(c,tech)             annual generation by country and technology [MWh]
   gen_monthly(tech,c,m)          monthly generation by country and technology [MWh]

*  plant related - derived
   cap_L(s,c)                     level capacity of storage facilities [MWh]
   cap_P(s,c)                     pump capacity of storage facilities [MW]
   avail(tech,c,t)                availability [%]

*  costs of technologies/infrastructure expanded
   cinv_exp(inv)                  investment costs for technologies and infrastructure expanded by the model [Euro per MW or MWh]
   cinv_hydtradecap(c,cc)         hydrogen trade capacity investment cost [Euro per MW]
   fixedcosts(inv)                annual fixed costs for technologies and infrastructure expanded by the model [Euro per MW or MWh]
   
*  hydrogen related - upload
   hydst_lev_potential(c)         hydrogen storage maximum potential in country c [MWh]
   h_demand_ex_annual(c)          annual exogenous hydrogen demand [MWh]
   hdem_demand_annual(c,hdem)     sectors' annual demand [different unit for each hdem]
   eta_hdem_tech(hdem,hdem_tech)  sectors' technologies conversion efficiencies [hdem unit output per MWh]
   oandm_costs(hdem,hdem_tech)    sectors' technologies O&M costs [Euro per MWh consumed]

*  hydrogen related - derived
   h_demand_ex(c,t)               hourly exogenous hydrogen demand [MWh]
   hdem_demand(hdem,c,t)          sectors' hourly demand [different unit for each hdem]
   
*  chp - upload
   chp_gen(i,c)                   yearly electricity generation by CHP plants by technology and country [MWh]
   heat_dem_up(t)                 hourly generation profile for heat-related demand [%]

*  chp - derived
   chp_dem(i,c,t)                 hourly chp demand [MWh]
   chp_adjustments(i,c,t)         minimum adjustment necessary to hourly chp demand for feasibility [MWh]

*  trade related
   ntc(c,c,t)                     net transfer capacities [MW]
   line_loss(c,cc)                cross-boarder flows losses [%]

*  fuel related
   carb_coef(f)                   carbon coefficent [t per MWh]
   pf(f,c)                        fuel price [Euro per MWh]
   pf_2(f,c)                      fuel price quadratic part [Euro per MWh^2]

*  renewables - upload
   renS(r,c,t)                    hourly renewable supply [MW]
   pot_ren_mwh(r,c)               potential for renewable supply [MWh]
   ren_cost_update(r,c,*)         updated cost parameters for base case calibration

*  hydro upload
   gen_ror_exog(c,t)              exogenous generation of run-of-river plants [MWh]
   reservoir_size_up(c,s)         upload reservoir size [MWh]
   reservoir_inflow_up(c,t,s)     upload reservoir inflow [MWh]
   reservoir_initial_up(c,t,tech) upload reservoir initial level [MWh]

*  renewables - derived
   betaRen(r,c,t)                 share of period t supply in total renewable []
   renTotal(r,c)                  total yearly renewables [MW]

*  hydro derived
   inflow(s,c,t)                  hourly inflows to storage [MWh]
   s_level_init(s,c,t)            initital storage level [MWh]

*  scaling of objective
*  scale                          scaling factor /%scale%/
   scale_obj                      scaling factor for objetive function /%scale_obj%/

   subsidy_res                    subsidy on renewable generation
;

scalar
   b_self_discharge_rate          battery self discharge rate [% per hour] /0.01/
   hydst_self_discharge_rate      hydrogen storage self discharge rate [% per hour] /0.0001/
;

*#####################################################################
*@            EXTRACTION OF NEW DATA FROM EXCEL
*#####################################################################
* load data

$onEcho > %datadir%reading_new_hydrogen_data.txt
dset=tech rng=NewtechSet!A1 rDim=1
dset=hdem rng=DemtechSet!A2:A4 rDim=1
dset=hdem_tech rng=DemtechSet!C2:C9 rDim=1
dset=inv rng=InvCosts!A2:A8 rDim=1
par=eta rng=EtaNew!A1:C500 rDim=2
par=h_demand_ex_annual rng=HydDemand!D2:E26 rDim=1
par=hdem_demand_annual rng=HydDemandSectors!A1:D26 cDim=1 rDim=1
par=hydst_lev_potential rng=SaltCavernsPotential!A2 rDim=1
par=eta_hdem_tech rng=DemtechSet!B2:D9 rDim=2
par=oandm_costs rng=DemtechSet!B2:E9 rDim=2 ignoreColumns=D
par=cinv_exp rng=InvCosts!A2:B8 rDim=1
par=fixedcosts rng=InvCosts!A2:D8 rDim=1 ignoreColumns=B,C
par=cinv_hydtradecap rng=HydTradeCosts!A1:C75 rDim=2
$offEcho
$call "gdxxrw %datadir%new_hydrogen_data.xlsx output=%datadir%new_hydrogen_data.gdx @%datadir%reading_new_hydrogen_data.txt";


*#####################################################################
*@                   DATA UPLOAD
*#####################################################################

$gdxin %datadir%new_hydrogen_data.gdx
$load tech
$gdxin

$gdxin %datadir%%baseData%.gdx
$loaddc t d m c f i ra ro r s baseload fixed peak mapTF map_t_d map_t_m
$if not %scenario%=="tyndp" $loaddc eu
$loaddc dur_d heat_dem_up
$loaddc penalty curtPenalty epsilon  p_carb demand pRef
$loaddc availUp availpeakUp cap cap_pump c_vom
$if %scenario% == "tyndp" $loaddc CCScapturerate
$loaddc ntc
$loaddc carb_coef pf pf_2
$loaddc renS pot_ren_mwh gen_ror_exog
$loaddc cinv_0 cinv_1
$loaddc reservoir_size_up reservoir_inflow_up reservoir_initial_up
$loaddc chp_gen gen_annual gen_monthly
$loaddc map_fuel_price_as map_om_cost_as
$gdxin

$gdxin %datadir%new_hydrogen_data.gdx
$loaddc hdem hdem_tech inv
$loaddc h_demand_ex_annual hdem_demand_annual
$loaddc eta eta_hdem_tech
$loaddc hydst_lev_potential
$loaddc cinv_exp cinv_hydtradecap fixedcosts oandm_costs
$gdxin


*#####################################################################
*@                        PARAMETER ASSIGNMENTS
*#####################################################################
tfirst(t) = no;
tfirst(t)$(ord(t) = 1) = yes;
hours_per_month(m) = sum(map_t_m(t,m),1*dur_d(t));

* if a baseprice file is provided, use it to update reference prices
* the baseprice gdx file has to
*    - to be privoded with full path
*    - contain a parameter r_price
*      which is used to overwrite existing references prices
$ifthen.baseprices set baseprices
$gdxin %baseprices%
$loaddc pRef_temp=r_price
pRef(c,t) = pRef_temp(c,t);
$iftheni.demand %adjustDemand% == yes
$loaddc demand_temp=r_demand
demand(c,t) = demand_temp(c,t);
$endif.demand
$endif.baseprices

*---------------------------------------------------------------------
*@@                           DEMAND
*---------------------------------------------------------------------
qRef(c)         = sum(t, dur_d(t) * demand(c,t));

* splitting of annual demand to hours preserves base case profile
beta(c,t)       = demand(c,t)/qRef(c);

*---------------------------------------------------------------------
*@@                    CONVENTIONAL CAPACITIES
*---------------------------------------------------------------------
*Biomass capacities are missing from ENTSO-E, so we add them manually
cap("biomass","IE") = 34;

* we do not have fuel prices for some countries and use those from
* neighboring countries instead:
pf(f,c)$((not pf(f,c))
         and (sum(tech$mapTF(tech,f), cap(tech,c) > 0)))
         = sum(map_fuel_price_as(c,cc,f), pf(f,cc));


* we do not have O&M costs for some countries and technologies and use those from
* neighboring countries instead:
c_vom(tech,c)$((not c_vom(tech,c))
         and (sum(techtech, cap(techtech,c) > 0)))
         = sum(map_om_cost_as(c,cc,tech), c_vom(tech,cc));

* availability as given by additional data
avail(tech,c,t) = availUP(tech,c);

* availability of nuclear and lignite generation limited by monthly production
avail(baseload,c,t)$(cap(baseload,c) and (sum(map_t_m(t,m), gen_monthly(baseload,c,m)) > 0))
         = sum(map_t_m(t,m),
           gen_monthly(baseload,c,m)/(cap(baseload,c)*hours_per_month(m))
           );
avail(baseload,c,t)$(not cap(baseload,c)) = 0;

* fixed availability for biomass and other
avail(fixed,c,t)$(cap(fixed,c) and gen_annual(c,fixed)) = gen_annual(c,fixed)/(cap(fixed,c)*8760);
avail(fixed,c,t)$(not (cap(fixed,c))) = 0;

*availability based on entsoe outage data for hardcoal, gas and oil
avail(peak,c,t)$(cap(peak,c) and gen_annual(c,peak) and (sum(map_t_m(t,m),availpeakUp(c,peak,m)) > 0))
         = sum(map_t_m(t,m),
           availpeakUp(c,peak,m)
           );
avail(peak,c,t)$(not cap(peak,c)) = 0;
*@Jan: what does this equation actually do???
*avail(fixed,c,t)$(not avail(fixed,c,t)) = sum((cc,tt)$avail(fixed,cc,tt), avail(fixed,cc,tt))/
*                                                  sum((cc,tt)$avail(fixed,cc,tt), 1);

* CCS
$if not %scenario% == "tyndp" CCScapturerate(tech)=0;

*---------------------------------------------------------------------
*@@                    NETWORK CONSTRAINTS
*---------------------------------------------------------------------
line_loss(c,cc) = %linelosses%;

*--------------------------------------------------------------------
*@@                      RENEWABLE PROFILES
*---------------------------------------------------------------------
* hourly profile renewables
renTotal(r,c)$gen_annual(c,r)           = sum(t, dur_d(t) * renS(r,c,t) * gen_annual(c,r));
betaRen(r,c,t)$renTotal(r,c)            = renS(r,c,t);

*---------------------------------------------------------------------
*@@                    STORAGE CAPACITIES
*---------------------------------------------------------------------
* storage capacitie
* pumping assumed same as generator
cap_P(s,c) = cap_pump(s,c);
cap_L(s,c) = reservoir_size_up(c,s);

*---------------------------------------------------------------------
*@@                       RUN-OF-RIVER
*---------------------------------------------------------------------
* take run-of-river production is only contrained by observed production
* set capacity to one and implement exogenously given production Profiles
* using availability factors
* even though we have ror capacities for many countries - but not for all
cap("RunOfRiver",c) = 1;
avail("RunOfRiver",c,t) = gen_ror_exog(c,t);

*---------------------------------------------------------------------
*@@                      PUMP STORAGE
*---------------------------------------------------------------------
inflow(s,c,t) = 0;
s_level_init(s,c,t) = 0;

*---------------------------------------------------------------------
*@@                     RESERVOIRS
*---------------------------------------------------------------------
* we now set initial and terminal reservoir levels per technology and country
s_level_init(s,c,t) = reservoir_initial_up(c,t,s);

* set reservoir inflows (this is now directly given in MWh)
inflow(s,c,t) = reservoir_inflow_up(c,t,s);

* reservoirs do not have a pump facility
cap_P("reservoir",c) = 0;

* Finally, ignore reservoir in countries without  inflows
cap("reservoir",c)$(not sum(t, inflow("reservoir",c,t))) = 0;

*---------------------------------------------------------------------
*@@                          CHP
*---------------------------------------------------------------------
* annual demand: if not capacity set demand to zero
chp_gen(i,c)$(not cap(i,c)) = 0;

* hourly chp demand
chp_dem(i,c,t) = chp_gen(i,c)*heat_dem_up(t);

* ensure hourly feasibility. In infeasible hours set demand to 50% for available capacity
chp_adjustments(i,c,t)$(chp_dem(i,c,t) > cap(i,c)*avail(i,c,t)) = chp_dem(i,c,t) - cap(i,c)*avail(i,c,t);
chp_dem(i,c,t)$(chp_adjustments(i,c,t) > 0) = cap(i,c)*avail(i,c,t)*0.5;

* for some countries, CHP demand is extremly high (above 50%): PL, CZ
* we restrict chp demand to be maximum 30 percent of total demand
* that affects chp demand in PL, CZ, and DK
parameter
    adjust_chp_scale(c)   scaling of chp demand to not exceed 30 of demand
;
adjust_chp_scale(c) = sum((i,t), chp_dem(i,c,t))/sum(t, demand(c,t));
adjust_chp_scale(c)$(adjust_chp_scale(c) > 0.3) = 0.3/adjust_chp_scale(c);
adjust_chp_scale(c)$(adjust_chp_scale(c) <= 0.3) = 1;
chp_dem(i,c,t) = chp_dem(i,c,t)*adjust_chp_scale(c);

*---------------------------------------------------------------------
*@@                ADDITIONAL CALIBRATION COST DATA
*---------------------------------------------------------------------
* if a file with new investment cost coefficients exists, overwrite
* old value

$if not exist "%datadir%%costData%.xlsx" $goto skipCostScaling
$call "gdxxrw %datadir%%costData%.xlsx o=%datadir%%costData%.gdx  par=ren_cost_update rdim=2 cdim=1"
$gdxin %datadir%%costData%.gdx
$loaddc ren_cost_update
cinv_0(r,c) = ren_cost_update(r,c,"cinv_0");
cinv_1(r,c) = ren_cost_update(r,c,"cinv_1");
$label skipCostScaling


*---------------------------------------------------------------------
*@@                HOURLY HYDROGEN DEMAND
*---------------------------------------------------------------------

h_demand_ex(c,t)=h_demand_ex_annual(c)/8760;
hdem_demand(hdem,c,t)=hdem_demand_annual(c,hdem)/8760;


$ontext
*#####################################################################
*                      SCALING OF VALUES
*#####################################################################
*storage
cap(tech,c)  = cap(tech,c);
cap_L(s,c)   = cap_L(s,c);
cap_P(s,c)   = cap_P(s,c);

* demand and renewables
demand(c,t)     = demand(c,t);
qRef(c)         = qRef(c);
renS(r,c,t)     = renS(r,c,t);
renTotal(r,c)   = renTotal(r,c);
ntc(c,cc,t)     = ntc(c,cc,t);
*availY(i,c)     = 0;

* scaling of inflows etc.
inflow(s,c,t)         = inflow(s,c,t);
s_level_init(s,c,t)     = s_level_init(s,c,t);

* scale chp
chp_dem(i,c,t) = chp_dem(i,c,t);
$offtext

*#####################################################################
*                        ADDITIONAL CALIBRATION
*#####################################################################
*------------------------------------------------------------
*@@               QCP DEMAND CALIBRATION
*------------------------------------------------------------
* for the QCP version, the demand function needs to be calibrated
* Note that demand is calibrated to a yearly function, for this
* we simply set a mean price.


* calibrate demand functions
pRef_annual(c) = sum(t, pRef(c,t) *demand(c,t))/sum(t, demand(c,t));
dem_b(c)$(pRef_annual(c) gt 0) = epsilon(c)*qRef(c)/pRef_annual(c);
dem_b(c)$(pRef_annual(c) eq EPS) = -100000;
dem_a(c) = qRef(c)*(1 - epsilon(c));

