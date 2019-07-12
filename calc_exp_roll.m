function roll = calc_exp_roll(V, R)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    g = 9.81;

    roll = atan(V.^2/(g*R));
end

