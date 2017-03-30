function filter = fscriterion_filter(distance_function_name)
%
% filter = fscriterion_filter(distance_function_name)
%
% %Example 1:
% dataset = load('datasets/wine.m');
% filter = fscriterion_filter('euclidean');
% [value, time] = filter.execute(filter, dataset)
%
%
if exist('distance_function_name')==1
  filter.distance_function_name=distance_function_name;
else
  filter.distance_function_name='euclidean';
end
filter.execute=@filterexecute;
end

function [value, time] = filterexecute(filter, dataset)
starttime=cputime;
  labels=unique(dataset(:,end));
  data = standardize(dataset);
  for ca=1:length(labels)
    filter_class_a=data(:,end)==labels(ca);
    for cb=ca:length(labels)
      filter_class_b=data(:,end)==labels(cb);
      if ~is_octave
        dists = pdist2(data(filter_class_a,1:end-1),data(filter_class_b,1:end-1),filter.distance_function_name);
        distances(ca,cb) = mean(dists(:));
      else
        dists = pdist2_octave(data(filter_class_a,1:end-1),data(filter_class_b,1:end-1),filter.distance_function_name);
        distances(ca,cb) = mean(dists(:));
      end
      distances(cb,ca) = distances(ca,cb);
    end
  end
sameclassdist=diag(distances);
values=bsxfun(@minus,distances,sameclassdist);
value=mean(values(:));
time=cputime-starttime;
end

function stdtrain = standardize(train)
m=mean(train(:,1:end-1));
s=std(train(:,1:end-1));
stdtrain=[bsxfun(@times,bsxfun(@minus,train(:,1:end-1),m),1./s), train(:,end)];
end

