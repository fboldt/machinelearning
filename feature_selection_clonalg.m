function fsclonalg = feature_selection_clonalg(fscriterion)
% 
% fsclonalg = feature_selection_clonalg(fscriterion)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% fsclonalg = feature_selection_clonalg(fscriterion)
% [selected_features, time] = fsclonalg.execute(fsclonalg, dataset)
%

if exist('fscriterion')==1
  fsclonalg.fscriterion = fscriterion;
else
  fsclonalg.fscriterion = fscriterion_filter();
end
fsclonalg.execute=@fsclonalgexecute;
fsclonalg.multisol=@multisol;
end

function [selected_features, time] = fsclonalgexecute(fsclonalg, dataset)
  numfeats=size(dataset,2)-1;
  [selected_solutions, fitness, time] = multisol(fsclonalg, dataset, ceil(numfeats^0.5));
  selected_features = selected_solutions{1};
end

function [selected_features, fitness, time] = multisol(fsclonalg, dataset, numsets)
starttime=cputime;
numfeats=size(dataset,2)-1;
if numfeats<=1
  time=cputime-starttime;
  selected_features{1}=[1];
  fitness = [0];
  time=cputime-starttime;
  return
end
if exist('numsets')~=1
  numsets = ceil(numfeats^0.5);
end
features=[1:numfeats];
fitness_function=@fsfitness;
population=rand(numsets,numfeats)>0.5;
%population=rand(numfeats,numfeats)>0.5;
params.data=dataset;
params.fscriterion=fsclonalg.fscriterion;
params.gen = 5*ceil(numfeats^0.5);
solutions = clonalg(fitness_function, population, params);
fitness = fitness_function(solutions, params);
[fitness,ind] = sort(fitness,'descend');
selected_features={};
for i=ind
  selected_features{i} = features(solutions(i,:));
end
time=cputime-starttime;
end

