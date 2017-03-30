function lm = classifier_linear_machine()
%
% lm = classifier_linear_machine()
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_linear_machine()
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: validation_houldout, create_performance, ml_evaluate.
%
lm.classifiername='LM - Linear Machine';
lm.train=@linear_machinetrain;
lm.predict=@linear_machinepredict;
lm.constructor=@classifier_linear_machine;
end

%%% Training function
function linear_machine = linear_machinetrain(linear_machine, dataset)
linear_machine.labels=unique(dataset(:,end));
newlabels = zeros(size(dataset(:,end)));
target = zeros(length(newlabels), length(linear_machine.labels));
for l=1:length(linear_machine.labels)
  target(:,l) = ((dataset(:,end)==linear_machine.labels(l)))*2-1;
end
D = dataset(:,1:end-1);
try
  omega = pinv(D); 
catch 
  warning('off')
  omega = D'*inv(D*D'); 
  warning('on')
end
linear_machine.w = omega * target;
end

%%% Prediction function
function [answers confidence] = linear_machinepredict(linear_machine, dataset)
newlabels = zeros(size(dataset(:,end)));
for l=1:length(linear_machine.labels)
  newlabels = newlabels+((dataset(:,end)==linear_machine.labels(l))*l);
end
y = 1 ./ (1 + exp(-(dataset(:,1:end-1) * linear_machine.w)));
[confidence, label_index]=max(y');
answers = linear_machine.labels(label_index');
end

