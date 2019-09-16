classdef Config
    properties
        net;
        CNN_resize; 
        
        filesR;
        filesQ;
        
        dSize;
        qSize;
        
        GPSMatrix;
        
        %pre-defined members:
        frameSkip = 1;
        imStartR = 0;
        imStartQ = 0;
        initCrop = [1 1 1 1];
        datafile = '/media/stephen/Data/MATLAB/MPF_RevisePaper/HybridNet/HybridNet.caffemodel';
        protofile = '/media/stephen/Data/MATLAB/MPF_RevisePaper/HybridNet/deploy.prototxt';
        
        SAD_resize = [64 32]; %width by height
        SAD_patchsize = 8;
        HOG_resize = [300 300];
        HOG_cellsize = [30 30];
    end
    methods
        function ConfigObj = SetupPreDefines(ConfigObj,varargin)
            for i = 1:2:length(varargin)    %name-value pairs
                if i <= length(varargin)
                    switch varargin{i}
                        case 'frameSkip'
                            ConfigObj.frameSkip = varargin{i+1};
                        case 'sadResize'
                            ConfigObj.SAD_resize = varargin{i+1};
                        case 'sadPatchSize'
                            ConfigObj.SAD_patchsize = varargin{i+1};
                        case 'initCrop'
                            ConfigObj.initCrop = varargin{i+1};
                        case 'hogResize'
                            ConfigObj.HOG_resize = varargin{i+1};
                        case 'hogCellSize'
                            ConfigObj.HOG_cellsize = varargin{i+1};
                    end   
                end    
            end
        end    
        function ConfigObj = loadNetwork(ConfigObj,networkType,datafile,protofile,HPC,Win)
            if networkType == 1 %CAFFE NETWORK
                if HPC == 1  %HPC is unable to use 3rd party files like importCaffeNetwork
                    load(datafile,'net'); 
                    ConfigObj.net = net;
                else    
                    ConfigObj.datafile = datafile;
                    ConfigObj.protofile = protofile;

                    ConfigObj.net = importCaffeNetwork(ConfigObj.protofile,ConfigObj.datafile);
                end    
                sz = ConfigObj.net.Layers(1,1).InputSize;
                ConfigObj.CNN_resize = sz(1:2);
            else
                if HPC == 1
                    addpath(genpath('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/matconvnet-1.0-beta25'));
                    run vl_setupnn
                    %ConfigObj.net = load('imagenet-vgg-verydeep-16.mat');
                    ConfigObj.net = load('imagenet-vgg-m-1024.mat');
                    ConfigObj.net = vl_simplenn_tidy(ConfigObj.net);
                    ConfigObj.net = vl_simplenn_move(ConfigObj.net, 'gpu');
                else    
                    if Win == 1
                        addpath(genpath('D:\MATLAB\Multi_SLAM_Fusion\matconvnet-1.0-beta25'));
                    else
                        addpath(genpath('/media/stephen/Data/MATLAB/Multi_SLAM_Fusion/matconvnet-1.0-beta25'));
                    end    
                    run vl_setupnn
                    %ConfigObj.net = load('imagenet-vgg-verydeep-16.mat');
                    ConfigObj.net = load('imagenet-vgg-m-1024.mat');
                    ConfigObj.net = vl_simplenn_tidy(ConfigObj.net);
                    ConfigObj.net = vl_simplenn_move(ConfigObj.net, 'gpu');
    %                 sz = ConfigObj.net.Layers(1,1).InputSize;
    %                 ConfigObj.CNN_resize = sz(1:2);
                end
            end
        end    
        function ConfigObj = loadImages(ConfigObj,Ref_folder,Query_folder,end_index)
            fR_temp = dir(Ref_folder);
            for i = 1:length(fR_temp)
                name = fR_temp(i).name;
                patns = {'jpeg','jpg','png'};
                for j = 1:length(patns)  %assuming same filetype across folder
                    k = strfind(name,patns{j});
                    if k %exists
                        file_type = fR_temp(i).name(k:end);
                        break
                    end    
                end    
                if k    
                    break
                end    
            end    
            Ref_file_type = strcat('*',file_type);
            fR = dir(fullfile(Ref_folder,Ref_file_type));
            Imcounter_R = ConfigObj.imStartR;
            fR2 = struct2cell(fR);
            tmpFilesR = sort_nat(fR2(1,:));
            i = 1;
            if nargin == 4
                while(((Imcounter_R+1) <= length(tmpFilesR)) && ((Imcounter_R+1) <= end_index))
                    filenamesR{i} = tmpFilesR(Imcounter_R+1);
                    Imcounter_R = Imcounter_R + ConfigObj.frameSkip;
                    i = i + 1;
                end
            else    
                while((Imcounter_R+1) <= length(tmpFilesR))
                    filenamesR{i} = tmpFilesR(Imcounter_R+1);
                    Imcounter_R = Imcounter_R + ConfigObj.frameSkip;
                    i = i + 1;
                end
            end
            %define struct member ConfigObj.fR
            ConfigObj.filesR.fR = filenamesR;
            ConfigObj.filesR.path = fR(1).folder;
            
            fQ_temp = dir(Query_folder);
            for i = 1:length(fQ_temp)
                name = fQ_temp(i).name;
                patns = {'jpeg','jpg','png'};
                for j = 1:length(patns)  %assuming same filetype across folder
                    k = strfind(name,patns{j});
                    if k %exists
                        file_type = fQ_temp(i).name(k:end);
                        break
                    end    
                end    
                if k    
                    break
                end    
            end    
            Query_file_type = strcat('*',file_type);
            fQ = dir(fullfile(Query_folder,Query_file_type));
            Imcounter_Q = ConfigObj.imStartQ;
            fQ2 = struct2cell(fQ);
            tmpFilesQ = sort_nat(fQ2(1,:));
            i = 1;
            if nargin == 4
                while(((Imcounter_Q+1) <= length(tmpFilesQ)) && ((Imcounter_Q+1) <= end_index))
                    filenamesQ{i} = tmpFilesQ(Imcounter_Q+1);
                    Imcounter_Q = Imcounter_Q + ConfigObj.frameSkip;
                    i = i + 1;
                end
            else    
                while((Imcounter_Q+1) <= length(tmpFilesQ))
                    filenamesQ{i} = tmpFilesQ(Imcounter_Q+1);
                    Imcounter_Q = Imcounter_Q + ConfigObj.frameSkip;
                    i = i + 1;
                end
            end
            %define struct member ConfigObj.fQ
            ConfigObj.filesQ.fQ = filenamesQ;
            ConfigObj.filesQ.path = fQ(1).folder;
            
            %set size of query and template image sets
            ConfigObj.dSize = length(filenamesR);
            ConfigObj.qSize = length(filenamesQ);
        end    
        function ConfigObj = loadGTFile(ConfigObj,GTFile)
            ConfigObj.GPSMatrix = GTFile.GPSMatrix;
            %TODO: add error checking and validation
        end    
        function ConfigObj = imageSettings(ConfigObj,varargin)
            
            
        end 
        %debug function - evaluate recall@N on match candidates
        function [recall, recall_pos] = evalMatches(this,currImageId,match_candidates)
            recall = 0;
            recall_pos = 0;
            %are any of the match_candidates within ground truth?
            for i = 1:length(match_candidates)
                if (this.GPSMatrix(this.imStartR + match_candidates(i),this.imStartQ + currImageId)==1)
                    recall = 1;
                    recall_pos = i;  %where in match_candidates is the true match located
                    break
                else  
                    
                end
            end    
        end 
    end
end    


