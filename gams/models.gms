$ontext
Defines all variables, equations and models
$offtext

*############################################################
*                VARIABLE AND EQUATION DEFINITION
*############################################################
Free Variable
    COST                total system cost - objective LP
    CSURP               consumer surplus
;

Positive Variable
*   conventional and res generation
    GEN(i,c,t)                      generation
    RESGEN(r,c)                     generation from renewable sources
    CURT(r,c,t)                     curtailment of renewable r  in region c in period t

*   storage plants
    S_LEV(s,c,t)                    storage level
    S_DISCHAR(s,c,t)                storage discharging i.e. feed to the grid
    S_CHAR(s,c,t)                   storage charging
    S_SPILL(s,c,t)                  storage spilling (newly introduced)
    S_MAGIC(s,c,t)                  magial storage water filling at high cost
    
*   hydrogen market
    HYDGEN(c,t)                     hydrogen generation from electrolysis [MWh]
    GEN_HYDFIRED(c,t)               power generation from hydrogen [MWh]
    HYD_TRADE(c,cc,t)               hydrogen trade from country c to cc [MWh]
    HYD_SLACK(c,t)
    
*   hydrogen storage
    HYDST_DISCHAR(hst,c,t)          hydrogen storage discharging [MW]
    HYDST_CHAR(hst,c,t)             hydrogen storage charging [MW]
    HYDST_LEV(hst,c,t)              hydrogen storage level [MWh]
    
*   expansion of technologies/infrastructure
    EXP_CAP(inv,c)                  expansion of capacity of inv in country c [either MW or MWh]
    EXP_HYD_TRADE_CAP(c,cc)         exapnsion of hydrogen trade capacity from country c to cc [MWh]

*   demand sectors markets
    HYD_HDEM(hdem,hdem_tech,c,t)    hydrogen demand from technology hdem_dem [MWh]
    ELEC_HDEM(hdem,hdem_tech,c,t)   electricity demand from technology hdem_dem [MWh]
    HDEM_SLACK(hdem,c,t)

*   others for the electricity market
    TRADE(c,cc,t)                   trade from country c to cc
    DEM(c)                          demand country c period t
    SLACK                           feasibility slack variable
    SLACK2

*   dsm variables
    DSM_UP(c,t)                     upwards demand side management [MWh]
    DSM_DN(c,t,tt)                  downwards demand side management [MWh]
    DSM_UP_DEMAND(c,t)
    DSM_DN_DEMAND(c,t)
;

equation
    obj_QCP             QCP objective definition - linear demand
    def_COST            LP objective definition and QCP total cost definition

*   electricity market
    mkt_G_LP             electricity market clearing generation - exogenous demand version
    mkt_G_QCP            electricity market clearing generation - endogenous demand version
    mkt_cap              maximum capacity restriction
    mkt_ntc              restriction on net transfer capacity
    mkt_chp              market clearing for chp generation
    
*   hydrogen market
    mkt_HYD_LP           hydrogen market clearing
    mkt_HYDGEN_CAP       maximum capacity restriction for hydrogen generation
    mkt_GEN_HYDFIRED_CAP maximum capacity restriction for hydrogen-fired power generation
    mkt_HYD_TRADE        restriction on hydrogen net transfer capacity
    mkt_HYD_TRADE_max    restriction on expansion of hydrogen net transfer capacity - ADDED FOR FEASIBILITY
    mkt_greenHyd         restriction for producing only green hydrogen
    
*   electricity storage facilities
    mkt_S_DISCHAR        storage discharging restriction
    mkt_S_CHAR           storage charging restriction
    mkt_S_LEV            storage level restriction
    mkt_B_DISCHAR        battery storage discharging restriction
    mkt_B_CHAR           battery storage charging restriction
    mkt_B_LEV            battery storage level restriction
    lom_S_LEV            law of motion storage level
    
*   hydrogen storage facilities
    mkt_HydSt_DISCHAR    hydrogen storage discharging restriction
    mkt_HydSt_CHAR       hydrogen storage charging restriction
    mkt_HydSt_LEV        hydrogen storage level restriction
    lom_HydSt_LEV        law of motion hydrogen storage level
    potential_HydSt      maximum potential restriction for hydrogen storage expansion
    mkt_s_terminal       storage terminal level constraint
    
*   demand sectors markets
    mkt_HDEM                demand sectors clearing
    const_DRI               constraint for proportionality of DRI's hydrogen and electricity utilization
    const_HydSynBlending    constraint for blending of hydrogen and synthetic methane
    const_CHPHyd            maximum capacity restriction for hydrogen-fired CHP
    mkt_Meth                maximum capacity restriction for methanation
    mkt_Meth_max            maximum capacity restriction for expansion of methanation
    
*   renewable
    res_Curt             restriction to ensure feasible curtailment
    res_pot_ren          restriction renewable potential

*   policy constraints
    res_quota            restriction for renewable quota system: absolute target
    res_quota_supply     restriction for renewable quota system: relative supply share
;

*############################################################
*                    EQUATION DECLARATIONS
*############################################################

*------------------------------------------------------------
*                      OBJECTIVES
*------------------------------------------------------------
* QCP objective: welfare
obj_QCP..
    CSURP                   =E=   scale_obj* [sum(c, (  (DEM(c)/(2*dem_b(c))) -  dem_a(c)/dem_b(c))*DEM(c))
                                  - COST
                                  - 1/2 * sum((r,c), cinv_1(r,c)*( sqr(RESGEN(r,c) + renTotal(r,c)) - sqr(renTotal(r,c))) )
                                   ]
;


* Total system cost (with quadratic total investment cost for QCP) / LP objective:
def_COST..
    COST                    =E= scale_obj*[
                                sum((t,i,c),
                                         dur_d(t)*GEN(i,c,t)*(1/eta(i,c))
                                         *sum(f$mapTF(i,f),
                                                 pf(f,c) + carb_coef(f)*p_carb(c)*(1-CCScapturerate(i))
                                         )
                                )
                                + sum((t,i,c),dur_d(t)*GEN(i,c,t)*c_vom(i,c))
                                + sum((hdem,c,t), dur_d(t)*penalty(c)*SLACK(c,t)+dur_d(t)*penalty(c)*HYD_SLACK(c,t)
                                +dur_d(t)*penalty(c)*HDEM_SLACK(hdem,c,t))
                                + sum((r,c,t), dur_d(t)*curtPenalty(c)*CURT(r,c,t))
                                + sum((r,c), cinv_0(r,c)*RESGEN(r,c))
                                + sum((inv,c),EXP_CAP(inv,c)*(cinv_exp(inv)+fixedcosts(inv)))
                                + sum((c,cc),EXP_HYD_TRADE_CAP(c,cc)*cinv_hydtradecap(c,cc))
                                + sum((hdem,hdem_tech,c,t),(HYD_HDEM(hdem,hdem_tech,c,t) + ELEC_HDEM(hdem,hdem_tech,c,t))*oandm_costs(hdem,hdem_tech))
                                ]
;

*NOTE: I included "fixedcosts(inv)" and the last term (i.e. "sum((hdem,hdem,c,t)...")
*      for completeness; however, they are all zeros and not sure if I will need them later.

*------------------------------------------------------------
*@@                 ELECTRICITY MARKET
*------------------------------------------------------------
* LP version: market clearing electricity
mkt_G_LP(c,t)..
    sum(i, GEN(i,c,t))
    + sum(s, S_DISCHAR(s,c,t) - S_CHAR(s,c,t))
    + sum(cc, (1 - line_loss(cc,c))*TRADE(cc,c,t) - TRADE(c,cc,t))
    + SLACK(c,t)
    + sum(r, betaRen(r,c,t)*(renTotal(r,c) + RESGEN(r,c))  - CURT(r,c,t))
    + GEN_HYDFIRED(c,t)
                            =E=    demand(c,t) + HYDGEN(c,t)/eta('Electrolyzers',c)
                            + sum((hdem,hdem_tech),ELEC_HDEM(hdem,hdem_tech,c,t))
;

* QCP version: market clearing electricity
mkt_G_QCP(c,t)..
    sum(i, GEN(i,c,t))
    + sum(s, S_DISCHAR(s,c,t) - S_CHAR(s,c,t))
    + sum(cc, (1 - line_loss(cc,c))*TRADE(cc,c,t) - TRADE(c,cc,t))
    + SLACK(c,t)
    + sum(r, betaRen(r,c,t)*(renTotal(r,c) + RESGEN(r,c)) - CURT(r,c,t))
                            =E=   beta(c,t)*DEM(c)
;

* cross-border trade capacities
mkt_ntc(c,cc,t)..
    ntc(c,cc,t)             =G=   TRADE(c,cc,t)
;

*------------------------------------------------------------
*@@                 HYDROGEN MARKET
*------------------------------------------------------------
* market clearing hydrogen (LP)
mkt_HYD_LP(c,t)..
    HYDGEN(c,t) + sum(hst,HYDST_DISCHAR(hst,c,t) - HYDST_CHAR(hst,c,t))
    + sum(cc, (1 - line_loss(cc,c))*HYD_TRADE(cc,c,t) - HYD_TRADE(c,cc,t))
    + HYD_SLACK(c,t)
                            =E=    h_demand_ex(c,t) + GEN_HYDFIRED(c,t)/eta('HydrogenFiredPower',c)
                                   + sum((hdem,hdem_tech),HYD_HDEM(hdem,hdem_tech,c,t))
                                   
;
*    

mkt_HYDGEN_CAP(c,t)..
    EXP_CAP('HydGeneration',c)             =G=    HYDGEN(c,t)
;

mkt_GEN_HYDFIRED_CAP(c,t)..
    EXP_CAP('HydFiredPowerGeneration',c)             =G=    GEN_HYDFIRED(c,t)
;

* hydrogen cross-border trade capacities
mkt_HYD_TRADE(c,cc,t)..
    EXP_HYD_TRADE_CAP(c,cc)            =G=   HYD_TRADE(c,cc,t)
;

* hydrogen cross-border trade capacities
mkt_HYD_TRADE_max(c,cc)..
    100            =G=   EXP_HYD_TRADE_CAP(c,cc)
;

*------------------------------------------------------------
*@@               RESTRICTIONS THERMAL PLANTS
*------------------------------------------------------------
* generation installed capacity
mkt_cap(i,c,t)$(avail(i,c,t)*cap(i,c))..
    cap(i,c)*avail(i,c,t)   =G=    GEN(i,c,t)
;

* chp constraint
mkt_chp(i,c,t)$chp_dem(i,c,t)..
    GEN(i,c,t)              =G=    chp_dem(i,c,t)
;

*------------------------------------------------------------
*@@               RESTRICTIONS STORAGE FACILITIES
*------------------------------------------------------------
* storage turbine capacity
mkt_S_DISCHAR(s,c,t)$cap(s,c)..
    cap(s,c)                =G=   S_DISCHAR(s,c,t)
;

* storage pump capacity
mkt_S_CHAR(s,c,t)$cap_P(s,c)..
    cap_P(s,c)              =G=   S_CHAR(s,c,t)
;

* storage level
mkt_S_LEV(s,c,t)$cap_L(s,c)..
    cap_L(s,c)              =G=   S_LEV(s,c,t)
;

mkt_B_DISCHAR(c,t)..
    EXP_CAP('Battery',c)              =G=   S_DISCHAR('Battery',c,t)
;

mkt_B_CHAR(c,t)..
    EXP_CAP('Battery',c)               =G=   S_CHAR('Battery',c,t)
;

mkt_B_LEV(c,t)..
    EXP_CAP('BatteryLevel',c)           =G=   S_LEV('Battery',c,t)
;


* law of motion for storage
lom_S_LEV(s,c,t)..
    S_LEV(s,c,t--1)*((1-b_self_discharge_rate)$(sameas(s,'Battery'))) + S_CHAR(s,c,t)*eta(s,c) - S_DISCHAR(s,c,t)
    + s_level_init(s,c,t)$(ord(t) eq 1)
    + inflow(s,c,t)
    - S_SPILL(s,c,t)

                            =E=   S_LEV(s,c,t)
;

*------------------------------------------------------------
*@@        RESTRICTIONS HYDROGEN STORAGE FACILITIES
*------------------------------------------------------------

mkt_HydSt_DISCHAR(hst,c,t)..
    EXP_CAP('HydStorage',c)              =G=   HYDST_DISCHAR(hst,c,t)
;

mkt_HydSt_CHAR(hst,c,t)..
    EXP_CAP('HydStorage',c)               =G=   HYDST_CHAR(hst,c,t)
;

mkt_HydSt_LEV(hst,c,t)..
    EXP_CAP('HydStorageLevel',c)           =G=   HYDST_LEV(hst,c,t)
;


* law of motion for hydrogen storage
lom_HydSt_LEV(hst,c,t)..
    HYDST_LEV(hst,c,t--1)*(1-hydst_self_discharge_rate) + HYDST_CHAR(hst,c,t) - HYDST_DISCHAR(hst,c,t)
                            =E=   HYDST_LEV(hst,c,t)
;

potential_HydSt(c)..
    hydst_lev_potential(c)            =G= EXP_CAP('HydStorageLevel',c)
;

mkt_greenHyd(c,t)..
    sum(r, betaRen(r,c,t)*(renTotal(r,c) + RESGEN(r,c))  - CURT(r,c,t)) =G= HYDGEN(c,t)
;

*------------------------------------------------------------
*@@        RESTRICTIONS HYDROGEN DEMAND SECTORS
*------------------------------------------------------------

mkt_HDEM(hdem,c,t)..
    sum(hdem_tech,(HYD_HDEM(hdem,hdem_tech,c,t) + ELEC_HDEM(hdem,hdem_tech,c,t))*eta_hdem_tech(hdem,hdem_tech))
        + HDEM_SLACK(hdem,c,t)
                                =E=
                                    hdem_demand(hdem,c,t)
;
* sum(hdem_tech$map_hdem_tech(hdem,hdem_tech),(HYD_HDEM(hdem,hdem_tech,c,t) + ELEC_HDEM(hdem,hdem_tech,c,t))*eta_hdem_tech(hdem,hdem_tech))

const_DRI(c,t)..
    HYD_HDEM('Steel','DRI',c,t) =E= 0.5 * ELEC_HDEM('Steel','DRI',c,t)
;

const_HydSynBlending(c,t)..
    0.25 * HYD_HDEM('HeatinginBuildings','SynMethaneBoilers',c,t) =G= HYD_HDEM('HeatinginBuildings','HydBoilers',c,t)
;

const_CHPHyd(c,t)..
    0.3 * GEN_HYDFIRED(c,t) =G= HYD_HDEM('HeatinginBuildings','CHPHyd',c,t)
;

mkt_Meth(c,t)..
    EXP_CAP('Methanation',c)    =G=   HYD_HDEM('HeatinginBuildings','SynMethaneBoilers',c,t)*eta('Methanation',c)
;

mkt_Meth_max(c,t)..
     100   =G=  EXP_CAP('Methanation',c)
;

*------------------------------------------------------------
*@@             RESTRICTIONS RENEWABLES
*------------------------------------------------------------
* Ensure curtailment to be less or equal renewable supply
res_Curt(r,c,t)..
    betaRen(r,c,t)*(renTotal(r,c) + RESGEN(r,c))
                            =G=   CURT(r,c,t)
;

res_pot_ren(r,c)..
    pot_ren_mwh(r,c)        =G=   renTotal(r,c) + RESGEN(r,c)
;

*------------------------------------------------------------
*@@            RES POLICY RELATED RESTRICTIONS
*------------------------------------------------------------
res_quota(q)$(ren_target(q) and sum(map_q(r,c,q), 1) > 0)..
     sum((r,c)$map_q(r,c,q),
         renTotal(r,c) + RESGEN(r,c) - sum(t,CURT(r,c,t)))
     + sum((i,c,t)$map_q(i,c,q), GEN(i,c,t))
     + sum((s,c,t)$map_q(s,c,q), S_DISCHAR(s,c,t))
                            =G= ren_target(q)
;

res_quota_supply(q)$(min_sh_renewables(q) and sum(map_q(r,c,q), 1) > 0)..
     sum((r,c)$map_q(r,c,q),
         renTotal(r,c) + RESGEN(r,c) - sum(t, CURT(r,c,t)))
     + sum((i,c,t)$map_q(i,c,q), dur_d(t)*GEN(i,c,t))
     + sum((s,c,t)$map_q(s,c,q), dur_d(t)*S_DISCHAR(s,c,t))
                            =G= min_sh_renewables(q)*
                                sum(c$(sum(tech$map_q(tech,c,q), 1) > 0),
$if %modeltype%=="LP"               sum(t, dur_d(t)*demand(c,t))
$if %modeltype%=="QCP"              DEM(c)
                                )
;

*####################################################################
*@                      MODEL DEFINITIONS
*####################################################################
model cepeem_LP
    /
   def_COST
   mkt_G_LP
   mkt_HYD_LP
   mkt_cap
   mkt_HYDGEN_CAP
   mkt_GEN_HYDFIRED_CAP
   mkt_S_DISCHAR
   mkt_S_CHAR
   mkt_S_LEV
   mkt_B_DISCHAR
   mkt_B_CHAR
   mkt_B_LEV
   lom_S_LEV
   mkt_HydSt_DISCHAR
   mkt_HydSt_CHAR
   mkt_HydSt_LEV
   lom_HydSt_LEV
   mkt_NTC
   mkt_HYD_TRADE
   mkt_HYD_TRADE_max
   mkt_HDEM
   const_DRI
   const_HydSynBlending
   const_CHPHyd
   mkt_Meth
   mkt_Meth_max
   res_Curt
   res_quota
   res_quota_supply
   mkt_chp
   potential_HydSt
/;

*   mkt_greenHyd   *can be added to make sure only green hydrogen is produced


model cepeem_QCP
    /
   obj_QCP
   def_COST
   mkt_G_QCP
   mkt_cap
   mkt_S_DISCHAR
   mkt_S_CHAR
   mkt_S_LEV
   lom_S_LEV
   mkt_NTC
   res_Curt
   res_quota
   res_quota_supply
   mkt_chp
/;

cepeem_LP.optfile = 1 ;
cepeem_LP.holdfixed=1 ;
cepeem_QCP.optfile = 1 ;
cepeem_QCP.holdfixed=1 ;

option QCP=CPLEX;
option LP=CPLEX;

