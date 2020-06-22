clear;
close all;

options.useOldStyleParams       = false;
options.reconstructProbs        = true;
options.plotReconstructedStates = true;
options.addTimeLabels           = false;
options.plotRealThermalData     = false;

% Define the experimental filters to run.
SimData=cell(0,1);
SimData{1}.Q=diag([0.001^2,0.2^2,0.2^2,0.2^2]);
SimData{1}.R=0.6^2;
SimData{1}.Pinit=diag([0.07^2,20^2,20^2,20^2]);
% 
%     % Setup for "Radian-Selkirk"
%     SimData{2}.Q=diag([0.001,0.5,0.03^2,0.03^2]);
%     SimData{2}.R=0.45^2;
%     SimData{2}.Pinit=diag([1.0,2100,300,300]);


if ispc()
    addpath('G:/Documents/00_MATLAB/00_Soaring/Soaring_simulation');
else
    addpath('/home/samuel/Personal/Soaring_simulation');
    addpath('/home/samuel/Personal/SoaringStudies/POMDP_vs_L1/');
end

log = loadLog();

if isempty(log)
    % User cancelled UI load.
    load('Data.mat');
else
    log = mapFields(log);
    log = AddSoaringData(log);

    save('Data.mat', 'log');
end

firstGPSAlt = interp1(log.GPS.Time,log.GPS.Alt,log.SOAR.Time(1));
log.GPS.Alt = log.GPS.Alt - (firstGPSAlt-log.SOAR.alt(1));

figure,plot(log.GPS.Time,log.GPS.Alt);
hold on;
plot(log.SOAR.Time,log.SOAR.alt,'r.');
xlabel('Time [s]'); ylabel('Altitude [m]');

[FlightData,flag]=selectIndividualThermal(log.SOAR);
close(gcf);

LineTypes = {'r','g','k','m','y','b'};

% Should all inputs be corrected for wind?
CorrectForWind = false;
if isfield(FlightData,'WindDelta')
    CorrectForWind=NaN;
    while isnan(CorrectForWind)
        try
            CorrectForWind = input('Remove wind influence? 0 / 1\n');
        catch
        end
    end
end

RunAnimation = input('Animate the encounter? 0/1\n');

% Check the update rate.
fprintf('Mean update rate: %f\n',mean(diff(FlightData.Time))*24*3600);

% Input the filter settings, for both the flightdata and any experimental
% filters.
if ~options.useOldStyleParams
    FlightData.Q=diag([0.001^2,0.2^2,0.2^2,0.2^2]);
    FlightData.R=0.2^2;
    FlightData.Pinit=diag([0.0049,50^2,300,300]);
else  
    FlightData.Q=diag([0.001,0.5,0.03^2,0.03^2]);
    FlightData.Pinit=diag([1.0,2100,300,300]);
    FlightData.R = 0.45^2;
end

NFilters=numel(SimData);

% Rerun the actual flight filter to get the covariance matrices etc.
FlightData.Xinit = FlightData.X(1,:)';
FlightData       = replayFilter(FlightData);

for i=1:NFilters
    SimData{i}.FilterInputs     = FlightData.FilterInputs;
    SimData{i}.posN             = FlightData.posN;
    SimData{i}.posE             = FlightData.posE;
    SimData{i}.Xinit            = [2.0;80.0;FlightData.Xinit(3:4)];
    SimData{i}.Time             = FlightData.Time;
    SimData{i}.WindDelta        = FlightData.WindDelta;
    SimData{i}                  = replayFilter(SimData{i});

    if (CorrectForWind)
        [SimData{i}.posN, SimData{i}.posE]       = windCorrect(SimData{i},'posN','posE');
        [SimData{i}.estPosN, SimData{i}.estPosE] = windCorrect(SimData{i},'estPosN','estPosE');
    end
end

if (CorrectForWind)
    [FlightData.posN, FlightData.posE] = windCorrect(FlightData,'posN','posE');
    
    [FlightData.estPosN, FlightData.estPosE] = windCorrect(FlightData,'estPosN','estPosE');
end

FlightData.nettorate = FlightData.FilterInputs(:,1);

realThermalData.pos = [-180, -260];
realThermalData.R = 80;
realThermalData.w = 2;

if options.plotRealThermalData
    plotTrackWithUpdraft(FlightData, options.addTimeLabels,realThermalData);
else
    plotTrackWithUpdraft(FlightData, options.addTimeLabels);
end

for i=1:NFilters
    % Plot track
    plot3(gca,SimData{i}.estPosE,SimData{i}.estPosN,FlightData.alt,LineTypes{i});
    % Label end point
    text(SimData{i}.estPosE(1),SimData{i}.estPosN(1),sprintf('q %f r %f',SimData{i}.Q(1,1),SimData{i}.R(1,1)));
end
xlimall=get(gca,'XLim');
ylimall=get(gca,'YLim');
grid on; grid minor;

%
% Plot the state estimates
%
figure;

Titles = {'Strength','Radius','North','East'};

% Strength and radius
leg = {'Logged','Replay'};
for iState=1:4
    subplot(2,2,iState);
    hold on;
    plot(FlightData.Time,FlightData.X(:,iState),'b')

    if options.plotReconstructedStates
        plot(FlightData.Time,FlightData.X_replay(:,iState),'r.')
    end

    for i=1:NFilters
        plot(SimData{i}.Time,SimData{i}.X(:,iState),LineTypes{i});
        leg{end+1} = sprintf('Filter %i', i);
    end
    title(Titles{iState});grid on; grid minor;
    xlabel('Time [s]');
end
legend(leg);

%
% Plot auto-correlations of state estimates
%
figure;
Titles = {'Pww','Prr','Pxx','Pyy'};
for iState=1:4
    subplot(2,2,iState);
    hold on;
    plot(FlightData.Time,FlightData.P(:,iState,iState),'b')
    for i=1:NFilters
        plot(FlightData.Time,SimData{i}.P(:,iState,iState),LineTypes{i})
    end
    title(Titles{iState});grid on; grid minor;
    xlabel('Time [s]')
end

figure; 
subplot(2,2,1);
plot(FlightData.Time,FlightData.X(:,3)/max(FlightData.X(:,3)))
hold on
plot(FlightData.Time,FlightData.FilterInputs(:,1),'r');
title('Measurement and X position');grid on; grid minor;
xlabel('Time [s]')

% The climb potential estimated at WP_LOITER_RAD.
estdist = 20.0;
thermalability_1 = FlightData.X(:,1).*exp(-(estdist.^2)./(FlightData.X(:,2).^2)) - 0.7;

% The climb potential estimated at the actual circling radius.
truedist = sqrt((FlightData.posN-FlightData.estPosN).^2+(FlightData.posE-FlightData.estPosE).^2);
thermalability_2 = FlightData.X(:,1).*exp(-(truedist.^2)./(FlightData.X(:,2).^2)) - 0.7;

% The true climb potential at WP_LOITER_RAD.
estdist2 = estdist*ones(size(FlightData.Time));
true_thermalability_1 = realThermalData.w*exp(-(estdist2.^2)./(realThermalData.R^2)) - 0.7;

% The true climb potential at the actual circling radius.

true_thermalability_2 = realThermalData.w*exp(-(truedist.^2)./(realThermalData.R^2)) - 0.7;

%
% Plot the estimated climb rate potential
%
subplot(2,2,2);
plot(FlightData.Time-FlightData.Time(1),thermalability_1)
hold on;
plot(FlightData.Time-FlightData.Time(1),thermalability_2)
for i=1:NFilters
    estdist = sqrt(SimData{i}.X(:,3).^2+SimData{i}.X(:,4).^2);
    thermalability_1 = SimData{i}.X(:,1).*exp(-(estdist.^2)./(SimData{i}.X(:,2).^2)) - 0.7;
    plot(FlightData.Time-FlightData.Time(1),thermalability_1,LineTypes{i})
end
if options.plotRealThermalData
    plot(FlightData.Time-FlightData.Time(1), true_thermalability_1)
    plot(FlightData.Time-FlightData.Time(1), true_thermalability_2)
end
title('Estimated thermalability');
xlabel('Time [s]');
ylabel('[m/s]');
grid on; grid minor;

subplot(2,2,3);
plot(FlightData.Time,FlightData.residual);
title('Residual');grid on; grid minor;
xlabel('Time [s]')

subplot(2,2,4);
plot(FlightData.Time,FlightData.FilterInputs(:,1));
title('Vario input');grid on; grid minor;
xlabel('Time [s]')

figure,scatter(FlightData.posE, FlightData.posN, 10,FlightData.FilterInputs(:,1));
colormap('bluewhitered');
xlabel('East [m]'); ylabel('North [m]');
h=colorbar;
set(h.Title,'String','Est updraft [m/s]');
axis equal;

if (RunAnimation)
    % Determine colour limits.
    [clims, colours] = calcColourLimits(FlightData.nettorate);

   limits = struct('x',xlimall,'y',ylimall,'c',clims);
   animateThermalEncounter(FlightData,SimData,LineTypes,colours,limits);
end

if options.plotRealThermalData
    rr = linspace(0,2*realThermalData.R,100);
    w1 = realThermalData.w*exp(-rr.^2/realThermalData.R^2);
    w2 = FlightData.X(end,1).*exp(-rr.^2./FlightData.X(end,2).^2);
    figure,plot(rr,w1,rr,w2); 
    hold on;
    plot([20.0,20.0], get(gca,'YLim'),'r--');
    legend('Real','Estimated');
end