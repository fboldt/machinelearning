function elm = classifier_pelm(FactorOfHiddenNeurons, FeatureSelectionMethod)
%
% elm = classifier_pelm(FactorOfHiddenNeurons, FeatureSelectionMethod)
%
% %Example:
% dataset = load('datasets/iris.m');
% classifier = classifier_pelm(); classifier.autotunning=true
% validation = validation_crossvalidation(2,1)
% [results confusion trtime tetime trainedclassifier] = ml_evaluate(dataset, classifier, validation)
% 
% See: validation_houldout, create_performance, ml_evaluate.
%
elm.classifiername='PELM - Prunned Extreme Learning Machine';
elm.train=@elmtrain;
elm.predict=@elmpredict;
elm.constructor=@classifier_pelm;
if exist('Elm_Type')==1
  elm.Elm_Type=Elm_Type;
else  
  elm.Elm_Type=1;
end
if exist('FactorOfHiddenNeurons')==1
  elm.FactorOfHiddenNeurons=FactorOfHiddenNeurons;
else
  elm.FactorOfHiddenNeurons=10;
end
if exist('ActivationFunction')==1
  elm.ActivationFunction=ActivationFunction;
else
  elm.ActivationFunction='sig';
end
if exist('trainAlgorithm')==1
  elm.trainAlgorithm=trainAlgorithm;
else
  elm.trainAlgorithm=@elm_pinv;
end
if exist('FeatureSelectionMethod')==1
  elm.FeatureSelectionMethod = FeatureSelectionMethod;
else
  fscriterion = fscriterion_filter();
  elm.FeatureSelectionMethod = feature_selection_ranking(fscriterion);
  %elm.FeatureSelectionMethod = feature_selection_pso(fscriterion);
end
end

%%% Training function
function elm = elmtrain(elm, dataset)
starttime=cputime;
if any(strcmp('autotunning',fieldnames(elm))) && elm.autotunning==true
  [nsamples nfeats] = size(dataset);
  nfeats = nfeats-1;
%  if nsamples/nfeats>1
    nfactors = unique((linspace(elm.FactorOfHiddenNeurons, nsamples/nfeats, 5)));
    grid = allcomb(num2cell(nfactors));
    validation = validation_multiholdout(3);
    tunned = tunning_gridsearch(elm, dataset, grid, validation);
    elm = tunned.train(tunned, dataset);
%  else
%    elm = normaltrain(elm, dataset);
%  end
else
  elm = normaltrain(elm, dataset);
end
elm.training_time=cputime-starttime;
end


function elm = normaltrain(elm, dataset)
if nargin==2
  parameters_names = fieldnames(elm);
  for loopIndex = 1:numel(parameters_names) 
    eval(sprintf('%s = %s', parameters_names{loopIndex}, 'elm.(parameters_names{loopIndex});'));
  end
end
%%%%%%%%%%% Macro definition
REGRESSION=0;
CLASSIFIER=1;
T=dataset(:,end)';
P=dataset(:,1:end-1)';
clear dataset;  %Release raw training data array
NumberofTrainingData=size(P,2);
NumberofInputNeurons=size(P,1);
if Elm_Type~=REGRESSION
    %%%%%%%%%%%% Preprocessing the data of classification
    sorted_target=sort(T,2);
    label=zeros(1,1); %Find and save in 'label' class label from training and testing data sets
    label(1,1)=sorted_target(1,1);
    j=1;
    for i = 2:NumberofTrainingData
        if sorted_target(1,i) ~= label(1,j)
            j=j+1;
            label(1,j) = sorted_target(1,i);
        end
    end
    number_class=j;
    NumberofOutputNeurons=number_class;
    %%%%%%%%%% Processing the targets of training
    temp_T=zeros(NumberofOutputNeurons, NumberofTrainingData);
    for i = 1:NumberofTrainingData
        for j = 1:number_class
            if label(1,j) == T(1,i)
                break; 
            end
        end
        temp_T(j,i)=1;
    end
    T=temp_T*2-1;
    elm.NumberofOutputNeurons=NumberofOutputNeurons;
    elm.label=label;
end     %end if of Elm_Type
elm.P=P;
elm.T=T;
%%%%%%%%%%% Calculate output weights OutputWeight (beta_i)
elm.NumberofHiddenNeurons=ceil(NumberofInputNeurons*elm.FactorOfHiddenNeurons);
if elm.NumberofHiddenNeurons==0
  elm.NumberofHiddenNeurons=1;
end
elm=trainAlgorithm(elm);
elm.train=@elmtrain;
elm.predict=@elmpredict;
elm.classifiername=classifiername;
elm.FactorOfHiddenNeurons = FactorOfHiddenNeurons;
elm.trainAlgorithm=@elm_pinv;
end

%%% Prediction function
function [output confidence] = elmpredict(elm_model, dataset)
%%%%%%%%%%% Macro definition
REGRESSION=0;
CLASSIFIER=1;
TV.T=dataset(:,end)';
TV.P=dataset(:,1:end-1)';
clear dataset; %Release raw testing data array
NumberofTestingData=size(TV.P,2);
elm_model_names = fieldnames(elm_model);
for loopIndex = 1:numel(elm_model_names) 
  eval(sprintf('%s = %s', elm_model_names{loopIndex}, 'elm_model.(elm_model_names{loopIndex});'));
end
if Elm_Type~=REGRESSION
    %%%%%%%%%% Processing the targets of testing
    temp_TV_T=zeros(NumberofOutputNeurons, NumberofTestingData);
    for i = 1:NumberofTestingData
        for j = 1:size(label,2)
            if label(1,j) == TV.T(1,i)
                break; 
            end
        end
        temp_TV_T(j,i)=1;
    end
    TV.T=temp_TV_T*2-1;
end    %end if of Elm_Type
%%%%%%%%%%% Calculate the output of testing input
start_time_test=cputime;
tempH_test=InputWeight*TV.P;
clear TV.P; %Release input of testing data             
ind=ones(1,NumberofTestingData);
BiasMatrix=BiasofHiddenNeurons(:,ind); %Extend the bias matrix BiasofHiddenNeurons to match the demention of H
tempH_test=tempH_test + BiasMatrix;
switch lower(ActivationFunction)
    case {'sig','sigmoid'}
        %%%%%%%% Sigmoid 
        H_test = 1 ./ (1 + exp(-tempH_test));
    case {'sin','sine'}
        %%%%%%%% Sine
        H_test = sin(tempH_test);        
    case {'hardlim'}
        %%%%%%%% Hard Limit
        H_test = hardlim(tempH_test);        
        %%%%%%%% More activation functions can be added here        
end
H_test = H_test(internal_features,:);
TY=(H_test' * OutputWeight)'; %TY: the actual output of the testing data
end_time_test=cputime;
TestingTime=end_time_test-start_time_test; %Calculate CPU time (seconds) spent by ELM predicting the whole testing data
if Elm_Type == REGRESSION
    TestingAccuracy=sqrt(mse(TV.T - TY)); %Calculate testing accuracy (RMSE) for regression case
    confusion=[TestingAccuracy 1-TestingAccuracy];
    output=TY;
end
if Elm_Type == CLASSIFIER
    [confidence, label_index_actual]=max(TY);
    output=elm_model.label(label_index_actual); 
    output=output';
    confidence=confidence';
end
end

function elm_model = elm_pinv(parameters)
parameters_names = fieldnames(parameters);
for loopIndex = 1:numel(parameters_names) 
  eval(sprintf('%s = %s', parameters_names{loopIndex}, 'parameters.(parameters_names{loopIndex});'));
  %disp(parameters_names{loopIndex});
end
%%%%%%%%%%% Macro definition
REGRESSION=0;
CLASSIFIER=1;
NumberofTrainingData=size(P,2);
NumberofInputNeurons=size(P,1);
%%%%%%%%%%% Calculate weights & biases
start_time_train=cputime;
%%%%%%%%%%% Random generate input weights InputWeight (w_i) and biases BiasofHiddenNeurons (b_i) of hidden neurons
InputWeight=rand(NumberofHiddenNeurons,NumberofInputNeurons)*2-1;
BiasofHiddenNeurons=rand(NumberofHiddenNeurons,1);
tempH=InputWeight*P;
clear P; %Release input of training data 
ind=ones(1,NumberofTrainingData);
BiasMatrix=BiasofHiddenNeurons(:,ind); %Extend the bias matrix BiasofHiddenNeurons to match the demention of H
tempH=tempH+BiasMatrix;
%%%%%%%%%%% Calculate hidden neuron output matrix H
elm_model.H=elm_calculateMatrixH(ActivationFunction,tempH);
clear tempH; %Release the temparary array for calculation of hidden neuron output matrix H
%%%%%%%%%%% Calculate output weights OutputWeight (beta_i)
labels=ones(1,size(T,2));
for i=1:size(T,1)
  labels(T(i,:)==1)=i;
end
data = [elm_model.H;labels]';
[elm_model.internal_features time] = FeatureSelectionMethod.execute(FeatureSelectionMethod, data);
elm_model.H = elm_model.H(elm_model.internal_features,:);
try
  OutputWeight=pinv(elm_model.H') * T';
end
if exist('OutputWeight')~=1
try
  warning('off')
  D=elm_model.H';
  omega = D'*inv(D*D'); 
  clear D;
  OutputWeight=omega * T';
  clear omega;
  warning('on')
end
end
if exist('OutputWeight')~=1
  OutputWeigt=rand(size(elm_model.H,1),size(T,1));
end
end_time_train=cputime;
elm_model.TrainingTime=end_time_train-start_time_train; %Calculate CPU time (seconds) spent for training ELM
elm_model.NumberofHiddenNeurons=NumberofHiddenNeurons;
if Elm_Type~=REGRESSION
    elm_model.NumberofInputNeurons=NumberofInputNeurons; elm_model.NumberofOutputNeurons=NumberofOutputNeurons; elm_model.InputWeight=InputWeight; elm_model.BiasofHiddenNeurons=BiasofHiddenNeurons; elm_model.OutputWeight=OutputWeight; elm_model.ActivationFunction=ActivationFunction; elm_model.label=label; elm_model.Elm_Type=Elm_Type;
else
    elm_model.InputWeight=InputWeight; elm_model.BiasofHiddenNeurons=BiasofHiddenNeurons; elm_model.OutputWeight=OutputWeight; elm_model.ActivationFunction=ActivationFunction; elm_model.Elm_Type=Elm_Type;
end
elm_model.FeatureSelectionMethod = FeatureSelectionMethod;
end

function H = elm_calculateMatrixH(ActivationFunction, tempH)
  %%%%%%%%%%% Calculate hidden neuron output matrix H
  switch lower(ActivationFunction)
      case {'sig','sigmoid'}
          %%%%%%%% Sigmoid 
          H = 1 ./ (1 + exp(-tempH));
      case {'sin','sine'}
          %%%%%%%% Sine
          H = sin(tempH);    
      case {'hardlim'}
          %%%%%%%% Hard Limit
          H = hardlim(tempH);            
          %%%%%%%% More activation functions can be added here                
  end
  clear tempH; %Release the temparary array for calcula of hidden neuron output matrix H
end

