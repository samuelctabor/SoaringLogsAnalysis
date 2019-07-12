load('Data.mat');

figure;
ax1 = subplot(3,1,1);
plot(Data.BARO.Time, Data.BARO.Alt)

ax2 = subplot(3,1,2);
plot(Data.RCOU.Time, Data.RCOU.C1)

ax3 = subplot(3,1,3);
plot(Data.BARO.Time, Data.BARO.Alt)

linkaxes([ax1,ax2,ax3],'x');