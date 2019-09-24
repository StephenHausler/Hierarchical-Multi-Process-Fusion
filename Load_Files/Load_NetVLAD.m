function elapsedTime = Load_NetVLAD(Dataset, saveFolder, HPC, Win)
%LOAD_NetVLAD

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oNetVLAD = ModuleNetVLAD;
oNetVLAD = init(oNetVLAD,'Nord',HPC,Win);
oNetVLAD = copyConstructor(oNetVLAD,Rfol,Qfol,GT_file);
tic;
oNetVLAD = saveDbaseTemplates(oNetVLAD,[saveFolder Dataset '_NetVLAD_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oNetVLAD = saveQueryTemplates(oNetVLAD,[saveFolder Dataset '_NetVLAD_Query.mat']);
elapsedTime.Query = toc;

end

