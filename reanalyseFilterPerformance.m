function reanalyseFilterPerformance()

    clear;
    close all;

    if ispc()
        addpath('G:/Documents/00_MATLAB/00_Soaring/Soaring_simulation');
    else
        addpath('/home/samuel/Personal/Kraus/03-Kraus/00_Soaring/Soaring_simulation');
    end

    if (0)
        [fname,fpath,filterIndex] = uigetfile({'*.log'; '*.mat'});

        if fname==0
            if (1)
                fpath = '/home/samuel/ArdupilotDev/ardupilot-tridge/ArduPlane';
                fname = 'log5.log';
            else
                fpath = '~/ExDocs/06_Data/Logs/WindyFF_Thermal_041014_onDIYD';
                fname = '2014-10-04 13-46-29.log';

                %fpath = 'G:/Documents/06_Data/Logs/WindyFF_Thermal_041014_onDIYD';
            end
            filterIndex = 1;
        end

        % Log file format
        Format.Time=1;
        Format.FilterInputs=2:4;
        Format.X=5:8;
        Format.Position=9:10;
        Format.Altitude=11;
        Format.Wind=12:13;

        fprintf('Opening %s\n', fullfile(fpath,fname))
        if (filterIndex==1)
            % Log file selected
            [Data.Soar,Data.GPS]=readLogFile(fullfile(fpath,fname),Format);
%             Data=mapFields(readLog(fullfile(fpath,fname)));
            save('Data.mat','Data')
        else
            % Mat file selected
            load(fullfile(fpath,fname));
        end
    else
        load('Data.mat');
    end
    
    firstGPSAlt = interp1(Data.GPS.Time,Data.GPS.Altitude,Data.Soar.Time(1));
    Data.GPS.Altitude = Data.GPS.Altitude - (firstGPSAlt-Data.Soar.Altitude(1));
    
    figure,plot(Data.GPS.Time,Data.GPS.Altitude);
    hold on;
    plot(Data.Soar.Time,Data.Soar.Altitude,'r.');
    xlabel('Time [s]'); ylabel('Altitude [m]');
    
    while 1

        [FlightData,flag]=selectIndividualThermal(Data.Soar);
        close(gcf);
        if flag==2
            break;
        end
        nT = numel(FlightData.Time);

        LineTypes = {'r','g','k','m','y','b'};

        % Should all inputs be corrected for wind?
        CorrectForWind = false;
        if isfield(FlightData,'WindDelta')
            CorrectForWind=NaN;
            while isnan(CorrectForWind)
                try
                    CorrectForWind = input('Remove wind influence? 0 / 1\n');
                catch
                end
            end
        end
        
        RunAnimation = input('Animate the encounter? 0/1\n');

        % Check the update rate.
        fprintf('Mean update rate: %f\n',mean(diff(FlightData.Time))*24*3600);
        
        % Input the filter settings, for both the flightdata and any experimental
        % filters.
%         FlightData.Q=diag([0.001^2,0.03^2,0.03^2,0.03^2]);
%         FlightData.R=0.45^2;
%         FlightData.Pinit=diag([0.000049,50^2,300,300]);
% %         FlightData.Pinit=diag([0.0049,50^2,300,300]);
        
        FlightData.Q=diag([0.001,0.5,0.03^2,0.03^2]);
        FlightData.Pinit=diag([1.0,2100,300,300]);
        FlightData.R = 0.45^2;
        
        SimData=cell(0,1);
%         SimData{1}.Q=diag([0.001,0.2,0.03^2,0.03^2]);
%         SimData{1}.R=0.45^2;
%         SimData{1}.Pinit=diag([1.0,2100,300,300]);
%         
%         % Setup for "Radian-Selkirk"
%         SimData{2}.Q=diag([0.001,0.5,0.03^2,0.03^2]);
%         SimData{2}.R=0.45^2;
%         SimData{2}.Pinit=diag([1.0,2100,300,300]);
        
        NFilters=numel(SimData);

        % Rerun the actual flight filter to get the covariance matrices etc.
        FlightData.Xinit = FlightData.X(1,:)';
        FlightData       = replayFilter(FlightData);

        for i=1:NFilters
            SimData{i}.FilterInputs     = FlightData.FilterInputs;
            SimData{i}.AircraftPosition = FlightData.AircraftPosition;
            SimData{i}.Xinit            = FlightData.X(1,:)';
            SimData{i}.Time             = FlightData.Time;
            SimData{i}.WindDelta        = FlightData.WindDelta;
            SimData{i}                  = replayFilter(SimData{i});

            if (CorrectForWind)
                SimData{i}.AircraftPosition = windCorrect(SimData{i},'AircraftPosition');
                SimData{i}.EstPosM          = windCorrect(SimData{i},'EstPosM');
            end
        end

        if (CorrectForWind)
            FlightData.AircraftPosition = windCorrect(FlightData,'AircraftPosition');
            FlightData.EstPosM          = windCorrect(FlightData,'EstPosM');
        end

        % Plot aircraft position
        figure;
        hold on;
        plot3(FlightData.EstPosM(:,1),FlightData.EstPosM(:,2),FlightData.Altitude,'b');

        % Plot measured updraft as colours
        av = mean( FlightData.FilterInputs(:,1));
        dev = std( FlightData.FilterInputs(:,1));
        clims =[0,av+2*dev];

        inputs_clipped = FlightData.FilterInputs(:,1);
        inputs_clipped(inputs_clipped>clims(2)) = clims(2);
        inputs_clipped(inputs_clipped<clims(1)) = clims(1);

        colours = (inputs_clipped-clims(1))/(clims(2)-clims(1));
        A=colormap('jet');
        set(gca,'CLim',clims);
        hc=colorbar;
        ht = get(hc,'Title');
        set(ht,'String','Netto rate m/s');
        for i=1:nT
            c=A(round(colours(i)*(size(A,1)-1))+1,:);
            plot3(FlightData.AircraftPosition(i,1),FlightData.AircraftPosition(i,2),FlightData.Altitude(i),'o','MarkerFaceColor',c,'MarkerEdgeColor',c);   % AC position
        end

        grid on;
        xlabel('East [m]');
        ylabel('North [m]');
        zlabel('Altitude [m]');
        axis equal;
        MapPlot = gca;

        set(gcf,'Position',[201 49 1201 948]);
        set(gca,'CameraPosition',[-224.4   -1476.7 1142.1]);
        
        
        % Add time labels.
%         idx = 1:100:length(FlightData.Time);
%         labels = arrayfun(@(x)datestr(x,'MM:SS'),FlightData.Time(idx)-FlightData.Time(1),'UniformOutput',false);
%         text(FlightData.AircraftPosition(idx,1),FlightData.AircraftPosition(idx,2),FlightData.Altitude(idx),labels);

        for i=1:NFilters
            % Plot track
            plot3(MapPlot,SimData{i}.EstPosM(:,1),SimData{i}.EstPosM(:,2),FlightData.Altitude(:),LineTypes{i});
            % Label end point
            text(SimData{i}.EstPosM(end,1),SimData{i}.EstPosM(end,2),sprintf('q %f r %f',SimData{i}.Q(1,1),SimData{i}.R(1,1)));
        end
        xlimall=get(gca,'XLim');
        ylimall=get(gca,'YLim');
        grid on; grid minor;
%         legend('Estimated position');

        %
        % Plot the state estimates
        %
        figure;

        Titles = {'Strength','Radius','North','East'};

        % Strength and radius
        leg = {'Logged','Replay'};
        for iState=1:2
            subplot(2,2,iState);
            hold on;
            plot(FlightData.Time,FlightData.X(:,iState),'b')
%             plot(FlightData.Time,FlightData.X_replay(:,iState),'r.')
            
            for i=1:NFilters
                plot(SimData{i}.Time,SimData{i}.X(:,iState),LineTypes{i});
                leg{end+1} = sprintf('Filter %i', i);
            end
            title(Titles{iState});grid on; grid minor;
            datetick('x');
        end
        legend(leg);
        
        % North and east
        Idx = [0,0,2,1];
        for iState=3:4
            subplot(2,2,iState);
            hold on;
            plot(FlightData.Time,FlightData.EstPosM(:,Idx(iState)),'b')
            for i=1:NFilters
                plot(FlightData.Time,SimData{i}.EstPosM(:,Idx(iState)),LineTypes{i})
            end
            title(Titles{iState});grid on; grid minor;
            datetick('x');
        end

        %
        % Plot auto-correlations of state estimates
        %
        figure;
        Titles = {'Pww','Prr','Pxx','Pyy'};
        for iState=1:4
            subplot(2,2,iState);
            hold on;
            plot(FlightData.Time,FlightData.P(:,iState,iState),'b')
            for i=1:NFilters
                plot(FlightData.Time,SimData{i}.P(:,iState,iState),LineTypes{i})
            end
            title(Titles{iState});grid on; grid minor;
            datetick('x');
        end


        figure; 
        subplot(2,2,1);
        plot(FlightData.Time,FlightData.X(:,3)/max(FlightData.X(:,3)))
        hold on
        plot(FlightData.Time,FlightData.FilterInputs(:,1),'r');
        title('Measurement and X position');grid on; grid minor;
        datetick('x');

        estdist = 20.0;%sqrt(FlightData.X(:,3).^2+FlightData.X(:,4).^2);
        thermalability = FlightData.X(:,1).*exp(-(estdist.^2)./(FlightData.X(:,2).^2)) - 0.7;

        %
        % Plot the estimated climb rate potential
        %
        subplot(2,2,2);
        plot(FlightData.Time-FlightData.Time(1),thermalability)
        hold on;
        for i=1:NFilters
            %estdist = sqrt(SimData{i}.X(:,3).^2+SimData{i}.X(:,4).^2);
            thermalability = SimData{i}.X(:,1).*exp(-(estdist.^2)./(SimData{i}.X(:,2).^2)) - 0.7;
            plot(FlightData.Time-FlightData.Time(1),thermalability,LineTypes{i})
        end
        title('Estimated thermalability');
        xlabel('Time (s)');
        ylabel('m/s');
        grid on; grid minor;
        datetick('x');

        subplot(2,2,3);
        plot(FlightData.Time,FlightData.residual);
        title('Residual');grid on; grid minor;
        datetick('x');
        
        subplot(2,2,4);
        plot(FlightData.Time,FlightData.FilterInputs(:,1));
        title('Vario input');grid on; grid minor;
        datetick('x');
        
        if (RunAnimation)
           limits = struct('x',xlimall,'y',ylimall,'c',clims);
           animateThermalEncounter(FlightData,SimData,LineTypes,colours,limits);
        end
    end
end