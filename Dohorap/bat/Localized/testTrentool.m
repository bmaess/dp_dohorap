ft_defaults
addpath('/scr/kuba1/Matlab/TRENTOOL3/');
load('/scr/kuba2/Dohorap/Main/Data/Localized/average-adults-Obj-localized.mat');

data.trial = {[pSTG; BA44]};
data.time = {[0.001:0.004:1; 0.001:0.004:1]};
data.label = {'pSTG', 'BA44'};
data.fsample = 1000;

cfgTEP.TEcalctype = 'VW_ds';
cfgTEP.predicttimemin_u = 10;
cfgTEP.predicttime_u = 25;
cfgTEP.predicttimemax_u
cfgTEP.toi = [0, 1];
cfgTEP.trialselect = 'no';
cfgTEP.sgncmb = {'pSTG','BA44'};
cfgTEP.Path2TSTOOL = '/scr/kuba1/sw/Matlab/OpenTSTOOL';
cfgTEP.optimizemethod = 'ragwitz';
cfgTEP.ragdim = 2:9;
cfgTEP.ragtaurange = [0.2 0.4];
cfgTEP.ragtausteps = 5;
cfgTEP.repPred = 60;
cfgTEP.flagNei = 'Mass';
cfgTEP.sizeNei = 4;

cfgTESS.optdimusage = 'indivdim';
cfgTESS.tail = 1;
cfgTESS.numpermutation = 250;
cfgTESS.shifttesttype = 'TEshift>TE';
cfgTESS.surrogatetype = 'trialshuffling';
cfgTESS.fileidout = '/scr/kuba1/Matlab/temp.mat';

TGA_results = InteractionDelayReconstruction_calculate(cfgTEP,cfgTESS,data);
