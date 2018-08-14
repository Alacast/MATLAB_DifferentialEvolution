function MC = mlb_compareModels(MC)

%%
nModels = length(MC.models);

for m1 = 1:nModels
  chain1 = mlb_loadFiles(MC.models(m1));
  for m2 = 1:nModels
    if m1 ~= m2
      chain2 = mlb_loadFiles(MC.models(m2));
      %
      aicDiff = chain1.AIC_burn - chain2.AIC_burn;
      MC.compare(m1).versus(m2).aicDiff = aicDiff;
      [MC.compare(m1).versus(m2).mu,MC.compare(m1).versus(m2).sig] = normfit(aicDiff);
    end    
  end
end

end