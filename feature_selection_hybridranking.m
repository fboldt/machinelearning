function fsranking = feature_selection_hybridranking(fscriterion)
% 
% fsranking = feature_selection_hybridranking(fscriterion)
%
% % Example 1:
% dataset=load('datasets/iris.m');
% fscriterion = fscriterion_wrapper(classifier_knn)
% fsranking = feature_selection_hybridranking(fscriterion)
% [selected_features time rank_value features_rank] = fsranking.execute(fsranking, dataset)
%
if exist('fscriterion')==1
  fsranking.fscriterion = fscriterion;
else
  fsranking.fscriterion = fscriterion_filter();
end
fsranking.execute=@fsrankingexecute;
end

function [selected_features, time, rank_value, features_rank] = fsrankingexecute(fsranking, dataset)
starttime=cputime;
numfeats=size(dataset,2)-1;
feature_values=zeros(numfeats,1);
fsc = fscriterion_filter;
fsr = feature_selection_ranking(fsc);
[selected_features time rank_value features_rank] = fsr.execute(fsr, dataset);
for feat=1:numfeats
  subset_values(feat) = fsranking.fscriterion.execute(fsranking.fscriterion, dataset(:,[features_rank(1:feat) end]));
end
[maximum index]=max(subset_values);
selected_features=features_rank(1:index);
time=cputime-starttime;
end

