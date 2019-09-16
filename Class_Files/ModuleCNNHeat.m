classdef ModuleCNNHeat < Config
    properties
        actLayer = 15;
        templates_D;
        templates_Q;
        N = 100;  %number of candidates output by this module
        M;  %number of candidates supplied to this module
        pyrlevel;
    end  
    methods
        function this = setActLayer(this,userActLayer)
            if strfind(this.net.Layers(userActLayer,1).Name,'relu') %if exist
                this.actLayer = userActLayer;
            else
                error('Please enter valid relu layer id for current network');
            end
        end    
        function this = setNumCandidates(this,NumCans,pyrlevel)
            if ((NumCans > 0) && (NumCans < this.dSize))
                this.N = NumCans;
            else
                error('Please enter valid CNN module candidate count, between 1 and number of database images');
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
                Im = imresize(Im,[this.CNN_resize(2) this.CNN_resize(1)],'lanczos3');
                
                heat = CNN_Create_Template_Dist(this.net,Im,this.actLayer);  %CNN-Dist
                this.templates_D(i,:) = heat(:);
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
                Im = imresize(Im,[this.CNN_resize(2) this.CNN_resize(1)],'lanczos3');
                
                heat = CNN_Create_Template_Dist(this.net,Im,this.actLayer);  %CNN-Dist
                templates_D(i,:) = heat(:);
            end
            save(saveName, 'templates_D');
        end    
        function this = saveQueryTemplates(this, saveName)
            %Create database template array:
            for i = 1:this.qSize
                Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{i})));
                %if i == 1
                    szIm = size(Im);
                %end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = imresize(Im,[this.CNN_resize(2) this.CNN_resize(1)],'lanczos3');
                
                heat = CNN_Create_Template_Dist(this.net,Im,this.actLayer);  %CNN-Dist
                templates_Q(i,:) = heat(:);
            end
            save(saveName, 'templates_Q');
        end    
        function this = loadDbaseTemplates(this, fileName)
            load(fileName,'templates_D');  %templates_D
            this.templates_D = templates_D;
            if (this.dSize < size(this.templates_D,1))
                this.templates_D((this.dSize+1):end,:) = [];
            end
        end    
        function this = loadQueryTemplates(this, fileName)
            load(fileName,'templates_Q');  %templates_Q
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
            
            %D_z = zscore(D_t); %zscore(D_t) or zscore(log(D_t))??
            %D_z = zscore(log(D_t));  
        end    
%         function [match_candidates] = findMatches(this,currImageId,prev_match_candidates)
%             Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
%             szIm = size(Im);
%             Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
%                 this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
%             
%             Im = imresize(Im,[this.CNN_resize(2) this.CNN_resize(1)],'lanczos3');
%             
%             heat = CNN_Create_Template_Dist(this.net,Im,this.actLayer); %CNN-Dist
%             template_Q(1,:) = heat(:);
%             if this.pyrlevel == 1
%                 D = pdist2(template_Q,this.templates_D,'cosine'); 
%             else
%                 D = pdist2(template_Q,this.templates_D(prev_match_candidates,:),'cosine');
%             end    
%             cnn_candidates = NaN(this.N,1);
%             for i = 1:this.N
%                 [~,cnn_candidates(i)] = min(D);
%                 D(cnn_candidates(i)) = NaN;
%             end
%             if this.pyrlevel == 1
%                 match_candidates = cnn_candidates;   
%             else
%                 match_candidates = prev_match_candidates(cnn_candidates);   
%             end 
%         end   
    end
end    




