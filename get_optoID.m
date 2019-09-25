function optoID = get_optoID(SYN,SPK,opts)
% Plots and creates optoID vector for all optoID'd neurons
% CH Donahue 09.25.19
% TBD: use waveform data and do stats based on Cohen/Uchida

% OPTIONS: 
% opts.plot_window = [-200 500]; % 
% opts.plot = 1; % 1 to plot, 0 not to
% opts.anWin = [0 20]; % 20ms window after laser onset
% opts.baseWin = [-100 0]; % 100ms prior to laser
% opts.gFilter = 20; % ms  = 1 std


% Check for fileName Identity
if SPK.fileName~=SYN.fileName
    error('FileName mismatch!')
end



spkWindow = opts.plot_window/1000;
gStd = opts.gFilter;
a = 1:round(gStd)*10;
hlen_a = length(a)/2;
Gfilter = normpdf(a,hlen_a,gStd)*1000;
sdfVec = opts.plot_window(1)-500:opts.plot_window(2)+500; % 
% Loop through neurons:
for nNum = 1:size(SPK.neuron,2)
    for lasNum= 1:size(SYN.optoTimes) % loop through each pulse
        stWin = SYN.optoTimes(lasNum)+spkWindow(1)-.5; % padded with 500ms 
        edWin = SYN.optoTimes(lasNum)+spkWindow(2)+.5;
        idx = find(SPK.neuron{nNum}.spikeTimes>=stWin & ...
            SPK.neuron{nNum}.spikeTimes<=edWin);
        spkTimes{nNum}{lasNum} = (SPK.neuron{nNum}.spikeTimes(idx) - SYN.optoTimes(lasNum))*1000;
        
        % info for stats: (in firing rates)
        stats{nNum}(lasNum,1) = length(find(spkTimes{nNum}{lasNum}>opts.baseWin(1) & ...
            spkTimes{nNum}{lasNum}<=opts.baseWin(2)))*(1000/(opts.baseWin(2)-opts.baseWin(1)));
        stats{nNum}(lasNum,2) = length(find(spkTimes{nNum}{lasNum}>opts.anWin(1) & ...
            spkTimes{nNum}{lasNum}<=opts.anWin(2)))*(1000/(opts.anWin(2)-opts.anWin(1)));
        
        
        
        % make SDF:
        v = zeros(size(sdfVec));
        spkVecIdx = find(ismember(sdfVec,round(spkTimes{nNum}{lasNum})));
        v(spkVecIdx) = 1;
        c = conv(v,Gfilter,'same');
        convMtx{nNum}(lasNum,:) = c;
        
        
    end
    [hT(nNum) pT(nNum)] = ttest2(stats{nNum}(:,1),stats{nNum}(:,2),'tail','left'); % Las>baseline 1-tailed
    
end
optoID = hT;

% Loop through MUA:
for nNum = 1:size(SPK.mua,2)
    for lasNum= 1:size(SYN.optoTimes) % loop through each pulse
        stWin = SYN.optoTimes(lasNum)+spkWindow(1)-.5; % padded with 500ms 
        edWin = SYN.optoTimes(lasNum)+spkWindow(2)+.5;
        idx = find(SPK.mua{nNum}.spikeTimes>=stWin & ...
            SPK.mua{nNum}.spikeTimes<=edWin);
        spkTimes_mua{nNum}{lasNum} = (SPK.mua{nNum}.spikeTimes(idx) - SYN.optoTimes(lasNum))*1000;
        
        % info for stats: (in firing rates)
        stats_mua{nNum}(lasNum,1) = length(find(spkTimes_mua{nNum}{lasNum}>opts.baseWin(1) & ...
            spkTimes_mua{nNum}{lasNum}<=opts.baseWin(2)))*(1000/(opts.baseWin(2)-opts.baseWin(1)));
        stats_mua{nNum}(lasNum,2) = length(find(spkTimes_mua{nNum}{lasNum}>opts.anWin(1) & ...
            spkTimes_mua{nNum}{lasNum}<=opts.anWin(2)))*(1000/(opts.anWin(2)-opts.anWin(1)));
        
        % make SDF:
        v = zeros(size(sdfVec));
        spkVecIdx = find(ismember(sdfVec,round(spkTimes_mua{nNum}{lasNum})));
        v(spkVecIdx) = 1;
        c = conv(v,Gfilter,'same');
        convMtx_mua{nNum}(lasNum,:) = c;
        
        
    end
    [hT_mua(nNum) pT_mua(nNum)] = ttest2(stats_mua{nNum}(:,1),stats_mua{nNum}(:,2),'tail','left');

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE POSTSCRIPT PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
if opts.plot==1
    numNeurons = size(SPK.neuron,2);
    numPages = ceil(numNeurons/20);
    posX = [ones(5,1); ones(5,1)*5]; % position of 10 plots per page
    posY = repmat([9:-2:1]',2,1);
    posX = repmat(posX,numPages,1); % repeat for multi-page)
    posY = repmat(posY,numPages,1); 


    ps = Postscript;
    ps = ps.open([SPK.fileName,'_optoID.ps']);
    ps.setfont('Arial',6);

    
    h.dim = [.75 1];
    h.xRange = opts.plot_window; 
    h.data{1}.color = [0 0 0];
    h.spkW = .015;
    h.labelFontSize = 6;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % LOOP THROUGH NEURONS:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    ps.textc(4.25,10.5,[SPK.fileName,'_optoID-Neurons [',num2str(opts.anWin(1)),...
        '-',num2str(opts.anWin(2)),'ms]']);
    for nNum = 1:size(SPK.neuron,2)        
        ps.text(posX(nNum)-.5,posY(nNum)+.5,['N',num2str(nNum),':'])    
        if hT(nNum)==1
            ps.setcolor([1 0 0]);
        end
        ps.text(posX(nNum)+2,posY(nNum)+.5,['p = ',num2str(pT(nNum),'%1.2f')])
        ps.setcolor([0 0 0]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Rasters:
        p = h;
        p.shift = [posX(nNum) posY(nNum)];
        p.line{1}.color = [1 0 0];
        p.line{1}.data = [0 0 0 1];
        for lasNum = 1:size(SYN.optoTimes,1)
            p.data{1}.x{lasNum} = spkTimes{nNum}{lasNum};
        end
        plot_raster_ps(p,ps);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        p = h;
        p.shift = [posX(nNum)+1 posY(nNum)];
        % INCLUDE LASER WINDOW
        p.data{1}.x = sdfVec;
        p.data{1}.y = nanmean(convMtx{nNum});
        p.data{1}.sem = nanstd(convMtx{nNum})./sqrt(size(SYN.optoTimes,1));
        mxPlot = ceil(max(p.data{1}.y+p.data{1}.sem)/5)*5;
        p.line{1}.color = [1 0 0];
        p.line{1}.data = [0 0 0 mxPlot];
        p.background{1}.data = [0 0 SYN.lasDur mxPlot];
        p.background{1}.color = [1 .8 .8];
        p.yRange = [0 mxPlot];
        p.xtick = -200:200:600;
        for i = 1:length(p.xtick)
            p.xtickLabel{i} = num2str(p.xtick(i),'%1.0f');
        end
        p.ytick = mxPlot;
        p.ytickLabel{1} = num2str(mxPlot,'%1.0f');

        plot_trace_ps(p,ps);
        
        if mod(nNum,10)==0
            ps.nextpage();
            ps.setfont('Arial',6);
            ps.textc(4.25,10.5,[SPK.fileName,'_optoID-Neurons'])
        end
        
        
    end
    
    ps.nextpage();
    ps.setfont('Arial',6);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % LOOP THROUGH MUA:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    ps.textc(4.25,10.5,[SPK.fileName,'_optoID-MUA'])
    for nNum = 1:size(SPK.mua,2)
        
        ps.text(posX(nNum)-.5,posY(nNum)+.5,['N',num2str(nNum),':'])
        if hT_mua(nNum)==1
            ps.setcolor([1 0 0]);
        end
        ps.text(posX(nNum)+2,posY(nNum)+.5,['p = ',num2str(pT_mua(nNum),'%1.2f')])
        ps.setcolor([0 0 0]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Rasters:
        p = h;
        p.shift = [posX(nNum) posY(nNum)];
        p.line{1}.color = [1 0 0];
        p.line{1}.data = [0 0 0 1];
        for lasNum = 1:size(SYN.optoTimes,1)
            p.data{1}.x{lasNum} = spkTimes_mua{nNum}{lasNum};
        end
        plot_raster_ps(p,ps);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        p = h;
        p.shift = [posX(nNum)+1 posY(nNum)];
        % INCLUDE LASER WINDOW
        p.data{1}.x = sdfVec;
        p.data{1}.y = nanmean(convMtx_mua{nNum});
        p.data{1}.sem = nanstd(convMtx_mua{nNum})./sqrt(size(SYN.optoTimes,1));
        mxPlot = ceil(max(p.data{1}.y+p.data{1}.sem)/5)*5;
        p.line{1}.color = [1 0 0];
        p.line{1}.data = [0 0 0 mxPlot];
        p.background{1}.data = [0 0 SYN.lasDur mxPlot];
        p.background{1}.color = [1 .8 .8];
        p.yRange = [0 mxPlot];
        p.ytick = mxPlot;
        p.ytickLabel{1} = num2str(mxPlot,'%1.0f');

        plot_trace_ps(p,ps);
        
        % Move to next page if 
        if mod(nNum,10)==0
            ps.nextpage();
            ps.textc(4.25,10.5,[SPK.fileName,'_optoID-MUA'])
        end
        
    end
end
%%

