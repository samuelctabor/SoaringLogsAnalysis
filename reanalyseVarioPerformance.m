% Script to reconstruct vario readngs from flight logs.
% Currently dataflash logs only but potentially tlogs in future.


clear;
close all;
% addpath('G:\Documents\MATLAB\Soaring_simulation');
addpath('/home/samuel/Personal/Kraus/03-Kraus/00_Soaring/Soaring_simulation');

globalAlt=[];
[fname,fpath,filterindex] = uigetfile({'*.log'; '*.mat'});

%fname = '2014-05-31 12-04-11_endremoved.log';
%fpath = 'C:\Program Files (x86)\Mission Planner\logs\FIXED_WING\1\Log_park_FBW_testing';
%fname='2014-06-14 19-07-28 90_fixed2.bin.log';
%fpath='C:\Program Files (x86)\Mission Planner\logs\FIXED_WING\1\FBWB_thermalling_140614';


FlightData.TimeS=zeros(1000,1);
FlightData.Aspd=zeros(1000,1);
FlightData.Alt=zeros(1000,1);
FlightData.Roll=zeros(1000,1);
FlightData.SpTECS=zeros(1000,1);
FlightData.SpDemTECS=zeros(1000,1);
FlightData.TimeSTECS=zeros(1000,1);
if (1) %(filterindex==1)
    
    fid=fopen(fullfile(fpath,fname));
    i=1;
    j=1;
    timestamps=[];
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        try
            if strcmp(tline(1:5),'CTUN,')
                data=sscanf(tline(6:end),'%f, %f, %f, %f, %f, %f, %f, %f');
                FlightData.CTUN.Time(i) = data(1)/1000;
                FlightData.CTUN.Roll(i)=data(3);
                FlightData.CTUN.Throttle(i)=data(6);
            elseif strcmp(tline(1:5),'TECS,')
                data=sscanf(tline(6:end),'%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f');
                FlightData.TECS.Sp(j)=data(7);
                FlightData.TECS.SpDem(j)=data(6);
                FlightData.TECS.Time(j)=data(1)/1000;
                j=j+1;
            elseif strcmp(tline(1:5),'NTUN,')
                data=sscanf(tline(6:end),'%f, %f, %f, %f, %f, %f, %f, %f, %f');
                FlightData.NTUN.Time(i)=data(1)/1000;
                FlightData.NTUN.Aspd(i)=data(7);
                FlightData.NTUN.Alt(i)=data(8);
                i=i+1;
            end
        catch er
            %fprintf('Issue reading line\n');
        end
    end
    
    FlightData.CTUN = removeGlitches(FlightData.CTUN);
    FlightData.NTUN = removeGlitches(FlightData.NTUN);
    FlightData.TECS = removeGlitches(FlightData.TECS);
    
    FlightData.TimeS = FlightData.NTUN.Time;
    FlightData.Roll = interp1(FlightData.CTUN.Time,FlightData.CTUN.Roll,FlightData.TimeS);
    FlightData.Throttle = interp1(FlightData.CTUN.Time,FlightData.CTUN.Throttle,FlightData.TimeS);
    FlightData.Aspd = FlightData.NTUN.Aspd;
    FlightData.Alt  = FlightData.NTUN.Alt;
    
    FlightData.SpDemTECS = interp1(FlightData.TECS.Time,FlightData.TECS.SpDem,FlightData.TimeS);
    FlightData.SpTECS = interp1(FlightData.TECS.Time,FlightData.TECS.Sp,FlightData.TimeS);
    
else
    load('C:\Program Files (x86)\Mission Planner\logs\Log_park_with_manual_thermalling\2014-05-31_11-22-22.tlog.mat');
    n = size(airspeed_mavlink_vfr_hud_t,1);
    FlightData.TimeS(1:n) = 24*3600*(airspeed_mavlink_vfr_hud_t(:,1)-airspeed_mavlink_vfr_hud_t(1,1));
    FlightData.TimeS(n+1:end)=[];
    FlightData.Alt(1:n)=alt_mavlink_vfr_hud_t(:,2);
    FlightData.Aspd(1:n) = airspeed_mavlink_vfr_hud_t(:,2);
    FlightData.Throttle(1:n)=throttle_mavlink_vfr_hud_t(:,2);
    idx = find((roll_mavlink_attitude_t(2:end,1)-roll_mavlink_attitude_t(1:end-1,1))<=0);
    temp = rollspeed_mavlink_attitude_t;
    temp(idx,:)=[];
    FlightData.Roll(1:n) = rad2deg(interp1(temp(:,1),temp(:,2),airspeed_mavlink_vfr_hud_t(:,1),'nearest'));
    
end

%filt_C = 0.9048;
filt_C = (1-0.985)/2;
filt_dt= 0.1;
filt_tau = filt_dt/filt_C;
%B = 0.04;
%Cd0 = 0.02;
B=0.027;
Cd0 = 0.029;
K = 25.6;


spdFilt = FlightData.Aspd;
c = (1.00-0.025); %0.97;
for i=2:length(FlightData.Aspd)
    spdFilt(i)=c*spdFilt(i-1)+(1-c)*FlightData.Aspd(i);
end
%spdFilt = interp1(FlightData.TimeSTECS,FlightData.SpDemTECS,FlightData.TimeS);

useSpd=spdFilt;
avSpd=(useSpd(1:end-1)+useSpd(2:end))./2;
temp = useSpd;
temp(2:end)=avSpd;
useSpd=avSpd;
TE = FlightData.Alt + 0.5*temp.^2/9.81;
dTEdt = (TE(2:end)-TE(1:end-1))./(FlightData.TimeS(2:end)-FlightData.TimeS(1:end-1));
dHdt = (FlightData.Alt(2:end)-FlightData.Alt(1:end-1))./(FlightData.TimeS(2:end)-FlightData.TimeS(1:end-1));

avRoll = deg2rad((FlightData.Roll(1:end-1)+FlightData.Roll(2:end))./2);
avThr = (FlightData.Throttle(1:end-1)+FlightData.Throttle(2:end))./2;
dt = FlightData.TimeS(2:end)-FlightData.TimeS(1:end-1);
Cl0 = K./useSpd.^2;
sinkrate = useSpd.*((Cd0./Cl0) + (B.*Cl0)./(cos(avRoll).^2));
dTEdt_cor = dTEdt + sinkrate;
vario_filt(1)=dTEdt_cor(1);

for i=2:length(dTEdt_cor)
    if avThr(i)>5
        vario_filt(i)=vario_filt(i-1);
    elseif vario_filt(i-1)==0
        vario_filt(i)=dTEdt_cor(i);
    else
        %c = filt_C;
        c = dt(i)/filt_tau;
        vario_filt(i)=(1-c)*vario_filt(i-1) + c*dTEdt_cor(i);
    end
end

figure,plot(FlightData.TimeS,FlightData.Aspd,FlightData.TimeS,spdFilt);
xlabel('Time [s]'); ylabel('Airspeed [m/s]');
grid on; grid minor;

figure;
ax(1)=subplot(4,1,1);
yyaxis('left');
plot(FlightData.TimeS,FlightData.Alt,'b');
yyaxis('right');
plot(FlightData.TimeS(2:end),avThr,'r');
title('Alt (m) & Thr');
ax(2)=subplot(4,1,2);
plot(FlightData.TimeS,FlightData.Aspd,'b');
hold on;
plot(FlightData.TimeS,spdFilt,'r');
title('Aspd (m/s)');
ax(3)=subplot(4,1,3);
plot(FlightData.TimeS,FlightData.Roll,'b');
title('Roll (deg)');
ax(4)=subplot(4,1,4);
%plot(FlightData.TimeS(2:end),dTEdt,'b');
title('Energy derivatives');
hold on;
plot(FlightData.TimeS(2:end),dTEdt_cor,'r');
plot(FlightData.TimeS(2:end),vario_filt,'g');
set(gca,'YLim',[-2,5]);
set(gca,'YTick',[-2:1:5]);
grid on;
linkaxes(ax,'x');

