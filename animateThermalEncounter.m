function animateThermalEncounter(FlightData, SimData,LineTypes,colours,limits)
%AnimateThermalEncounter Animate an encounter with a thermal. Both actual
%and simulated filters can be plotted.
%   Detailed explanation goes here

    figure;
    axis_anim=gca;
    A = colormap;
    for iT=1:numel(FlightData.Time)
        
        c=A(round(colours(iT)*(size(A,1)-1))+1,:);
        
        % Plot aircraft position and current reading
        plot(axis_anim,FlightData.posE(iT),FlightData.posN(iT),'o','MarkerFaceColor',c,'MarkerEdgeColor',c);   % AC position
        hold(axis_anim,'on');
        
        plot(axis_anim, FlightData.posE(1:iT), FlightData.posN(1:iT),'r:');
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
    plot(ax,Filter.estPosE(iT),Filter.estPosN(iT),strcat(LineType,'^'),...
                'MarkerFaceColor',LineType,...
                'MarkerEdgeColor',LineType);
            
    % Position estimate history
    plot(ax,Filter.estPosE(1:iT),Filter.estPosN(1:iT),LineType,....
                'MarkerFaceColor',LineType,...
                'MarkerEdgeColor',LineType);
    
    % Confidence ellipse
    draw_confidence_ellipse(ax,Filter.estPosE(iT),Filter.estPosN(iT),squeeze(Filter.P(iT,[4,3],[4,3])),LineType);
    
    % Estimated thermal size
    draw_ellipse(ax,Filter.estPosE(iT),Filter.estPosN(iT),Filter.X(iT,2),Filter.X(iT,2),0.0,LineType);
end
