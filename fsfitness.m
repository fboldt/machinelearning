function fit = fsfitness(filters, params)
for i = 1:size(filters,1)
  if sum(filters(i,:))==0
    fit(i)=-Inf;
    continue
  end
  fit(i) = params.fscriterion.execute(params.fscriterion, params.data(:,[filters(i,:),true]));
  %fit(i) = params.fscriterion.executewrapper(params.fscriterion, params.data(:,[filters(i,:),true]));
end
end



