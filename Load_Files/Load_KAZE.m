function elapsedTime = Load_KAZE(Dataset, saveFolder, HPC, Win)
%LOAD_OLO

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oKAZE = ModuleKAZE;
oKAZE = copyConstructor(oKAZE,Rfol,Qfol,GT_file);
tic;
oKAZE = saveDbaseTemplates(oKAZE,[saveFolder Dataset '_KAZE_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oKAZE = saveQueryTemplates(oKAZE,[saveFolder Dataset '_KAZE_Query.mat']);
elapsedTime.Query = toc;

end

