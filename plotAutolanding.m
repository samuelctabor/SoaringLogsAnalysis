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
plot(log.TECS.TimeS, log.TECS.f);
plotModes(gca,log);    
title('Flags');


figure;


ax(1)=subplot(3,1,1);

plot(log.BARO.TimeS, log.BARO.Alt, log.TECS.TimeS, log.TECS.h, log.TECS.TimeS, log.TECS.hdem);
plotModes(gca,log);    
title('Altitude');


ax(2)=subplot(3,1,2);
plot(log.TECS.TimeS, log.TECS.th, log.RCOU.TimeS, (log.RCOU.C6-params.SERVO6_MIN)/(params.SERVO6_MAX - params.SERVO6_MIN));
for iP=1:length(log.PARM.TimeS)
params.(log.PARM.Name{iP}) = log.PARM.Value(iP);
end
hold on
plotModes(gca,log);
title('Throttle');

ax(3)=subplot(3,1,3);
plot(log.CMD.TimeS, log.CMD.CNum)
hold on
plotModes(gca,log);
title('Command num');
linkaxes(ax,'x')

