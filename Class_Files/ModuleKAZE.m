classdef ModuleKAZE < Config
    properties
        Feat;
        Dbase_kpt = {};
        Dbase_desc = {};
        Query_kpt = {};
        Query_desc = {};
        N = 10; %number of candidates output by this module
        M; %number of candidates supplied to this module
        pyrlevel;
        method = 1;  %0: no filtering SURF matches, 1: filter SURF matches
    end  
    methods
        function this = init(this, HPC)
            
        end
        function this = setNumCandidates(this,NumCans,pyrlevel)
            if ((NumCans > 0) && (NumCans <= this.dSize))
                this.N = NumCans;
            else
                error('Please enter valid KAZE module candidate count, between 1 and number of database images');
            end
            this.pyrlevel = pyrlevel;
        end    
        function this = extractDbaseFeats(this)
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                Im = rgb2gray(Im);
                %if i == 1
                    szIm = size(Im);
                %end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
                
                pts = detectKAZEFeatures(Im);
                [this.Dbase_desc{i},this.Dbase_kpt{i}] = extractFeatures(Im,pts,'Method','KAZE');
            end
        end       
        function this = saveDbaseTemplates(this, saveName)
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                Im = rgb2gray(Im);
                %if i == 1
                    szIm = size(Im);
                %end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
                
                pts = detectKAZEFeatures(Im);
                [desc{i},kpt{i}] = extractFeatures(Im,pts,'Method','KAZE');
            end
            save(saveName,'desc','kpt');
        end
        function this = saveQueryTemplates(this, saveName)
            for i = 1:this.qSize
                Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{i})));
                Im = rgb2gray(Im);
                %if i == 1
                    szIm = size(Im);
                %end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
                
                pts = detectKAZEFeatures(Im);
                [desc{i},kpt{i}] = extractFeatures(Im,pts,'Method','KAZE');
            end
            save(saveName,'desc','kpt');
        end
        function this = loadDbaseTemplates(this, fileName)
            load(fileName);  %desc, kpt
            this.Dbase_desc = desc; this.Dbase_kpt = kpt;
        end
        function this = loadQueryTemplates(this, fileName)
            load(fileName);  %desc, kpt
            this.Query_desc = desc; this.Query_kpt = kpt;
        end
        function D_t = findDifference(this,currImageId,prev_match_candidates)
            if this.pyrlevel == 1
                if this.method == 1   %pre-filter matchings option
                    for i = 1:this.dSize
                        [~, dist] = matchFeatures(this.Query_desc{currImageId},...
                            this.Dbase_desc{i},'MatchThreshold', 20, 'MaxRatio',0.7);
                        while length(dist) < 20
                            dist = [dist; 1];
                        end
                        [~,ord] = sort(dist);
                        ord(21:end) = [];
                        dist = dist(ord);  %20 best matches
                        D(i) = sum(dist);  %smallest distance is best match
                    end
                else
                    for i = 1:this.dSize
                        [~, dist] = matchFeatures(this.Query_desc{currImageId},...
                            this.Dbase_desc{i},'MatchThreshold', 100, 'MaxRatio',1);
                        D(i) = sum(dist);  %smallest distance is best match
                    end
                end
            else
                if this.method == 1
                    for i = 1:length(prev_match_candidates)
                        [~, dist] = matchFeatures(this.Query_desc{currImageId},...
                            this.Dbase_desc{prev_match_candidates(i)},'MatchThreshold', 20, 'MaxRatio',0.7);
                        while length(dist) < 20
                            dist = [dist; 1];
                        end
                        [~,ord] = sort(dist);
                        ord(21:end) = [];
                        dist = dist(ord);  %20 best matches
                        D(i) = sum(dist);  %smallest distance is best match
                    end
                else
                    for i = 1:length(prev_match_candidates)
                        [~, dist] = matchFeatures(this.Query_desc{currImageId}, this.Dbase_desc{prev_match_candidates(i)},'MatchThreshold', 100, 'MaxRatio',1);
                        D(i) = sum(dist);
                    end
                end
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
            Im = rgb2gray(Im);
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
            Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
            
            pts = detectKAZEFeatures(Im);
            [desc,~] = extractFeatures(Im,pts,'Method','KAZE'); 
            
            if this.pyrlevel == 1
                if this.method == 1   %pre-filter matchings option
                    for i = 1:this.dSize
                        [~, dist] = matchFeatures(desc, this.Dbase_desc{i},'MatchThreshold', 20, 'MaxRatio',0.7);
                        if length(dist) < 20
                            D(i) = 10;
                        else
                            [~,ord] = sort(dist);
                            ord(21:end) = [];
                            dist = dist(ord);  %20 best matches
                            D(i) = sum(dist);  %smallest distance is best match
                        end
                    end
                else    
                    for i = 1:this.dSize
                        [~, dist] = matchFeatures(desc, this.Dbase_desc{i},'MatchThreshold', 100, 'MaxRatio',1);
                        D(i) = sum(dist);  %smallest distance is best match
                    end 
                end
            else
                if this.method == 1
                    for i = 1:length(prev_match_candidates)
                        [~, dist] = matchFeatures(desc, this.Dbase_desc{prev_match_candidates(i)},'MatchThreshold', 20, 'MaxRatio',0.7);
                        if length(dist) < 20
                            D(i) = 10;
                        else    
                            [~,ord] = sort(dist);
                            ord(21:end) = [];
                            dist = dist(ord);  %20 best matches
                            D(i) = sum(dist);  %smallest distance is best match
                        end
                    end 
                else
                    for i = 1:length(prev_match_candidates)
                        [~, dist] = matchFeatures(desc, this.Dbase_desc{prev_match_candidates(i)},'MatchThreshold', 100, 'MaxRatio',1);
                        D(i) = sum(dist);
                    end
                end    
            end
            surf_candidates = NaN(this.N,1);
            %extract top N scores
            for i = 1:this.N
                [q,surf_candidates(i)] = min(D); 
                if i == 1
                    q1 = q;
                end
                if this.pyrlevel == 3
                    
                elseif i == 2
                    q2 = q;
                else
                    
                end
                D(surf_candidates(i)) = NaN;
            end
            if this.pyrlevel == 3
                q2 = min(D);
            end
            quality = q2 / q1;  % larger val (which is worse) / smaller val
            if this.pyrlevel == 1
                match_candidates = surf_candidates;   
            else
                match_candidates = prev_match_candidates(surf_candidates);   
            end    
        end
    end
end    




