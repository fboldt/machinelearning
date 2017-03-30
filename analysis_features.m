function occurences = analysis_features(dataset, used_features)
% 
% occurences = analysis_features(dataset, used_features)
%
% dataset=load('datasets/wine.m');
% [results numfeats time used_features]=experiment_feature_selection(@feature_selection_ranking, dataset);
% occurences = analysis_features(dataset, used_features)
% [rank ordered_occurences] = sort(occurences, 'descend')
%
occurences=zeros(1, size(dataset,2)-1);
[rounds folds] = size(used_features);
for r=1:rounds
  for f=1:folds
    occurences(used_features{r,f})=occurences(used_features{r,f})+1;
  end
end

