function leaveoneout = validation_leaveoneout(performance, standardization)
%
% leaveoneout = validation_leaveoneout(performance, standardization)
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_knn()
% validation = validation_leaveoneout()
% [results confusion traintime testtime trained_classifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: classifier_knn, create_performance, ml_evaluate.
%
if exist('performance')==1
  leaveoneout.performance=performance;
else
  leaveoneout.performance=create_performance('acc');
end
if exist('standardization')==1
  leaveoneout.standardization=standardization;
else
  leaveoneout.standardization=true;
end
leaveoneout.execute=@leaveoneoutexecute;
end

function [results confusion traintime testtime trained_classifier] = leaveoneoutexecute(leaveoneout, dataset, classifier)
nsamples = size(dataset,1);
crossvalidation = validation_crossvalidation(nsamples, 0, leaveoneout.standardization, leaveoneout.performance);
[results confusion traintime testtime trained_classifier] = ml_evaluate(dataset, classifier, crossvalidation);
end

