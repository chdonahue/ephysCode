function run_kilosort(fName,runKiloOps)
% This function will run kilsort based on parameters in the
% StandardConfig.m and channelMap.m files. Modify those as your experiments
% require. 
% runKiloOps contains all the local environment information:
    % runKiloOps.pathToKilosort (path to kilosort functions)
    % runKiloOps.pathToNpy (path to matlab NPY functions)
    % runKiloOps.pathToTaskData (path where directories for your experiment live)
    % runKiloOps.pathToYourConfigFile (path where standardConfig.m and
                % chanMap are)
% CH Donahue 09.18.19


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN KILOSORT:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run(fullfile(runKiloOps.pathToYourConfigFile, 'StandardConfig.m'))
ops.root = [runKiloOps.pathToTaskData,fName];
ops.fbinary = [runKiloOps.pathToTaskData,fName,'\',fName];
% Skip if already run:
if exist([ops.root,'\params.py'])
    disp(['KILSOSORT ALREADY EXISTS: ',fName])
    return;
end

disp(['RUNNING KILOSORT ON: ',fName])
tic; % start timer
%
if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

if strcmp(ops.datatype , 'openEphys')
   ops = convertOpenEphysToRawBInary(ops);  % convert data, only for OpenEphys
end
%
[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

% AutoMerge. rez2Phy will use for clusters the new 5th column of st3 if you run this)
%     rez = merge_posthoc2(rez);

% save matlab results file
save(fullfile(ops.root,  'rez.mat'), 'rez', '-v7.3');

% save python results file for Phy
rezToPhy(rez, ops.root);

% remove temporary file
fclose('all');
delete(ops.fproc);
    