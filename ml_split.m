function [train, test] = ml_split(dataset, proportion, stratified, seed)
%
% [train,test] = ml_split(dataset, proportion, stratified, seed)
%
% Split a dataset into training and testing data, according some proportion, in a stratified or a completely random manner. 
% 
% %Example:
% dataset=load('datasets/iris.m');
% dataset=[dataset(1:4,:);dataset(51:54,:);dataset(101:104,:)]
% proportion=0.75;
% stratified=true;
% seed=1;
% [train,test] = ml_split(dataset, proportion, stratified, seed)
%
if nargin<2
  proportion=0.5;
end
nlabels=length(unique(dataset(:,end)));
nsamples=size(dataset,1);
if nsamples*proportion < nlabels
  proportion=nlabels/nsamples
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
data=dataset(randperm(size(dataset,1)),:);
if stratified
  [labels,idx]=sort(data(:,end));
else
  idx=randperm(size(dataset,1));
end
[n,d]=rat(proportion);
[row,idx2]=sort(mod([0:length(idx)-1]*n,d)<n,2,'descend');
data=data(idx(idx2),:);
train=data(row,:); train=train(randperm(size(train,1)),:);
test=data(~row,:); test=test(randperm(size(test,1)),:);
if ~stratified && labelsmissing(dataset, train)>0 
  [train,test] = ml_split(dataset, proportion, stratified);
end
end

function x = labelsmissing(dataset, part)
labels = unique(dataset(:,end))';
complabels = repmat(labels, size(part,1), 1);
x = sum(sum(bsxfun(@eq, part(:,end), complabels))==0);
end

