function wrapper = fscriterion_wrapper(classifier, validation)
%
% wrapper = fscriterion_wrapper(classifier, validation)
%
% %Example 1:
% dataset = load('datasets/iris.m');
% classifier = classifier_knn()
% validation = validation_holdout()
% wrapper = fscriterion_wrapper(classifier, validation)
% [value, time] = wrapper.execute(wrapper, dataset)
%
% See: validation_houldout, create_performance, ml_evaluate.
%
if exist('classifier')==1
  wrapper.classifier=classifier;
else
  wrapper.classifier=classifier_knn();
end
if exist('validation')==1
  wrapper.validation = validation;
else
  wrapper.validation = validation_multiholdout(5,0.7,randi(9999));
end
wrapper.execute=@wrapperexecute;
end

function [value, time, wrapper] = wrapperexecute(wrapper, dataset)
starttime=cputime;
values = ml_evaluate(dataset, wrapper.classifier, wrapper.validation);
value = mean(values(:));
time=cputime-starttime;
end

