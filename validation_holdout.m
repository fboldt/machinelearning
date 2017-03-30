function holdout = validation_holdout(proportion, seed, standardization, performance, stratified)
%
% holdout = validation_holdout(proportion, seed, standardization, performance, stratified)
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_knn()
% validation = validation_holdout(0.5)
% [results confusion traintime testtime trained_classifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: classifier_knn, create_performance, ml_evaluate.
%
if exist('proportion')==1
  holdout.proportion=proportion;
else
  holdout.proportion=0.8;
end
if exist('stratified')==1
  holdout.stratified=stratified;
else
  holdout.stratified=true;
end
if exist('performance')==1
  holdout.performance=performance;
else
  holdout.performance=create_performance('f1avg');
end
if exist('standardization')==1
  holdout.standardization=standardization;
else
  holdout.standardization=true;
end
if exist('seed')==1
  holdout.seed=seed;
end
holdout.execute=@holdoutexecute;
end

function [value confusion traintime testtime trained_classifier] = holdoutexecute(holdout, dataset, classifier)
if any(strcmp('seed',fieldnames(holdout)))
  if ~is_octave
    rng(holdout.seed);
  else
    rand('seed',holdout.seed);
  end
end
[train,test] = ml_split(dataset, holdout.proportion, holdout.stratified);
[confusion traintime testtime trained_classifier] = ml_testing(classifier, train, test, holdout.standardization);
value = holdout.performance.execute(confusion);
end

