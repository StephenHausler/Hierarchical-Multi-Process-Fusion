function elapsedTime = Load_CNNWhole(Dataset, saveFolder, HPC, Win)
%LOAD_CNNWhole

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

oCNNWhole = ModuleCNNWhole;
oCNNWhole = loadNetwork(oCNNWhole,CAFFE_NETWORK,datafile,protofile,HPC,Win);
oCNNWhole = copyConstructor(oCNNWhole,Rfol,Qfol,GT_file);
oCNNWhole.setActLayer(15);
tic;
oCNNWhole = saveDbaseTemplates(oCNNWhole,[saveFolder Dataset '_CNNWhole_Dbase.mat']);
elapsedTime.Dbase = toc;
tic;
oCNNWhole = saveQueryTemplates(oCNNWhole,[saveFolder Dataset '_CNNWhole_Query.mat']);
elapsedTime.Query = toc;

end
