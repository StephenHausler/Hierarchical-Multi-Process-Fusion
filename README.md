# Hierarchical-Multi-Process-Fusion

This repository contains the source code for my ICRA 2020 paper (under review): Hierarchical Multi-Process Fusion.

Software Requirements:
1. MATLAB 2018a or later.
2. MATLAB Deep Learning Toolbox
3. importCaffeNetwork add-on
4. MatConvNet (installed)
5. NetVLAD
6. HybridNet pre-trained network
7. Only-Look-Once

Initial Setup Instructions:
1. Open Config.m and modify lines 63, 71 and 73 to point to the location of MatConvNet.
2. Open copyConstructor.m and modify the pre-defines as required and the maximum number of frames to run. 
3. Open Class_Files/ModuleNetVLAD.m and modify lines 15, 19 and 22 to point to NetVLAD and lines 16, 20 and 23 to point to MatConvNet.
4. Open Load_Paths and modify all paths to point to the datasets you wish to use. Qfol is the query images and Rfol contains the database images. 
5. Open Class_Files/ModuleOnlyLookOnce.m and modify lines 21, 22, 23, 31, 32, 33, 35, 36 and 37 to point to where you saved Only-Look-Once.
6. Open Multi_SLAM_Fusion.m and modify lines 13, 14, 17, 18, 20 and 21 to point to where you saved the HybridNet pre-trained network. 
7. Open the 'computePlaceRec' files and set those paths as desired for saving results and dataset choice. Then define the selection of methods to use and the number of candidates to pass between tiers. 

Initial Run Instructions:
1. Run computeAllFeats.m for the dataset you wish to use. Note: there are some extra features that were not included in the paper, to reduce the paper length and complexity. 
2. Then run computePlaceRec_1N_testset.m. Alternatively, create your own 'computePlaceRec' file following the structure in the other PlaceRec files.
