function [ FlightData,globalAlt] = readLogFile( fullfilename, Format )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    fid=fopen(fullfilename);

    data=zeros(10000,13);
    i=1;
    ii=1;
    timestamps=[];
    globalAlt.Time=zeros(10000,1);
    globalAlt.Alt=zeros(10000,1);
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        try
            if length(tline)>3 && strcmp(tline(1:3),'TH:')
                data(i,:)=sscanf(tline(4:end),'%f, %f,%f,%f,%f,%f,%f,%f,%f,%f');
                i=i+1;
            elseif length(tline)>4 && strcmp(tline(1:4),'THML')
                temp=sscanf(tline(7:end),'%i, %f, %f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f');
                data(i,1:length(temp))=temp;
                i=i+1;
%             elseif strcmp(tline(1:3),'GPS')
%                 tempdata = sscanf(tline(5:end),'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f');
%                 globalAlt.Time(ii)=tempdata(2)/1000;
%                 globalAlt.Alt(ii)=tempdata(9);
%                 ii=ii+1;
            elseif length(tline)>4 && strcmp(tline(1:4),'NTUN')
                tempdata = sscanf(tline(6:end),'%f,%f,%f,%f,%f,%f,%f,%f,%f');
                globalAlt.Time(ii)=tempdata(1)/1000;
                globalAlt.Airspeed(ii)=tempdata(7);
                globalAlt.Altitude(ii)=tempdata(8);
                ii=ii+1;
            end
        catch er
            fprintf('Issue reading line\n');
        end
    end
    
    data(i:end,:)=[];
    globalAlt.Time(ii:end)=[];
    globalAlt.Altitude(ii:end)=[];
    
    if isempty(data)
        error('EKF did not run in this flight.');
    end
    
    if size(data,2)>=11 % Log format
        FlightData.Time             = data(:,Format.Time)/1000;
        FlightData.FilterInputs     = data(:,Format.FilterInputs);
        FlightData.X                = data(:,Format.X);
        FlightData.AircraftPositionDegrees = ...
                               fliplr(data(:,Format.Position))*1e7;
        FlightData.Altitude         = data(:,Format.Altitude);
        FlightData.WindDelta = fliplr(data(:,Format.Wind));
        
        RefPos = FlightData.AircraftPositionDegrees(1,:);
        PositionArray = [ones(size(data,1),1)*RefPos(1),ones(size(data,1),1)*RefPos(2)];
        FlightData.AircraftPosition = latlong_to_m(FlightData.AircraftPositionDegrees-PositionArray,FlightData.AircraftPositionDegrees(1,2));
        
        FlightData.TimeStep=0.3*ones(size(data,1),1);
        FlightData.P = zeros(size(data,1),4);
    end
    
    globalAlt = removeGlitches(globalAlt);

end

