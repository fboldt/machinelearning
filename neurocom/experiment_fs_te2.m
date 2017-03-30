function experiment_fs_te3(fsm, cla, seed)
if exist('seed')==1
  rng(seed)
end
if exist('fsm')~=1
  fsm='feature_selection_hybridranking';
end
if exist('cla')~=1
  cla='elm(10)';
end
baseclassifier = eval(['classifier_',cla]);
fprintf('Classifier: %s\n', baseclassifier.classifiername);
fscriterion = fscriterion_wrapper(baseclassifier);

feature_selection_method = eval(['@',fsm]);
fsmethod = feature_selection_method(fscriterion);
classifier = classifier_fs(fsmethod, baseclassifier);
acc = create_performance('acc');
ppv = create_performance('ppv');
tpr = create_performance('tpr');
f1s = create_performance('f1score');

dstrain=[1:21];
train0=load('datasets/tedata/d00.m');
for i=1:length(dstrain)
  train=[train0; load(['datasets/tedata/d',num2str(dstrain(i),'%02d'),'.m'])];
%end

%%% Standardization
m=mean(train(:,1:end-1));
s=std(train(:,1:end-1));
stdtrain=[bsxfun(@times,bsxfun(@minus,train(:,1:end-1),m),1./s), train(:,end)];

%%% Classifier Training
starttime=cputime;
classifier = classifier.train(classifier, stdtrain);
traintime=cputime-starttime
trtimes(i)=traintime;
if any(strcmp('selected_features',fieldnames(classifier)))
  used_features=classifier.selected_features
else
  used_features=[1:size(train,2)-1]
end
numfeats = length(used_features)
nf(i) = numfeats;

fprintf('testfile numfeats trtime   tetime   acc      prec     rec      f1s\n');
dstest=dstrain;%[1];
test=[];
%for i=1:length(dstest)
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
  precisions(i) = precision(2);
  recall = tpr.execute(confusion);
  recalls(i) = recall(2);
  f1score = f1s.execute(confusion);
  f1scores(i) = f1score(2);
  fprintf('%s %8d %f %f %f %f %f %f\n', testfile, numfeats, traintime, testtime, acuracies(i), precisions(i), recalls(i), f1scores(i));
  d00perf(i,1) = precision(1);
  d00perf(i,2) = recall(1);
  d00perf(i,3) = f1score(1);
end
d00perf
d00avg=mean(d00perf)
d00std=mean(d00perf)
results= [nf;trtimes;testtimes;acuracies;precisions;recalls;f1scores]'
averages=mean(results)
stdevs=std(results)

end


