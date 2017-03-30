function trainedclassifier = tunning_gridsearch(baseclassifier, dataset, grid, validation)
%
% trainedclassifier = tunning_gridsearch(classifier, dataset, grid, validation)
%
% %Example:
% dataset=load('datasets/iris.m');
% classifier = classifier_knn()
% grid = allcomb({1 3 5 7 9 11 13 15})
% validation = validation_holdout()
% model = tunning_gridsearch(classifier, dataset, grid, validation)
% [results confusion trtime tetime trained_classifier] = ml_evaluate(dataset, model, validation)
%
% See: classifier_knn, validation_houldout, validation_crossvalidation, create_performance, ml_evaluate.
%

if exist('baseclassifier')==1
  tunned.baseclassifier = baseclassifier;
else
  tunned.baseclassifier = classifier_knn();
end
if exist('grid')==1
  tunned.grid = grid;
else
  tunned.grid = {};
end
if exist('validation')==1
  tunned.validation = validation;
else
  tunned.validation = validation_holdout();
end
trainedclassifier = tunnedtrain(tunned, dataset);

function tunned = tunnedtrain(tunned, dataset)
bestmodel = gridsearch(tunned, dataset);
tunned = bestmodel.train(bestmodel, dataset);
end

function bestmodel = gridsearch(tunned, dataset)
if size(tunned.grid,1) == 0 || iscell(tunned.grid)==0
  bestmodel = tunned.baseclassifier;
  return
end
numgridlines = size(tunned.grid,1);
bestCrit = -Inf;
bestmodel = tunned.baseclassifier;
for i=1:numgridlines
  gl = tunned.grid(i,:);
  model = genmodel(tunned.baseclassifier, gl);
  crit = -Inf;
  try
    crit = mean(mean(ml_evaluate(dataset, model, tunned.validation)));
  end
  if crit > bestCrit
    bestCrit=crit;
    bestmodel=model;
  end
end
end

function model = genmodel(classifier, gl)
if size(gl,2) == 1
  model = classifier.constructor(gl{1});
  return
end
if size(gl,2) == 2
  model = classifier.constructor(gl{1},gl{2});
  return
end
if size(gl,2) == 3
  model = classifier.constructor(gl{1},gl{2},gl{3});
  return
end
if size(gl,2) == 4
  model = classifier.constructor(gl{1},gl{2},gl{3},gl{4});
  return
end
if size(gl,2) == 5
  model = classifier.constructor(gl{1},gl{2},gl{3},gl{4},gl{5});
  return
end
if size(gl,2) == 6
  model = classifier.constructor(gl{1},gl{2},gl{3},gl{4},gl{5},gl{6});
  return
end
if size(gl,2) == 7
  model = classifier.constructor(gl{1},gl{2},gl{3},gl{4},gl{5},gl{6},gl{7});
  return
end
end

end

