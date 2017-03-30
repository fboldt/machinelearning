function ensemble = classifier_adaboost(numberofclassifiers)
%
% ensemble = classifier_adaboost(numberofclassifiers)
%
% %Example:
% dataset=load('datasets/wine.m');
% numberofclassifiers = 50;
% classifier = classifier_adaboost(numberofclassifiers); classifier.autotunning=true
% validation = validation_crossvalidation(2)
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
%
if exist('numberofclassifiers')==1
  ensemble.numberofclassifiers=numberofclassifiers;
else
  ensemble.numberofclassifiers=50;
end
ensemble.classifiername = 'Adaboost';
ensemble.train=@ensembletrain;
ensemble.predict=@ensemblepredict;
ensemble.constructor=@classifier_adaboost;
ensemble.autotunning=false;
end

%%% Training function
function ensemble = ensembletrain(ensemble, dataset)
starttime=cputime;
if ensemble.autotunning
  NLearn = {50 100 150 200};
  grid = allcomb(NLearn);
  validation = validation_multiholdout(3);
  tunned = tunning_gridsearch(ensemble, dataset, grid, validation);
  ensemble = tunned.train(tunned, dataset);
else
ensemble.MatlabEnsemble = fitensemble(dataset(:,1:end-1), dataset(:,end), 'AdaBoostM2', ensemble.numberofclassifiers, 'Tree');
end
ensemble.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = ensemblepredict(ensemble, dataset)
[answers confidences]=predict(ensemble.MatlabEnsemble, dataset(:,1:end-1));
end

