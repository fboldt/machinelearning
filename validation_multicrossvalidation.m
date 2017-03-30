function multicrossvalidation = validation_multicrossvalidation(number_of_rounds, number_of_folds, seed, standardization, performance, stratified)
%
% multicrossvalidation = validation_multicrossvalidation(number_of_rounds, number_of_folds, seed, standardization, performance, stratified)
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_knn()
% validation = validation_multicrossvalidation(5)
% [results confusion traintime testtime trained_classifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: classifier_knn, create_performance, ml_evaluate.
%


if exist('stratified')==1
  multicrossvalidation.crossvalidation = validation_crossvalidation(number_of_folds, seed, standardization, performance, stratified);
  else
  if exist('performance')==1
    multicrossvalidation.crossvalidation = validation_crossvalidation(number_of_folds, seed, standardization, performance);
  else
    if exist('standardization')==1
      multicrossvalidation.crossvalidation = validation_crossvalidation(number_of_folds, seed, standardization);
    else
      if exist('seed')==1
        multicrossvalidation.crossvalidation = validation_crossvalidation(number_of_folds, seed);
      else
        if exist('number_of_folds')==1
          multicrossvalidation.crossvalidation = validation_crossvalidation(number_of_folds);
        else
          multicrossvalidation.crossvalidation = validation_crossvalidation();
        end
      end
    end
  end
end
if exist('seed')==1
  multicrossvalidation.seed=seed;
end
if exist('number_of_rounds')==1
  multicrossvalidation.number_of_rounds=number_of_rounds;
else
  multicrossvalidation.number_of_rounds=5;
end
multicrossvalidation.execute=@multicrossvalidationexecute;
end

function [results confusion traintime testtime trained_classifier] = multicrossvalidationexecute(multicrossvalidation, dataset, classifier)
if any(strcmp('seed',fieldnames(multicrossvalidation)))
  if ~is_octave
    rng(multicrossvalidation.seed);
  else
    rand('seed',multicrossvalidation.seed);
  end
end
seeds=randperm(10000);
for r=1:multicrossvalidation.number_of_rounds
  multicrossvalidation.crossvalidation.seed=seeds(r);
  fprintf('round %2d -> seed: %4d | ', r, seeds(r));
  starttime=cputime;
  [results(:,r) confusion{r} trtime tetime trcla] = ml_evaluate(dataset, classifier, multicrossvalidation.crossvalidation);
  time=cputime-starttime;
  meanfeats=0;
  for f=1:multicrossvalidation.crossvalidation.number_of_folds
    traintime{f,r} = trtime{f};
    testtime{f,r} = tetime{f};
    trained_classifier{f,r} = trcla{f};
  end
  meanfeats=meanfeats/multicrossvalidation.crossvalidation.number_of_folds;
  fprintf('perf: %f, time: %f\n', mean(results(:,r)), time);
end
end

