function elapsedTime = Load_SAD(Dataset, saveFolder, HPC, Win)
%LOAD_SAD 

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oSAD = ModuleSAD;
oSAD = copyConstructor(oSAD,Rfol,Qfol,GT_file);
tic;
oSAD = saveDbaseTemplates(oSAD,[saveFolder Dataset '_SAD_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oSAD = saveQueryTemplates(oSAD,[saveFolder Dataset '_SAD_Query.mat']);
elapsedTime.Query = toc;

end

