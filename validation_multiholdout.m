function multiholdout = validation_multiholdout(repetitions, proportion, seed, standardization, performance, stratified)
%
% multiholdout = validation_multiholdout(repetitions, proportion, seed, standardization, performance, stratified)
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_knn()
% validation = validation_multiholdout(3)
% [results confusion traintime testtime trained_classifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: classifier_knn, create_performance, ml_evaluate.
%

if exist('stratified')==1
  multiholdout.holdout = validation_holdout(proportion, seed, standardization, performance, stratified);
  else
  if exist('performance')==1
    multiholdout.holdout = validation_holdout(proportion, seed, standardization, performance);
  else
    if exist('standardization')==1
      multiholdout.holdout = validation_holdout(proportion, seed, standardization);
    else
      if exist('seed')==1
        multiholdout.holdout = validation_holdout(proportion, seed);
      else
        if exist('proportion')==1
          multiholdout.holdout = validation_holdout(proportion);
        else
          multiholdout.holdout = validation_holdout();
        end
      end
    end
  end
end
if exist('repetitions')==1
  multiholdout.repetitions=repetitions;
else
  multiholdout.repetitions=5;
end
multiholdout.execute=@multiholdoutexecute;
end

function [results confusion traintime testtime trained_classifier] = multiholdoutexecute(multiholdout, dataset, classifier)
if any(strcmp('seed',fieldnames(multiholdout)))
  if ~is_octave
    rng(multiholdout.seed);
  else
    rand('seed',multiholdout.seed);
  end
end
seeds=randperm(1000);
for r=1:multiholdout.repetitions
  multiholdout.holdout.seed=seeds(r);
  [results(r,:) confusion{r} traintime{r} testtime{r} trained_classifier{r}] = ml_evaluate(dataset, classifier, multiholdout.holdout);
end
end

