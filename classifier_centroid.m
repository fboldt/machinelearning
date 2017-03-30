function centroid = classifier_centroid()
%
% centroid = classifier_centroid()
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_centroid()
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: validation_houldout, create_performance, ml_evaluate.
%
centroid.classifiername='Centroid';
centroid.train=@centroidtrain;
centroid.predict=@centroidpredict;
centroid.constructor=@classifier_centroid;
end

%%% Training function
function centroid = centroidtrain(centroid, dataset)
labels=unique(dataset(:,end));
centroid.dataset = [];
origin = zeros(1,size(dataset,2)-1);
for l=1:length(labels)
  samples = dataset(:,end)==labels(l);
  if sum(samples) == 1
    average = dataset(samples,1:end-1);
  else
    average = mean(dataset(samples,1:end-1));
  end
  centroid.dataset = [centroid.dataset; [average, labels(l)]];
end
end

%%% Prediction function
function [answers confidences] = centroidpredict(centroid, dataset)
if is_octave
  distances = pdist2_octave(centroid.dataset(:,1:end-1),dataset(:,1:end-1),'euclidean');
else
  distances = pdist2(centroid.dataset(:,1:end-1),dataset(:,1:end-1),'euclidean');
end
% 1-NN simplest implementation
%********
 [min_values, min_indexes] = min(distances);
 answers=centroid.dataset(min_indexes,end);
 %max_value = max(distances(:));
 %confidences = (max_value./min_values)/max_value;
%********
 confidences = (max(distances)./min_values-1)';
end

