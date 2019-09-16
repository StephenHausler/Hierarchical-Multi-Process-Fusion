classdef ModuleSAD < Config
    properties
        templates_D;
        templates_Q;
        N = 100;   %number of candidates output by this module
        M;          %number of candidates supplied to this module
        pyrlevel;   %needed in order to make code agnostic to module location
        normalise = 1;        
        rWindow = 20;        
        D_store;       
    end  
    methods
        function this = setNumCandidates(this,NumCans,pyrlevel)
            if ((NumCans > 0) && (NumCans < this.dSize))
                this.N = NumCans;
            else
                error('Please enter valid SAD module candidate count, between 1 and number of database images');
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
                if i == 1
                    this.templates_D = cast(this.templates_D,'uint8');
                end
                Im = imresize(Im,[this.SAD_resize(2) this.SAD_resize(1)],'lanczos3');
                Im = rgb2gray(Im);
                ImP = patchNormalizeHMM(Im,this.SAD_patchsize,0,0);
                this.templates_D(i,:) = ImP(:);
            end     
            this.D_store = zeros(this.qSize,this.dSize); 
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
                if i == 1
                    this.templates_D = cast(this.templates_D,'uint8');
                end
                Im = imresize(Im,[this.SAD_resize(2) this.SAD_resize(1)],'lanczos3');
                Im = rgb2gray(Im);
                ImP = patchNormalizeHMM(Im,this.SAD_patchsize,0,0);
                templates_D(i,:) = ImP(:);
            end     
            save(saveName, 'templates_D');
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
                if i == 1
                    this.templates_Q = cast(this.templates_Q,'uint8');
                end
                Im = imresize(Im,[this.SAD_resize(2) this.SAD_resize(1)],'lanczos3');
                Im = rgb2gray(Im);
                ImP = patchNormalizeHMM(Im,this.SAD_patchsize,0,0);
                templates_Q(i,:) = ImP(:);      
            end    
            save(saveName, 'templates_Q');
        end    
        function this = loadDbaseTemplates(this, fileName)
            load(fileName,'templates_D');
            this.templates_D = templates_D;
            this.D_store = zeros(this.qSize,this.dSize); 
        end  
        function this = loadQueryTemplates(this, fileName)
            load(fileName,'templates_Q');
            this.templates_Q = templates_Q;
            this.D_store = zeros(this.qSize,this.dSize);
        end    
        function D_t = findDifference(this,currImageId,prev_match_candidates)
            if this.pyrlevel == 1
                D = abs(this.templates_D - this.templates_Q(currImageId,:));
                D = sum(D,2)./(this.SAD_resize(2)*this.SAD_resize(1));
            else
                D = abs(this.templates_D(prev_match_candidates,:) - this.templates_Q(currImageId,:));
                D = sum(D,2)./(this.SAD_resize(2)*this.SAD_resize(1));
            end    
            D = D';
            %two-stage normalize - first, max-min, then second, zscore:
            D_ma = max(D); D_mi = min(D); D_d = D_mi - D_ma;
            %D_d = abs(D_ma - D_mi); D_t = D - D_mi; D_t = D_t ./ D_d;
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
        function [match_candidates, this] = findMatches(this,currImageId,prev_match_candidates)
            Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
            
            Im = imresize(Im,[this.SAD_resize(2) this.SAD_resize(1)],'lanczos3');
            Im = rgb2gray(Im);
            ImP = patchNormalizeHMM(Im,this.SAD_patchsize,0,0);
            template_Q(1,:) = ImP(:);
            
            if this.pyrlevel == 1          
                D = abs(this.templates_D - template_Q);
                D = sum(D,2)./(this.SAD_resize(2)*this.SAD_resize(1));
            else    
                D = abs(this.templates_D(prev_match_candidates,:) - template_Q);
                D = sum(D,2)./(this.SAD_resize(2)*this.SAD_resize(1));
            end
            if this.normalise == 1
                D_h = (D - mean(D)) ./ std(D);  %this is z-score normalization

                this.D_store(currImageId,:) = D_h;

                if currImageId > this.rWindow
                    for i = 1:length(D_h)
                       D_h(i) = (D_h(i) - mean(this.D_store((currImageId-this.rWindow):(currImageId),i))) ...
                           ./ std(this.D_store((currImageId-this.rWindow):(currImageId),i));      
                    end
                    clear D
                    D = D_h;
                else
                    clear D
                    D = D_h;   
                end
            end          
            sad_candidates = NaN(this.N,1);
            for i = 1:this.N
                [~,sad_candidates(i)] = min(D); %candidates are the best N scores
                D(sad_candidates(i)) = NaN;
            end
            if this.pyrlevel == 1
                match_candidates = sad_candidates;   
            else
                match_candidates = prev_match_candidates(sad_candidates);   
            end 
        end    
    end
end    




