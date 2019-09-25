function SYN = createSyncFile(fName,opts)
% This extracts sync data from each experiment
% CH Donahue 09.18.19

dirName = [opts.rootDir,fName,'/'];
eventFile = [dirName,'all_channels.events'];
% Initialize:
SYN.syncTimes = [];
SYN.camTimes = [];
SYN.optoTimes = [];
SYN.lasDur = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET EVENT TIMESTAMPS:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[data, timestamps, info] = load_open_ephys_data(eventFile);
data = data+1; % correct for numbering offset
% Get sync signal indicies:
syncIdx = find(data==opts.sync.syncChan & info.eventId==1); % indicies where TTL was sent (went high)
camIdx = find(data==opts.sync.camChan & info.eventId==1);
optoIdx = find(data==opts.sync.optoChan & info.eventId==1);
optoOffIdx = find(data==opts.sync.optoChan & info.eventId==0);

% Save data:
SYN.fileName = fName;
SYN.opts = opts;
SYN.syncTimes = timestamps(syncIdx);
SYN.camTimes = timestamps(camIdx);
SYN.optoTimes = timestamps(optoIdx);
SYN.lasDur = round((nanmedian(timestamps(optoOffIdx)-timestamps(optoIdx)))*1000); % in ms
save([fName,'_sync'],'SYN')

