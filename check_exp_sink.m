% Calculate expected thermalling sink.

R = 80.0;
V = 25.0;
g = 9.81;

Cd0 = 0.00859;
B   = 0.0156;
K   = 490;

AR = 25;
b = 14.5;
S = b^2/AR;
m = 300;
K_calc = 16*300/S

roll = atan(V^2/(g*R));

CL0 = K / V^2;
C1 = Cd0/CL0;
C2 = B*CL0;

exp_sink = V*(C1+C2/cos(roll)^2)


Vv = 10:0.1:50;

roll_1 = calc_exp_roll(Vv,R);
exp_sink_1 = calc_exp_sink(Vv,roll_1,K,Cd0,B);
figure,plot(Vv,exp_sink_1)

roll_2 = calc_exp_roll(Vv,R);
exp_sink_2 = calc_exp_sink(Vv,roll_2,90,Cd0,B);
hold on,plot(Vv,exp_sink_2)
