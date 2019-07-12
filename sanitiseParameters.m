function LogOut = sanitiseParameters(LogIn)
%sanitiseParameters
    excludeParams = {'STAT_RUNTIME', 'STAT_FLTTIME','GND_ABS_PRESS'};

    PARM = LogIn.PARM;
    PARM.Name(PARM.Name==char(0)) = char(32);
    PARM.Name = string(PARM.Name);
    PARM.Name = strtrim(PARM.Name);

    idx = ismember(PARM.Name, excludeParams);

    PARM.Name(idx)   = [];
    PARM.TimeUS(idx) = [];
    PARM.TimeS(idx)  = [];
    PARM.LineNo(idx) = [];
    PARM.Value(idx)  = [];
    PARM.Time(idx)   = [];
    PARM.DatenumUTC(idx) = [];

    % Remove repeated params (MP sends twice)
    idx = find(strcmp(PARM.Name(1:end-1), PARM.Name(2:end)) & PARM.Value(1:end-1)==PARM.Value(2:end) & abs(PARM.Time(1:end-1) - PARM.Time(2:end))<1);

    PARM.Name(idx)   = [];
    PARM.TimeUS(idx) = [];
    PARM.TimeS(idx)  = [];
    PARM.LineNo(idx) = [];
    PARM.Value(idx)  = [];
    PARM.Time(idx)   = [];
    PARM.DatenumUTC(idx) = [];
    
    LogOut = LogIn;
    LogOut.PARM = PARM;
end

