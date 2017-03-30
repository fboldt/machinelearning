function classifier = classifier_clonalge(fscriterion, baseclassifier,  numberofclassifiers)
%
% classifier = classifier_clonalge(fscriterion, baseclassifier,  numberofclassifiers)
%
% %Example:
% dataset=load('datasets/wine.m');
% baseclassifier = classifier_knn()
% fscriterion = fscriterion_wrapper(baseclassifier)
% classifier = classifier_clonalge(fscriterion, baseclassifier)
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
%
% See: classifier_knn, validation_houldout, validation_crossvalidation, create_performance, ml_evaluate.
%
if exist('fscriterion')==1
  classifier.fscriterion = fscriterion;
else
  classifier.fscriterion = fscriterion_filter();
end
if any(strcmp('classifier',fieldnames(classifier.fscriterion)))
  classifier.baseclassifier=classifier.fscriterion.classifier;
else
  classifier.baseclassifier=classifier_knn();
end
if exist('baseclassifier')==1
  classifier.baseclassifier=baseclassifier;
else
  classifier.baseclassifier=classifier_knn;
end
classifier.numberofclassifiers=0;
if exist('numberofclassifiers')==1 
  classifier.numberofclassifiers=numberofclassifiers;
end
classifier.train=@classifiertrain;
classifier.predict=@classifierpredict;
classifier.constructor=@classifier_clonalge;
classifier.classifiername='CLONALGE - Clonalg Ensemble';
classifier.autotunning = false;
end

%%% Training function
function classifier = classifiertrain(classifier, dataset)
starttime=cputime;
classifier.labels=unique(dataset(:,end));
fsclonalg = feature_selection_clonalg(classifier.fscriterion);
if classifier.numberofclassifiers<2
  noc = 2;
else
  noc = classifier.numberofclassifiers;
end
[selected_features, fitness, time] = fsclonalg.multisol(fsclonalg, dataset, noc);
if classifier.numberofclassifiers<1
  noc = 1;
end
if noc > length(selected_features)
  noc = length(selected_features);
end
for i=1:noc
  classifier.trained_classifier{i} = classifier.baseclassifier.train(classifier.baseclassifier,[dataset(:,selected_features{i}),dataset(:,end)]);
  classifier.selected_features{i} = selected_features{i};
end
classifier.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = classifierpredict(classifier, dataset)
starttime=cputime;
for i=1:length(classifier.trained_classifier)
    [tmp_answers(:,i) tmp_confidence(:,i)] = classifier.baseclassifier.predict(classifier.trained_classifier{i},[dataset(:,classifier.selected_features{i}),dataset(:,end)]);
end
if length(classifier.trained_classifier)==1
  answers = tmp_answers;
  confidences = tmp_confidence;
else
  for i=1:length(classifier.labels)
    confidence(:,i)=mean(((tmp_answers==classifier.labels(i)).*tmp_confidence)')';
  end
  [confidences labels_indexes]=max(confidence');
  labels=repmat(classifier.labels, 1, length(labels_indexes));
  answers = labels(labels_indexes');
end
time=cputime-starttime;
end

