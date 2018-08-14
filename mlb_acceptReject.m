function accepted = mlb_acceptReject(model,prop,prev)
% determines if the proposed parameters, propPost, are more or less likely than 
% the posterior probability of the previous iteration, prev. 
% Accepts the new params with probability, post(prop) / prevPost


logRatio = prop.logPost - prev.logPost;
r = log(rand(model.settings.n.chains,1));

kept = r <= logRatio;
% reject any with prior = 0
kept(isinf(prop.logPrior)) = 0;

fn = fieldnames(prop);
for c = 1:model.settings.n.chains
  if kept(c)
    for f = 1:length(fn)
      if ~strcmp(fn{f},'pairwise')
        accepted.(fn{f})(c,:) = prop.(fn{f})(c,:);
      else
        accepted.pairwise.predict(c,:) = prop.pairwise.predict(c,:);
        accepted.pairwise.parameters(c,:) = prop.pairwise.parameters(c,:);
      end
    end
  else
    for f = 1:length(fn)
      if ~strcmp(fn{f},'pairwise')
        accepted.(fn{f})(c,:) = prev.(fn{f})(c,:);
      else
        accepted.pairwise.predict(c,:) = prev.pairwise.predict(c,:);
        accepted.pairwise.parameters(c,:) = prev.pairwise.parameters(c,:);
      end
    end
  end
end

accepted.kept = kept;