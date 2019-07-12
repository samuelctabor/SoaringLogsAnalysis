function log=LoadLatestBINFile(logPath, id, useMAT)
    addpath('~/Documents/kps_simulation_environment/ardupilog');
    
    if nargin<2 || isempty(id)
        fid = fopen([logPath,'/LASTLOG.TXT']);
        line = fgetl(fid);
        fclose(fid);
        id = str2double(line);
    end
    
    logname = sprintf('%08i',id);
    
    fprintf("Log = %s\n", logname);
    
    file = dir([logPath,'/',logname,'.BIN']);
    
    if useMAT
        matfiles = dir([logPath, '/',logname,'.mat']);
        matfiledate = max([matfiles.datenum]);
    
        if file.datenum<matfiledate
            warning('No new log');
            log=load([logPath,'/',logname,'.mat']);
            return;
        end
    end
    

    log = Ardupilog(fullfile(logPath,[logname,'.BIN']));
    log = log.getStruct();
    log = NormaliseTimes(log);
    log.PARM.Name = cellstr(log.PARM.Name);

    if useMAT
        save([logPath,'/',logname,'.mat'], '-struct','Log');
    end
end