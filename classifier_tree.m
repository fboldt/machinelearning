function tree = classifier_tree(AlgorithmForCategorical, MaxNumSplits, MaxNumCategories, Prune)
%
% tree = classifier_tree(AlgorithmForCategorical, MaxNumSplits, MaxNumCategories, Prune)
%
% %Example:
% dataset=load('datasets/iris.m');
% classifier = classifier_tree(); classifier.autotunning=true
% validation = validation_holdout()
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
%

if exist('AlgorithmForCategorical')==1 
  tree.AlgorithmForCategorical = AlgorithmForCategorical;
else
  tree.AlgorithmForCategorical = 'Exact';
end

if exist('MaxNumSplits')==1 
  tree.MaxNumSplits = MaxNumSplits;
else
  tree.MaxNumSplits = 0;
end

if exist('MaxNumCategories')==1 
  tree.MaxNumCategories = MaxNumCategories;
else
  tree.MaxNumCategories = 10;
end

if exist('Prune')==1
  tree.Prune = Prune;
else
  tree.Prune = 'off';
end

tree.classifiername = 'Tree';
tree.train=@treetrain;
tree.predict=@treepredict;
tree.constructor=@classifier_tree;
tree.autotunning = false;
end

%%% Training function
function tree = treetrain(tree, dataset)
starttime=cputime;
if tree.autotunning
  AlgorithmForCategorical = {'Exact','PCA'};
  MaxNumSplits = {10 50 100};
  MaxNumCategories= {10 50 100};
  Prune = {'off','on'};
  grid = allcomb(AlgorithmForCategorical,MaxNumSplits,MaxNumCategories,Prune);
  validation = validation_multiholdout(3);
  tunned = tunning_gridsearch(tree, dataset, grid, validation);
  tree = tunned.train(tunned, dataset);
else
if tree.MaxNumSplits <= 0
  tree.MaxNumSplits = size(dataset,1) - 2;
end
model = templateTree('Type', 'classification', 'SplitCriterion', 'gdi', 'AlgorithmForCategorical', tree.AlgorithmForCategorical, 'MaxNumSplits', tree.MaxNumSplits, 'MaxNumCategories', tree.MaxNumCategories, 'Prune', tree.Prune);
tree.model = fitcecoc(dataset(:,1:end-1),dataset(:,end),'Learners',model);
end
tree.training_time=cputime-starttime;
end

%%% Prediction function
function [answers confidences] = treepredict(tree, dataset)
[answers confidences] = tree.model.predict(dataset(:,1:end-1));
end

