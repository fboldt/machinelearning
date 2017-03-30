function cfse = classifier_ifse(fsmethod, baseclassifier, numberofclassifiers)
%
% cfse = classifier_ifse(fsmethod, baseclassifier, numberofclassifiers)
%
% %Example:
% dataset=load('datasets/wine.m');
% baseclassifier = classifier_knn()
% fscriterion = fscriterion_wrapper(baseclassifier)
% fsmethod = feature_selection_ranking(fscriterion)
% numberofclassifiers = 3
% classifier = classifier_ifse(fsmethod, baseclassifier, numberofclassifiers)
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
%
% See: classifier_knn, validation_houldout, validation_crossvalidation, create_performance, ml_evaluate.
%
if exist('fsmethod')==1
  cfse.fsmethod=fsmethod;
else
  cfse.fsmethod=feature_selection_ranking();
end
if exist('baseclassifier')==1
  cfse.baseclassifier=baseclassifier;
else
  if any(strcmp('classifier',fieldnames(cfse.fsmethod.fscriterion)))
    cfse.baseclassifier=cfse.fsmethod.fscriterion.classifier;
  else
    cfse.baseclassifier=classifier_knn();
  end
end
if exist('numberofclassifiers')==1
  cfse.numberofclassifiers=numberofclassifiers;
else
  cfse.numberofclassifiers=1;
end
cfse.train=@cfsetrain;
cfse.predict=@cfsepredict;
cfse.constructor=@classifier_ifse;
cfse.classifiername='FSE - Feature Selection Ensemble';
cfse.autotunning = false;
end

%%% Training function
function cfse = cfsetrain(cfse, dataset)
starttime=cputime;
fscla = classifier_fs(cfse.fsmethod, cfse.baseclassifier);
if cfse.numberofclassifiers>1
randens = classifier_random_ensemble(fscla, cfse.numberofclassifiers, 1, 1);
else
randens = classifier_random_ensemble(fscla, 1, 1);
end
ovocla = classifier_ionevsone(randens); 
cfse.trained_classifier = ovocla.train(ovocla, dataset);
count=1;
for j=1:length(cfse.trained_classifier.trained_classifier)
  for i=1:length(cfse.trained_classifier.trained_classifier{j})
    used_features{count} = cfse.trained_classifier.trained_classifier{j}.trained_classifier{i}.selected_features;
    count=count+1;
  end
end
occurences = analysis_features(dataset, used_features);
features = [1:size(dataset,2)];
cfse.selected_features = features(occurences>0);
cfse.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = cfsepredict(cfse, dataset)
starttime=cputime;
[answers confidence] = cfse.trained_classifier.predict(cfse.trained_classifier,dataset);
time=cputime-starttime;
end

