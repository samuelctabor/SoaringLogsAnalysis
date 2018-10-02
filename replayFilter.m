function Data=replayFilter( Data)
%replayFilter Run an EFK filter using the readings logged during an actual
%flight.
%   Data is a structure containing the filter settings and the flight data.

    nt = numel(Data.Time);
    
    have_x=1;
    if ~any(strcmpi(fieldnames(Data),'x'))
        have_x=0;
        Data.X=zeros(nt,4);
    end
    Data.P=zeros(nt,4,4);
    Data.EstPosM=zeros(nt,2);

    ekf=ExtendedKalmanFilter_thermal(Data.Pinit,Data.Xinit,Data.Q,Data.R);

    for k=1:nt
        if ~have_x
            Data.X(k,:)=ekf.x;
        end
        Data.X_replay(k,:)=ekf.x;
        Data.P(k,:,:)=ekf.P;
        Data.residual(k)=ekf.residual;
        ekf.update(Data.FilterInputs(k,1),Data.FilterInputs(k,2),Data.FilterInputs(k,3));
    end
    Data.EstPosM = Data.AircraftPosition(:,1:2)+fliplr(Data.X(:,3:4));
    if have_x
        [resid,idx] = max(max(abs(Data.X-Data.X_replay)));
        if resid>1e-3
            warning('Mismatch between recalculated and logged states! Max resid of %f in state %i',resid,idx);
        end
    end
end

