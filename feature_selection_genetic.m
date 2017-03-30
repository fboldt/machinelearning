function fsgenetic = feature_selection_genetic(fscriterion)
% 
% fsgenetic = feature_selection_genetic(fscriterion)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% fsgenetic = feature_selection_genetic(fscriterion)
% [selected_features, time] = fsgenetic.execute(fsgenetic, dataset)
%

if exist('fscriterion')==1
  fsgenetic.fscriterion = fscriterion;
else
  fsgenetic.fscriterion = fscriterion_filter();
end
fsgenetic.execute=@fsgeneticexecute;
end

function [selected_features, time] = fsgeneticexecute(fsgenetic, dataset)
starttime=cputime;
numfeats=size(dataset,2)-1;
features=[1:numfeats];
params.data=dataset;
params.fscriterion=fsgenetic.fscriterion;
fitness_function=@(filters)fsfitness_ga(filters, params);
gaoptions=gaoptimset('display','off');
[solution value] = ga(fitness_function, numfeats, gaoptions);
value=-value;
selected_features = features(solution>0);
time=cputime-starttime;
end

function fit = fsfitness_ga(filters, params)
fit = -fsfitness(filters>0, params);
end

