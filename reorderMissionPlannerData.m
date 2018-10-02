function Data=ReOrderMissionPlannerData(MPData)
% Reorder Mission Planner matlab data. This comes as a structure
% containing, for each message X, the fields X and
% X_label. X is an array, and X_label a cell array
% containing the names of the columns in X. This function converts to
% a structure, each member of which is named one of X_label and
% contains the corresponding data from X.

    for iMessage=1:length(MPData.Seen)
        thisLabels = eval(['MPData.',MPData.Seen{iMessage},'_label']);
        thisVars   = eval(['MPData.',MPData.Seen{iMessage}]);

        for iField = 1:length(thisLabels)
            thisLabel = regexprep(thisLabels{iField},'\W','');
            Data.(MPData.Seen{iMessage}).(thisLabel) = thisVars(:,iField);
        end
    end
end
