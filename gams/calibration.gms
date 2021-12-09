
*based on check_capacities_cap_max_gen
avail('Gas','GR',t) = avail('Gas','GR',t) * 0.8;
avail('Nuclear','NL',t) = avail('Nuclear','NL',t) * 0.8;
avail('Gas','RO',t) = avail('Gas','RO',t) * 0.75;
avail('HardCoal','RO',t) = avail('HardCoal','RO',t) * 0.6;
avail('Nuclear','RO',t) = avail('Nuclear','RO',t) * 0.9;

avail('Nuclear','BG',t) = avail('Nuclear','BG',t) * 0.95;
avail('Nuclear','DE',t) = avail('Nuclear','DE',t) * 0.92;
avail('Nuclear','SE',t) = avail('Nuclear','SE',t) * 0.95;

* Values for DE from Statistik der Kohlewirtschaft
*pf('HardCoal',c) = 11.30;
*pf('Gas',c) = 14.11;

* and some hydro calibration
inflow('Reservoir','CH',t) = inflow('Reservoir','CH',t) * 0.65;
inflow('Reservoir','SE',t) = inflow('Reservoir','SE',t) * 0.7;
inflow('PumpOpen','NO',t) = inflow('PumpOpen','NO',t) * 0.7;

*and now the price calibration
pf('Uran','SK') = pf('Uran','SK') * 1.2;
pf('Uran','BG') = pf('Uran','BG') * 1.8;
pf('Uran','RO') = pf('Uran','RO') * 2;

pf('Lignite','GR') = pf('Lignite','GR') * 1.4;
pf('Lignite','BG') = pf('Lignite','BG') * 1.8;
pf('Lignite','RO') = pf('Lignite','RO') * 2;
pf('Lignite','SK') = pf('Lignite','SK') * 2;

pf('HardCoal','PL') = pf('HardCoal','PL')*1.4;
pf('HardCoal','IT') = pf('HardCoal','IT')*2;
pf('HardCoal','ES') = pf('HardCoal','ES')*1.4;
pf('HardCoal','RO') = pf('HardCoal','RO')*2;
pf('HardCoal','DK') = pf('HardCoal','DK')*1.2;
pf('HardCoal','FR') = pf('HardCoal','FR')*1.1;
pf('HardCoal','SE') = pf('HardCoal','SE') * 2;
pf('HardCoal','SK') = pf('HardCoal','SK') * 2;
pf('HardCoal','HR') = pf('HardCoal','HR') * 1.5;
pf('HardCoal','HU') = pf('HardCoal','HU') * 1.25;
pf('HardCoal','GB') = pf('HardCoal','GB')*1.25;
pf('HardCoal','BG') = pf('HardCoal','BG') * 1.8;
pf('HardCoal','DE') = pf('HardCoal','DE')*1;


*pf_2('HardCoal','DE') = 0.1;
*pf_2('HardCoal','ES') = 0.1;
*pf_2('HardCoal','IT') = 0.1;


pf('Gas','DE') = pf('Gas','DE')*0.8;
pf('Gas','FR') = pf('Gas','FR') * 1.2;
pf('Gas','AT') = pf('Gas','AT') * 0.8;
pf('Gas','BE') = pf('Gas','BE') * 1.2;
pf('Gas','DK') = pf('Gas','DK')*1.1;
pf('Gas','IE') = pf('Gas','IE') * 1.25;
pf('Gas','SK') = pf('Gas','SK') * 1.8;
pf('Gas','SE') = pf('Gas','SE') * 2.5;
pf('Gas','IT') = pf('Gas','IT')*1.4;
pf('Gas','PT') = pf('Gas','PT') * 1.1;
pf('Gas','ES') = pf('Gas','ES')*1.4;

pf('Gas','HR') = pf('Gas','HR') * 1.5;
pf('Gas','HU') = pf('Gas','HU') * 1.25;
pf('Gas','GB') = pf('Gas','GB') * 1.25;
pf('Gas','NO') = pf('Gas','NO') * 1.2;
pf('Gas','GR') = pf('Gas','GR') * 1.4;
pf('Gas','BG') = pf('Gas','BG') * 1.8;
pf('Gas','RO') = pf('Gas','RO') * 4;

pf('Oil','SE') = pf('Oil','SE') * 4;
pf('Oil','DE') = pf('Oil','DE') * 0.9;

pf('Other','RO') = pf('Other','RO')*4;
pf('Other','CH') = pf('Other','CH')*3;
*cap('Other','RO') = 0;

c_vom('Other',c) = 2.6;







