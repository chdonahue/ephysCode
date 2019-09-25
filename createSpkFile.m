function SPK = createSpkFile(fName,opts)
% This will spike-sorted data and put it into a SPK structure for further data analysis.
% dirName is the directory for each experiment (i.e. 'F:\testData\CD190819A_190917_01\') 
% CH Donahue 09.18.19
% NEXT: do average Waveform, Electrode number where most prominant, etc.

dirName = [opts.rootDir,fName,'/'];
spkTimeFile = [dirName,'spike_times.npy'];
spkClusterFile = [dirName,'spike_clusters.npy'];
clusterGroupFile = [dirName,'cluster_group.tsv'];
templateFile = [dirName,'templates.npy'];

% CREATE SPK STRUCTURE:
SPK.fileName = fName; % NOTE: fix later to be name from .csv file
SPK.opts = opts;

% Get spike times, clusters, and groups:
spikeSampleNum = readNPY(spkTimeFile); % THIS RETURNS SAMPLE NUMBER. 
clusterVec = readNPY(spkClusterFile); % Cluster ID for each spike
grp = tdfread(clusterGroupFile);
templates = readNPY(templateFile);


% GET ISOLATED NEURONS:
goodIdx = find(grp.group(:,1)=='g');
for nNum = 1:length(goodIdx)
    clusterID = grp.cluster_id(goodIdx(nNum));
    spkIdx = find(clusterVec==clusterID);
    SPK.neuron{nNum}.spikeTimes = double(spikeSampleNum(spkIdx))/opts.samplingRate;
    SPK.neuron{nNum}.template = squeeze(templates(clusterID+1,:,:));
    SPK.neuron{nNum}.electrode = find(max(abs(SPK.neuron{nNum}.template),[],1)==...
        max(max(abs(SPK.neuron{nNum}.template),[],1)));% Electrode ID where maximum deflection found
end

% GET MULTIUNIT ACTIVITY:
muaIdx = find(grp.group(:,1)=='m');
for nNum = 1:length(muaIdx)
    clusterID = grp.cluster_id(muaIdx(nNum));
    spkIdx = find(clusterVec==clusterID);
    SPK.mua{nNum}.spikeTimes = double(spikeSampleNum(spkIdx))/opts.samplingRate;
    SPK.mua{nNum}.template = squeeze(templates(clusterID+1,:,:));
    SPK.mua{nNum}.electrode = find(max(abs(SPK.mua{nNum}.template),[],1)==...
        max(max(abs(SPK.mua{nNum}.template),[],1)));% Electrode ID where maximum deflection found
end


% SAVE DATA:
save([fName,'_spikes'],'SPK')
