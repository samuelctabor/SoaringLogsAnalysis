
figure;

plot([FlightData.posE(1:5:end), FlightData.estPosE(1:5:end)]',[FlightData.posN(1:5:end), FlightData.estPosN(1:5:end)]','Color',[0.8,0.8,0.9])
hold on
plot(FlightData.estPosE, FlightData.estPosN,'b');
scatter(FlightData.posE,FlightData.posN,5,FlightData.nettorate);
colormap('bluewhitered');

fullLog = log;
% log = 
figure;
plot(log.CTUN.TimeS,log.CTUN.Roll,log.CTUN.TimeS,log.CTUN.NavRoll)
