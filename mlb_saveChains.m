function mlb_saveChains(model)
% save the large amount of data stored in the model's chains into txt files to 
% preserve ML memory

chainDir = [pwd filesep 'chainSave' filesep];

for c = 1:model.settings.n.chains
  CH = model.chains(c);
  % save the predictions
%   CH.
  
end
end
