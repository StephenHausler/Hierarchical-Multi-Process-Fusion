function elapsedTime = Load_SURF(Dataset, saveFolder, HPC, Win)
%LOAD_SURF

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oSURF = ModuleSURF;
oSURF = copyConstructor(oSURF,Rfol,Qfol,GT_file);
tic;
oSURF = saveDbaseTemplates(oSURF,[saveFolder Dataset '_SURF_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oSURF = saveQueryTemplates(oSURF,[saveFolder Dataset '_SURF_Query.mat']);
elapsedTime.Query = toc;

end