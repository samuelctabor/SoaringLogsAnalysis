function LogOut = populateModeNames(LogIn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    modeNames = ...  
       {'MANUAL'
        'CIRCLE'
        'STABILIZE'
        'TRAINING'
        'ACRO'
        'FLY_BY_WIRE_A'
        'FLY_BY_WIRE_B'
        'CRUISE'
        'AUTOTUNE'
        ''
        'AUTO'
        'RTL'
        'LOITER'
        ''
        'AVOID_ADSB'
        'GUIDED'
        'INITIALISING'
        'QSTABILIZE'
        'QHOVER'
        'QLOITE'
        'QLAND'
        'QRTL'};

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
%     AVOID_ADSB    = 14,
%     GUIDED        = 15,
%     INITIALISING  = 16,
%     QSTABILIZE    = 17,
%     QHOVER        = 18,
%     QLOITER       = 19,
%     QLAND         = 20,
%     QRTL          = 21

    LogOut = LogIn;
    
    for iT=1:length(LogOut.MODE.TimeS)
        LogOut.MODE.ModeName{iT} = modeNames{LogOut.MODE.ModeNum(iT)+1};
    end
end