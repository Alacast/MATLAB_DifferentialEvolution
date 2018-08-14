function model = mlb_prepareModel(model)
% takes a model object and determines some basic information, such as the
% number of parameters, etc...

%% CHECK SETTINGS
if ~isfield(model,'settings')
  model.settings.n.chains = 1;
  model.settings.n.groups = 1;
  model.settings.n.steps = 1000;
end
if ~isfield(model.settings.n,'chains')
  model.settings.n.chains = 4;
end
if ~isfield(model.settings.n,'groups')
  model.settings.n.groups = 1;
end
if ~isfield(model.settings.n,'steps')
  model.settings.n.steps = 1000;
end

%% SAMPLING
if ~isfield(model.settings,'sampling')
  model.settings.sampling.pMutate = 1;
  model.settings.sampling.variance = .1;
  model.settings.sampling.pMigrate = 0;
  model.settings.sampling.pBurnin = .1;
end
if ~isfield(model.settings.sampling,'pMutate')
  model.settings.sampling.pMutate = .9;
end
if ~isfield(model.settings.sampling,'variance')
  model.settings.sampling.variance = .1;
end
if ~isfield(model.settings.sampling,'pMigrate')
  model.settings.sampling.pMigrate = .1;
end
if ~isfield(model.settings.sampling,'pBurnin')
  model.settings.sampling.pBurnin = .1;
end

%% BASIC
model.n.params = length(model.names.params);
model.settings.sampling.nChainsPerGroup = model.settings.n.chains / model.settings.n.groups;
%% FOR SAVING OUTPUTS
% configure the number of outputs
if ~isfield(model.n,'conditions')
  model.n.conditions = 1;
end
if ~isfield(model.n,'predictions')
  model.n.predictions = 1;
end

%% FUNCTION NAMES
if ~isfield(model.function,'convert')
  model.function.convert = '';
end
if ~isfield(model.function,'postpredict')
  model.function.postpredict = '';
end

%% COMPARISONS
if ~isfield(model,'comparisons')
  % prediction comparisons
  model.comparisons.pairwise.predictions.conditions = [];
  model.comparisons.pairwise.predictions.values = [0];
  model.comparisons.pairwise.predictions.dir = 1;
  % parameter comparisons
  model.comparisons.pairwise.parameters.comparisons = [];
  model.comparisons.pairwise.parameters.values = zeros(model.n.params,1);
  model.comparisons.pairwise.parameters.dir = ones(model.n.params,1);
end

%% ITERATIVE RUNNIUNG
% do we try to rerun the model with old parameters, if they exist?
if ~isfield(model.settings.sampling, 'usePrevious')
  model.settings.sampling.usePrevious = 0;
end

if ~isfield(model.settings.sampling,'startingSeed')
  model.settings.sampling.startingSeed = [];
end

%% PLOTTING
model.plotting.figBase = 1;
%% USE PARALLEL
if ~isfield(model.settings,'useParallel')
  model.settings.useParallel = 0;
end

%% FIRST TIME SETUP
model.settings.sampling.nBurnin = model.settings.sampling.pBurnin * model.settings.n.steps;

% Put the chains into groups
if ~(int64(model.settings.sampling.nChainsPerGroup) == model.settings.sampling.nChainsPerGroup)
  disp(['Warning: cannot evenly divide chains into the specified number' ...
    ' of groups, model.settings nGroups = 1'])
  model.settings.n.groups = 1;
  model.settings.sampling.nChainsPerGroup = model.settings.n.chains;
end

if model.settings.sampling.nChainsPerGroup < 4 && (1-model.settings.sampling.pMutate) > 0
  disp(['Warning: Crossover requires at least 4 chains per group, and you'...
    ' only have ' num2str(model.settings.sampling.nChainsPerGroup) '. Disabling for now.'])
  model.settings.sampling.pMutate = 1;
  model.settings.n.groups = 1;
  model.settings.sampling.nChainsPerGroup = model.settings.n.chains;
end
chainOrder = randperm(model.settings.n.chains);
model.settings.sampling.groups = nan(model.settings.n.chains,1);
groupNums = repmat(1:model.settings.n.groups,[1,model.settings.sampling.nChainsPerGroup]);
model.settings.sampling.groups = groupNums(chainOrder);

% scale the variance
for p = 1:model.n.params
  edges = ...
    icdf(...
    model.bayes.priors{p,1},...
    [.01 .99],...
    model.bayes.priors{p,2},...
    model.bayes.priors{p,3});
  
  model.settings.sampling.varianceScaled(:,p) = ...
    diff(edges,1,2);
  model.settings.sampling.min(:,p) = edges(1);
  model.settings.sampling.max(:,p) = edges(2);
end



