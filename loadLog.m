function log = loadLog()
% Select a log using UI, saving location for next call.

    persistent fpath;
    
    if isempty(fpath) || length(fpath)==1 || ~exist(fpath,'dir')
        fpath = pwd;
    end
    
    [fname,fpathOut,~] = uigetfile({'*.log;*.mat;*.BIN'},'Select',fpath);
    
    if fname==0
        log = [];
    else
        fpath = fpathOut;
        fprintf('%s %s\n', fname,fpath);

        aplog = Ardupilog(fullfile(fpath,fname));

        log = aplog.getStruct();
        log = fillNKF1(log);
        log = NormaliseTimes(log);
    end
end

