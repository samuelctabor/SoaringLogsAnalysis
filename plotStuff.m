close all;
addpath('~/Documents/kps_simulation_environment/ardupilog')
addpath('/home/samuel/Personal/SoaringStudies/POMDP_vs_L1/');

if (1)

    log = loadLog();
    
    log.PARM.Name = cellstr(log.PARM.Name);
    
    log = fillNKF1(log);
    
    idx = find(~ (contains(log.PARM.Name,'STAT_RUNTIME') | contains(log.PARM.Name,'STAT_FLTTIME')));
    [num2cell(log.PARM.TimeS(idx)), log.PARM.Name(idx), num2cell(log.PARM.Value(idx))]

%     log = TrimTime(log,[3750,3780]);
%     log = TrimTime(log,[3600,3780]);
%     log = TrimTime(log,[385,470]);
    
    polar.K   = log.PARM.Value(strcmp(log.PARM.Name,'SOAR_POLAR_K'));
    polar.CD0 = log.PARM.Value(strcmp(log.PARM.Name,'SOAR_POLAR_CD0'));
    polar.B   = log.PARM.Value(strcmp(log.PARM.Name,'SOAR_POLAR_B'));

    wp_loiter_rad = log.PARM.Value(strcmp(log.PARM.Name,'WP_LOITER_RAD'));

%     log = TrimTime(log,[900,1100]);
elseif (1)
    log = LoadLatestBINFile('~/Personal/ardupilot/ArduPlane/logs',[],false);
    
    idx = find(~ (contains(log.PARM.Name,'STAT_RUNTIME') | contains(log.PARM.Name,'STAT_FLTTIME')));
    [num2cell(log.PARM.TimeS(idx)), log.PARM.Name(idx), num2cell(log.PARM.Value(idx))]

    log = TrimTime(log,[100,350]);
    
    polar.K = 71.7;
    polar.CD0 = 0.05;
    polar.B   = 0.045;

    wp_loiter_rad  =20.0;
end


% idx = find(strfind(log.PARM.Name,'WP_LOITER_RAD'))
% idx=contains(log.PARM.Name,'SOAR')
idx = find(~ (contains(log.PARM.Name,'STAT_RUNTIME') | contains(log.PARM.Name,'STAT_FLTTIME')));
[num2cell(log.PARM.TimeS(idx)), log.PARM.Name(idx), num2cell(log.PARM.Value(idx))]

for iP=1:length(log.PARM.TimeS)
    params.(log.PARM.Name{iP}) = log.PARM.Value(iP);
end

% log = TrimTime(log,[1960,2070]);

% soarMode = interp1(time, modeNum(iA), log.SOAR.TimeS, 'previous');

figure

% xD = log.SOAR.x1;
% xD = log.SOAR.x0;
% % % xD = log.VAR.alt;
plot(log.VAR.TimeS, log.VAR.alt, log.TECS.TimeS, log.TECS.hdem);
plotModes(gca,log);    
title('Altitude');

% Thermalability
if isfield(log.SOAR,'th')
    thermalability = log.SOAR.th;
else
    thermalability = log.SOAR.x0.*exp(-(10.0./log.SOAR.x1).^2) - 0.7;
end
figure,plot(log.SOAR.TimeS, thermalability);
plotModes(gca,log);    
title('Thermalability');

% Netto rate.
figure,plot(log.VAR.TimeS, log.VAR.filt);
plotModes(gca,log);    
title('Filtered vario rate');

% Reconstructed expected thermalling sink.#
if isfield(log.VAR,'exs')
    exp_thermalling_sink = log.VAR.exs;
else
%     exp_thermalling_sink = interp1(log.SOAR.TimeS, log.SOAR.x0.*exp(-(40.0./log.SOAR.x1).^2) - log.SOAR.th, log.VAR.TimeS);
    exp_thermalling_sink = calc_exp_sink(log.VAR.aspd_filt,wp_loiter_rad, polar.K, polar.CD0, polar.B);
end
exp_roll = calc_exp_roll(log.VAR.aspd_filt,wp_loiter_rad);
exp_thermalling_sink2 = calc_exp_sink(log.VAR.aspd_filt, exp_roll, polar.K, polar.CD0, polar.B);

figure,plot(log.VAR.TimeS, exp_thermalling_sink,log.VAR.TimeS, exp_thermalling_sink2);
plotModes(gca,log);    
title('Expected sink');

% Distance to real thermal.
dist = sqrt((log.SOAR.x2 + 180).^2 + (log.SOAR.x3 + 260).^2);
figure,plot(log.SOAR.TimeS, dist);
plotModes(gca,log);    
title('Distance to thermal');

% Estimated at location
% r = log.SOAR.lat -
figure,plot(log.VAR.TimeS, log.VAR.cl, log.VAR.TimeS, log.VAR.fc)
plotModes(gca,log);
title('Climb rate and Filtered');

figure,plot(log.VAR.TimeS, log.VAR.raw, log.VAR.TimeS, log.VAR.filt, log.VAR.TimeS, log.VAR.filt - log.VAR.exs)
legend('Raw','Filtered','Exp climb');
title('Netto rates');
plotModes(gca,log);

figure,plot(log.VAR.TimeS, log.VAR.cl, log.VAR.TimeS, log.VAR.raw, log.VAR.TimeS,log.VAR.raw - log.VAR.exs)
legend('Climb','Netto','Exp climb');
title('Climbs');
% plotModes(gca,log);

% Attempt to reconstruct these.
if isfield(log.VAR,'dsp')
    raw2 = log.VAR.cl + log.VAR.dsp.*log.VAR.aspd_filt/9.81 + calc_exp_sink(log.VAR.aspd_filt, log.VAR.roll, polar.K, polar.CD0, polar.B);
else
    raw2 = log.VAR.cl + calc_exp_sink(log.VAR.aspd_filt, log.VAR.roll, polar.K, polar.CD0, polar.B);
end

exp_roll = calc_exp_roll(log.VAR.aspd_filt,wp_loiter_rad);
ex_s = calc_exp_sink(log.VAR.aspd_filt, exp_roll, polar.K, polar.CD0, polar.B);
ex_c = raw2 - ex_s;
% ex_c2 = log.VAR.raw - log.VAR.
hold on;
plot(log.VAR.TimeS, raw2, log.VAR.TimeS, ex_c)

legend('Climb','Netto','Exp climb','Netto2','Exp climb 2');




% log = TrimTime(log,[70,150]);
% cr = interp1(log.VAR.TimeS, log.VAR.filt, log.NKF1.TimeS);
cr = interp1(log.VAR.TimeS, log.VAR.cl, log.NKF1.TimeS);
figure,scatter(log.NKF1.PE, log.NKF1.PN, 10, cr);  axis equal; grid on;
text(log.NKF1.PE(1),  log.NKF1.PN(1),  'Start','HorizontalAlignment','left');
text(log.NKF1.PE(end),log.NKF1.PN(end),'End',  'HorizontalAlignment','left');
xlabel('East [m]');
ylabel('North [m]');
h=colorbar;
ht=get(h,'Title');
set(ht,'String','Rate m/s');
title('Coloured by climb rate');