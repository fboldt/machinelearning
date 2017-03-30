function fssbs = feature_selection_sbs(fscriterion, maximum_number_of_features)
% 
% fssbs = feature_selection_sbs(fscriterion, maximum_number_of_features)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% fssbs = feature_selection_sbs(fscriterion)
% [selected_features, time, progress_values, features_rank] = fssbs.execute(fssbs, dataset)
%
if exist('fscriterion')==1
  fssbs.fscriterion = fscriterion;
else
  fssbs.fscriterion = fscriterion_filter();
end
if exist('maximum_number_of_features')==1
  fssbs.maximum_number_of_features = maximum_number_of_features;
end
fssbs.execute=@fssbsexecute;
end

function [selected_features, time, progress_values, features_rank] = fssbsexecute(fssbs, dataset)
starttime=cputime;
numfeats=size(dataset,2)-1;
if any(strcmp('maximum_number_of_features',fieldnames(fssbs)))
  maxfeats=fssbs.maximum_number_of_features;
else
  maxfeats=1;
end
selected_features=[1:numfeats];
progress_values=[fssbs.fscriterion.execute(fssbs.fscriterion, dataset)];
unselected_features=[];
while length(selected_features)>maxfeats
  best_value=-1;
  for feat=selected_features
    value = fssbs.fscriterion.execute(fssbs.fscriterion, dataset(:,[setdiff(selected_features,feat),end]));
    if value>best_value
      worst_feature=feat;
      best_value=value;
    end
  end
  progress_values=[progress_values,best_value];
  selected_features=setdiff(selected_features,worst_feature);
  unselected_features=[unselected_features,worst_feature];
end
features_rank=[selected_features, unselected_features(end:-1:1)];
%if maxfeats==1
%  [maximum index]=max(progress_values);
%  selected_features=features_rank(1:index);
%end
if any(strcmp('maximum_number_of_features',fieldnames(fssbs)))
  selected_features = features_rank(1:fssbs.maximum_number_of_features);
else
  for feat=1:numfeats
    subset_values(feat) = fssbs.fscriterion.execute(fssbs.fscriterion, dataset(:,[features_rank(1:feat) end]));
  end
  [maximum index]=max(subset_values);
  selected_features=features_rank(1:index);
  progress_values=subset_values;
end
time=cputime-starttime;
end

