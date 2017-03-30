function experiment_cwru19c(dsopt, cla, fsm, numberofclassifiers, seed, autotunning)
%
% experiment_cwru19c(dummy_dataset_name, cla, fsm, numberofclassifiers, seed, autotunning)
%
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
if exist('seed')==1
  rng(seed);
end
[results totaltime confusion trtime tetime numfeats]=run_experiment(dsopt, classifier)
average=mean(results);
stddev=std(results);
fprintf('meanperf    std_perf    meanfeat    std_feat    trtime      stdtrti     tetime    stdteti\n')
fprintf('%f    %f    %f    %f    %f    %f    %f    %f\n', average, stddev, mean(numfeats(:)), std(numfeats(:)), mean(trtime(:)), std(trtime(:)), mean(tetime(:)), std(tetime(:)) )
end


function [results totaltime confusion trtime tetime numfeats] = run_experiment(dsopt, classifier)
nfolds=4; 
starttime=cputime;
if fsopt == 'cwru19c'
folds{1} = load('datasets/cwru-load0.m');
folds{2} = load('datasets/cwru-load1.m');
folds{3} = load('datasets/cwru-load2.m');
folds{4} = load('datasets/cwru-load3.m');
else
folds{1} = load('datasets/cwru0.m');
folds{2} = load('datasets/cwru1.m');
folds{3} = load('datasets/cwru2.m');
folds{4} = load('datasets/cwru3.m');
end
  for f=1:nfolds
    train = [];
    for l=1:nfolds
      if f==l
        test = folds{l};
      else
        train = [train; folds{l}];
      end
    end
    perf = create_performance();
    [conftemp trtimes{f} tetimes{f} trcla{f}] = ml_testing(classifier, train, test, true);
    results(f) = perf.execute(conftemp);
    fprintf('fold-%02d: %f\n', f, results(f))
    for i=1:length(conftemp)
      fprintf('confold: %d', f)
      for j=1:length(conftemp)
        fprintf(',%d', conftemp(i,j))
      end
      fprintf('\n')
    end
    if f==1
      confusion=conftemp;
    else
      confusion=confusion+conftemp;
    end
    trtime(f)=trtimes{f};
    tetime(f)=tetimes{f};
    if any(strcmp('selected_features',fieldnames(trcla{f})))
      fprintf('feats-fold-%d: ', f); 
      disp(trcla{f}.selected_features)
      numfeats(f) = length(trcla{f}.selected_features);
    end
  end
totaltime=cputime-starttime;
if exist('numfeats')~=1 
  numfeats = (size(folds{1},2))-1;
end
end

