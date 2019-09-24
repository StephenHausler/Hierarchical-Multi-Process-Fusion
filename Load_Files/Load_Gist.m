function elapsedTime = Load_Gist(Dataset, saveFolder, HPC, Win)
%LOAD_HOG 

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oGist = ModuleGist;
oGist = init(oGist, HPC, Win);
oGist = copyConstructor(oGist,Rfol,Qfol,GT_file);
tic;
oGist = saveDbaseTemplates(oGist,[saveFolder Dataset '_Gist_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oGist = saveQueryTemplates(oGist,[saveFolder Dataset '_Gist_Query.mat']);
elapsedTime.Query = toc;

end

