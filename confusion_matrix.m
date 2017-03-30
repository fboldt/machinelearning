function confusion = confusion_matrix(train,actual,predicted)
%
% confusion = confusion_matrix(train,actual,predicted)
%
% Convert two vectors into a confusion matrix.
%
% %Example: 
% dataset=load('datasets/iris.m');
% [train,test]=ml_split(dataset(randperm(size(dataset,1)),:), 0.5);
% classifier = classifier_knn(1, 'euclidean');
% classifier = classifier.train(classifier, train);
% answers = classifier.predict(classifier, test);
% confusion=confusion_matrix(train,test,answers)
%
labels=unique(train(:,end));
confusion=zeros(length(labels));
for index=1:length(predicted)
  a = find(labels==actual(index,end),1);
  p = find(labels==predicted(index),1);
  confusion(a,p) = confusion(a,p) + 1;
end
end

