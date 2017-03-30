function crossvalidation = validation_crossvalidation(number_of_folds, seed, standardization, performance, stratified)
%
% crossvalidation = validation_crossvalidation(number_of_folds, seed, standardization, performance, stratified)
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_knn()
% validation = validation_crossvalidation(5)
% [results confusion traintime testtime trained_classifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: classifier_knn, create_performance, ml_evaluate.
%
if exist('number_of_folds')==1
  crossvalidation.number_of_folds=number_of_folds;
else
  crossvalidation.number_of_folds=5;
end
if exist('stratified')==1
  crossvalidation.stratified=stratified;
else
  crossvalidation.stratified=true;
end
if exist('performance')==1
  crossvalidation.performance=performance;
else
  crossvalidation.performance=create_performance('f1avg');
end
if exist('standardization')==1
  crossvalidation.standardization=standardization;
else
  crossvalidation.standardization=true;
end
if exist('seed')==1
  crossvalidation.seed=seed;
end
crossvalidation.execute=@crossvalidationexecute;
end

function [results confusion traintime testtime trained_classifier] = crossvalidationexecute(crossvalidation, dataset, classifier)
if any(strcmp('seed',fieldnames(crossvalidation)))
  if ~is_octave
    rng(crossvalidation.seed); 
  else
    rand('seed',crossvalidation.seed);
  end
end
[data,idx] = ml_folds(dataset, crossvalidation.number_of_folds, crossvalidation.stratified);
for f = 1:crossvalidation.number_of_folds
  train=data(idx~=f,:);
  test=data(idx==f,:);
  starttime=cputime;
  [conftemp traintime{f} testtime{f} trained_classifier{f}] = ml_testing(classifier, train, test, crossvalidation.standardization);
  results(f,:) = crossvalidation.performance.execute(conftemp);
  fprintf('fold-%02d: %f\n', f, mean(results(f,:)))
  for i=1:length(conftemp)
    fprintf('confold: %d', f)
    for j=1:length(conftemp)
      fprintf(',%d', conftemp(i,j))
    end
    fprintf('\n')
  end
  if f==1
    confusion=conftemp;
  else
    confusion=confusion+conftemp;
  end
end
end

