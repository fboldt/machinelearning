function [confusion traintime testtime classifier] = ml_testing(classifier, train, test, standardization)
%
% [confusion traintime testtime trained_classifier] = ml_testing(classifier, train, test, standardization)
%
% %Example: 
% dataset=load('datasets/iris.m');
% [train,test]=ml_split(dataset(randperm(size(dataset,1)),:), 0.5);
% classifier = classifier_knn()
% [confusion traintime testtime trained_classifier] = ml_testing(classifier, train, test, false)
%
if exist('standardization')==1 && standardization==true 
  [train, test] = standardize(train, test);
end

starttime=cputime;
classifier = classifier.train(classifier, train);
traintime=cputime-starttime;

starttime=cputime;
answers = classifier.predict(classifier, test);
testtime=cputime-starttime;

confusion = confusion_matrix(train,test,answers);
end

function [stdtrain, stdtest] = standardize(train, test)
m=mean(train(:,1:end-1));
s=std(train(:,1:end-1));
stdtrain=[bsxfun(@times,bsxfun(@minus,train(:,1:end-1),m),1./s), train(:,end)];
stdtest=[bsxfun(@times,bsxfun(@minus,test(:,1:end-1),m),1./s), test(:,end)];
end

