function log = loadLog(filepath)
% Select a log using UI, saving location for next call.

    if nargin<1
        persistent fpath;

        if isempty(fpath) || length(fpath)==1 || ~exist(fpath,'dir')
            fpath = pwd;
        end

        [fname,fpathOut,~] = uigetfile({'*.log;*.mat;*.BIN'},'Select',fpath);

        if fname==0
            log = [];
            return;
        else
            fpath = fpathOut;
            fprintf('%s %s\n', fname,fpath);

            filepath = fullfile(fpath,fname);
        end
    end 

    aplog = Ardupilog(filepath);

    log = aplog.getStruct();
    log = fillNKF1(log);
    log = NormaliseTimes(log);
end

