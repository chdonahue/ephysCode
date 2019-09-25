% batch_extractEphys.m
% Batch processes ephys data. Loops through .csv file and extracts
% spike data (eventually, waveform, LFP) for each
% spike-sorted dataset.
% CH Donahue 09.18.19

clear variables;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET EXPERIMENT SPECIFIC OPTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Experiment-wide options/settings:
opts.rootDir = '/Volumes/KreitzerLab/Chris/DA_PROJECT/rawData/ephys_DA/'; % root directory where all the experiments live 
opts.samplingRate = 30000; % 30kHz (should probably take this from metadata somehwere)

% Accelerometer options:
opts.acc.res = 1; % downsample accelerometer at 1ms resolution

% Hardware Sync Port setup:
opts.sync.optoChan = 1; % Laser sends TTL to port 1
opts.sync.syncChan = 2; % Task Sync from statescript to port 2
opts.sync.camChan = 3; % Basler TTL sync to port 3

% optoID options:
opts.optoID.window = [-200 500]; % spikes to save relative to each pulse


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOOP THROUGH MATCHING BLOCKS DATA:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getExpData;
for fNum = 1:size(EPHY_Data{3},1)
    fName = regexprep(EPHY_Data{3}{fNum},'_matchingBlocks(\w*)','');
    
    
    % if doesn't exist, process these:
    SPK = createSpkFile(fName,opts);
    ACC = createAccFile(fName,opts);
    SYN = createSyncFile(fName,opts);
    

    % TODO: WAVEFORM for all, LFP
    
end


