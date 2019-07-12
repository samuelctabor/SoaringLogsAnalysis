Vx = 28;
Vz = 1.6;

polar_K = 490; % 2*W/rhp*S
polar_B = 0.0156;

CL = polar_K/Vx^2;
CD_CL = Vz/Vx;

% CD_CL = CD0/CL + B*CL
CD0 = CL*(CD_CL - polar_B*CL)