function classifier = classifier_psoecoc(baseclassifier)
%
% classifier = classifier_psoecoc(baseclassifier)
%
% %Example:
% baseclassifier = classifier_knn;
% classifier = classifier_psoecoc(baseclassifier)
% train = load('datasets/kahraman_tr.m');
% test = load('datasets/kahraman_te.m');
% [confusion traintime testtime trained_classifier] = ml_testing(classifier, train, test, false)
%
% See: classifier_elm, validation_houldout, validation_crossvalidation, create_performance, ml_evaluate.
%
if exist('baseclassifier')==1
  classifier.baseclassifier=baseclassifier;
else
  classifier.baseclassifier=classifier_fs; %knn;
end
classifier.train=@classifiertrain;
classifier.predict=@classifierpredict;
classifier.classifiername='PSO ECOC';
classifier.constructor=@classifier_psoecoc;
end

%%% Training function
function classifier = classifiertrain(classifier, dataset)
starttime=cputime;
dataold = dataset;
[dataset validation] = ml_split(dataset,0.8,true);
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
for i=1:length(classifier.labels)
  labelsi = dataset(:,end)==classifier.labels(i);
    classifier.codematrix(:,count) = -1*ones(nlabels,1);
    classifier.codematrix(i,count) = 1;
    labelsj = dataset(:,end)~=classifier.labels(i);
    classifier.trained_classifier{count} = classifier.baseclassifier.train(classifier.baseclassifier, [[dataset(labelsi,1:end-1) ones(sum(labelsi),1)];[dataset(labelsj,1:end-1) -1*ones(sum(labelsj),1)]]);
    count=count+1;
end
%classifier.codematrix = optimize(classifier, validation);
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
[confidences idx] = max([tmp_confidence.*tmp_answers*(classifier.codematrix')]');
answers = classifier.labels(idx);
time=cputime-starttime;
end

function codematrix = optimize(classifier, dataset)
  starttime=cputime;
  params.dataset=dataset;
  params.classifier=classifier;
  fitness_function=@(filters)fitnessneg(filters, params);
  tam = numel(classifier.codematrix);
  options = optimoptions('particleswarm','display','off');
  lb = -1*ones(tam,1);
  ub = ones(tam,1);
  [solution value] = particleswarm(fitness_function,tam,lb,ub,options);
  codematrix = vec2mat(round(solution),size(classifier.codematrix,2));
  time=cputime-starttime;
end

function value = fitnessneg(filters, params)
  value = -fitness(filters,params);
end

function value = fitness(filters, params)
  classifier = params.classifier;
  classifier.codematrix = vec2mat(round(filters),size(classifier.codematrix,2));
  [answers confidences] = classifierpredict(classifier, params.dataset);
  confusion=confusion_matrix(params.dataset,params.dataset,answers);
  %value = trace(confusion)/sum(sum(confusion));
  perf = create_performance;
  value = perf.execute(confusion);
end

