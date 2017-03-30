function experiment_round(dataset_name, cla, fsm, numberofclassifiers, seed, autotunning)
%
% experiment_round(dataset_name, classifier_name, feature_selection_method_name, number_of_classifiers, seed)
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
else
  autotunning=false;
end
if exist('numberofclassifiers')~=1 
  numberofclassifiers=1;
end
if exist('fsm')==1 && strcmp(fsm,'none')~=1
  fscriterion = fscriterion_wrapper(classifier);
  fsmethod= eval(['feature_selection_',fsm,'(fscriterion)']); 
  disp([fsm, ' ', num2str(numberofclassifiers), ' classifiers'])
  classifier = classifier_fse(fsmethod, classifier, numberofclassifiers);
else
  disp('nofs')
end
if exist('seed')~=1
  seed=0; %randi(1000)
end
[results totaltime confusion trtime tetime numfeats]=run_experiment(dataset, classifier, seed)
average=mean(results);
stddev=std(results);
fprintf('meanperf    std_perf    meanfeat    std_feat    trtime      stdtrti     tetime    stdteti\n')
fprintf('%f    %f    %f    %f    %f    %f    %f    %f\n', average, stddev, mean(numfeats(:)), std(numfeats(:)), mean(trtime(:)), std(trtime(:)), mean(tetime(:)), std(tetime(:)) )
end


function [results totaltime confusion trtime tetime numfeats] = run_experiment(dataset, classifier, seed)
if exist('seed')~=1
  seed = randi(9999)
end
nfolds=10; 
validation=validation_crossvalidation(nfolds, seed);
starttime=cputime;
[results, confusion, trtimes, tetimes, trcla] = ml_evaluate(dataset, classifier, validation);
totaltime=cputime-starttime;
  for f=1:nfolds
    trtime(f)=trtimes{f};
    tetime(f)=tetimes{f};
    if any(strcmp('selected_features',fieldnames(trcla{f})))
      fprintf('feats-fold-%d: ', f); 
      disp(trcla{f}.selected_features)
      numfeats(f) = length(trcla{f}.selected_features);
    end
  end
if exist('numfeats')~=1 
  numfeats = (size(dataset,2))-1;
end
end

