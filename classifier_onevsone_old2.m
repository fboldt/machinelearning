function classifier = classifier_onevsone(baseclassifier)
%
% classifier = classifier_onevsone(baseclassifier)
%
% %Example:
% dataset=load('datasets/wine.m');
% baseclassifier = classifier_linear_machine;
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
%classifier.codematrix = [];
count=1;
for i=1:length(classifier.labels)-1
  labelsi = dataset(:,end)==classifier.labels(i);
  for j=(i+1):length(classifier.labels)
    %classifier.codematrix(:,count) = zeros(nlabels,1);
    %classifier.codematrix(i,count) = 1;
    %classifier.codematrix(j,count) = 1;
    labelsj = dataset(:,end)==classifier.labels(j);
    classifier.trained_classifier{count} = classifier.baseclassifier.train(classifier.baseclassifier, [dataset(labelsi,:);dataset(labelsj,:)]);
    count=count+1;
  end
end
classifier.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = classifierpredict(classifier, dataset)
starttime=cputime;
nl = length(classifier.labels);
tmp_answers = zeros(size(dataset,1), (nl*(nl-1))/2)-1;
tmp_confidence = zeros(size(dataset,1), (nl*(nl-1))/2)-1;
for i=1:length(classifier.trained_classifier)
    [tmp_answers(:,i) tmp_confidence(:,i)] = classifier.baseclassifier.predict(classifier.trained_classifier{i},dataset);
end
if length(classifier.labels)==2
  answers = tmp_answers;
  confidences = tmp_confidence;
else
  answers = mode(tmp_answers,2);
  tmpidx = bsxfun(@eq,tmp_answers,answers);
  confidences = sum(tmp_confidence.*tmpidx,2)./sum(tmpidx,2);
end
time=cputime-starttime;
end

