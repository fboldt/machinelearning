function fsall = feature_selection_all(fscriterion)
% 
% fsall = feature_selection_best_random(fscriterion)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fsall = feature_selection_all()
% [selected_features, time] = fsall.execute(fsall, dataset)
%
fsall.execute = @fsallexecute;
end

function [selected_features, time] = fsallexecute(fsall, dataset)
  starttime=cputime;
  numfeats=size(dataset,2)-1;
  selected_features=[1:numfeats];
  time=cputime-starttime;
end


