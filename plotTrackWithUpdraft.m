function returnHandle=plotTrackWithUpdraft(FlightData, addTimeLabels, realThermalData)

    if nargin<2 || isempty(addTimeLabels)
        addTimeLabels = false;
    end
    
    % Plot aircraft position
    figure;
    hold on;
    plot3(FlightData.estPosE,FlightData.estPosN,FlightData.alt,'b');

    hc=colorbar;
    ht = get(hc,'Title');
    set(ht,'String','Netto rate m/s');

    scatter3(FlightData.posE,FlightData.posN,FlightData.alt,5,FlightData.nettorate);
    colormap('bluewhitered');
    
    grid on;
    xlabel('East [m]');
    ylabel('North [m]');
    zlabel('Altitude [m]');
    axis equal;
    returnHandle = gca;

    set(gcf,'Position',[201 49 1201 948]);
    set(gca,'CameraPosition',[-224.4   -1476.7 1142.1]);
    
    if nargin>2
        xl = get(gca,'XLim');
        yl = get(gca,'YLim');
        
        [X,Y] = ndgrid(xl(1):xl(2),yl(1):yl(2));
        r2 = (X-realThermalData.pos(1)).^2 + (Y-realThermalData.pos(2)).^2;
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