% Compile script for MatConvNet (HPC run script)

addpath(genpath('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/matconvnet-1.0-beta25'));

vl_compilenn('enableGpu',true,'cudaRoot','/pkg/suse12/software/cuda/9.2.88',...
    'CudaMethod','nvcc','EnableImreadJpeg',false);

% cudnn/7.1-cuda-9.2.88

% /pkg/suse12/modules/all
% /pkg/suse12/modules/system/cuda/9.2.88

Compile_Success = 1;
save('Compiled.mat','Compile_Success');

%module load matlab/2018b
%module load cuda/9.2.88
%module load gcc/6.3.0-2.27