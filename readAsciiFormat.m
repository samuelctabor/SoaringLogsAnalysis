function Log = readLog(fileName)
%readLog Read the new datalog format.
    
    str = sprintf('grep -E ''SOAR|GPS'' %s | grep -v NKF > tmplog.txt',strrep(fileName,' ','\ '));
    system(str);
    
    fid = fopen('tmplog.txt');
    
    
    line = fgetl(fid);
    
    % Format is as follows.
    %2017-02-28 21:53:41.88: SOAR {TimeUS : 259694000, nettorate : 1.72906470299, dx : -0.449217021465, dy : 0.0431920625269, x0 : 2.0, x1 : 30.0, x2 : -4.98270225525, x3 : 0.415542244911, lat : 1e-07, lng : -46.1%
    SoarData={};
    GPSData = {};
    while ischar(line)
        if ~isempty(strfind(line,'SOAR'))
                dat = textscan(line,'%f-%f-%f %f:%f:%f: %s {%s : %d, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f}');

                if ~any(cellfun(@isempty,dat))
                    SoarData(end+1,:) = dat;
                end
        elseif ~isempty(strfind(line,'GPS'))            
                dat = textscan(line,'%f-%f-%f %f:%f:%f: %s {%s : %d, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f, %s : %f}');

                if ~any(cellfun(@isempty,dat))
                    GPSData(end+1,:) = dat;
                end
        end
        line = fgetl(fid);
    end

   Log.GPS  = DataToStruct(GPSData);
   Log.Soar = DataToStruct(SoarData);
end

function Struct = DataToStruct(Data)
    Struct.Time = datenum(cell2mat(Data(:,1:6)));
                            
    % Assign to structure
    for i=8:2:size(Data,2)
        fieldname = Data{1,i}{1};
        data=[Data{:,i+1}];
        Struct.(fieldname) = data(:);
    end
end

