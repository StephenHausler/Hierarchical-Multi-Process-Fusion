function [Qfol, Rfol, GT_file] = Load_Paths(Dataset, HPC, Win)
%LOAD_PATHS Summary of this function goes here
%   Detailed explanation goes here

if HPC == 1
    if strcmp(Dataset,'Nordland')
        Qfol = '/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_summer_cont';
        Rfol = '/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_winter_cont';
        GT_file = load('/home/n7542704/D_Drive_Backup/Windows/Nordland/Nordland_GPSMatrix.mat');
    elseif strcmp(Dataset,'Berlin')
%         Qfol = '/home/n7542704/Datasets/Berlin_Kudamm/Query_Test';
%         Rfol = '/home/n7542704/Datasets/Berlin_Kudamm/Reference_Test';
%         GT_file = load('/home/n7542704/Datasets/Berlin_Kudamm/Berlin_GPSMatrix_50meters_Test.mat');
%         Qfol = '/home/n7542704/Datasets/Berlin_Kudamm/Query';
%         Rfol = '/home/n7542704/Datasets/Berlin_Kudamm/Reference';
%         GT_file = load('/home/n7542704/Datasets/Berlin_Kudamm/Berlin_GPSMatrix_50meters.mat');
        Qfol = '/home/n7542704/Datasets/Berlin_Kudamm/Query_Test';
        Rfol = '/home/n7542704/Datasets/Berlin_Kudamm/Reference_Test';
        GT_file = load('/home/n7542704/Datasets/Berlin_Kudamm/Berlin_GPSMatrix_50meters_Test.mat');
    elseif strcmp(Dataset,'Qld')
        
        
    elseif strcmp(Dataset,'Oxford')
        
        
    end
else
    if Win == 1
        if strcmp(Dataset,'Nordland')
            Qfol = 'D:\Windows\Nordland\nordland_summer_cont';
            Rfol = 'D:\Windows\Nordland\nordland_winter_cont';
            GT_file = load('D:\Windows\Nordland\Nordland_GPSMatrix.mat');
        elseif strcmp(Dataset,'Berlin')
            Qfol = 'D:\Windows\Berlin_Kudamm\Query';
            Rfol = 'D:\Windows\Berlin_Kudamm\Reference';
            GT_file = load('D:\Windows\Berlin_Kudamm\Berlin_GPSMatrix_50meters.mat');       
        elseif strcmp(Dataset,'Qld')
            
        
        elseif strcmp(Dataset,'Oxford') 
          
            
        end
    else %Ubuntu
        if strcmp(Dataset,'Nordland')
            Qfol = '/media/stephen/Data/Windows/Nordland/nordland_summer_images';
            Rfol = '/media/stephen/Data/Windows/Nordland/nordland_winter_images';
            GT_file = load('/media/stephen/Data/Windows/Nordland/Nordland_GPSMatrix.mat');
        elseif strcmp(Dataset,'Berlin')
            Qfol = '/media/stephen/Data/Windows/Berlin_Kudamm/Query';
            Rfol = '/media/stephen/Data/Windows/Berlin_Kudamm/Reference';
            GT_file = load('/media/stephen/Data/Windows/Berlin_Kudamm/Berlin_Kudamm_GPSMatrix_3frames.mat');       
        elseif strcmp(Dataset,'Qld')
            
        
        elseif strcmp(Dataset,'Oxford') 
          
          
        end
    end
end
end


% if HPC == 1
%     if strcmp(Dataset,'Nordland')
%         Qfol = '/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_summer_images';
%         Rfol = '/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_winter_images';
%         GT_file = load('/home/n7542704/D_Drive_Backup/Windows/Nordland/Nordland_GPSMatrix.mat');
%     elseif strcmp(Dataset,'Berlin')
%         Qfol = '/home/n7542704/Datasets/Berlin_Kudamm/Query';
%         Rfol = '/home/n7542704/Datasets/Berlin_Kudamm/Reference';
%         GT_file = load('/home/n7542704/Datasets/Berlin_Kudamm/Berlin_GPSMatrix_50meters.mat');
%     elseif strcmp(Dataset,'Qld')
%         
%         
%     elseif strcmp(Dataset,'Oxford')
%         
%         
%     end
% else
%     if Win == 1
%         if strcmp(Dataset,'Nordland')
%             Qfol = 'D:\Windows\Nordland\nordland_summer_images';
%             Rfol = 'D:\Windows\Nordland\nordland_winter_images';
%             GT_file = load('D:\Windows\Nordland\Nordland_GPSMatrix.mat');
%         elseif strcmp(Dataset,'Berlin')
%             Qfol = 'D:\Windows\Berlin_Kudamm\Query';
%             Rfol = 'D:\Windows\Berlin_Kudamm\Reference';
%             GT_file = load('D:\Windows\Berlin_Kudamm\Berlin_GPSMatrix_50meters.mat');       
%         elseif strcmp(Dataset,'Qld')
%             
%         
%         elseif strcmp(Dataset,'Oxford') 
%           
%             
%         end
%     else %Ubuntu
%         if strcmp(Dataset,'Nordland')
%             Qfol = '/media/stephen/Data/Windows/Nordland/nordland_summer_images';
%             Rfol = '/media/stephen/Data/Windows/Nordland/nordland_winter_images';
%             GT_file = load('/media/stephen/Data/Windows/Nordland/Nordland_GPSMatrix.mat');
%         elseif strcmp(Dataset,'Berlin')
%             Qfol = '/media/stephen/Data/Windows/Berlin_Kudamm/Query';
%             Rfol = '/media/stephen/Data/Windows/Berlin_Kudamm/Reference';
%             GT_file = load('/media/stephen/Data/Windows/Berlin_Kudamm/Berlin_Kudamm_GPSMatrix_3frames.mat');       
%         elseif strcmp(Dataset,'Qld')
%             
%         
%         elseif strcmp(Dataset,'Oxford') 
%           
%           
%         end
%     end
% end
% end

