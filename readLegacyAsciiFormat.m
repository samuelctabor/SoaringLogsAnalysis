function Data = readLegacyAsciiFormat( fullfilename )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    fid=fopen(fullfilename);

    data=zeros(10000,13);
    i=1;
    ii=1;

    % Log file formatt
    Format.Time=1;
    Format.FilterInputs=2:4;
    Format.X=5:8;
    Format.Position=9:10;
    Format.Altitude=11;
    Format.Wind=12:13;

    Data.GPS.Time=zeros(10000,1);
    Data.GPS.Alt=zeros(10000,1);
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
%                 Data.GPS.Time(ii)=tempdata(2)/1000;
%                 Data.GPS.Alt(ii)=tempdata(9);
%                 ii=ii+1;
            elseif length(tline)>4 && strcmp(tline(1:4),'NTUN')
                tempdata = sscanf(tline(6:end),'%f,%f,%f,%f,%f,%f,%f,%f,%f');
                Data.GPS.Time(ii)=tempdata(1)/1000;
                Data.GPS.Airspeed(ii)=tempdata(7);
                Data.GPS.Alt(ii)=tempdata(8);
                ii=ii+1;
            end
        catch er
            fprintf('Issue reading line\n');
        end
    end
    
    data(i:end,:)=[];
    Data.GPS.Time(ii:end)=[];
    Data.GPS.Alt(ii:end)=[];
    
    if isempty(data)
        error('EKF did not run in this flight.');
    end
    
    if size(data,2)>=11 % Log format
        Data.SOAR.Time             = data(:,Format.Time)/1000;
        Data.SOAR.FilterInputs     = data(:,Format.FilterInputs);
        Data.SOAR.X                = data(:,Format.X);
        Data.SOAR.AircraftPositionDegrees = ...
                               fliplr(data(:,Format.Position))*1e7;
        Data.SOAR.alt         = data(:,Format.Altitude);
        Data.SOAR.WindDelta = fliplr(data(:,Format.Wind));
        
        % Probably no EKF position in this case so use the first GPS
        % location.
        RefPos = Data.SOAR.AircraftPositionDegrees(1,:);

        Data.SOAR.AircraftPosition = latlong_to_m(Data.SOAR.AircraftPositionDegrees-RefPos,Data.SOAR.AircraftPositionDegrees(1,2));        

        Data.SOAR.TimeStep=0.3*ones(size(data,1),1);
        Data.SOAR.P = zeros(size(data,1),4);
    end
    
    Data.GPS = removeGlitches(Data.GPS);
end

