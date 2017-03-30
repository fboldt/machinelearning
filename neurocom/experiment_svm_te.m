function experiment_svm_te()
classifier = classifier_svm();
classifier.autotunning = true;

acc = create_performance('acc');
ppv = create_performance('ppv');
tpr = create_performance('tpr');
f1s = create_performance('f1score');

dstrain=[0 1 2 4 5];%[1:22]-1;%
train=[];
for i=1:length(dstrain)
  train=[train; load(['datasets/tedata/d',num2str(dstrain(i),'%02d'),'.m'])];
end
%%% Standardization
m=mean(train(:,1:end-1));
s=std(train(:,1:end-1));
stdtrain=[bsxfun(@times,bsxfun(@minus,train(:,1:end-1),m),1./s), train(:,end)];

%%% Classifier Training
starttime=cputime;
classifier = classifier.train(classifier, stdtrain)
traintime=cputime-starttime
if any(strcmp('selected_features',fieldnames(classifier)))
  used_features=classifier.selected_features
else
  used_features=[1:size(train,2)-1]
end
numfeats = length(used_features)

fprintf('testfile time     acc      prec     rec      f1s\n');
dstest=dstrain;%[1];
test=[];
for i=1:length(dstest)
  testfile=['d',num2str(dstest(i),'%02d'),'_te.m'];
  testclass{i} = ['d',num2str(dstest(i),'%02d')];
  test = load(['datasets/tedata/d',num2str(dstest(i),'%02d'),'_te.m']);
  stdtest=[bsxfun(@times,bsxfun(@minus,test(:,1:end-1),m),1./s), test(:,end)];
  starttime=cputime;
  answers = classifier.predict(classifier, stdtest);
  testtime=cputime-starttime;
  testtimes(i) = testtime;
  confusion = confusion_matrix(train,test,answers);
  acuracies(i) = acc.execute(confusion);
  precision = ppv.execute(confusion);
  precisions(i) = precision(i);
  recall = tpr.execute(confusion);
  recalls(i) = recall(i);
  f1score = f1s.execute(confusion);
  f1scores(i) = f1score(i);
  fprintf('%s %f %f %f %f %f\n', testfile, testtime, acuracies(i), precisions(i), recalls(i), f1scores(i));
end

results= [testtimes;acuracies;precisions;recalls;f1scores]'
averages=mean(results)
stdevs=std(results)

end


