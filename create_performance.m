function performance = create_performance(performance_name)
%
% performance = create_performance(performance_name)
%
% * Implemented performances:
% accuracy (acc)
% precision (ppv)
% recall or sensitivity (tpr)
% f1 score (f1)
% f1 score average (f1avg)
%
% performance_name default: accuracy
% 
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_knn(1, 'euclidean');
% performance = create_performance('f1avg')
% validation = validation_holdout(0.5, randi(1000), true, performance);
% [results confusion] = ml_evaluate(dataset, classifier, validation)
% 
% See: classifier_knn, validation_houldout, ml_evaluate.
%
if exist('performance_name')==0
  performance_name='f1avg';
end
performance.name=performance_name;
if numel(performance_name)==numel('acc') && all(lower(performance_name)=='acc') || numel(performance_name)==numel('accuracy') && all(lower(performance_name)=='accuracy')
  performance.execute=@performance_acc;
  return
end
if numel(performance_name)==numel('ppv') && all(lower(performance_name)=='ppv') || numel(performance_name)==numel('precision') && all(lower(performance_name)=='precision')
  performance.execute=@performance_ppv;
  return
end
if numel(performance_name)==numel('tpr') && all(lower(performance_name)=='tpr') || numel(performance_name)==numel('recall') && all(lower(performance_name)=='recall') || numel(performance_name)==numel('sensitivity') && all(lower(performance_name)=='sensitivity')
  performance.execute=@performance_tpr;
  return
end
if numel(performance_name)==numel('f1') && all(lower(performance_name)=='f1') || numel(performance_name)==numel('f1score') && all(lower(performance_name)=='f1score')
  performance.execute=@performance_f1score;
  return
end
if numel(performance_name)==numel('f1avg') && all(lower(performance_name)=='f1avg') || numel(performance_name)==numel('f1average') && all(lower(performance_name)=='f1average')
  performance.execute=@performance_f1average;
  return
end
performance.execute=@performance_f1average;
end

function accuracy = performance_acc(confusion)
  accuracy = trace(confusion)/sum(sum(confusion));
end

function precision = performance_ppv(confusion) 
for c=1:length(confusion)
  precision(c) = confusion(c,c)/sum(confusion(c,:));
end
end

function recall = performance_tpr(confusion) 
for c=1:length(confusion)
  recall(c) = confusion(c,c)/sum(confusion(:,c));
end
end

function f1score = performance_f1score(confusion)
  precision = performance_ppv(confusion);
  filter = isnan(precision);
  precision(filter) = 1;
  recall = performance_tpr(confusion);
  filter = isnan(recall);
  recall(filter) = 1; 
  warning('off') ;
  f1score = 2*((precision.*recall)./(precision+recall));
  warning('on');
end

function f1average = performance_f1average(confusion)
  warning('off');

  precisions = performance_ppv(confusion);
  filter = isnan(precisions);
  %precision = mean(precisions(~filter));
  precisions(filter)=1; precision = mean(precisions);

  recalls = performance_tpr(confusion);
  filter = isnan(recalls);
  %recall = mean(recalls(~filter));
  recalls(filter)=1; recall = mean(recalls);

  f1average = 2*((precision.*recall)./(precision+recall));

  warning('on');
  if isnan(f1average)
    f1average = 0;
  end
end

