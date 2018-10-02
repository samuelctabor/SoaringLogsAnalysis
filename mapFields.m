function [StructOut] = mapFields(Struct)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    if ~isfield(Struct,'SOAR') && isfield(Struct,'Soar')
        Struct.SOAR = Struct.Soar;
    end
    
    FlightData.Time = Struct.SOAR.Time;
    FlightData.FilterInputs = [Struct.SOAR.nettorate,Struct.SOAR.dx,Struct.SOAR.dy];
    
    FlightData.X =[Struct.SOAR.x0,Struct.SOAR.x1,Struct.SOAR.x2,Struct.SOAR.x3];
    
    FlightData.AircraftPositionDegrees = ...
                        fliplr([Struct.SOAR.lat,Struct.SOAR.lng]*1e7);
                    
    FlightData.Altitude = Struct.SOAR.alt;
    
    FlightData.WindDelta = [Struct.SOAR.dy_w,Struct.SOAR.dx_w];
    
    RefPos = FlightData.AircraftPositionDegrees(1,:);
    nT = length(FlightData.Time);
    FlightData.AircraftPosition = latlong_to_m(FlightData.AircraftPositionDegrees-repmat(RefPos,nT,1),FlightData.AircraftPositionDegrees(1,2));
    
    FlightData.TimeStep = ones(nT,1)*min(diff(FlightData.Time));
    FlightData.P = zeros(nT,4);
    
    % GPS data 
    GPSData.Time = Struct.GPS.Time;
    GPSData.Alt  = Struct.GPS.Alt;
    
    StructOut.SOAR = FlightData;
    StructOut.GPS  = GPSData;
    

end

