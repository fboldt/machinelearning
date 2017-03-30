function svm = classifier_svm(C, kernel, kval)
%
% svm = classifier_svm(C, kernel, kval)
%
% %Example:
% dataset=load('datasets/iris.m');
% classifier = classifier_svm(); classifier.autotunning=true
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
%
if exist('C')==1
  svm.C = C;
else
  svm.C = 1;
end
if exist('kernel')==1
  svm.kernel = kernel;
else
  svm.kernel = 'linear';
end
if exist('kval')==1
  svm.kval = kval;
else
  svm.kval = 1;
end

svm.classifiername = 'SVM - Support Vector Machine';
svm.train=@svmtrain;
svm.predict=@svmpredict;
svm.constructor=@classifier_svm;
svm.autotunning=false;
end

%%% Training function
function svm = svmtrain(svm, dataset)
starttime=cputime;
if svm.autotunning
  C = {0.03125, 0.125, 0.5, 2, 8, 32, 128, 512, 2048, 8192, 32768};
  glin = allcomb(C,{'linear'},{1});
  gamma = {8, 2, 0.5, 0.125, 0.03125, 0.0078125, 0.00195313, 0.000488281, 0.00012207, 0.0000305176};
  grbf = allcomb(C,{'rbf'},gamma);
  porder = num2cell([2:7]);
  gpol = allcomb(C,{'polynomial'},porder);
  grid = [glin; grbf; gpol];
  validation = validation_multiholdout(3);
  tunned = tunning_gridsearch(svm, dataset, grid, validation);
  svm = tunned.train(tunned, dataset);
else
svm.labels=unique(dataset(:,end))';
newlabels = zeros(size(dataset(:,end)));
target = zeros(length(newlabels), 1);
for l=1:length(svm.labels)
  target((dataset(:,end)==svm.labels(l)),1) = l-1;
end
starttime=cputime;
if strcmp('polynomial',svm.kernel)~=0
  svm.model = templateSVM('BoxConstraint', svm.C, 'KernelFunction', svm.kernel, 'PolynomialOrder', svm.kval);
else 
  svm.model = templateSVM('BoxConstraint', svm.C, 'KernelFunction', svm.kernel, 'KernelScale', svm.kval);
end
svm.trainedSVM = fitcecoc(dataset(:,end-1),target,'Learners',svm.model);
end
svm.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = svmpredict(svm, dataset)
[y confidences] = svm.trainedSVM.predict(dataset(:,end-1));
target = uint16(zeros(length(y), 1));
for l=1:length(svm.labels)
  target = target+(uint16(y==(l-1))*uint16(l));
end
answers = svm.labels(target);
end

