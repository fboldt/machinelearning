function experiment_5x2(dataset_name, cla, fsm, fsc, numberofclassifiers, seed, autotunning)
%
% experiment_5x2(dataset_name, cla, fsm, fsc, numberofclassifiers, seed, autotunning)
%
if exist('dataset_name')~=1
  dataset_name='datasets/iris.m';
end
dataset=load(dataset_name);
if exist('cla')==1
  classifier=eval(['classifier_',cla]);
else
  classifier=classifier_knn;
end
if exist('autotunning')==1 && autotunning
  classifier.autotunning=true;
end
if exist('fsm')==1 && strcmp(fsm,'none')~=1
  validation = validation_multiholdout(3);
  fscriterion = fscriterion_wrapper(classifier, validation);
  if exist('fsc')==1
    fscriterion = eval(['fscriterion_',fsc]);
  end
  fsmethod= eval(['feature_selection_',fsm,'(fscriterion)']); 
  if exist('numberofclassifiers')==1 && numberofclassifiers>1
    disp([fsm, ' ', num2str(numberofclassifiers), ' classifiers'])
    classifier = classifier_fse(fsmethod, classifier, numberofclassifiers);
  else
    disp(fsm)
    classifier = classifier_fs(fsmethod, classifier);
  end
else
  disp('nofs')
end
if exist('seed')~=1
  seed=0; %randi(1000)
end
[results totaltime confusion trtime tetime numfeats]=run_experiment(dataset, classifier, seed);
results, 
average=mean(results)
stddev=std(results)
confusion
fprintf('meanperf    std_perf    meanfeat    std_feat    trtime    tetime\n')
fprintf('%f    %f    %f    %f    %.4f    %.4f\n', mean(average(:)), std(average(:)), mean(numfeats(:)), std(numfeats(:)), trtime, tetime)
end


function [results totaltime totalconfusion trtime tetime numfeats] = run_experiment(dataset, classifier, seed)
if exist('seed')==1
  rng(seed); %rand('seed',seed);
end
nfolds=2; nrounds=5;
validation=validation_multicrossvalidation(nrounds, nfolds);
starttime=cputime;
[results, confusion, trtimes, tetimes, trcla] = ml_evaluate(dataset, classifier, validation)
trtime=0;
tetime=0;
totaltime=cputime-starttime;
totalconfusion=zeros(size(confusion{1}));
for r=1:nrounds
  for f=1:nfolds
    trtime=trtime+trtimes{f,r};
    tetime=tetime+tetimes{f,r};
    if any(strcmp('selected_features',fieldnames(trcla{f,r})))
      trcla{f,r}.selected_features
      numfeats(f,r) = length(trcla{f,r}.selected_features);
    end
  end
  totalconfusion=totalconfusion+confusion{r};
end
if exist('numfeats')~=1
  numfeats = (size(dataset,2))-1;
end
end

