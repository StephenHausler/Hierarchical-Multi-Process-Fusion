function this = copyConstructor(this,Rfol,Qfol,GT_file)
    this = SetupPreDefines(this,'frameSkip',1,'sadResize',[64 32],'initCrop',...
        [1 1 1 1],'hogResize',[300 300],'hogCellSize',[30 30]);
    this = loadImages(this,Rfol,Qfol,1000); %final optional input: limit number of frames
    this = loadGTFile(this,GT_file);
end
%limit to 1000 for the test set to speed-up the time to run KAZE.
%remove 300 when finished bug finding.