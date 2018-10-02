function [StructOut] = mapFields(Struct)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% 
%     % Weird reversed fields
%     alt = Struct.Soar.lng;
%     Struct.Soar.lng = Struct.Soar.alt;
%     Struct.Soar.alt = alt;
%     % SOAR data
    

    FlightData.Time = Struct.Soar.Time;
    FlightData.FilterInputs = [Struct.Soar.nettorate,Struct.Soar.dx,Struct.Soar.dy];
    
    FlightData.X =[Struct.Soar.x0,Struct.Soar.x1,Struct.Soar.x2,Struct.Soar.x3];
    
    FlightData.AircraftPositionDegrees = ...
                        fliplr([Struct.Soar.lat,Struct.Soar.lng]*1e7);
                    
    FlightData.Altitude = Struct.Soar.alt;
    
    FlightData.WindDelta = [Struct.Soar.dy_w,Struct.Soar.dx_w];
    
    RefPos = FlightData.AircraftPositionDegrees(1,:);
    nT = length(FlightData.Time);
    FlightData.AircraftPosition = latlong_to_m(FlightData.AircraftPositionDegrees-repmat(RefPos,nT,1),FlightData.AircraftPositionDegrees(1,2));
    
    FlightData.TimeStep = ones(nT,1)*min(diff(FlightData.Time));
    FlightData.P = zeros(nT,4);
    
    % GPS data 
    GPSData.Time =     Struct.GPS.Time;
    GPSData.Altitude = Struct.GPS.Time;
    
    StructOut.Soar = FlightData;
    StructOut.GPS = GPSData;
    

end

