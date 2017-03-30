function fsrfs = feature_selection_rfs(fscriterion, number_of_chances, number_of_repetitions)
% 
% fsrfs = feature_selection_rfs(fscriterion, number_of_chances, number_of_repetitions)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% fsrfs = feature_selection_rfs(fscriterion)
% [selected_features, time, progress_values] = fsrfs.execute(fsrfs, dataset)
%
if exist('fscriterion')==1
  fsrfs.fscriterion = fscriterion;
else
  fsrfs.fscriterion = fscriterion_filter();
end
if exist('number_of_chances')==1
  fsrfs.number_of_chances = number_of_chances;
else
  fsrfs.number_of_chances = -1;
end
if exist('number_of_repetitions')==1
  fsrfs.number_of_repetitions = number_of_repetitions;
else
  fsrfs.number_of_repetitions = 1;
end
fsrfs.execute=@fsrfsexecute;
end

function [selected_features, time, progress_values] = fsrfsexecute(fsrfs, dataset)
starttime=cputime;
feats=[1:size(dataset,2)-1];
features=[];
if fsrfs.number_of_chances >0
  number_of_chances = fsrfs.number_of_chances;
else
  number_of_chances = ceil(length(feats)^0.5);
end
for c=1:number_of_chances
  features=[features,feats(randperm(length(feats)))];
end
best_value=-Inf;
best_subset=[];
best_progress_values=[];
for rep=1:fsrfs.number_of_repetitions
  current_value=-Inf;
  current_subset=[];
  progress_values=[];
  for feat=features
    value = fsrfs.fscriterion.execute(fsrfs.fscriterion, dataset(:,[current_subset,feat,end]));
    if value>current_value || length(current_subset)==0
      current_value=value;
      current_subset=[current_subset,feat];
    end;
    if length(current_subset)>1
      tmpss=setdiff(current_subset, randi(length(current_subset)));
      value = fsrfs.fscriterion.execute(fsrfs.fscriterion, dataset(:,[tmpss,end]));
      if value>current_value
        current_value=value;
        current_subset=tmpss;
      end
    end
    progress_values=[progress_values, current_value];
  end
  if current_value>best_value;
      best_value=current_value;
      best_subset=current_subset;
      best_progress_values=progress_values;
  end
end
selected_features=best_subset;
progress_values=best_progress_values;
time=cputime-starttime;
end

