% Step input response to 0.03
a=0.03;
time = 0:0.02:10;
input = 2+zeros(size(time));

output = zeros(size(time));
for iT=2:length(time)
    output(iT) = output(iT-1)*(1-a) + input(iT)*a;
end

hold on; plot(time, input, time, output);