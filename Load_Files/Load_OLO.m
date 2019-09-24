function elapsedTime = Load_OLO(Dataset, saveFolder, HPC, Win)
%LOAD_OLO

MATCONV_NETWORK = 2;

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oOLO = ModuleOnlyLookOnce;
oOLO = copyConstructor(oOLO,Rfol,Qfol,GT_file);
oOLO = init(oOLO,HPC,Win);
oOLO = loadNetwork(oOLO,MATCONV_NETWORK,1,1,HPC,Win);
tic;
oOLO = saveDbaseTemplates(oOLO,[saveFolder Dataset '_OLO_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oOLO = saveQueryTemplates(oOLO,[saveFolder Dataset '_OLO_Query.mat']);
elapsedTime.Query = toc;

end
