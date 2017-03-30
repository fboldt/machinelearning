function experiment_re(dataset_name, basecla, numcla, numsamps, numfeats, seed)
%
% experiment_re(dataset_name, basecla, numcla, numsamps, numfeats, seed)
%
if exist('dataset_name')~=1
  dataset_name='datasets/iris.m';
end
dataset=load(dataset_name);
baseclassifier=classifier_linear_machine;
if exist('basecla')==1
  baseclassifier=eval(['classifier_',basecla]);
  %baseclassifier.autotunning=true;
end
if exist('numcla')~=1
  numcla=1;
end
if exist('numsamps')~=1
  numsamps=1;
end
if exist('numfeats')~=1
  numfeats=1;
end
if exist('seed')~=1
  seed=0; %randi(1000)
end
classifier=classifier_random_ensemble(baseclassifier, numcla, numsamps, numfeats);
[results totaltime confusion trtime tetime numfeats]=run_experiment(dataset, classifier, seed);
results, 
average=mean(results)
confusion
fprintf('meanperf    std_perf    meanfeat    std_feat    trtime    tetime\n')
fprintf('%f    %f    %f    %f    %.4f    %.4f\n', mean(average(:)), std(average(:)), mean(numfeats(:)), std(numfeats(:)), trtime, tetime)
end


function [results totaltime totalconfusion trtime tetime numfeats] = run_experiment(dataset, classifier, seed)
if exist('seed')==1
  if ~is_octave
    rng(seed);
  else
    rand('seed',seed);
  end
else
  seed=randi(9999);
end
nfolds=10; nrounds=10;
%nfolds=5; nrounds=5;
validation=validation_multicrossvalidation(nrounds, nfolds, seed);
starttime=cputime;
[results, confusion, trtimes, tetimes, trcla] = ml_evaluate(dataset, classifier, validation);
trtime=0;
tetime=0;
totaltime=cputime-starttime;
totalconfusion=zeros(size(confusion{1}));
for r=1:nrounds
  for f=1:nfolds
    trtime=trtime+trtimes{f,r};
    tetime=tetime+tetimes{f,r};
    if any(strcmp('selected_features',fieldnames(trcla{f,r})))
      numfeats(f,r) = length(trcla{f,r}.selected_features);
    end
  end
  totalconfusion=totalconfusion+confusion{r};
end
if exist('numfeats')~=1
  numfeats = (size(dataset,2))-1;
end
end

