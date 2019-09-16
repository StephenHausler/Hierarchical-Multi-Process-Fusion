classdef ModuleORB < Config
    properties
        Feat;
        Dbase_kpt = {};
        Dbase_desc = {};
        Query_kpt = {};
        Query_desc = {};
        N = 10; %number of candidates output by this module
        M; %number of candidates supplied to this module
        pyrlevel;
    end  
    methods
        function this = init(this, HPC, Win)
            if HPC == 1
                addpath(genpath('/home/n7542704/MATLAB_2019_Working/Support_Packages/visionopencv'));
            else    
                if Win == 1
                    addpath(genpath('D:\MATLAB\Support_Packages\visionopencv'));
                else    
                    addpath(genpath('/media/HPC/MATLAB_2019_Working/Support_Packages/visionopencv'));
                end    
            end    
        end
        function this = setNumCandidates(this,prevCanCount,NumCans,pyrlevel)
            if pyrlevel == 1
                if ((NumCans > 0) && (NumCans < this.dSize))
                    this.N = NumCans;
                else
                    error('Please enter valid ORB module candidate count, between 1 and number of database images');
                end    
            else    
                if ((NumCans > 0) && (NumCans < prevCanCount))
                    this.N = NumCans;
                else
                    error('Please enter valid ORB module candidate count, between 1 and previous match candidate count');
                end   
                %this.M = prevCanCount;
            end
            this.pyrlevel = pyrlevel;
        end    
        function this = extractDbaseFeats(this)
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                Im = rgb2gray(Im);
                if i == 1
                    szIm = size(Im);
                end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
                
                pts  = detectORBFeaturesOCV(Im);
                [desc_uint8, kpt] = extractORBFeaturesOCV(Im, pts);
                this.desc{i} = binaryFeatures(desc_uint8);

                this.kpt{i} = kpt;
                %[indexPairs,matchmetric] = matchFeatures(features1,features2)
            end
        end      
        function this = saveDbaseTemplates(this, saveName)
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                Im = rgb2gray(Im);
                if i == 1
                    szIm = size(Im);
                end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
                
                pts  = detectORBFeaturesOCV(Im);
                [desc_uint8, kp] = extractORBFeaturesOCV(Im, pts);
                desc{i} = binaryFeatures(desc_uint8);
                kpt(i) = kp;         
            end
            save(saveName,'desc','kpt');
        end       
        function this = saveQueryTemplates(this, saveName)
            for i = 1:this.qSize
                Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{i})));
                Im = rgb2gray(Im);
                if i == 1
                    szIm = size(Im);
                end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
                
                pts  = detectORBFeaturesOCV(Im);
                [desc_uint8, kp] = extractORBFeaturesOCV(Im, pts);
                desc{i} = binaryFeatures(desc_uint8);
                kpt(i) = kp;     
            end
            save(saveName,'desc','kpt');
        end    
        function this = loadDbaseTemplates(this, fileName)
            load(fileName);  %desc, kpt
            this.Dbase_desc = desc; this.Dbase_kpt = kpt;
        end    
        function this = loadQueryTemplates(this, fileName)
            load(fileName);
            this.Query_desc = desc; this.Query_kpt = kpt;
        end    
        function [match_candidates] = findMatches(this,currImageId,prev_match_candidates)
            Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
            Im = rgb2gray(Im);
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
            
            Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
            
            %maybe consider using another image processing method to 'mask'
            %distracting image regions?
            
            pts  = detectORBFeaturesOCV(Im);
            [desc_uint8, ~] = extractORBFeaturesOCV(Im, pts);
            desc = binaryFeatures(desc_uint8);
            
            if this.pyrlevel == 1
                for i = 1:this.dSize
                    %[~, dist] = matchFeatures(desc, this.desc{i}, 'MatchThreshold', 20);
                    [~, dist] = matchFeatures(desc, this.Dbase_desc{i},'MatchThreshold', 100, 'MaxRatio',1);
                    %20% best matches
                    D(i) = sum(dist);  %smallest distance is best match
                    %actually, the above is not true if the number of
                    %matched features varies due to filtering within
                    %matchFeatures!
                    %with aggressive filtering in matchFeatures, the
                    %optimal metric becomes the length of dist!
                end    
            else
                for i = 1:length(prev_match_candidates)
                    [~, dist] = matchFeatures(desc, this.desc{prev_match_candidates(i)},'MatchThreshold', 100, 'MaxRatio',1);
                    
                    D(i) = sum(dist);
                end
            end
            orb_candidates = NaN(this.N,1);
            %extract top N scores
            for i = 1:this.N
                [~,orb_candidates(i)] = min(D);  
                D(orb_candidates(i)) = NaN;
            end
            if this.pyrlevel == 1
                match_candidates = orb_candidates;   
            else
                match_candidates = prev_match_candidates(orb_candidates);   
            end    
        end
    end
end    




