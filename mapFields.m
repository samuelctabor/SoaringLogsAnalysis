function [StructOut] = mapFields(Struct)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    if ~isfield(Struct,'SOAR') && isfield(Struct,'Soar')
        Struct.SOAR = Struct.Soar;
    end
    StructOut = Struct;
    
    fields = fieldnames(StructOut);
    for iF=1:length(fields)
        if (~isfield(StructOut.(fields{iF}), 'Time') && ~isfield(StructOut.(fields{iF}), 'TimeUS'))
            StructOut = rmfield(StructOut, fields{iF});
        end
    end
    
    StructOut.SOAR.Time = Struct.SOAR.Time;
    StructOut.SOAR.FilterInputs = [Struct.SOAR.nettorate,Struct.SOAR.dx,Struct.SOAR.dy];
    
    StructOut.SOAR.X =[Struct.SOAR.x0,Struct.SOAR.x1,Struct.SOAR.x2,Struct.SOAR.x3];
    
    StructOut.SOAR.AircraftPositionDegrees = ...
                        fliplr([Struct.SOAR.lat,Struct.SOAR.lng]*1e7);
                        
    StructOut.SOAR.WindDelta = [Struct.SOAR.dy_w,Struct.SOAR.dx_w];
    
    RefPos = StructOut.SOAR.AircraftPositionDegrees(1,:);
    nT = length(StructOut.SOAR.Time);
    StructOut.SOAR.AircraftPosition = latlong_to_m(StructOut.SOAR.AircraftPositionDegrees-repmat(RefPos,nT,1),StructOut.SOAR.AircraftPositionDegrees(1,2));
    
    StructOut.SOAR.TimeStep = ones(nT,1)*min(diff(StructOut.SOAR.Time));
    StructOut.SOAR.P = zeros(nT,4);
end

