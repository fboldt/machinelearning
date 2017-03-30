function fsbest_random = feature_selection_best_random(fscriterion, number_of_tries)
% 
% fsbest_random = feature_selection_best_random(fscriterion, number_of_tries)
%
% % Example 1:
% dataset=load('datasets/wine.m');
% fscriterion = fscriterion_filter()
% fsbest_random = feature_selection_best_random(fscriterion)
% [selected_features, time, best_value] = fsbest_random.execute(fsbest_random, dataset)
%
if exist('fscriterion')==1
  fsbest_random.fscriterion = fscriterion;
else
  fsbest_random.fscriterion = fscriterion_filter();
end
if exist('number_of_tries')==1
  fsbest_random.number_of_tries = number_of_tries;
end
fsbest_random.execute=@fsbest_randomexecute;
end

function [selected_features, time, best_value] = fsbest_randomexecute(fsbest_random, dataset)
starttime=cputime;
numfeats=size(dataset,2)-1;
if any(strcmp('number_of_tries',fieldnames(fsbest_random)))
  number_of_tries=fsbest_random.number_of_tries;
else
  number_of_tries=ceil(numfeats^0.5);
end
subsets = rand(number_of_tries^2,numfeats)<repmat(1:number_of_tries,numfeats,number_of_tries)'/(1+number_of_tries);
best_value=-Inf;
best_subset=ones(1,numfeats)==1;
for i=1:size(subsets,1)
  while sum(subsets(i,:))==0
    subsets(i,:)=rand(1,numfeats)>0.5;
  end 
  if number_of_tries>1
    value = fsbest_random.fscriterion.execute(fsbest_random.fscriterion, dataset(:,[subsets(i,:) true]));
  else
    value = 0;
  end
  if value>best_value || value==best_value && sum(subsets(i,:))<sum(best_subset)
    best_value=value;
    best_subset=subsets(i,:);
  end
end
features=1:numfeats;
selected_features=features(best_subset);
time=cputime-starttime;
end

