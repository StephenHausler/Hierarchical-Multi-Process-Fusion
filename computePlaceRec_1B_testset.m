clc
clear
close all

addpath('Features_Berlin_Test');
addpath('Class_Files');
addpath('Load_Files');
%addpath('Features');
%addpath('D:\MATLAB_HPC_Offline\Features');
%addpath('Features_HPCTest');
addpath('Helper_Funcs');

%Dataset = 'Nordland';
Dataset = 'Berlin';

saveFolder = 'Berlin_Testset_Results/';
mkdir(saveFolder);

% CNNHeat     -->   1
% SAD         -->   2
% HOG         -->   3
% ORB         -->   4
% SURF        -->   5
% NetVLAD     -->   6
% CNNWhole    -->   7
% BoW         -->   8
% KAZE        -->   9
% OLO         -->   10
% Gist        -->   11

%x is level number, y is number within level
methodStruct.Names(1,1) = 6;
% methodStruct.Names(1,2) = 11;
methodStruct.Names(2,1) = 9;
% methodStruct.Names(2,2) = 3;
methodStruct.Names(3,1) = 10;
% methodStruct.Names(3,2) = 10;

methodStruct.NumCands(1) = 50; 
methodStruct.NumCands(2) = 10;
methodStruct.NumCands(3) = 1;

HPC = 0;    %setting to change if run locally (0), or on HPC server (1).
Win = 1;    %OS setting (Windows = 1 or Ubuntu = 0)
GPUJob = 1; %Used to remove GPU from HPC options, in order to run A HUGE NUMBER OF JOBS.

experimentNumber = 1;

debugMode = 0;
setID = 1;  %0 = train set, 1 = test set.

w(1) = 0.5; w(2) = 0.75; w(3) = 1; %number from 0-1
%ideally, want to weight the final layer more than the earlier layers.

Multi_SLAM_Fusion(experimentNumber, Dataset, saveFolder, methodStruct,...
    HPC, Win, GPUJob, debugMode, setID, w);






