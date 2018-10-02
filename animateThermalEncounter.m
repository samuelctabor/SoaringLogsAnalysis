function AnimateThermalEncounter(FlightData, SimData,LineTypes,colours,limits)
%AnimateThermalEncounter Animate an encounter with a thermal. Both actual
%and simulated filters can be plotted.
%   Detailed explanation goes here

    figure;
    axis_anim=gca;
    A = colormap;
    for iT=1:numel(FlightData.Time)
        
        c=A(round(colours(iT)*(size(A,1)-1))+1,:);
        
        % Plot aircraft position and current reading
        plot(axis_anim,FlightData.AircraftPosition(iT,1),FlightData.AircraftPosition(iT,2),'o','MarkerFaceColor',c,'MarkerEdgeColor',c);   % AC position
        hold(axis_anim,'on');
        
        plot(axis_anim, FlightData.AircraftPosition(1:iT,1), FlightData.AircraftPosition(1:iT,2),'r:');
        % Mark the actual filter data
        DrawFilter(axis_anim,iT,FlightData,'b');
        
        % Mark the simulated filter data
        for i=1:length(SimData)
            DrawFilter(axis_anim,iT,SimData{i},LineTypes{i});
        end

        set(axis_anim,'XLim',limits.x,'YLim',limits.y,'CLim',limits.c,'DataAspectRatio',[1,1,1]);

        colorbar('peer',axis_anim);
        hold(axis_anim,'off');
        title(axis_anim,sprintf('Time %3.1fs (%d)', FlightData.Time(iT)-FlightData.Time(1),iT));
        
        xlabel(axis_anim,'East [m]');
        ylabel(axis_anim,'North [m]');
        
        pause(0.03);
    end
end

function DrawFilter(ax,iT,Filter,LineType)
    % Current position estimate
    plot(ax,Filter.EstPosM(iT,1),Filter.EstPosM(iT,2),strcat(LineType,'^'),...
                'MarkerFaceColor',LineType,...
                'MarkerEdgeColor',LineType);
            
    % Position estimate history
    plot(ax,Filter.EstPosM(1:iT,1),Filter.EstPosM(1:iT,2),LineType,....
                'MarkerFaceColor',LineType,...
                'MarkerEdgeColor',LineType);
    
    % Confidence ellipse
    draw_confidence_ellipse(ax,Filter.EstPosM(iT,1),Filter.EstPosM(iT,2),squeeze(Filter.P(iT,3:4,3:4)),LineType);
    
    % Estimated thermal size
    draw_ellipse(ax,Filter.EstPosM(iT,1),Filter.EstPosM(iT,2),Filter.X(iT,2),Filter.X(iT,2),0.0,LineType);
end
