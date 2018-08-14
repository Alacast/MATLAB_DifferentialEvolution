function times = speedTest(params)

times.full = loop(params);

fN = fieldnames(times.full);
for FF = 1:length(fN)
  times.per.(fN{FF}) = mean(mean(mean(times.full.(fN{FF}) ./ (params{1} .* params{2}'))));
end



  function times = loop(params)
    c = params{1};
    s = params{2};
    p = params{3};
    nC = length(c);
    nS = length(s);
    nP = length(p);
    
    for CC = 1:nC
      for SS = 1:nS
        for PP = 1:nP
        model.settings.n.chains = c(CC);
        model.settings.n.steps = s(SS);
        model.settings.n.params = p(PP);
        
        times.text(CC,SS,PP) = runTextFiles(model);
        times.matrix(CC,SS,PP) = runMatrix(model);
        
        pause(1)
        end
      end
    end
  end
    
    

  function t = runTextFiles(model)
    nC = model.settings.n.chains;
    nS = model.settings.n.steps;
    nP = model.settings.n.params;
    
    cDir = [pwd filesep 'chainSave' filesep];
    deleteFiles(cDir,'*.txt');
    pause(1)
    for CC = 1:nC
      fileName{CC} = [cDir 'chain_' num2str(CC) '.txt'];      
      fID{CC} = fopen(fileName{CC},'a+');
    end
    fmt = [repmat('%f ', 1, nP) '\n'];
    data = ones(1,nP);
    
    tic
    for SS = 1:nS
      for CC = 1:nC        
        fprintf(fID{CC},fmt, data);
      end
    end
    t = toc;
    
    fclose('all');
    
  end

function t = runMatrix(model)
    nC = model.settings.n.chains;
    nS = model.settings.n.steps;
    nP = model.settings.n.params;
    
    store = nan(nC,nP,nS);
    data = ones(1,nP);
        
    tic
    for SS = 1:nS
      for CC = 1:nC
        store(CC,:,SS) = data;
      end
    end
    t = toc;
    
    fclose('all');
    
  end

  function deleteFiles(foldHome,type)
%     '*.txt'
    filePattern = fullfile(foldHome, type);
    fileDir = dir(filePattern);
    for f = 1:length(fileDir)
      fullFName = [foldHome fileDir(f).name];
      delete(fullFName)
    end
  end
end