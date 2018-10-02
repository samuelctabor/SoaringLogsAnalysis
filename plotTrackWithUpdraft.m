function plotTrackWithUpdraft(FlightData, addTimeLabels)

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

    for i=1:numel(FlightData.Time)
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
    if addTimeLabels
        idx = 1:100:length(FlightData.Time);
        labels = arrayfun(@(x)datestr(x,'MM:SS'),FlightData.Time(idx)-FlightData.Time(1),'UniformOutput',false);
        text(FlightData.AircraftPosition(idx,1),FlightData.AircraftPosition(idx,2),FlightData.Altitude(idx),labels);
    end
end