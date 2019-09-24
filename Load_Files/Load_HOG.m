function elapsedTime = Load_HOG(Dataset, saveFolder, HPC, Win)
%LOAD_HOG 

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oHOG = ModuleHOG;
oHOG = copyConstructor(oHOG,Rfol,Qfol,GT_file);
tic;
oHOG = saveDbaseTemplates(oHOG,[saveFolder Dataset '_HOG_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oHOG = saveQueryTemplates(oHOG,[saveFolder Dataset '_HOG_Query.mat']);
elapsedTime.Query = toc;

end

