function plotTrackWithUpdraft(FlightData, addTimeLabels)

    % Plot aircraft position
    figure;
    hold on;
    plot3(FlightData.estPosE,FlightData.estPosN,FlightData.alt,'b');

    % Plot measured updraft as colours
    av = mean( FlightData.nettorate);
    dev = std( FlightData.nettorate);
    clims =[0,av+2*dev];

    inputs_clipped = FlightData.nettorate;
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
        plot3(FlightData.posE(i),FlightData.posN(i),FlightData.alt(i),'o','MarkerFaceColor',c,'MarkerEdgeColor',c);   % AC position
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
        text(FlightData.posE(idx),FlightData.posN(idx),FlightData.alt(idx),labels);
    end
end