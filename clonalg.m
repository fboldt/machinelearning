function [P] = clonalg(fitness_function, P, parameters)

% Immune Algorithm - Evolutionary strategy inspired in the Immune System
% Operations: Hypermutation, Editing, Selection
% Each clone has size proportional to its affinity
%
% function [solutions] = clonalg(fitness_function,P,parameters);
% solution 	-> best solutions found
% P    	-> initial population (binary)
% gen  	-> number of generations
% pm   	-> hypermutation probability
% per  	-> percentile of the population to suffer random reshuffle
% 
% T    	-> temporary population
%
% %Example:
% fitness_function=@fitness_test2d;
% P=(rand(10,20)-0.5)>0;
% solutions = clonalg(fitness_function,P);
% fitness = fitness_function(solutions,{})';
% positions = [1:size(P,1)]';
% results=[positions fitness];
% [x ind] = sort(fitness,'descend');
% results(ind,:)
% 
if nargin <= 1,
  disp('Fitness function and initial population (P) are mandatory.')
  return
end

if nargin==3
  parameters_names = fieldnames(parameters);
  for loopIndex = 1:numel(parameters_names) 
    eval(sprintf('%s = %s', parameters_names{loopIndex}, 'parameters.(parameters_names{loopIndex});'));
  end
else
  parameters={};
end
if exist('gen')==0,
  gen = size(P,2)*2;
end
if exist('pm')==0,
  pm = 1/size(P,2)^2;
end
per = 0.0; 
n = size(P,1);
if exist('numclones')==0
  numclones=4;
end
fat = numclones/n;

%disp(sprintf('Number of generations: %d',gen));
%disp(sprintf('Population size: %d',n));
%disp(sprintf('Mutation probability: %.3f',pm));
%disp(sprintf('Number of clones per candidate: %d',fat*n));

% Hypermutation controlling parameters
pma = pm; itpm = ceil(gen*1); pmr = 0.8;

% General defintions
[N,L] = size(P); it = 0;

%%% anti-degradation
%maxdegrad=gen;
%bestvalue=-Inf;
%bestP=P;
%degrad=0;

% Generations
while it <= gen 
  T = []; cs = [];
  fitP = fitness_function(P,parameters);
  [a,ind] = sort(fitP);
  
  %%% anti-degradation
%  if a(end)>bestvalue
%    bestvalue=a(end);
%    bestP=P;
%    degrad=0;
%  else
%    degrad=degrad+1;
%    if degrad>maxdegrad
%      P=bestP;
%      break
%    end
%  end

  % Reproduction
  [T,pcs] = reprod(n,fat,N,ind,P,T);

  % Hypermutation
  M = rand(size(T,1),L) <= pm;
  T = T - 2 .* (T.*M) + M;
  T(pcs,:) = P(fliplr(ind(end-n+1:end)),:);
  T=T==1;
  
  % New Re-Selection (Multi-peak solution)
  fitT = fitness_function(T,parameters);
  pcs = [0 pcs];
  for i=1:n,
    [out(i),bcs(i)] = max(fitT(pcs(i)+1:pcs(i+1)));		% Maximizationn problem
    bcs(i) = bcs(i) + pcs(i);
  end;
  P(fliplr(ind(end-n+1:end)),:) = T(bcs,:);
   
  % Editing (Repertoire shift)
  nedit = round(per*N); it = it + 1;
  P(ind(1:nedit),:) = cadeia(nedit,L,0,0,0);
  pm = pmcont(pm,pma,pmr,it,itpm); 
  
end

% Reproduction
function [T,pcs] = reprod(n,fat,N,ind,P,T);
% n		-> number of clones
% fat	-> multiplying factor
% ind	-> best individuals
% T		-> temporary population
% pcs	-> final position of each clone
if n == 1,
   cs = N;
   T = ones(N,1) * P(ind(1),:);
else,
   for i=1:n,
      % cs(i) = round(fat*N/i);
      cs(i) = round(fat*N);
      pcs(i) = sum(cs);
      T = [T; ones(cs(i),1) * P(ind(end-i+1),:)];
   end;
end;

% Control of pm
function [pm] = pmcont(pm,pma,pmr,it,itpm);
% pma	-> initial value
% pmr	-> control rate
% itpm	-> iterations for restoring
if rem(it,itpm) == 0,
   pm = pm * pmr;
   if rem(it,10*itpm) == 0,
      pm = pma;
   end;
end;

% Function CADEIA
function [ab,ag] = cadeia(n1,s1,n2,s2,bip)
if nargin == 2,
   n2 = n1; s2 = s1; bip = 1;
elseif nargin == 4,
   bip = 1;
end;
% Antibody (Ab) chains
ab = 2 .* rand(n1,s1) - 1;
if bip == 1,
   ab = hardlims(ab);
else,
   ab = hardlim(ab);
end;
% Antigen (Ag) chains
ag = 2 .* rand(n2,s2) - 1;
if bip == 1,
   ag = hardlims(ag);
else,
   ag = hardlim(ag);
end;
% End Function CADEIA

