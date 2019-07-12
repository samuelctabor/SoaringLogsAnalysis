function [outputArg1,outputArg2] = plotGraph(Log, fields, plotModes, plotParams, plotEvents, ax)
%plotGraph Plots fields from a log file, specified in MAVExplorer-like
%syntax.

    createAxes = false;
    
    if ischar(fields)
        fields = {fields};
    end
    
    if nargin<3 || isempty(plotModes)
        plotModes = true;
    end
    if nargin<4 || isempty(plotParams)
        plotParams = true;
    end
    if nargin<5 || isempty(plotEvents)
        plotEvents = true;
    end
    
    if nargin<6 || isempty(ax) 
        createAxes = true;
    end

    % Extract value vectors and evaluate functions (eventually)
    lines = struct('plotOnAxis',1,'values',0,'TimeS',0,'axis',0);

    lines = repmat(lines,1,length(fields));
    
    for iF=1:length(fields)
        
        % Unpack subfields
        subfields = strsplit(fields{iF},{'.',':'});
        
        % Identify any that are to be plotted on 2nd axis
        idx = ~isnan(str2double(subfields));
        if any(idx)
            lines(iF).plotOnAxis = str2double(subfields{idx});
            subfields = subfields(~idx);
        end
        
        switch length(subfields)
            case 1
                lines(iF).values = Log.(subfields{1});
                lines(iF).TimeS = Log.TimeS;
            case 2
                lines(iF).values = Log.(subfields{1}).(subfields{2});
                lines(iF).TimeS = Log.(subfields{1}).TimeS;
            case 3
                lines(iF).values = Log.(subfields{1}).(subfields{2}).(subfields{3});
                lines(iF).TimeS = Log.(subfields{1}).(subfields{2}).TimeS;
        end
        

        % Detect outliers.
%         while 1
%             idx = diff(lines(iF).TimeS)<-1;
%             if any(idx)
%                 lines(iF).TimeS = lines(iF).TimeS([~idx;true]);
%                 lines(iF).values = lines(iF).values([~idx;true]);
%             else
%                 break;
%             end
%         end
    end
    
    % Assign an axis handle to each line.
    if createAxes
        figure;
        nSubplots = max([lines.plotOnAxis]);
        
        if nSubplots>3
            nCols = 2;
        else
            nCols = 1;
        end
        nRows = ceil(nSubplots/nCols);
        
        for iSP=1:nSubplots
            ax(iSP) = subplot(nRows, nCols, iSP);
            
            grid(ax(iSP), 'on');
            grid(ax(iSP), 'minor');
            hold(ax(iSP), 'on')
            
            idx = find([lines.plotOnAxis]==iSP);
            
            for i=1:length(idx)
                iL = idx(i);
                lines(iL).axis = gca;
                plot(lines(iL).axis,lines(iL).TimeS, lines(iL).values,'LineStyle','-','Marker','.');
            end
            
            xlabel('Time [s]');
            
            % Plot parameter change events.
            if plotParams
                for iP=1:length(Log.PARM.Time)
                    if Log.PARM.Time(iP)>60
                        yl = get(ax(iSP),'YLim');
                        plot(ax(iSP), Log.PARM.Time(iP)*[1,1],yl,'r--');
                        text(ax(iSP), Log.PARM.Time(iP), yl(1),sprintf('%s=%3.1f', Log.PARM.Name(iP), Log.PARM.Value(iP)),'Rotation',90,'Interpreter','none');
                    end
                end
            end
            
            % Plot mode change events.
            if plotModes
                for iP=1:length(Log.MODE.Time)
                    yl = get(ax(iSP),'YLim');
                    plot(ax(iSP), Log.MODE.Time(iP)*[1,1],yl,'r--');
                    text(ax(iSP), Log.MODE.Time(iP), yl(1), Log.MODE.ModeName{iP},'Rotation',90,'Interpreter','none');
                end
            end
            
            
            if length(idx)>1
                legend(fields(idx));
                ylabel('Value');
            else
                ylabel(fields(idx));
            end
        end
    else
        lines.axis = ax;
    end
       
    linkaxes(ax,'x');
    

end

