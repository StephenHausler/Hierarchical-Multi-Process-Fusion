clc
clear
close all

%rmpath('Features_BugFinder');
%rmpath('Features');
%addpath('Features_Berlin');
addpath('Class_Files');
addpath('Load_Files');
addpath('Features');
%addpath('Features_Nordland_Cont');
%addpath('D:\MATLAB_HPC_Offline\Features');
%addpath('Features_HPCTest');
addpath('Helper_Funcs');

Dataset = 'Nordland';
%Dataset = 'Berlin';

%saveFolder = 'Results_Individuals_HPCTest/';
saveFolder = 'Results_Trainset_050919/';
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
%methodStruct.Names(1,2) = 11;
methodStruct.Names(2,1) = 9;
%methodStruct.Names(2,2) = 7;
%methodStruct.Names(3,1) = 9;
%methodStruct.Names(3,2) = 10;

methodStruct.NumCands(1) = 100; 
methodStruct.NumCands(2) = 1;
%methodStruct.NumCands(3) = 1;

HPC = 1;    %setting to change if run locally (0), or on HPC server (1).
Win = 0;    %OS setting
GPUJob = 1; %Used to remove GPU from HPC options, in order to run A HUGE NUMBER OF JOBS.

experimentNumber = 1;

w(1) = 0.5; w(2) = 0.75; w(3) = 1; %number from 0-1
%ideally, want to weight the final layer more than the earlier layers.

Multi_SLAM_Fusion(experimentNumber, Dataset, saveFolder, methodStruct,...
    HPC, Win, GPUJob, debugMode, setID, w);

