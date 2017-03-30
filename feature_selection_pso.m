function fspso = feature_selection_pso(fscriterion)
% 
% fspso = feature_selection_pso(fscriterion)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% fspso = feature_selection_pso(fscriterion)
% [selected_features, time] = fspso.execute(fspso, dataset)
%

if exist('fscriterion')==1
  fspso.fscriterion = fscriterion;
else
  fspso.fscriterion = fscriterion_filter();
end
fspso.execute=@fspsoexecute;
end

function [selected_features, time] = fspsoexecute(fspso, dataset)
starttime=cputime;
numfeats=size(dataset,2)-1;
features=[1:numfeats];
params.data=dataset;
params.fscriterion=fspso.fscriterion;
fitness_function=@(filters)fsfitness_pso(filters, params);
options = optimoptions('particleswarm','display','off');
%lb = zeros(numfeats,1);
%ub = ones(numfeats,1);
%[solution value] = particleswarm(fitness_function, numfeats, lb, ub, options);
[solution value] = particleswarm(fitness_function, numfeats, [], [], options);
value=-value;
selected_features = features(solution>0);
time=cputime-starttime;
end

function fit = fsfitness_pso(filters, params)
fit = -fsfitness(filters>0, params);
end

