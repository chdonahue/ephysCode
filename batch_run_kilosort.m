% batch_run_kilosort.m
% This script will batch-process kilosort on the list of files contained in the .csv
% files called in getExpData.m. Will need to customize local environment
% and getExpData.m. Open up standardConfig.m and make sure has all options that you
% want (I have not explored these and am using defaults for most). 
% NOTE: Data directories need the following naming convention:
% AnName_Date_Session
% CH Donahue 09.18.19

clear variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET UP LOCAL ENVIRONMENT:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runKiloOps.pathToKilosort = 'C:\Users\KreitzerLab\Documents\MATLAB\KiloSort-master'; % path to kilosort folder
runKiloOps.pathToNpy = 'C:\Users\KreitzerLab\Documents\MATLAB\npy-matlab-master'; % path to npy-matlab scripts
runKiloOps.pathToLocalData = 'F:\';
runKiloOps.pathToTaskData = 'F:\testData\'; % where all the data directories live for this experiment
runKiloOps.pathToYourConfigFile = 'F:\configFiles'; % All config files for each experiment will go here (chanMap.mat and StandardConfig.m (with all kilosort settings)
addpath(genpath(runKiloOps.pathToKilosort)); 
addpath(genpath(runKiloOps.pathToNpy)); 
addpath(genpath(runKiloOps.pathToLocalData)) % path to local data storage


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOOP THROUGH MATCHING BLOCK FILES AND RUN KILOSORT:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getExpData;
for fNum = 1:size(EXP_Data{3},1)
    fName = regexprep(EXP_Data{3}{fNum},'_matchingBlocks(\w*)','');
    run_kilosort(fName,runKiloOps);
end




