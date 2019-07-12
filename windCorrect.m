function [ correctedx, correctedy ] = windCorrect( FlightData, fieldx, fieldy )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    correctedx = FlightData.(fieldx) - cumsum(FlightData.WindDelta(:,1));
    correctedy = FlightData.(fieldy) - cumsum(FlightData.WindDelta(:,2));
  
end

