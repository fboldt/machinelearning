function distance = fscriterion_distance(distance_function_name)
%
% distance = fscriterion_distance(distance_function_name)
%
% %Example 1:
% dataset = load('datasets/iris.m');
% distance = fscriterion_distance('euclidean');
% [value, time] = distance.execute(distance, dataset)
%
%
if exist('distance_function_name')==1
  distance.distance_function_name=distance_function_name;
else
  distance.distance_function_name='euclidean';
end
distance.execute=@distanceexecute;
end

function [value, time] = distanceexecute(distance, dataset)
starttime=cputime;
  labels=unique(dataset(:,end));
  for c=1:length(labels)
    filter_class=dataset(:,end)==labels(c);
    if ~is_octave
      dists = pdist2(dataset(filter_class,1:end-1),dataset(~filter_class,1:end-1),distance.distance_function_name);
      distances(c) = mean(dists(:));
      %dists = pdist2(dataset(filter_class,1:end-1),dataset(filter_class,1:end-1),distance.distance_function_name);
      %sameclassdist(c) = mean(dists(:));
    else
      dists = pdist2_octave(dataset(filter_class,1:end-1),dataset(~filter_class,1:end-1),distance.distance_function_name);
      distances(c) = mean(dists(:));
      %dists = pdist2_octave(dataset(filter_class,1:end-1),dataset(filter_class,1:end-1),distance.distance_function_name);
      %sameclassdist(c) = mean(dists(:));
    end
  end
%end
value=mean(distances);%mean(distances-sameclassdist);
time=cputime-starttime;
end

