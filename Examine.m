% enum FlightMode {
%     MANUAL        = 0,
%     CIRCLE        = 1,
%     STABILIZE     = 2,
%     TRAINING      = 3,
%     ACRO          = 4,
%     FLY_BY_WIRE_A = 5,
%     FLY_BY_WIRE_B = 6,
%     CRUISE        = 7,
%     AUTOTUNE      = 8,
%     AUTO          = 10,
%     RTL           = 11,
%     LOITER        = 12,
%     GUIDED        = 15,
%     INITIALISING  = 16
%     }

Modes.MANUAL        = 0;
Modes.CIRCLE        = 1;
Modes.STABILIZE     = 2;
Modes.TRAINING      = 3;
Modes.ACRO          = 4;
Modes.FLY_BY_WIRE_A = 5;
Modes.FLY_BY_WIRE_B = 6;
Modes.CRUISE        = 7;
Modes.AUTOTUNE      = 8;
Modes.AUTO          = 10;
Modes.RTL           = 11;
Modes.LOITER        = 12;
Modes.GUIDED        = 15;
Modes.INITIALISING  = 16;

MPData = load('C:\Program Files (x86)\Mission Planner\logs\FIXED_WING\1\2015-03-22 13-15-26.bin.mat');

Data = ReOrderMissionPlannerData(MPData);

DataInt = InterpolateMissionPlannerData(Data,'CTUN');

Idx = DataInt.MODE.ModeNum == Modes.FLY_BY_WIRE_B;

figure,plot(DataInt.CTUN.TimeMS(Idx),DataInt.NTUN.Alt(Idx),'bo');
hold on;
plot(DataInt.CTUN.TimeMS(Idx),DataInt.CTUN.ThrOut(Idx),'go');
plot([DataInt.CTUN.TimeMS(1),DataInt.CTUN.TimeMS(end)],[80,80],'r:');
