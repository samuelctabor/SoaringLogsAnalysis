function log = fillNKF1(log)
% fillNKF1 Adds in data for NKF1 (specifically position in m) in case EKF
% was not running. This is the case for simulations using EKF_TYPE=10
% (SITL).

    if isfield(log,'NKF1') && ~isempty(log.NKF1.TimeUS)
        % Looks like we already have NKF1 data.
        return;
    end
    
    earthRad = 6.3781*1e6;
    
    ind = log.AHR2.Lat ~= 0  & log.AHR2.Lng ~= 0;
    idx = find(ind, 1, 'first');
    homePos = [log.AHR2.Lat(idx), log.AHR2.Lng(idx)];
    
    log.NKF1.TimeUS = log.AHR2.TimeUS(ind);
    log.NKF1.TimeS  = log.AHR2.TimeUS/1e6;
    
    log.NKF1.PD = -log.AHR2.Alt(ind);
    
    log.NKF1.PN = [log.AHR2.Lat(ind) - homePos(1)] * earthRad;
    log.NKF1.PE = [log.AHR2.Lng(ind) - homePos(2)] * earthRad * cos(homePos(1));
end

