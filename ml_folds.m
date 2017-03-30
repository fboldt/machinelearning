function [newDataset, foldIndexes] = ml_folds(dataset, nFolds, stratified, seed)
%
% [newDataset, foldIndexes] = ml_folds(dataset, number_of_folds, stratified, seed)
%
% Reorder a dataset trying to distribute the dataset's lables in n folds in stratified mode or permute dataset rows and return indexes to manipulate folds.
% 
% %Example:
% dataset=load('datasets/iris.m');
% dataset=[dataset(1:4,:);dataset(51:54,:);dataset(101:104,:)];
% [newDataset,foldIndexes] = ml_folds(dataset, 4, true, 1) 
%
if nargin<2
  nFolds=5;
end
if nargin<3
  stratified=false;
end
if nargin==4
  if ~is_octave
    rng(seed);
  else 
    rand('seed',seed);
  end
end
newDataset=dataset(randperm(size(dataset,1)),:);
if stratified
  [labels,idx]=sort(newDataset(:,end));
  [foldIndexes,idx2]=sort(mod(0:length(idx)-1,nFolds)+1);
  newDataset=newDataset(idx(idx2),:);
else
  foldIndexes=mod(randperm(size(dataset,1)),nFolds)+1;
end
if ~stratified && labelsmissing(dataset, nFolds, foldIndexes)>0 
  [newDataset, foldIndexes] = ml_folds(dataset, nFolds, stratified);
end
end

function x = labelsmissing(dataset, nFolds, foldIndexes)
x = 0;
labels = unique(dataset(:,end))';
for f = 1:nFolds
  train=dataset(foldIndexes~=f,:);
  complabels = repmat(labels, size(train,1), 1);
  x = x + sum(sum(bsxfun(@eq, train(:,end), complabels))==0);
end
end

