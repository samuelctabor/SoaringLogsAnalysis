function [StructOut] = mapFields(Struct)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    % Mislabelled fields.
    if isfield(Struct.SOAR,'lat') && ~isfield(Struct.SOAR,'north')
        Struct.SOAR.north = Struct.SOAR.lat;
        Struct.SOAR.east  = Struct.SOAR.lng;
    end
    
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
    StructOut.SOAR.FilterInputs = [Struct.SOAR.nettorate,Struct.SOAR.north, Struct.SOAR.east, Struct.SOAR.dx_w,Struct.SOAR.dy_w];
    
    StructOut.SOAR.X =[Struct.SOAR.x0,Struct.SOAR.x1,Struct.SOAR.x2,Struct.SOAR.x3];
    
    StructOut.SOAR.WindDelta = [Struct.SOAR.dx_w,Struct.SOAR.dy_w];

    StructOut.SOAR.P = zeros(length(StructOut.SOAR.TimeS),4);
end

