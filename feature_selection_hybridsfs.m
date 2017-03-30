function fssfs = feature_selection_hybridsfs(fscriterion)
% 
% fssfs = feature_selection_hybridsfs(fscriterion)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% fssfs = feature_selection_hybridsfs(fscriterion)
% [selected_features, time, progress_values, features_rank] = fssfs.execute(fssfs, dataset)
%
if exist('fscriterion')==1
  fssfs.fscriterion = fscriterion;
else
  fssfs.fscriterion = fscriterion_filter();
end
fssfs.execute=@fssfsexecute;
end

function [selected_features, time, rank_value, features_rank] = fssfsexecute(fsranking, dataset)
starttime=cputime;
numfeats=size(dataset,2)-1;
feature_values=zeros(numfeats,1);
fsc = fscriterion_filter;
fsr = feature_selection_sfs(fsc);
[selected_features time rank_value features_rank] = fsr.execute(fsr, dataset);
for feat=1:numfeats
  subset_values(feat) = fsranking.fscriterion.execute(fsranking.fscriterion, dataset(:,[features_rank(1:feat) end]));
end
[maximum index]=max(subset_values);
selected_features=features_rank(1:index);
time=cputime-starttime;
end

