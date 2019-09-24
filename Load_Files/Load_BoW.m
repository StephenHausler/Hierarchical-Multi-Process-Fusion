function elapsedTime = Load_BoW(Dataset, saveFolder, HPC, Win)
%LOAD_BoW (using SURF features)

Opt_Create_BoW = 0; %extremely slow

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oBoW = ModuleBoW;
oBoW = copyConstructor(oBoW,Rfol,Qfol,GT_file);
if Opt_Create_BoW == 1
    oBoW = createBoWBag(oBoW,[saveFolder Dataset '_BoW_Bag.mat']);
    %don't bother recording this time, will be very very long anyway (and
    %only ever needs to be run once)
end    
tic;
oBoW = saveBoWIndex(oBoW,[saveFolder Dataset '_BoW_Index.mat'],[saveFolder Dataset '_BoW_Bag.mat']);
%process queries on-the-fly
elapsedTime = toc;

end