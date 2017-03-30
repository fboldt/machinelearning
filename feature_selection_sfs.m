function fssfs = feature_selection_sfs(fscriterion, number_of_features)
% 
% fssfs = feature_selection_sfs(fscriterion, number_of_features)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% fssfs = feature_selection_sfs(fscriterion)
% [selected_features, time, progress_values, features_rank] = fssfs.execute(fssfs, dataset)
%
if exist('fscriterion')==1
  fssfs.fscriterion = fscriterion;
else
  fssfs.fscriterion = fscriterion_filter();
end
if exist('number_of_features')==1
  fssfs.number_of_features = number_of_features;
end
fssfs.execute=@fssfsexecute;
end

function [selected_features, time, progress_values, features_rank] = fssfsexecute(fssfs, dataset)
starttime=cputime;
numfeats=size(dataset,2)-1;
if any(strcmp('number_of_features',fieldnames(fssfs)))
  maxfeats=fssfs.number_of_features;
else
  maxfeats=numfeats;
end
selected_features=[];
progress_values=[];
features=[1:numfeats];
while length(selected_features)<maxfeats
  best_value=-1;
  for feat=setdiff(features,selected_features)
    value = fssfs.fscriterion.execute(fssfs.fscriterion, dataset(:,[selected_features,feat,end]));
    if value>best_value
      best_feature=feat;
      best_value=value;
    end
  end
  progress_values=[progress_values, best_value];
  selected_features=[selected_features, best_feature];
end
features_rank=selected_features;
if any(strcmp('number_of_features',fieldnames(fssfs)))
  selected_features = features_rank(1:fssfs.number_of_features);
else
  for feat=1:numfeats
    subset_values(feat) = fssfs.fscriterion.execute(fssfs.fscriterion, dataset(:,[features_rank(1:feat) end]));
  end
  [maximum index]=max(subset_values);
  selected_features=features_rank(1:index);
  progress_values=subset_values;
end
time=cputime-starttime;
end

