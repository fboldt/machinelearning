function cascade = feature_selection_cascade()
% 
% cascade = feature_selection_cascade()
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% cascade = feature_selection_cascade()
% cascade = cascade.add_feature_selection_method(cascade, feature_selection_sfs(fscriterion));
% cascade = cascade.add_feature_selection_method(cascade, feature_selection_clonalg(fscriterion));
% [selected_features time] = cascade.execute(cascade, dataset)
%
cascade.fsm={};
cascade.execute=@cascadeexecute;
cascade.add_feature_selection_method=@addfsm;
end

function [selected_features time] = cascadeexecute(cascade, dataset)
cascade = cascade.add_feature_selection_method(cascade, feature_selection_all);
starttime=cputime;
selected_features=randperm(size(dataset,2)-1);
for i=1:length(cascade.fsm)
  selfeats = cascade.fsm{i}.execute(cascade.fsm{i}, dataset(:,[selected_features end]));
  selected_features = selected_features(selfeats);
end
time=cputime-starttime;
end

function newcascade = addfsm(cascade, fsm)
n = length(cascade.fsm);
cascade.fsm{n+1}=fsm;
newcascade=cascade;
end

