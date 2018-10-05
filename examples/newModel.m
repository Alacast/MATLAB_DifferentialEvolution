function O = newModel(varargin)
%% WARNING: CHANGE THIS SCRIPT AT YOUR RISK
% This script is used as the template for creating new models. Any changes
% made to this file will be automatically implemented into any new models
% you create in the future.


%% HELP
% % INPUTS:
% % % This accepts multiple inputs, 
% % % 1. OPmode = string; determines which of the modes to run in, 'init',
% 'fit', or 'pred'
% % % 2. DEPENDS ON OPmode; in 'fit' mode, varargin{2} = params,
% varargin{3} = data; in 'pred' mode... (tbd)

%% MAIN EXECUTION
% Define how we want the script. 



% By default, if the user gives no inputs, this script runs in 'init'
% mode, which means that it will construct a model object and return this
% as the output to the user
if nargin == 0
  OPmode = 'init';
else
  OPmode = varargin{1};
end

switch OPmode
  
  case 'init'
    % % % initialize the model % % %
    
    % create a MODEL class that will run THIS function
    M = MODEL(mfilename);
    
    % associate data (table, raw values) with the model
    M.data = [];
    
    % set priors for each parameter(row)
    M.bayes.priors(1,:) = {[],[],[],    [],[],    [],[]};
    
    O = M;
  case 'fit'
    % compute the log likelihood of the data, given the model
    params = varargin{2};
    data = varargin{3};
    
    % loglikelihood
    O = [];
    
  case 'pred'
    % predict a set of representative data given the model and a set of
    % parameters
    O = nan;
end
end