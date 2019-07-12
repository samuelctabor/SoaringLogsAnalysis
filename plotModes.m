function [outputArg1,outputArg2] = plotModes(ax,log)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    log = populateModeNames(log);

    xl = get(ax,'XLim');
    yl = get(ax,'YLim');
    
    if isempty(log.MODE.TimeS)
        % No mode information.
        return;
    end
    
    time = [log.MODE.TimeS; xl(2)];
    modeNum = [log.MODE.ModeNum; log.MODE.ModeNum(end)];
    modeName = [log.MODE.ModeName, log.MODE.ModeName(end)];

    [time,iA] = unique(time);
    modeNum = modeNum(iA);
    modeName = modeName(iA);

    hold on;

    [modeNums, iA, iC] = unique(modeNum);
    colors = get(ax,'ColorOrder');
    colors = repmat(colors,10,1);

    yl = yl([1,2,2,1]);

    nP = size(time,1)-1;
    for iT=1:nP
        hP(iT) = patch(time([iT,iT,iT+1,iT+1]), yl, colors(iC(iT),:),'FaceAlpha',0.2,'EdgeColor',[0.3,0.3,0.3]);
    end

    ch = get(ax,'Children');
    nL = length(ch)-nP;
    set(ax,'Children',ch([end-nL:end,1:nP]));

    legend(hP(iA),modeName{iA},'Interpreter','none');
end

