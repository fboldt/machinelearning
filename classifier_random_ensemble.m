function random_ensemble = classifier_random_ensemble(baseclassifier, numberofclassifiers, samplesProportion, featuresProportion)
%
% random_ensemble = classifier_random_ensemble(baseclassifier, numberofclassifiers, samplesProportion, featuresProportion)
%
% %Example:
% dataset=load('datasets/wine.m');
% baseclassifier = classifier_knn;
% numberofclassifiers = 5;
% samplesProportion = 0.5;
% featuresProportion = 0.5;
% classifier = classifier_random_ensemble(baseclassifier, numberofclassifiers, samplesProportion, featuresProportion)
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
%
% See: classifier_elm, validation_houldout, validation_crossvalidation, create_performance, ml_evaluate.
%
if exist('baseclassifier')==1
  random_ensemble.baseclassifier=baseclassifier;
else
  random_ensemble.baseclassifier=classifier_linear_machine;
end
if exist('numberofclassifiers')==1
  random_ensemble.numberofclassifiers=numberofclassifiers;
else
  random_ensemble.numberofclassifiers=1;
end
if exist('samplesProportion')==1
  random_ensemble.samplesProportion=samplesProportion;
else
  random_ensemble.samplesProportion=1;
end
if exist('featuresProportion')==1
  random_ensemble.featuresProportion=featuresProportion;
else
  random_ensemble.featuresProportion=1;
end
random_ensemble.train=@random_ensembletrain;
random_ensemble.predict=@random_ensemblepredict;
random_ensemble.classifiername='RE - Random Ensemble';
random_ensemble.constructor=@classifier_random_ensemble;
end

%%% Training function
function random_ensemble = random_ensembletrain(random_ensemble, dataset)
starttime=cputime;
[train test] = ml_split(dataset, random_ensemble.samplesProportion, false);
features=zeros(1,size(dataset,2)-1);
for i=1:random_ensemble.numberofclassifiers
  random_ensemble.features{i} = rand(1,size(dataset,2)-1)<random_ensemble.featuresProportion;
  if sum(random_ensemble.features{i})==0
    feats=zeros(1,size(dataset,2)-1)==0;
    feats(1,randi(size(dataset,2)-1))=true;
    random_ensemble.features{i}=feats;
  end
  random_ensemble.trained_classifier{i} = random_ensemble.baseclassifier.train(random_ensemble.baseclassifier, [train(:,random_ensemble.features{i}),train(:,end)]);
  features=features+random_ensemble.features{i};
end
random_ensemble.selected_features=[1:size(dataset,2)-1];
random_ensemble.selected_features=random_ensemble.selected_features(features>0);
random_ensemble.labels=unique(train(:,end));
random_ensemble.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = random_ensemblepredict(random_ensemble, dataset)
starttime=cputime;
for i=1:random_ensemble.numberofclassifiers
  [tmp_answers(:,i) tmp_confidence(:,i)] = random_ensemble.baseclassifier.predict(random_ensemble.trained_classifier{i},[dataset(:,random_ensemble.features{i}),dataset(:,end)]);
end
if random_ensemble.numberofclassifiers==1
  answers = tmp_answers;
  confidences = tmp_confidence;
else
  for i=1:length(random_ensemble.labels)
    confidence(:,i)=mean(((tmp_answers==random_ensemble.labels(i)).*tmp_confidence)')';
  end
  [confidences labels_indexes]=max(confidence');
  %labels=repmat(random_ensemble.labels, 1, length(labels_indexes));
  %answers = labels(labels_indexes');
  answers = mode(tmp_answers,2);
end
time=cputime-starttime;
end



