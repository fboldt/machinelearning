function experiment_gspca_te()
classifier = classifier_svm();
classifier.autotunning = true;

acc = create_performance('acc');
ppv = create_performance('ppv');
tpr = create_performance('tpr');
f1s = create_performance('f1score');

dstrain=[0 1 2 4 5];%[1:22]-1;%
train=[];
for i=1:length(dstrain)
  tmp = load(['datasets/tedata/d',num2str(dstrain(i),'%02d'),'.m']);
  train=[train; tmp];
end

%%% Standardization
m=mean(train(:,1:end-1));
s=std(train(:,1:end-1));
stdtrain=[bsxfun(@times,bsxfun(@minus,train(:,1:end-1),m),1./s), train(:,end)];

PruningFactor=0.1;

%%%PCA
w = 1./var(stdtrain(:,1:end-1));
[wcoeff, score, latent, tsquared, explained] = pca(stdtrain(:,1:end-1), 'VariableWeights', w);
numcomponents = sum(latent>=PruningFactor)
selected_features=[1:numcomponents];
score=score(:,1:numcomponents);
wcoeff=wcoeff(:,1:numcomponents);
pcatrain = [score train(:,end)];

%%% Classifier Training
starttime=cputime;
classifier = classifier.train(classifier, pcatrain)
traintime=cputime-starttime
used_features=[1:size(pcatrain,2)-1];
numfeats = length(used_features)

fprintf('testfile time     acc      prec     rec      f1s\n');
dstest=dstrain;%[1];
test=[];
for i=1:length(dstest)
  testfile=['d',num2str(dstest(i),'%02d'),'_te.m'];
  testclass{i} = ['d',num2str(dstest(i),'%02d')];
  test = load(['datasets/tedata/d',num2str(dstest(i),'%02d'),'_te.m']);
%%% Standardization
%m=mean(test(:,1:end-1));
%s=std(test(:,1:end-1));
  stdtest=[bsxfun(@times,bsxfun(@minus,test(:,1:end-1),m),1./s), test(:,end)];
  cscore = bsxfun(@times, zscore(stdtest(:,1:end-1)), sqrt(w)) * wcoeff;
  pcatest = [cscore stdtest(:,end)];
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


