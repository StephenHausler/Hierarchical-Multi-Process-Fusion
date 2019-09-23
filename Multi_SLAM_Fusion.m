function Multi_SLAM_Fusion(experimentNumber, Dataset, saveFolder, methodStruct,...
    HPC, Win, GPUJob, debugMode, setID, w)

warning off

if setID == 1
    [Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win);
else
    [Qfol, Rfol, GT_file] = Load_Paths_TrainSet(Dataset, HPC, Win);
end

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

CAFFE_NETWORK = 1;
MATCONV_NETWORK = 2;

if ((HPC == 1) && (GPUJob == 1))
    gpuInfo = gpuDevice();  %clears any old data from HPC GPU from other users
    save('WhichGPU.mat','gpuInfo');  %used to verify the GPU HPC uses
end

%% Turn Modules On:

sz_Methods = size(methodStruct.Names);
method_counter = 0;

%note: this approach assumes each level has an equal number of methods in
%it.
for i = 1:sz_Methods(1)
    for j = 1:sz_Methods(2)
        method_counter = method_counter + 1;
        method_id(method_counter).Names = methodStruct.Names(i,j);
        method_id(method_counter).Level = i;
        method_id(method_counter).Number = j; 
    end
end

%create a 'dummy' class for evaluating ground truth
oDummy = ModuleSAD;
if debugMode == 0
    oDummy = copyConstructor(oDummy,Rfol,Qfol,GT_file);
else
    oDummy = copyConstructor_debugger(oDummy,Rfol,Qfol,GT_file);
end

for i = 1:method_counter
    switch method_id(i).Names
        case 1  %CNNHeat
            oCNNHeat = ModuleCNNHeat;
            oCNNHeat = loadNetwork(oCNNHeat,CAFFE_NETWORK,datafile,protofile,HPC,Win);
            oCNNHeat = copyConstructor(oCNNHeat,Rfol,Qfol,GT_file);
            oCNNHeat.setActLayer(15);
            oCNNHeat = setNumCandidates(oCNNHeat,methodStruct.NumCands(method_id(i).Level),method_id(i).Level);  
            oCNNHeat = loadDbaseTemplates(oCNNHeat, [Dataset '_CNNHeat_Dbase']);
            oCNNHeat = loadQueryTemplates(oCNNHeat, [Dataset '_CNNHeat_Query']);
        case 2  %SAD
            oSAD = ModuleSAD;
            oSAD = copyConstructor(oSAD,Rfol,Qfol,GT_file);
            oSAD = setNumCandidates(oSAD,methodStruct.NumCands(method_id(i).Level),method_id(i).Level);
            oSAD = loadDbaseTemplates(oSAD, [Dataset '_SAD_Dbase']);
            oSAD = loadQueryTemplates(oSAD, [Dataset '_SAD_Query']);
        case 3  %HOG
            oHOG = ModuleHOG;
            oHOG = copyConstructor(oHOG,Rfol,Qfol,GT_file);
            oHOG = setNumCandidates(oHOG,methodStruct.NumCands(method_id(i).Level),method_id(i).Level);
            oHOG = loadDbaseTemplates(oHOG, [Dataset '_HOG_Dbase']);
            oHOG = loadQueryTemplates(oHOG, [Dataset '_HOG_Query']);
        case 4  %ORB - TODO
            oORB = ModuleORB;
            oORB = copyConstructor(oORB,Rfol,Qfol,GT_file);
            oORB = init(oORB, HPC, Win);
            oORB = setNumCandidates(oORB,pyrstruct(1)*numMethodsPerLayer,pyrstruct(2),2);
            oORB = loadDbaseTemplates(oORB, [Dataset '_ORB_Feats']);
        case 5  %SURF
            oSURF = ModuleSURF;
            oSURF = copyConstructor(oSURF,Rfol,Qfol,GT_file);
            oSURF = setNumCandidates(oSURF,methodStruct.NumCands(method_id(i).Level),method_id(i).Level);
            oSURF = loadDbaseTemplates(oSURF, [Dataset '_SURF_Dbase']);
            oSURF = loadQueryTemplates(oSURF, [Dataset '_SURF_Query']);
        case 6  %NetVLAD
            oNetVLAD = ModuleNetVLAD;
            oNetVLAD = init(oNetVLAD,'Nord',HPC,Win);
            oNetVLAD = copyConstructor(oNetVLAD,Rfol,Qfol,GT_file);
            oNetVLAD = setNumCandidates(oNetVLAD,methodStruct.NumCands(method_id(i).Level),method_id(i).Level);
            oNetVLAD = loadDbaseTemplates(oNetVLAD, [Dataset '_NetVLAD_Dbase']);
            oNetVLAD = loadQueryTemplates(oNetVLAD, [Dataset '_NetVLAD_Query']);
        case 7  %CNNWhole
            oCNNWhole = ModuleCNNWhole;
            oCNNWhole = loadNetwork(oCNNWhole,CAFFE_NETWORK,datafile,protofile,HPC,Win);
            oCNNWhole = copyConstructor(oCNNWhole,Rfol,Qfol,GT_file);
            oCNNWhole.setActLayer(15);
            oCNNWhole = setNumCandidates(oCNNWhole,methodStruct.NumCands(method_id(i).Level),method_id(i).Level);
            oCNNWhole = loadDbaseTemplates(oCNNWhole, [Dataset '_CNNWhole_Dbase']);
            oCNNWhole = loadQueryTemplates(oCNNWhole, [Dataset '_CNNWhole_Query']);
        case 8  %BoW - TODO
            oBoW = ModuleBoW;
            oBoW = copyConstructor(oBoW,Rfol,Qfol,GT_file);
            oBoW = setNumCandidates(oBoW,NaN,pyrstruct(1),1);
            oBoW = createBoWIndex(oBoW, 1); %object, load option
        case 9  %KAZE
            oKAZE = ModuleKAZE;
            oKAZE = copyConstructor(oKAZE,Rfol,Qfol,GT_file);
            oKAZE = setNumCandidates(oKAZE,methodStruct.NumCands(method_id(i).Level),method_id(i).Level);
            oKAZE = loadDbaseTemplates(oKAZE, [Dataset '_KAZE_Dbase']);
            oKAZE = loadQueryTemplates(oKAZE, [Dataset '_KAZE_Query']);
        case 10  %OLO
            oOLO = ModuleOnlyLookOnce;
            oOLO = copyConstructor(oOLO,Rfol,Qfol,GT_file);
            oOLO = init(oOLO,HPC,Win);
            oOLO = loadNetwork(oOLO,MATCONV_NETWORK,1,1,HPC,Win);
            oOLO = setNumCandidates(oOLO,methodStruct.NumCands(method_id(i).Level),method_id(i).Level);
            oOLO = loadDbaseTemplates(oOLO, [Dataset '_OLO_Dbase']);
            oOLO = loadQueryTemplates(oOLO, [Dataset '_OLO_Query']);
        case 11  %Gist
            oGist = ModuleGist;
            oGist = copyConstructor(oGist,Rfol,Qfol,GT_file);
            oGist = init(oGist, HPC, Win);
            oGist = setNumCandidates(oGist,methodStruct.NumCands(method_id(i).Level),method_id(i).Level);
            oGist = loadDbaseTemplates(oGist, [Dataset '_Gist_Dbase']);
            oGist = loadQueryTemplates(oGist, [Dataset '_Gist_Query']);
    end
end

%% Run Query Traverse:
thresh = 0:0.5:50;

recall_count_by_level = zeros(1,sz_Methods(1));
recall_top1_by_level = zeros(1,sz_Methods(1));
recall_count_final = 0;

true_pos = zeros(1,length(thresh));
false_pos = zeros(1,length(thresh));
true_neg = zeros(1,length(thresh));
false_neg = zeros(1,length(thresh));

prev_match = 0;

te = zeros(1,sz_Methods(1));
tic

%Loop through each query image
for i = 1:oDummy.qSize
    for j = 1:sz_Methods(1)  %for each level
        t1 = tic;
        for k = 1:sz_Methods(2)   %for each method in each level
            if j == 1
                switch methodStruct.Names(j,k)
                    case 1
                        D{k} = findDifference(oCNNHeat,i,NaN);
                    case 2    
                        D{k} = findDifference(oSAD,i,NaN);
                    case 3
                        D{k} = findDifference(oHOG,i,NaN);
                    case 4
                        D{k} = findDifference(oORB,i,NaN);
                    case 5
                        D{k} = findDifference(oSURF,i,NaN);
                    case 6
                        D{k} = findDifference(oNetVLAD,i,NaN);
                    case 7
                        D{k} = findDifference(oCNNWhole,i,NaN);
                    case 8
                        D{k} = findDifference(oBoW,i,NaN);
                    case 9
                        D{k} = findDifference(oKAZE,i,NaN);
                    case 10
                        D{k} = findDifference(oOLO,i,NaN);
                    case 11
                        D{k} = findDifference(oGist,i,NaN);
                end
            else
                switch methodStruct.Names(j,k)
                    case 1
                        D{k} = findDifference(oCNNHeat,i,candidates);
                    case 2
                        D{k} = findDifference(oSAD,i,candidates);
                    case 3
                        D{k} = findDifference(oHOG,i,candidates);
                    case 4
                        D{k} = findDifference(oORB,i,candidates);
                    case 5
                        D{k} = findDifference(oSURF,i,candidates);
                    case 6
                        D{k} = findDifference(oNetVLAD,i,candidates);
                    case 7
                        D{k} = findDifference(oCNNWhole,i,candidates);
                    case 8
                        D{k} = findDifference(oBoW,i,candidates);
                    case 9
                        D{k} = findDifference(oKAZE,i,candidates);
                    case 10
                        D{k} = findDifference(oOLO,i,candidates);
                    case 11
                        D{k} = findDifference(oGist,i,candidates);
                end
            end    
        end
        
        %check if at final level, if so, add/multiply difference scores
        %together
        
        %else, evaluate each method individually and use the union of the
        %candidates as the set to send to the next level.
        
        %at the end, re-normalise the difference scores in each level, using the top 10
        %candidates from the final level. (so 0.9-1 becomes 0-1).
        
        if j == sz_Methods(1)
            D_combined = D{1};
            if sz_Methods(2) > 1
                for k = 2:sz_Methods(2)
                    D_combined = D_combined + D{k}; %in final level, add the scores together
                end
            end   
            D_combined = D_combined ./ sz_Methods(2); %then average
            for k = 1:sz_Methods(2)
                D_level{j,k} = D{k};
            end
                        
            clear candidates;
            candidates = NaN(methodStruct.NumCands(j),1);
            for n = 1:methodStruct.NumCands(j)
                [~,candidates(n)] = max(D_combined);
                D_combined(candidates(n)) = NaN;
            end
            C_level{j} = candidates;
            clear D;
            %this final level needs to use methods that can moderately
            %handle both viewpoint and condition variations.
        else
            D_c = D;
            candidates = [];
            clear init_candidates;
            for k = 1:sz_Methods(2)                
                for n = 1:methodStruct.NumCands(j)
                    [~,init_candidates(n)] = max(D_c{k});
                    D_c{k}(init_candidates(n)) = NaN;
                end
                candidates = [candidates init_candidates]; %union of candidates
            end
            for k = 1:sz_Methods(2)
                D_level{j,k} = D{k};
            end
            C_level{j} = candidates;
            clear D;
        end
        
        te(j) = te(j) + toc(t1);
        
    end
    %end of the levels
    %now fuse together D scores from multiple levels
    
    %use the candidates fed into the final level to decide which diff
    %scores to use.
    finalLevelCands = C_level{(sz_Methods(1) - 1)}; %grab list of cands for sum
    
    for j = 1:sz_Methods(1)
        switch sz_Methods(2)
            case 1
                D_level2{j} = D_level{j,1};
                D_level3{j} = D_level{j,1};
            case 2
                if j == sz_Methods(1)
                    D_level2{j} = (D_level{j,1}+D_level{j,2})./2; %sum because final layer
                    D_level3{j} = (D_level{j,1}+D_level{j,2})./2;
                else    
                    D_level2{j} = max([D_level{j,1};D_level{j,2}],[],1); %max because union
                    D_level3{j} = (D_level{j,1}+D_level{j,2})./2;
                end
            case 3    
                if j == sz_Methods(1)
                    D_level2{j} = (D_level{j,1}+D_level{j,2}+D_level{j,3})./3;
                    D_level3{j} = (D_level{j,1}+D_level{j,2}+D_level{j,3})./3;
                else
                    D_level2{j} = max([D_level{j,1};D_level{j,2};D_level{j,3}],[],1); 
                    D_level3{j} = (D_level{j,1}+D_level{j,2}+D_level{j,3})./3;
                end
        end
    end
        
    for j = 1:sz_Methods(1)
            
        diffs{j} = D_level2{j}(finalLevelCands);
            
    end
    
    %now re-normalise everything to 0-1 * level weight factor
    for j = 1:sz_Methods(1)
        D_ma = max(diffs{j});
        D_mi = min(diffs{j});
        D_d = D_ma - D_mi;
        D_t = diffs{j} - D_mi;
        D_t = D_t ./ D_d;
        diffsNorm{j} = D_t .* w(j);
    end
    
    D_super = diffsNorm{1};
    for j = 2:sz_Methods(1)
        D_super = D_super + diffsNorm{j};
    end
    
    D_super = zscore(D_super);
    
    clear candidates;
    clear init_candidates;
    clear quality;
    
    [quality,init_candidates] = max(D_super);

    candidates = finalLevelCands(init_candidates);    
%%
    %at this point, should have a single candidate and a single quality
    %score.
    recall_binary = evalMatches(oDummy,i,candidates);
    if recall_binary == 1  %true match
        recall_count_final = recall_count_final + 1;
        for t = 1:length(thresh) %quality score thresholds for PR curve
            if quality > thresh(t) 
                true_pos(t) = true_pos(t) + 1;
            else
                false_neg(t) = false_neg(t) + 1;
            end
        end
    else  %false match
        for t = 1:length(thresh) %quality score thresholds for PR curve
            if quality > thresh(t)
                false_pos(t) = false_pos(t) + 1;
            else
                false_neg(t) = false_neg(t) + 1; 
            end
        end
    end        
    for j = 1:sz_Methods(1)  %for each level, evaluate recall rate
        [recall_binary, pos] = evalMatches(oDummy,i,C_level{j});
        if recall_binary == 1
            recall_count_by_level(j) = recall_count_by_level(j) + 1;
            position_of_recall(i,j) = pos;
        else
            position_of_recall(i,j) = NaN;
        end    
        [~,recallbylevelcandidatetop1] = max(D_level3{j});
        [recall_binary, ~] = evalMatches(oDummy,i,recallbylevelcandidatetop1);
        if recall_binary == 1
            recall_top1_by_level(j) = recall_top1_by_level(j) + 1;
        else

        end    
    end    
    
end
elapsedTime = toc;
numFrames = oDummy.qSize;
recall_final = recall_count_final/numFrames;
for j = 1:sz_Methods(1)
    recall_by_level(j) = recall_count_by_level(j)/numFrames;
    recall_top1_by_level(j) = recall_top1_by_level(j)/numFrames;
end
for t = 1:length(thresh)
    Precision(t) = true_pos(t) / (true_pos(t) + false_pos(t));
    Recall(t) = true_pos(t) / (true_pos(t) + false_neg(t));
    F1score(t) = 2*true_pos(t) / (2*true_pos(t) + false_pos(t) + false_neg(t));
end 

Precision(isnan(Precision)) = [];
Precision = [Precision 1];
Recall(length(Precision)+1:end) = [];
Precision = fliplr(Precision);
Recall = fliplr(Recall);
if (length(Recall) ~= length(Precision))
    Recall = [0 Recall];
end
AUC = trapz(Recall,Precision);

maxF1Score = max(F1score);

save([saveFolder Dataset '_Exp' num2str(experimentNumber) '.mat'],'methodStruct','recall_final','recall_by_level',...
    'numFrames','true_pos','false_pos','false_neg','Precision','Recall','position_of_recall',...
    'maxF1Score','AUC','elapsedTime','te','recall_top1_by_level');
end


