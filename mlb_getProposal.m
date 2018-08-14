function prop = mlb_getProposal(model,prev,t)
% generate new proposed parameter values based on previous iteration if possible
% if we are on step 1, start fresh by sampling from the priors, otherwise,
% use the DE procedure.

% Proposals store the current value of the:
% -parameters
% -log prior, posterior, and likelihood
% for each chain at the current time step

%% INIT
prop.params = nan(model.settings.n.chains,model.n.params);

%%
if isnan(prev.params)
  
  % % % LOAD PREVIOUS PARAMETERS? % % %
  if model.settings.sampling.usePrevious
    prop.params = model.settings.sampling.previousParams .* ones(model.settings.n.chains,1);
  elseif ~isempty(model.settings.sampling.startingSeed)
    prop.params = model.settings.sampling.startingSeed .* ones(model.settings.n.chains,1);
  else
    for p = 1:model.n.params      
      prop.params(:,p) = icdf(...
        model.bayes.priors{p,1},...
        0.5,...
        model.bayes.priors{p,2},...
        model.bayes.priors{p,3})*ones([model.settings.n.chains,1]);
    end
  end
    
  prop.mode = zeros(model.settings.n.chains,1);
  
else
  % we have already had the chains running, so let's do DE
  
  % what operations will be perform this time?
  doMigrate = rand < model.settings.sampling.pMigrate;
  doMutate = rand(model.settings.n.chains,1) < model.settings.sampling.pMutate;
  doCrossover = ~doMutate;
  
  %
  mutate_prop = zeros(model.settings.n.chains,model.n.params);
  crossover_prop = zeros(model.settings.n.chains,model.n.params);
  
  if doMigrate && model.settings.n.groups > 1
    de_migrate
  end
  
  mutate_prop = de_mutate;
  if model.settings.sampling.nChainsPerGroup >=4
    crossover_prop = de_crossover;
  end
  prop.params = prev.params + mutate_prop + crossover_prop;
  
  prop.mode = doMutate + doCrossover*2;
  
  % prevent overunder
  prop.params = min(prop.params,model.settings.sampling.max);
  prop.params = max(prop.params,model.settings.sampling.min);
  %   keyboard
  
  
end



%% Functions
  function de_migrate
    % swap chains around from one group to another
    bestChains = nan(model.settings.n.groups,1);
    %
    % pick the best particle from each group to move
    % should not always move all groups; only :
    % eta = randi(model.settings.n.groups);
    % groupList = nchoosek(model.settings.n.groups,eta);
    for g = 1:model.settings.n.groups
      groupChains = find(model.settings.sampling.groups == g);
      groupProps = prev.logPost(groupChains);
      bestChains(g) = groupChains(find(max(groupProps) == groupProps,1,'first'));
    end
    %
    % now move their assignments around
    for g = 1:model.settings.n.groups
      nextGroupNumber = mod(g,model.settings.n.groups)+1;
      model.settings.sampling.groups(bestChains(g)) = nextGroupNumber;
    end
  end

  function mutate_prop = de_mutate
    %     beta = 0.05;
    %     two38 = 2.38^2;
    %     for c = 1:model.settings.n.chains
    %       S = two38*prev.cov{c}/model.n.params;
    %       %       mean(mean(abs(S)))
    %       if numel(S) == 1
    %         S = eye(model.n.params)*S;
    %       end
    %       R1 = mvnrnd(zeros(1,model.n.params),S);
    %       R2 = mvnrnd(zeros(1,model.n.params),eye(model.n.params)*(.1^2)./model.n.params);
    %       perturb(c,:) = ((1-beta)*R1)+(beta*R2);
    %     end
    
    perturb = ...
      model.settings.sampling.variance .* ...
      model.settings.sampling.varianceScaled...
      .* randn(model.settings.n.chains,model.n.params)...
      .* repmat(doMutate,1,model.n.params);
    mutate_prop = perturb;
    
    %     if any(sum(prop.params - prev.params,2) >100)
    %       keyboard
    %     end
  end

  function crossover_prop = de_crossover
    crossover_prop = zeros(model.settings.n.chains,model.n.params);
    for c = 1:model.settings.n.chains
      if doCrossover(c)
        % see Approximate Bayesian computation with differential evolution, page 4
        myGroup = model.settings.sampling.groups(c); % what group am I in
        groupChains = find(model.settings.sampling.groups == myGroup); % who is in my group
        groupChains(groupChains == c) = []; % remove myself from list of options
        
        % sample a base particle with probability proportional to overall fit
        p_thetaB = prev.logPost(groupChains,:); % posterior likelihood
        relativeWeightsInLog = p_thetaB - min(p_thetaB);
        relativeWeightsInP = exp(relativeWeightsInLog);
        if any(isinf(relativeWeightsInP))
          %           relativeWeightsInP(~isinf(relativeWeightsInP)) = 0;
          bestOther = max(relativeWeightsInP(~isinf(relativeWeightsInP)));
          relativeWeightsInP(isinf(relativeWeightsInP)) = bestOther;
        end
        totalP = sum(relativeWeightsInP);
        if isinf(totalP); totalP = bestOther; end
        normedWeights = relativeWeightsInP ./ totalP;
        normedWeights = normedWeights ./ sum(normedWeights);
        csWeights = cumsum(normedWeights);
        r = sum(rand > csWeights)+1;
        theta_B = groupChains(r);
        
        %         p_thetaBNorm = p_thetaB ./ sum(p_thetaB); % normalize probability
        %         p_thetaBNorm(isnan(p_thetaBNorm)) = 1/length(p_thetaBNorm); % if all == 0, then make equal prob
        %         [sortPTheta,sortPIndex] = sort(p_thetaBNorm);
        %         p_thetaCS = cumsum(sortPTheta);
        %         r = sum(rand > p_thetaCS)+1;
        %         theta_B = groupChains(sortPIndex(r));
        
        %         theta_B = groupChains(randi(length(groupChains))); % base particle
        groupChains(groupChains == theta_B) = []; % don't resample base
        
        theta_M = groupChains(randi(length(groupChains))); % first reference
        groupChains(groupChains == theta_M) = []; % don't resample base
        
        theta_N = groupChains(randi(length(groupChains))); % first reference
        
        refDist = prev.params(theta_M,:) - prev.params(theta_N,:);
        baseDist = prev.params(theta_B,:) - prev.params(c,:);
        gamma1 = .5 + (.5 * rand(1,model.n.params));
        % two modes of sampling
        if t <= model.settings.sampling.nBurnin
          gamma2 = .5 + (.5 * rand);
        else
          gamma2 = 0;
        end
        b = (.002 * rand) - .001;
        
        %         prop.params(c,:) = prev.params(c,:) + scaledDist + b;
        
        
        crossover_prop(c,:) = gamma1.*(refDist) + gamma2*(baseDist) + b;
        
        %         if any(sum((prop.params(c,:) - prev.params(c,:)),2) >100)
        %           keyboard
        %         end
      end
    end
    try kappa = model.settings.sampling.kappa;
    catch kappa = 1;
    end
    reset = rand(size(crossover_prop)) >= kappa;
    crossover_prop(reset==1) = 0;
  end


end