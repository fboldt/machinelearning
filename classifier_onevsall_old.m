function classifier = classifier_onevsall(baseclassifier)
%
% classifier = classifier_onevsall(baseclassifier)
%
% %Example:
% dataset=load('datasets/wine.m');
% baseclassifier = classifier_linear_machine;
% classifier = classifier_onevsall(baseclassifier)
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
%
% See: classifier_elm, validation_houldout, validation_crossvalidation, create_performance, ml_evaluate.
%
if exist('baseclassifier')==1
  classifier.baseclassifier=baseclassifier;
else
  classifier.baseclassifier=classifier_linear_machine;
end
classifier.train=@classifiertrain;
classifier.predict=@classifierpredict;
classifier.classifiername='1vs1 - One vs. All';
classifier.constructor=@classifier_onevsall;
end

%%% Training function
function classifier = classifiertrain(classifier, dataset)
starttime=cputime;
classifier.labels=unique(dataset(:,end));
for i=1:length(classifier.labels)
  labelsi = dataset;
  labelsi(:,end) = dataset(:,end)==classifier.labels(i);
  classifier.trained_classifier{i} = classifier.baseclassifier.train(classifier.baseclassifier, labelsi);
end
classifier.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = classifierpredict(classifier, dataset)
starttime=cputime;
nl = length(classifier.labels);
tmp_answers = zeros(size(dataset,1), (nl*(nl-1))/2)-1;
tmp_confidence = zeros(size(dataset,1), (nl*(nl-1))/2)-1;
for i=1:nl
  [tmp_answers(:,i) tmp_confidence(:,i)] = classifier.baseclassifier.predict(classifier.trained_classifier{i},dataset);
end
if length(classifier.labels)==2
  answers = tmp_answers{1,2};
  confidences = tmp_confidence{1,2};
else
  %for i=1:length(classifier.labels)
  %  confidence(:,i)=mean((((tmp_answers==classifier.labels(i)).*tmp_confidence)')';
  %end
  confidence = tmp_answers.*tmp_confidence;
  [confidences labels_indexes]=max(confidence');
  labels=repmat(classifier.labels, 1, length(labels_indexes));
  answers = labels(labels_indexes');
end
time=cputime-starttime;
end



