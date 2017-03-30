function classifier = classifier_onevsone(baseclassifier)
%
% classifier = classifier_onevsone(baseclassifier)
%
% %Example:
% dataset=load('datasets/wine.m');
% baseclassifier = classifier_knn;
% classifier = classifier_onevsone(baseclassifier)
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
classifier.classifiername='1vs1 - One vs. One';
classifier.constructor=@classifier_onevsone;
end

%%% Training function
function classifier = classifiertrain(classifier, dataset)
starttime=cputime;
classifier.labels=unique(dataset(:,end));
nlabels = length(classifier.labels);
classifier.codematrix = [];
count=1;
for i=1:length(classifier.labels)-1
  labelsi = dataset(:,end)==classifier.labels(i);
  for j=(i+1):length(classifier.labels)
    classifier.codematrix(:,count) = zeros(nlabels,1);
    classifier.codematrix(i,count) = 1;
    classifier.codematrix(j,count) = -1;
    labelsj = dataset(:,end)==classifier.labels(j);
    classifier.trained_classifier{count} = classifier.baseclassifier.train(classifier.baseclassifier, [[dataset(labelsi,1:end-1) ones(sum(labelsi),1)];[dataset(labelsj,1:end-1) -1*ones(sum(labelsj),1)]]);
    count=count+1;
  end
end
classifier.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = classifierpredict(classifier, dataset)
starttime=cputime;
tmp_answers = [];
tmp_confidence = [];
for i=1:length(classifier.trained_classifier)
    [tmp_answers(:,i) tmp_confidence(:,i)] = classifier.baseclassifier.predict(classifier.trained_classifier{i},dataset);
end
[confidences idx] = max([tmp_confidence.*tmp_answers*(classifier.codematrix')*(1/(length(classifier.labels)-1))]');

answers = classifier.labels(idx);
time=cputime-starttime;
end

