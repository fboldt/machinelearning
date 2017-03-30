function experiment_filter(dataset_name, cla, fsm, seed, autotunning)
%
% experiment_filter(dataset_name, classifiers_list, feature_selection_method_name, seed)
%


fscriterion = fscriterion_filter();

if exist('dataset_name')~=1
  dataset_name='datasets/iris.m';
end
dataset=load(dataset_name);

if exist('cla')==1
  i=1;
  classifiers={};
  while length(cla)>0 
    [classi cla] = strtok(cla); 
    classifiers{i}=eval(['classifier_',classi]);
    i=i+1;
  end
else
  classifiers{1}=classifier_knn;
end

if exist('fsm')==1 && strcmp(fsm,'none')~=1
  fsmethod= eval(['feature_selection_',fsm,'(fscriterion)']); 
else
  fsmethod= eval(['feature_selection_ranking','(fscriterion)']); 
  fsm = 'ranking'
end

if exist('seed')~=1
  seed=1; 
  %seed=randi(1000);
end

if exist('autotunning')==1 && autotunning
for i=1:length(classifiers)
  classifiers{i}.autotunning = true;
end
else
  autotunning=false;
end

dataset_name, fsm, seed, autotunning

performance = create_performance('f1avg');

nfolds=10; nrounds=10;
if ~is_octave
  rng(seed); 
else
  rand('seed',seed);
end
seeds=randperm(1000);
for r=1:nrounds
  rng(seeds(r)); %rand('seed',seeds(r));
  [data,idx] = ml_folds(dataset, nfolds);
  fprintf('round %2d\n', r)
  for f=1:nfolds
    fprintf('    fold %2d\n', f)
    train=data(idx~=f,:);
    test=data(idx==f,:);
    [train, test] = standardize(train, test);
    [selected_features selection_time(f,r)]= fsmethod.execute(fsmethod, train);
    numfeats(f,r) = length(selected_features);
    for c=1:length(classifiers)
      starttime=cputime;
      trained_classifier = classifiers{c}.train(classifiers{c}, [train(:,selected_features),train(:,end)]);
      trtime=cputime-starttime;
      starttime=cputime;
      answers = trained_classifier.predict(trained_classifier,[test(:,selected_features),test(:,end)]);
      tetime=cputime-starttime;
      confusion = confusion_matrix(train,test,answers);
      results{c}(f,r) = performance.execute(confusion);
      fprintf('perf: %f, trti: %f, teti: %f, %s\n', results{c}(f,r), trtime, tetime, strtok(trained_classifier.classifiername))
    end
  end
  fprintf('\n')
end
numfeats
fprintf('avgfeats: %f, stdfeats: %f\n', mean(mean(numfeats)), std(mean(numfeats)))
selection_time
fprintf('avgtime: %f, stdtime: %f\n', mean(selection_time(:)), std(selection_time(:)))
for c=1:length(classifiers)
  disp(classifiers{c}.classifiername)
  results{c}
  average=mean(results{c})
  fprintf('avgperf: %f    stdperf: %f   %s\n', mean(average(:)), std(average(:)), strtok(classifiers{c}.classifiername))
end
end

function [stdtrain, stdtest] = standardize(train, test)
m=mean(train(:,1:end-1));
s=std(train(:,1:end-1));
stdtrain=[bsxfun(@times,bsxfun(@minus,train(:,1:end-1),m),1./s), train(:,end)];
stdtest=[bsxfun(@times,bsxfun(@minus,test(:,1:end-1),m),1./s), test(:,end)];
end

