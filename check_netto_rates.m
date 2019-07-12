polar.K = 71.7;
polar.CD0 = 0.05;
polar.B   = 0.045;

if (0)
    log.VAR.TimeS = 160.90;
    log.VAR.aspd_filt = 9.047;
    log.VAR.roll = 0.4596;

    log.VAR.cl = 0.79466;
    log.VAR.exs = 0.93689;
    log.VAR.raw = 1.599;
    log.VAR.filt = 1.5842;
    log.VAR.dsp = -0.17096;
    log.VAR.ex_c = 0.647368;
elseif (0)
     log = LoadLatestBINFile('~/Personal/ardupilot/ArduPlane/logs',[],false);
    
%     idx = find(~ (contains(log.PARM.Name,'STAT_RUNTIME') | contains(log.PARM.Name,'STAT_FLTTIME')));
%     [num2cell(log.PARM.TimeS(idx)), log.PARM.Name(idx), num2cell(log.PARM.Value(idx))]

%     log = TrimTime(log,[100,350]);
else
%     aplog = Ardupilog(fullfile('~/Desktop/MarcosLogs/240619/','00000004.BIN'));
%     aplog = Ardupilog(fullfile('~/Personal/Radian/','log2.bin'));
    aplog = Ardupilog(fullfile('~/Personal/Radian/','00000008.BIN'));
        
    log = aplog.getStruct();
    log = NormaliseTimes(log);
    log.PARM.Name = cellstr(log.PARM.Name);
    
    log = fillNKF1(log);
    
%     log = TrimTime(log,[2353,2905]);
    

end


polar.K   = log.PARM.Value(strcmp(log.PARM.Name,'SOAR_POLAR_K'));
polar.CD0 = log.PARM.Value(strcmp(log.PARM.Name,'SOAR_POLAR_CD0'));
polar.B   = log.PARM.Value(strcmp(log.PARM.Name,'SOAR_POLAR_B'));

wp_loiter_rad = log.PARM.Value(strcmp(log.PARM.Name,'WP_LOITER_RAD'));

exp_roll = calc_exp_roll(log.VAR.aspd_filt,wp_loiter_rad);
    
% Attempt to reconstruct these.
% raw2 = log.VAR.cl + log.VAR.dsp.*log.VAR.aspd_filt/9.81 + calc_exp_sink(log.VAR.aspd_filt, log.VAR.roll, polar.K, polar.CD0, polar.B);
raw2 = log.VAR.cl + calc_exp_sink(log.VAR.aspd_filt, log.VAR.roll, polar.K, polar.CD0, polar.B);



ex_s = calc_exp_sink(log.VAR.aspd_filt, exp_roll, polar.K, polar.CD0, polar.B);

ex_c = raw2 - ex_s;

figure,plot(log.VAR.TimeS, log.VAR.cl, log.VAR.TimeS, log.VAR.raw, log.VAR.TimeS,log.VAR.raw - log.VAR.exs)
legend('Climb','Netto','Exp climb');
title('Climbs');
hold on;
plot(log.VAR.TimeS, raw2, log.VAR.TimeS, ex_c)

legend('Climb','Netto','Exp climb','Netto2','Exp climb 2');


% Difference in logged and re-calculated RAW is due to dsp.
delta = raw2 - log.VAR.raw;
dsp = delta*9.81./log.VAR.aspd_filt;

figure,plot(log.VAR.TimeS, dsp);