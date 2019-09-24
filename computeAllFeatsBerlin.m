clc
clear
close all

addpath('Class_Files');
addpath('Load_Files');
addpath('Helper_Funcs');

%Dataset = 'Nordland';
Dataset = 'Berlin';

saveFolder = 'Features_Berlin_Test/';
%saveFolder = 'Features_HPCTest_diffResTest/';

mkdir(saveFolder);

HPC = 1;
Win = 0;

%run all of this on HPC
Time_CNNHeat = Load_CNNHeat(Dataset,saveFolder,HPC,Win);
Time_CNNWhole = Load_CNNWhole(Dataset,saveFolder,HPC,Win);
Time_HOG = Load_HOG(Dataset,saveFolder,HPC,Win);
Time_KAZE = Load_KAZE(Dataset,saveFolder,HPC,Win);
Time_NetVLAD = Load_NetVLAD(Dataset,saveFolder,HPC,Win);
Time_OLO = Load_OLO(Dataset,saveFolder,HPC,Win);
Time_SAD = Load_SAD(Dataset,saveFolder,HPC,Win);
Time_SURF = Load_SURF(Dataset,saveFolder,HPC,Win);
Time_Gist = Load_Gist(Dataset,saveFolder,HPC,Win);

save('Load_Times_Berlin_Test.mat','Time_CNNHeat','Time_CNNWhole','Time_HOG','Time_KAZE',...
     'Time_NetVLAD','Time_OLO','Time_SAD','Time_SURF','Time_Gist');


