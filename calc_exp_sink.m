function exp_sink = calc_exp_sink(V, roll, K, Cd0, B)
% Calculate expected thermalling sink.

CL0 = K ./ V.^2;
C1 = Cd0./CL0;
C2 = B*CL0;

% exp_sink = V.*(C1+C2./((cos(roll)).^2));
exp_sink = V.*(C1+C2./(1 - roll.^2/2).^2);
end
