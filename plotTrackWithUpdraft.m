function returnHandle=plotTrackWithUpdraft(FlightData, addTimeLabels, realThermalData)

    if nargin<2 || isempty(addTimeLabels)
        addTimeLabels = false;
    end
    
    % Plot aircraft position
    figure;
    hold on;
    plot3(FlightData.estPosE,FlightData.estPosN,FlightData.alt,'b');

    % Plot measured updraft as colours
    [clims, colours] = calcColourLimits(FlightData.nettorate);
    
    A=colormap('jet');
    set(gca,'CLim',clims);
    hc=colorbar;
    ht = get(hc,'Title');
    set(ht,'String','Netto rate m/s');

    for i=1:numel(FlightData.Time)
        c=A(round(colours(i)*(size(A,1)-1))+1,:);
        plot3(FlightData.posE(i),FlightData.posN(i),FlightData.alt(i),'o','MarkerFaceColor',c,'MarkerEdgeColor',c);   % AC position
    end

    lim=100;
    xlim([-lim,lim]);
    ylim([-lim,lim]);
    
    grid on;
    xlabel('East [m]');
    ylabel('North [m]');
    zlabel('Altitude [m]');
    axis equal;
    returnHandle = gca;

    set(gcf,'Position',[201 49 1201 948]);
    set(gca,'CameraPosition',[-224.4   -1476.7 1142.1]);

%     lim=100;
%     xlim([-lim,lim]);
%     ylim([-lim,lim]);
    
    if nargin>2
        xl = get(gca,'XLim');
        yl = get(gca,'YLim');
        
        [X,Y] = ndgrid(xl(1):xl(2),yl(1):yl(2));
        r2 = (X-realThermalData.pos(2)).^2 + (Y-realThermalData.pos(1)).^2;
        W = realThermalData.w * exp(-r2/realThermalData.R^2);
        
        contourf(X,Y,W);
    end
        
    % Add time labels.
    if addTimeLabels
        idx = 1:100:length(FlightData.Time);
        labels = arrayfun(@(x)datestr(x,'MM:SS'),FlightData.Time(idx)-FlightData.Time(1),'UniformOutput',false);
        text(FlightData.posE(idx),FlightData.posN(idx),FlightData.alt(idx),labels);
    end
end