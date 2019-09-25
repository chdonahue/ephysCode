function ACC = createAccFile(fName,opts)
% This extracts accelerometer data from each experiment
% NOTE: need to define pitch/roll/etc. 
% CH Donahue 09.18.19

ts = opts.acc.res/1000; % downsample at 1ms resolution

dirName = [opts.rootDir,fName,'/'];
for axNum = 1:3
    accFile{axNum} = [dirName,'100_AUX',num2str(axNum),'.continuous'];
    [data, timestamps, info] = load_open_ephys_data(accFile{axNum});
    % DOWNSAMPLE TO 1ms:
    xVec = 0:ts:timestamps(end);
    accData(:,axNum) = interp1(timestamps,data,xVec);
end

% Save data:
ACC.fileName = fName;
ACC.opts = opts;
ACC.t = xVec';
ACC.data = accData; % accelerometer data
save([fName,'_acc'],'ACC')

