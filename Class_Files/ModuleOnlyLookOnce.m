classdef ModuleOnlyLookOnce < Config
    properties
        templates_D;
        templates_Q;
        N = 1;  %number of candidates output by this module
        M;  %number of candidates supplied to this module
        pyrlevel;
%         actLayerFeat = 27;
%         actLayerMask = 29;
        actLayerFeat = 13;
        actLayerMask = 15;
        index;
        C;
        word_size;
        wordcnt;
        totalimg;
    end  
    methods
        function this = init(this, HPC, Win)
            if HPC == 1
                addpath(genpath('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/IROS2017_OnlyLookOnce'));
                load('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/IROS2017_OnlyLookOnce/build_vocabulary/word_10000.mat');
                load('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/IROS2017_OnlyLookOnce/build_vocabulary/reverse_10000.mat');
                this.index = index;
                this.C = C;
                this.word_size = word_size;
                this.wordcnt = wordcnt;
                this.totalimg = totalimg;
            else    
                if Win == 1
                    addpath(genpath('D:\MATLAB\Multi_SLAM_Fusion\IROS2017_OnlyLookOnce'));
                    load('D:\MATLAB\Multi_SLAM_Fusion\IROS2017_OnlyLookOnce\build_vocabulary\word_10000.mat');
                    load('D:\MATLAB\Multi_SLAM_Fusion\IROS2017_OnlyLookOnce\build_vocabulary\reverse_10000.mat');
                else 
                    addpath(genpath('/media/stephen/Data/Multi_SLAM_Fusion/IROS2017_OnlyLookOnce'));
                    load('/media/stephen/Data/MATLAB/Multi_SLAM_Fusion/IROS2017_OnlyLookOnce/build_vocabulary/word_10000.mat');
                    load('/media/stephen/Data/MATLAB/Multi_SLAM_Fusion/IROS2017_OnlyLookOnce/build_vocabulary/reverse_10000.mat');
                end    
                this.index = index;
                this.C = C;
                this.word_size = word_size;
                this.wordcnt = wordcnt;
                this.totalimg = totalimg;
            end    
        end
        function this = setActLayer(this,userActLayerFeat,userActLayerMask)
            this.actLayerFeat = userActLayerFeat;
            this.actLayerMask = userActLayerMask;
        end    
        function this = setNumCandidates(this,NumCans,pyrlevel)
            if ((NumCans > 0) && (NumCans < this.dSize))
                this.N = NumCans;
            else
                error('Please enter valid LookOnce module candidate count, between 1 and number of database images');
            end
            this.pyrlevel = pyrlevel;
        end
        function this = createDbaseTemplates(this)
            %Create database template array:
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                %if i == 1
                    szIm = size(Im);
                %end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = single(Im);
                Im = imresize(Im, this.net.meta.normalization.imageSize(1:2),'lanczos3') ;
                Im = Im - this.net.meta.normalization.averageImage;
                %re-write as batch format, ideally 10. This will make it
                %process much faster.
                
                Img = gpuArray(Im);
                
                res1 = vl_simplenn(this.net, Img);
                
                feat1 = res1(this.actLayerFeat).x; % 13*13*512
                feat1 = permute(feat1,[3 1 2]); %512*13*13;
                mask1 = res1(this.actLayerMask).x; % 13*13*512
                mask1 = permute(mask1,[3 1 2]); % 512*13*13

                feat1c = gather(feat1);
                mask1c = gather(mask1);
                
                encodef1 = encode_feat(feat1c,mask1c);
                encodef1 = encodef1';
                
                this.templates_D(i,:,:) = encodef1;
            end
            %may need to save templates to disk - very large memory
            %requirement.
        end    
        function this = saveDbaseTemplates(this, saveName)
            %Create database template array:
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                %if i == 1
                    szIm = size(Im);
                %end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = single(Im);
                Im = imresize(Im, this.net.meta.normalization.imageSize(1:2),'lanczos3') ;
                Im = Im - this.net.meta.normalization.averageImage;
                %re-write as batch format, ideally 10. This will make it
                %process much faster.
                
                Img = gpuArray(Im);
                
                res1 = vl_simplenn(this.net, Img);
                
                feat1 = res1(this.actLayerFeat).x; % 13*13*512
                feat1 = permute(feat1,[3 1 2]); %512*13*13;
                mask1 = res1(this.actLayerMask).x; % 13*13*512
                mask1 = permute(mask1,[3 1 2]); % 512*13*13

                feat1c = gather(feat1);
                mask1c = gather(mask1);
                
                encodef1 = encode_feat(feat1c,mask1c);
                encodef1 = encodef1';
                
                templates_D(i,:,:) = encodef1;
            end
            save(saveName,'templates_D');
            %may need to save templates to disk - very large memory
            %requirement.
        end    
        function this = saveQueryTemplates(this, saveName)
            %Create query template array:
            for i = 1:this.qSize
                Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{i})));
                %if i == 1
                    szIm = size(Im);
                %end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = single(Im);
                Im = imresize(Im, this.net.meta.normalization.imageSize(1:2),'lanczos3') ;
                Im = Im - this.net.meta.normalization.averageImage;
                %re-write as batch format, ideally 10. This will make it
                %process much faster.
                
                Img = gpuArray(Im);
                
                res1 = vl_simplenn(this.net, Img);
                
                feat1 = res1(this.actLayerFeat).x; % 13*13*512
                feat1 = permute(feat1,[3 1 2]); %512*13*13;
                mask1 = res1(this.actLayerMask).x; % 13*13*512
                mask1 = permute(mask1,[3 1 2]); % 512*13*13

                feat1c = gather(feat1);
                mask1c = gather(mask1);
                
                encodef1 = encode_feat(feat1c,mask1c);
                encodef1 = encodef1';
                
                templates_Q(i,:,:) = encodef1;
            end
            save(saveName,'templates_Q');
            %may need to save templates to disk - very large memory
            %requirement.  
        end    
        function this = loadDbaseTemplates(this, fileName)
            load(fileName,'templates_D');
            this.templates_D = templates_D; 
        end    
        function this = loadQueryTemplates(this, fileName)
            load(fileName,'templates_Q');
            this.templates_Q = templates_Q;            
        end    
        function D_t = findDifference(this,currImageId,prev_match_candidates)
            if this.pyrlevel == 1
                for i = 1:this.dSize
                    D(i) = compare_two(this.templates_D(i,:,:),this.templates_Q(currImageId,:,:),...
                        this.C,this.index,this.word_size,this.wordcnt,this.totalimg);
                end
            else
                for i = 1:length(prev_match_candidates)
                    D(i) = compare_two(this.templates_D(prev_match_candidates(i),:,:),...
                        this.templates_Q(currImageId,:,:),this.C,this.index,this.word_size,this.wordcnt,this.totalimg);
                end 
            end    
            % closer to 1 is better match for OLO!
            %two-stage normalize - first, max-min, then second, zscore:
            D_ma = max(D); D_mi = min(D); D_d = D_ma - D_mi; 
            D_t = D - D_mi; 
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
            
            Im = single(Im);
            Im = imresize(Im, this.net.meta.normalization.imageSize(1:2),'lanczos3') ;
            %Im = imresize(Im, this.net.meta.normalization.imageSize(1:2)) ;
            Im = Im - this.net.meta.normalization.averageImage;
            
            Img = gpuArray(Im);
            
            res2 = vl_simplenn(this.net, Img) ;
            
            %originally used 14, now using 12
            feat2 = res2(this.actLayerFeat).x; % 13*13*512
            feat2 = permute(feat2,[3 1 2]); %512*13*13;
            mask2 = res2(this.actLayerMask).x; % 13*13*512
            mask2 = permute(mask2,[3 1 2]); % 512*13*13
            
            feat2c = gather(feat2);
            mask2c = gather(mask2);

            encodef2 = encode_feat(feat2c,mask2c);
            encodef2 = encodef2';
            
            if this.pyrlevel == 1
                for i = 1:this.dSize
                    score(i) = compare_two(this.templates_D(i,:,:),encodef2,...
                        this.C,this.index,this.word_size,this.wordcnt,this.totalimg);
                end
            else
                for i = 1:length(prev_match_candidates)
                    score(i) = compare_two(this.templates_D(prev_match_candidates(i),:,:),...
                        encodef2,this.C,this.index,this.word_size,this.wordcnt,this.totalimg);
                end 
            end    
            olo_candidates = NaN(this.N,1);
            for i = 1:this.N
                [q,olo_candidates(i)] = max(score);  % closer to 1 is better match
                if i == 1
                    q1 = q;
                end  
                if i == 2
                    q2 = q;
                end    
                score(olo_candidates(i)) = NaN;
            end    
            if this.N == 1
                q2 = max(score);
            end
            quality = q1 / q2;  % larger val / smaller val
            if this.pyrlevel == 1
                match_candidates = olo_candidates;   
            else    
                match_candidates = prev_match_candidates(olo_candidates);   
            end 
            %return a quality metric? Ratio of best score compared to next
            %best score outside window around the best score.
        end
        function [encodef1,encodef2] = findMatchesPar(this,currImageId,prev_match_candidates)
            Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
            
            Im = single(Im);
            %Im = imresize(Im, this.net.meta.normalization.imageSize(1:2),'lanczos3') ;
            Im = imresize(Im, this.net.meta.normalization.imageSize(1:2)) ;
            Im = Im - this.net.meta.normalization.averageImage;
            
            Img = gpuArray(Im);
            
            res2 = vl_simplenn(this.net, Img) ;
            
            %originally used 14, now using 12
            feat2 = res2(12).x; % 13*13*512
            feat2 = permute(feat2,[3 1 2]); %512*13*13;
            mask2 = res2(16).x; % 13*13*512
            mask2 = permute(mask2,[3 1 2]); % 512*13*13
            
            feat2c = gather(feat2);
            mask2c = gather(mask2);

            encodef2 = encode_feat(feat2c,mask2c);
            encodef2 = encodef2';
            
            for j = 1:length(prev_match_candidates)
                encodef1(j,:,:) = this.templates_D(prev_match_candidates(j),:,:);
            end
        end     
    end
end    


function score = compare_two(test_feat_in,refer_feat_in,C,index,word_size,wordcnt,totalimg)
% function description: compare two images "test" and "refer"; 
% test, refer: mask_channel*N where mask_channel is the number of regions
% per image (defined as 200) and N is the dimensionality. each row is
% l2-normalized

test_feat(:,:) = test_feat_in(1,:,:);
refer_feat(:,:) = refer_feat_in(1,:,:);

% the number of row equal to the number of regions per image.
mask_channel = size(test_feat,1);

% a 512*512 matrix where each row represents the distances between each region and all other regions. Using dot product.
% Because test_feat and refer_feat are both l2_normalized, this actually
% implements the formula (6) in the paper. 
test_temp = test_feat*refer_feat';

% column max is each reference region to all regions in the test image
% Ranging from 1 (cos0, most similar) to -1 (cos180, least similar)
[col_value,col_idx] = max(test_temp,[],1); 

% row max is each region in the test to all regions in the reference image.
[row_value,row_idx] = max(test_temp,[],2); 
        
mutual = 0;

%word_size = 10000; % A vocabulary with 10000 words
% load(['build_vocabulary/reverse_' num2str(word_size) '.mat']); % load the reverse
% load(['build_vocabulary/word_' num2str(word_size) '.mat']); % load the clustering center

for inner = 1:mask_channel % for each region in the test image
    %if(col_idx(inner) ~= row_idx(col_idx(inner))) % if the match is not mutual
    if(col_idx(row_idx(inner)) ~= inner)  %if the match is not mutual
        row_value(inner) = 0; % we don't take that match into account.
                %row_value(inner) = row_value(inner);
    else
        if(row_value(inner) ~=0) % in case there are some mutual matches where both match to the other with a 0 score, this can happen when that region is pooled by a completely black mask
            mutual = mutual + 1; % not identify a mutual match as test region:inner, reference region:row_idx(inner)
                    %mutual_matrix = [mutual_matrix;inner row_idx(inner)];
        else
            row_value(inner) = 0;
        end
    end
    
end

    %the index where there is mutual match between the 'nonzero' and 'row_idx(nonzero)'
    nonzero = find(row_value ~= 0); % 
    test_nonzero = single(test_feat(nonzero,:)); % the features of test regions which have mutual match with the reference image
    refer_nonzero = single(refer_feat(row_idx(nonzero),:)); % the features of the reference which match to the 'test_nonzero',   'row_value(nonzero) = col_value(row_idx(nonzero))'
    Cg = gpuArray(C);
    tng = gpuArray(test_nonzero);
    rng = gpuArray(refer_nonzero);

    testdist = pdist2(Cg,tng); % each column is a testing region to all clustering centers
    referdist = pdist2(Cg,rng);% each column is a reference region to all clustering centers

    [t_value,t_index] = min(testdist); % t_index is the index of the assignment words
    [r_value,r_index] = min(referdist); % r_index is the index of the assignment words

    row_value(nonzero) = (row_value(nonzero).*(log10(totalimg./wordcnt(t_index)))').*(log10(totalimg./wordcnt(r_index)))';
        
    score = sum(row_value)/mask_channel; % calculate the average matching score, may replace 'mutual' by 'mask_channel' to encourage more mutual (but maybe less similar) matches.     

end