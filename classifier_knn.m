function knn = classifier_knn(k, distance_function_name)
%
% knn = classifier_knn(k, distance_function_name)
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_knn(); classifier.autotunning=true
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: validation_houldout, create_performance, ml_evaluate.
%
knn.classifiername='KNN - K-Nearest Neighbors';
if exist('k')==1
  knn.k=k;
else
  knn.k=1;
end
if exist('distance_function_name')==1
  knn.distance_function_name=distance_function_name;
else
  knn.distance_function_name='euclidean';
end
knn.train=@knntrain;
knn.predict=@knnpredict;
knn.constructor=@classifier_knn;
knn.autotunning=false;
end

%%% Training function
function knn = knntrain(knn, dataset)
starttime=cputime;
if knn.autotunning
  %grid = allcomb({1 3 5 7 9 11 13 15},{'euclidean' 'cityblock' 'minkowski' 'chebychev' 'mahalanobis' 'cosine'});
  grid = allcomb({1 3 5 7});
  validation = validation_multiholdout;
  tunned = tunning_gridsearch(knn, dataset, grid, validation);
  knn = tunned.train(tunned, dataset);
else
knn.dataset=dataset;
end
knn.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = knnpredict(knn, dataset)
if is_octave
  distances = pdist2_octave(knn.dataset(:,1:end-1),dataset(:,1:end-1),knn.distance_function_name);
else
  distances = pdist2(knn.dataset(:,1:end-1),dataset(:,1:end-1),knn.distance_function_name);
end
dist = bsxfun(@rdivide,distances,max(distances));
[val,idx]=sort(dist);
labels=zeros(size(idx,2),knn.k);
confs=zeros(size(idx,2),knn.k);
for x=1:knn.k
  labels(:,x)=knn.dataset(idx(x,:),end);
  confs(:,x)=1-val(x,:);
end
[answers votes]=mode(labels,2);
confidences=mean(confs.*bsxfun(@eq,labels,answers),2);
% 1-NN simplest implementation
%********
% [min_values, min_indexes] = min(distances);
% answers=knn.dataset(min_indexes,end);
%********
end

