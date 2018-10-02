function [ corrected ] = windCorrect( FlightData, field )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    corrected = FlightData.(field) - cumsum(FlightData.WindDelta);
  
end

