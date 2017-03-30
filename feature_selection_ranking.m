function fsranking = feature_selection_ranking(fscriterion, number_of_features)
% 
% fsranking = feature_selection_ranking(fscriterion, number_of_features)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% fsranking = feature_selection_ranking(fscriterion)
% [selected_features time rank_value features_rank] = fsranking.execute(fsranking, dataset)
%
if exist('fscriterion')==1
  fsranking.fscriterion = fscriterion;
else
  fsranking.fscriterion = fscriterion_filter();
end
if exist('number_of_features')==1
  fsranking.number_of_features = number_of_features;
end
fsranking.execute=@fsrankingexecute;
end

function [selected_features, time, rank_value, features_rank] = fsrankingexecute(fsranking, dataset)
starttime=cputime;
numfeats=size(dataset,2)-1;
feature_values=zeros(numfeats,1);
for feat=1:numfeats
  feature_values(feat) = fsranking.fscriterion.execute(fsranking.fscriterion, dataset(:,[feat end]));
end
[rank_value,features_rank]=sort(feature_values,'descend');
rank_value=rank_value';
features_rank=features_rank';
if any(strcmp('number_of_features',fieldnames(fsranking)))
  selected_features = features_rank(1:fsranking.number_of_features);
else
  for feat=1:numfeats
    subset_values(feat) = fsranking.fscriterion.execute(fsranking.fscriterion, dataset(:,[features_rank(1:feat) end]));
  end
  [maximum index]=max(subset_values);
  selected_features=features_rank(1:index);
end
time=cputime-starttime;
end

