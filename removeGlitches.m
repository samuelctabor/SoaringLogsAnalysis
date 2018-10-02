function Data = removeGlitches(Data)
% Check for glitches.
    idx = find((Data.Time(2:end) - Data.Time(1:end-1)) < 0, 1, 'first');
    
    while ~isempty(idx)
        if idx<length(Data.Time)/2
            Data = structfun(@(x) rmStart(x,idx), Data ,'UniformOutput',false);
        else
            Data = structfun(@(x) rmEnd(x,idx), Data ,'UniformOutput',false);
        end
        idx = find((Data.Time(2:end) - Data.Time(1:end-1)) < 0, 1, 'first');
    end
end

function x=rmStart(x, idx)
    x(1:idx)=[];
end

function x=rmEnd(x, idx)
    x(idx:end)=[];
end