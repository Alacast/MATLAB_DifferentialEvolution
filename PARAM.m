classdef PARAM < matlab.mixin.Copyable
  properties (SetObservable)
    % name
    name = '';
    
    % properties of prior distribution
    prior = cell(1,3);
    
    % allowed range of the value
    range = nan(1,2);
    
    % actual value
    value = nan;
    
    % log likelihood of the prior
    logPrior = nan;
  end
  
  events
    priorChanged
  end
  
  methods
    function P = PARAM(varargin)
      % Creates a parameter
      
      % % % add listeners % % %
      addlistener(P,'prior','PostSet',@P.reset_value);
      addlistener(P,'prior','PostSet',@P.calc_range);
      addlistener(P,'value','PostSet',@P.calc_prior);
      
      % % % if a prior is given, then use it % % %
      if nargin > 0
        P.prior = varargin{1};
      end
    end
    
    function calc_prior(P,~,~)
      % Calculate the (log) prior probability of the parameter's current value, given its prior distribution.
      P.logPrior = MODEL.calc_safeLL(pdf(P.prior{1},P.value,P.prior{2},P.prior{3}));
    end
    
    function calc_range(P,~,~)
      % Calculate the acceptable range that this parameter value can take
      % on without being out of bounds 
      P.range = icdf(P.prior{1},[.001,.999],P.prior{2},P.prior{3});
    end
    
    function calc_safeV(P)
      % Makes sure the value for a given parameter is within its allowed
      % range
      if P.value < P.range(1) || P.value > P.range(2)
        P.value = max(P.range(1),min(P.range(2),P.value));
      end
    end
    
    function reset_value(P,~,~)
      % reset the parameter's current value to the 50th percentile of its prior distribution.
      P.value = icdf(P.prior{1},0.5,P.prior{2},P.prior{3});
      P.calc_prior;
    end
  end
  methods (Static)
    
  end
end
