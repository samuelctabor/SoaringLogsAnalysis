function [ FlightData, flag ] = selectIndividualThermal( FlightData )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    nt = numel(FlightData.Time);
    flag = 1;
    
    time = [-1; FlightData.Time];

    dt = diff(time);
    is_modestart = dt > 1000*mode(dt);

    if all(is_modestart)
        return;
    else
        % Sometimes these params were never updated. This happens when the actual
        % corrections are disabled, leaving only wind FF and corrections for AC
        % motion. In this case we'll just show everything.     
        % Check for multiple thermal encounters
        idx = find(is_modestart);

        if (length(idx)>1)
            
            fprintf(' # start dt     dh\n');
            for i=1:length(idx)
                idx_p=[idx;nt];
                dh=FlightData.alt(idx_p(i+1)-1)-FlightData.alt(idx_p(i));
                dt=FlightData.Time(idx_p(i+1)-1)-FlightData.Time(idx_p(i));
                fprintf('%2i %5i %3.1f %+3.1f\n',i, FlightData.Time(idx_p(i)), dt,dh);
            end
            
            try
                toPlot = input(sprintf('Which thermal encounter to plot? (1-%i)\n',length(idx)));
            catch 
                toPlot = [];
            end
            
            if isempty(toPlot)
                % Return a flag to indicate we should terminate.
                flag = 2;
                return;
            elseif (toPlot<1 || toPlot>length(idx))
                fprintf('Invalid input, showing thermal 1.\n');
                toPlot=1;
            end
            idx(end+1) = nt+1;
            names=fieldnames(FlightData);
            nT = numel(FlightData.TimeUS);
            for i=1:numel(names)
                if size(FlightData.(names{i}),1) == nT
                    FlightData.(names{i})=FlightData.(names{i})(idx(toPlot):idx(toPlot+1)-1,:);
                end
            end
        else
            %FlightData=FlightDataRaw;
        end
    end
    
    FlightData.Time = FlightData.Time - FlightData.Time(1);

end

