function [clims, colours] = calcColourLimits(data)
% Determine the colour limits.

    av = mean( data);
    dev = std( data);
    clims =[0,av+2*dev];

    inputs_clipped = data;
    inputs_clipped(inputs_clipped>clims(2)) = clims(2);
    inputs_clipped(inputs_clipped<clims(1)) = clims(1);

    colours = (inputs_clipped-clims(1))/(clims(2)-clims(1));
end