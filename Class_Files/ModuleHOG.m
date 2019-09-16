classdef ModuleHOG < Config
    properties
        templates_D;
        templates_Q;
        N = 10;   %number of candidates output by this module
        M;          %number of candidates supplied to this module
        pyrlevel;   %needed in order to make code agnostic to module location
    end  
    methods
        function this = setNumCandidates(this,NumCans,pyrlevel)
            if ((NumCans > 0) && (NumCans < this.dSize))
                this.N = NumCans;
            else
                error('Please enter valid HOG module candidate count, between 1 and number of database images');
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
                Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
                Im = rgb2gray(Im);
                this.templates_D(i,:) = extractHOGFeatures(Im,'CellSize',this.HOG_cellsize);
            end
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
                Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
                Im = rgb2gray(Im);
                templates_D(i,:) = extractHOGFeatures(Im,'CellSize',this.HOG_cellsize);
            end
            save(saveName,'templates_D');
        end    
        function this = saveQueryTemplates(this, saveName)
            for i = 1:this.qSize
               Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{i})));
               szIm = size(Im);
               Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                   this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
               Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
               Im = rgb2gray(Im);
               templates_Q(i,:) = extractHOGFeatures(Im,'CellSize',this.HOG_cellsize);
            end
            save(saveName,'templates_Q');
        end
        function this = loadDbaseTemplates(this, fileName)
            load(fileName,'templates_D');  
            this.templates_D = templates_D; 
            if (this.dSize < size(this.templates_D,1))
                this.templates_D((this.dSize+1):end,:) = [];
            end
        end    
        function this = loadQueryTemplates(this, fileName)
            load(fileName,'templates_Q');
            this.templates_Q = templates_Q;
            if (this.qSize < size(this.templates_Q,1))
                this.templates_Q((this.qSize+1):end,:) = [];
            end
        end
        function D_t = findDifference(this,currImageId,prev_match_candidates)
            if this.pyrlevel == 1
                D = pdist2(this.templates_Q(currImageId,:),this.templates_D); %L2
            else
                D = pdist2(this.templates_Q(currImageId,:),this.templates_D(prev_match_candidates,:));
            end
            %two-stage normalize - first, max-min, then second, zscore:
            D_ma = max(D); D_mi = min(D); D_d = D_mi - D_ma;
            D_t = D - D_ma;
            D_t = D_t ./ D_d;
            
            if this.pyrlevel ~= 1
                D_f = zeros(1,this.dSize);
                for i = 1:length(prev_match_candidates)
                    D_f(prev_match_candidates(i)) = D_t(i);
                end    
                clear D_t;
                D_t = D_f;
            end
        end
        function [match_candidates] = findMatches(this,currImageId,prev_match_candidates)
            Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
            
            Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
            Im = rgb2gray(Im);
            template_Q(1,:) = extractHOGFeatures(Im,'CellSize',this.HOG_cellsize);
            
            if this.pyrlevel == 1          
                D = pdist2(template_Q,this.templates_D,'cosine'); 
            else    
                D = pdist2(template_Q,this.templates_D(prev_match_candidates,:),'cosine');
            end
            hog_candidates = NaN(this.N,1);
            for i = 1:this.N
                [~,hog_candidates(i)] = min(D); %candidates are the best N scores
                D(hog_candidates(i)) = NaN;
            end
            if this.pyrlevel == 1
                match_candidates = hog_candidates;   
            else
                match_candidates = prev_match_candidates(hog_candidates);   
            end 
        end 
    end
end    




