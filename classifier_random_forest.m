function crf = classifier_random_forest(numberofclassifiers, NVarToSample)
%
% crf = classifier_random_forest(numberofclassifiers, NVarToSample)
%
% %Example:
% dataset=load('datasets/wine.m');
% classifier = classifier_random_forest(); classifier.autotunning=true
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
%

if exist('numberofclassifiers')==1
  crf.numberofclassifiers=numberofclassifiers;
else
  crf.numberofclassifiers=50;
end
if exist('NVarToSample')==1
  crf.NVarToSample=NVarToSample;
else
  crf.NVarToSample='all';
end
crf.classifiername = 'RF - Random Forest';
crf.train=@crftrain;
crf.predict=@crfpredict;
crf.constructor=@classifier_random_forest;
crf.autotunning=false;
end

%%% Training function
function crf = crftrain(crf, dataset)
starttime=cputime;
if crf.autotunning
  NLearn = {50 100 150 200};
  [n d] = size(dataset);
  d=d-1;
  raiz_d = round(sqrt(d));
  range = round(0.2*d);
  NVarToSamples = num2cell(unique(ceil(logspace(log(1),log(raiz_d/2),5)))); % Number of feature +-20%
  NVarToSamples{length(NVarToSamples)+1}='all';
  grid = allcomb(NLearn,NVarToSamples);
  validation = validation_multiholdout(3);
  tunned = tunning_gridsearch(crf, dataset, grid, validation);
  crf = tunned.train(tunned, dataset);
else
crf.BaggedEnsemble = TreeBagger(crf.numberofclassifiers, dataset(:,1:end-1), dataset(:,end), 'NVarToSample', crf.NVarToSample);
end
crf.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = crfpredict(crf, dataset)
[resp confidences] = predict(crf.BaggedEnsemble, dataset(:,1:end-1));
answers = cellfun(@str2num,resp);
confidences = max(confidences')';
end

