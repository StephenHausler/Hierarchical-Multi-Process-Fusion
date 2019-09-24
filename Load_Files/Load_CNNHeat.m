function elapsedTime = Load_CNNHeat(Dataset, saveFolder, HPC, Win)
%LOAD_CNNHeat

CAFFE_NETWORK = 1;
if HPC == 1
    datafile = '/home/n7542704/MATLAB_2019_Working/Neural_Networks/HybridNet/HybridNet.mat';
    protofile = '/home/n7542704/MATLAB_2019_Working/Neural_Networks/HybridNet/HybridNet.mat';  
else    
    if Win == 1
        datafile = 'D:\MATLAB\MPF_RevisePaper\HybridNet\HybridNet.caffemodel';
        protofile = 'D:\MATLAB\MPF_RevisePaper\HybridNet\deploy.prototxt';
    else
        datafile = '/media/stephen/Data/MATLAB/MPF_RevisePaper/HybridNet/HybridNet.caffemodel';
        protofile = '/media/stephen/Data/MATLAB/MPF_RevisePaper/HybridNet/deploy.prototxt';
    end
end

[Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);

oCNNHeat = ModuleCNNHeat;
oCNNHeat = loadNetwork(oCNNHeat,CAFFE_NETWORK,datafile,protofile,HPC,Win);
oCNNHeat = copyConstructor(oCNNHeat,Rfol,Qfol,GT_file);
oCNNHeat.setActLayer(15);
tic;
oCNNHeat = saveDbaseTemplates(oCNNHeat,[saveFolder Dataset '_CNNHeat_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oCNNHeat = saveQueryTemplates(oCNNHeat,[saveFolder Dataset '_CNNHeat_Query.mat']);
elapsedTime.Query = toc;

end
