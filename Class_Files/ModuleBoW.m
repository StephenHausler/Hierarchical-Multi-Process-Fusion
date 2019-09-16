classdef ModuleBoW < Config
    properties
        N = 10; %number of candidates output by this module
        M; %number of candidates supplied to this module
        pyrlevel;
        imageIndex;
    end  
    methods
        function this = setNumCandidates(this,prevCanCount,NumCans,pyrlevel)
            if pyrlevel == 1
                if ((NumCans > 0) && (NumCans < this.dSize))
                    this.N = NumCans;
                else
                    error('Please enter valid SURF module candidate count, between 1 and number of database images');
                end    
            else    
                if ((NumCans > 0) && (NumCans < prevCanCount))
                    this.N = NumCans;
                else
                    error('Please enter valid SURF module candidate count, between 1 and previous match candidate count');
                end   
                %this.M = prevCanCount;
            end
            this.pyrlevel = pyrlevel;
        end    
        function this = createBoWBag(this, saveName)
            %dont train on entire dataset, train using just first 1000
            %images. And use a voc size of 20,000 words.
            imds = imageDatastore(char(this.filesR.path),'FileExtensions',{'.jpg','.png','.jpeg'});
            
            if length(imds.Files) > this.dSize
                imds.Files(this.dSize+1:end)=[];
            end
            
            if length(imds.Files) > 1000
                imdsBag = subset(imds,1:1000);
            end
            
            r = [this.HOG_resize(2) this.HOG_resize(1)];
            cr = this.initCrop;
            
            imds.ReadFcn = @MyReadFcn; %custom function handler goes here
            imdsBag.ReadFcn = @MyReadFcn;

            vocSize = 20000;
            
            bag = bagOfFeatures(imdsBag,'VocabularySize',vocSize);

            save(saveName,'bag');
            
            function data = MyReadFcn(filename)
                onState = warning('off', 'backtrace');
                c = onCleanup(@() warning(onState));
                data = imread(filename);
                data = rgb2gray(data);
                sz = size(data);
                data = data(cr(1):(sz(1)-cr(2)),cr(3):(sz(2)-cr(4)));
                data = imresize(data,r,'lanczos3');
            end
        end
        function this = saveBoWIndex(this, saveName, fileName)
            imds = imageDatastore(char(this.filesR.path),'FileExtensions',{'.jpg','.png','.jpeg'});
            if length(imds.Files) > this.dSize
                imds.Files(this.dSize+1:end)=[];
            end
            load(fileName,'bag');
            saveImageIndex = indexImages(imds, bag);  %create BoF invert index using SURF features

            save(saveName,'saveImageIndex');
        end        
        function this = loadBoWIndex(this, fileName)
            load(fileName,'saveImageIndex');
            this.imageIndex = saveImageIndex;
        end
        function [match_candidates] = findMatches(this,currImageId,prev_match_candidates)
            Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
            Im = rgb2gray(Im);
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(1)),...
                this.initCrop(3):(szIm(2)-this.initCrop(3)),:);
            Im = imresize(Im,[this.HOG_resize(2) this.HOG_resize(1)],'lanczos3');
            
            match_candidates = retrieveImages(Im,this.imageIndex,'NumResults',this.N);
            %not sure how accurate this will be, with only 20,000 visual
            %words
        end
    end
end    



% function data = readDatastoreImage(filename)
% %READDATASTOREIMAGE Read file formats supported by IMREAD.
% %
% %   See also matlab.io.datastore.ImageDatastore, datastore,
% %            mapreduce.
% 
% %   Copyright 2016 The MathWorks, Inc.
% 
% % Turn off warning backtrace before calling imread
% onState = warning('off', 'backtrace');
% c = onCleanup(@() warning(onState));
% data = imread(filename);

