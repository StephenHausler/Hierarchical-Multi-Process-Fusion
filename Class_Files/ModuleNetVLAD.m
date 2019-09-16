classdef ModuleNetVLAD < Config
    properties
        templates_D;
        templates_Q;
        N = 1;  %number of candidates output by this module
        M;  %number of candidates supplied to this module
        pyrlevel;
        dbFeatFn;
        qFeatFn;
    end  
    methods   %Need to decide if want to re-write serialAllFeats to fit with
        %my other code...
        function this = init(this, name, HPC, Win)
            if HPC == 1
                addpath(genpath('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/NetVLAD'));
                addpath(genpath('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/matconvnet-1.0-beta25'));
            else
                if Win == 1
                    addpath(genpath('D:\Multi_SLAM_Fusion_Ver2\NetVLAD'));
                    addpath(genpath('D:\MATLAB\Multi_SLAM_Fusion\matconvnet-1.0-beta25'));
                else    
                    addpath(genpath('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion/netvlad-master'));
                    addpath(genpath('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion/matconvnet-1.0-beta25'));
                end
            end    
            run vl_setupnn

            netID = 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';
            paths= localPaths(HPC);
            
            load( sprintf('%s%s.mat', paths.ourCNNs, netID), 'net' );
            this.net= relja_simplenn_tidy(net);

            this.dbFeatFn= sprintf('%s%s_%s_db.bin', paths.outPrefix, netID, name);
            this.qFeatFn = sprintf('%s%s_%s_q.bin', paths.outPrefix, netID, name);
        end
        function this = setNumCandidates(this,NumCans,pyrlevel)
            if ((NumCans > 0) && (NumCans <= this.dSize))
                this.N = NumCans;
            else
                error('Please enter valid NetVLAD module candidate count, between 1 and number of database images');
            end
            this.pyrlevel = pyrlevel;
        end
        function this = createDbaseTemplates(this)
            %Create database template array:
            this.templates_D = serialAllFeats(this.net, this.filesR.path, this.filesR.fR,...
                this.dbFeatFn, 'batchSize', 10, 'CropSize',this.initCrop, 'Resize',[224 224]);%[480 640]
        end    
        function this = saveDbaseTemplates(this, saveName)
            %Create database template array:
            templates_D = serialAllFeats(this.net, this.filesR.path, this.filesR.fR,...
                this.dbFeatFn, 'batchSize', 10, 'CropSize',this.initCrop, 'Resize',[224 224]);%[480 640]
            save(saveName, 'templates_D');
        end 
        function this = saveQueryTemplates(this, saveName)
            templates_Q = serialAllFeats(this.net, this.filesQ.path, this.filesQ.fQ,...
                this.qFeatFn, 'batchSize', 10, 'CropSize',this.initCrop, 'Resize',[224 224]);%[480 640]
            save(saveName, 'templates_Q');
        end
        function this = loadDbaseTemplates(this, fileName)
            load(fileName, 'templates_D');
            this.templates_D = templates_D';
            if (this.dSize < size(this.templates_D,1))
                this.templates_D((this.dSize+1):end,:) = [];
            end
        end    
        function this = loadQueryTemplates(this, fileName)
            load(fileName, 'templates_Q');
            this.templates_Q = templates_Q';
            if (this.qSize < size(this.templates_Q,1))
                this.templates_Q((this.qSize+1):end,:) = [];
            end
        end
        %re-write below:
        function D_t = findDifference(this,currImageId,prev_match_candidates)
            if this.pyrlevel == 1
                D = pdist2(this.templates_Q(currImageId,:),this.templates_D);
            else
                D = pdist2(this.templates_Q(currImageId,:),this.templates_D(prev_match_candidates,:));
            end
            %two-stage normalize - first, max-min, then second, zscore:
            D_ma = max(D); D_mi = min(D); D_d = D_mi - D_ma;
            D_t = D - D_ma;
            D_t = D_t ./ D_d;  %need to normalize such that the best match is 1 and the worst match is 0.
            
            if this.pyrlevel ~= 1
                D_f = zeros(1,this.dSize);
                for i = 1:length(prev_match_candidates)
                    D_f(prev_match_candidates(i)) = D_t(i);
                end    
                clear D_t;
                D_t = D_f;
            end
        end
        function [match_candidates,quality] = findMatches(this,currImageId,prev_match_candidates)
            Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
            Im = imresize(Im, [224 224],'lanczos3');
            Im = single(Im);
            
            template_Q = SingleFeat(this.net, Im);
            
            %now compare template_Q with templates_D using same method as
            %NetVLAD, but re-written here...
            quality = 0;
            if this.pyrlevel == 1
                [ids,~]= rawNnSearch(template_Q, this.templates_D, this.N);    
            elseif this.pyrlevel == 3
                [ids,ds]= rawNnSearch(template_Q, this.templates_D(:,prev_match_candidates), (this.N + 1));
                quality = ds(1) / ds(2);  %larger/smaller
                ids = ids(1);
            else    
                [ids,~]= rawNnSearch(template_Q, this.templates_D(:,prev_match_candidates), this.N);
            end
            if this.pyrlevel == 1
                match_candidates = ids;   
            else
                match_candidates = prev_match_candidates(ids);   
            end 
        end
    end
end    
function template_Q = SingleFeat(net, Im)
opts= struct(...
    'useGPU', true, ...
    'numThreads', 8, ...
    'batchSize', 10, ...
    'Resize',[480 640],...
    'CropSize',[1 1 1 1]...
    );
simpleNnOpts= {'conserveMemory', true, 'mode', 'test'};
net= netPrepareForTest(net);
if opts.useGPU
    net= relja_simplenn_move(net, 'gpu');
else
    net= relja_simplenn_move(net, 'cpu');
end
Im(:,:,1)= Im(:,:,1) - net.meta.normalization.averageImage(1,1,1);
Im(:,:,2)= Im(:,:,2) - net.meta.normalization.averageImage(1,1,2);
Im(:,:,3)= Im(:,:,3) - net.meta.normalization.averageImage(1,1,3);

if opts.useGPU
    ims= gpuArray(Im);
end

% ---------- extract features
res= vl_simplenn(net, ims, [], [], simpleNnOpts{:});
clear ims;
template_Q= reshape( gather(res(end).x), [], 1 );
clear res;

end


