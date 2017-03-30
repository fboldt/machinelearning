function cfs = classifier_fs(fsmethod, baseclassifier)
%
% cfs = classifier_fs(fsmethod, baseclassifier)
%
% %Example:
% dataset=load('datasets/wine.m');
% baseclassifier = classifier_knn()
% fscriterion = fscriterion_wrapper(baseclassifier)
% fsmethod = feature_selection_ranking(fscriterion)
% classifier = classifier_fs(fsmethod, baseclassifier)
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
%
% See: classifier_knn, validation_houldout, validation_crossvalidation, create_performance, ml_evaluate.
%
if exist('fsmethod')==1
  cfs.fsmethod=fsmethod;
else
  cfs.fsmethod=feature_selection_ranking();
end
if exist('baseclassifier')==1
  cfs.baseclassifier=baseclassifier;
else
  if any(strcmp('classifier',fieldnames(cfs.fsmethod.fscriterion)))
    cfs.baseclassifier=cfs.fsmethod.fscriterion.classifier;
  else
    cfs.baseclassifier=classifier_knn();
  end
end
cfs.train=@cfstrain;
cfs.predict=@cfspredict;
cfs.constructor=@classifier_fs;
cfs.classifiername='FSC - Feature Selection Classifier';
cfs.autotunning = false;
end

%%% Training function
function cfs = cfstrain(cfs, dataset)
starttime=cputime;
cfs.baseclassifier.autotunning=cfs.autotunning;
[features values] = cfs.fsmethod.execute(cfs.fsmethod, dataset);
cfs.selected_features = features;
cfs.trained_classifier = cfs.baseclassifier.train(cfs.baseclassifier, [dataset(:,cfs.selected_features),dataset(:,end)]);
cfs.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = cfspredict(cfs, dataset)
starttime=cputime;
[answers confidences] = cfs.baseclassifier.predict(cfs.trained_classifier,[dataset(:,cfs.selected_features),dataset(:,end)]);
time=cputime-starttime;
end

