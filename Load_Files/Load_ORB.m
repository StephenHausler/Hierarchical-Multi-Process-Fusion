function elapsedTime = Load_ORB(Dataset, saveFolder, HPC, Win)

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oORB = ModuleORB;
oORB = copyConstructor(oORB,Rfol,Qfol,GT_file);
oORB = init(oORB, HPC, Win);
tic;
oORB = saveDbaseTemplates(oORB,[saveFolder Dataset '_ORB_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oORB = saveQueryTemplates(oORB,[saveFolder Dataset '_ORB_Query.mat']);
elapsedTime.Query = toc;

end