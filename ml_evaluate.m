function [results confusion traintime testtime trained_classifier] = ml_evaluate(dataset, classifier, validation)
%
% [results confusion traintime testtime] = ml_evaluate(dataset, classifier, validation)
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_knn()
% validation = validation_holdout()
% [results confusion traintime testtime trained_classifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: classifier_knn, validation_houldout, create_performance.
%
if nargin<2
  classifier=create_classifier();
end
if nargin<3
  validation=create_validation();
end
[results confusion traintime testtime trained_classifier] = validation.execute(validation, dataset, classifier);
end

