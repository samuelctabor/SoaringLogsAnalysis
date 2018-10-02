function [ DataOut ] = InterpolateMissionPlannerData( Data, MessageForTime )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    Messages    = fieldnames(Data);
    if ~ismember(MessageForTime,Messages)
        error('%s not a message in data!');
    end
    
    CommonTime = Data.(MessageForTime).TimeMS;
    CommonTime = unique(CommonTime);
    
    for iMessage=1:length(Messages)
        thisMessage = Messages{iMessage};
        if any(strcmp(thisMessage,{'MSG','STRT'}))
           continue;
        end
        Fields = fieldnames(Data.(thisMessage));
        thisTime = Data.(thisMessage).TimeMS;
        [thisTime,IA]=unique(thisTime);
        DataOut.(thisMessage).TimeMS = CommonTime;
        for jField=1:length(Fields)
            if ~strcmp(Fields{jField},'TimeMS')
                thisData = Data.(thisMessage).(Fields{jField});
                thisData = thisData(IA);
                if strcmp(thisMessage,'MODE')
                    DataOut.(thisMessage).(Fields{jField}) = ...
                        GetPrevious(thisTime,thisData,CommonTime);
                else
                DataOut.(thisMessage).(Fields{jField}) = ...
                    interp1(thisTime,thisData,CommonTime);
                end
            end
        end
    end
    
end

function Out = GetPrevious(Times1,Data,Times2)
    N1 = length(Times1);
    N2 = length(Times2);
    
    Times1R =repmat(Times1, 1,N2);
    Times2R =repmat(Times2',N1,1);
    
    dT = Times2R - Times1R;
    dTc = dT>0;
    
    idx = zeros(size(Times2));
    for i=1:N2
        idx(i) = find(dTc(:,i),1,'last');
    end
        
    Out  = Data(idx);
end
    
    


