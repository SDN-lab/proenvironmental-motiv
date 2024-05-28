%% Data simulation, PR & MI script %% Adpated from script written by Pat Lockwood & Marco Wittmann 2019 by Jo Cutler 2020
%%% simulation script for parameter recovery and  model identifiability for different
%%% models for prosocial motivation effort task
%%%

clear all;
close all;
%clearvars

addpath('models');
addpath('tools');

beep off;

% Specify whether to run parameter recovery, model identifiability, or both
% -------------------------------------------- %

runPR = 0; % whether to run parameter recovery 1 = yes, 0 = no **
runMI = 1; % whether to run model identifiability 1 = yes, 0 = no **

mlePR = 2; % whether PR to run maximum likelihood = 1, or hierarchical em fit = 2 **
mleMI = 2; % whether MI to run maximum likelihood = 1, or hierarchical em fit = 2 **

nrep = 1; % how many iterations of mle fit to run
% re-runs the fit so parameters don't get stuck in a local minima
% can be 1 for decision-making tasks as unlikely to make a difference
% but more important to be >1 for learning tasks

% Specify model with which to generate simulated behaviour
% -------------------------------------------- %

models = {'two_k_one_beta', 'two_k_one_beta_linear', 'two_k_one_beta_hyperbolic'...
    'two_k_two_beta', 'two_k_two_beta_linear', 'two_k_two_beta_hyperbolic'};

modPR = 2; % enter the model number to run PR on - numerical index in models variable **

% Load in schedule
% -------------------------------------------- %

load trialorderPM.mat % specify trial order file here **
nTrls = size(data.agent,1);

minEffort = min(data.effort); % minimum effort level
maxReward = max(data.reward); % maximum reward level

% the discount rate that means the maximum reward and minimum effort has a
% value of 0
bounds.beta = [0, 10]; % enter bounds on beta values here **

betamin = min(bounds.beta);
betamax = max(bounds.beta);

toRun = [];
if runPR == 1
    toRun = [toRun, 1];
end
if runMI == 1
    toRun = [toRun, 2];
end

toRunOptions = {'PR', 'MI'};
mleOptions = {'mle', 'em'};

for tr = toRun
    
    rng default % resets the randomisation seed to ensure results are reproducible (MATLAB 2019b)
    
    if tr == 1 % for parameter recovery:
        type = 1; % how to simulate parameters 1 = grid of values, 2 = distribution **
        nRounds = 1; % only 1 round needed for PR
        modelsTR = modPR; % the model number to run PR on - numerical index in models variable
        mle_em = mlePR; % whether to run maximum likelihood = 1, or hierarchical em fit = 2
    elseif tr == 2 % for model identifiability:
        type = 2; % how to simulate parameters 1 = grid of values, 2 = distribution **
        nRounds = 10; % how many times to run MI (used in best model counts) **
        modelsTR = 1:length(models); % for MI run all models
        mle_em = mleMI; % whether to run maximum likelihood = 1, or hierarchical em fit = 2
    end
    
    if type == 2
        nSubj = 100; % how many subjects to simulate if not defined by grid **
    else
        nSubj = NaN; % if grid (type == 1) number defined by grid combinations below
    end
    
    for r = 1:nRounds
        
        for m = modelsTR % loop over model number(s) specified above
            
            clearvars -except toRun* models* type *bounds *min *max stim nTrls nBlocks nSubj tr nRounds mle* r m all_* data nrep
            close all;
            
            modelID = models{m};
            s.PM.expname = 'PM';
            
            maxK = maxValue(data, 'k', 'modelID'); % maximum k calculated as
            bounds.k = [0, maxK]; % enter bounds on k values here **
            kmin = min(bounds.k);
            kmax = max(bounds.k);
            
            params = get_params(modelID); % if adding new model functions also add the parameters here **
            nParam  = length(params);
            
            if tr == 1
                msg = ['Running parameter recovery for ', modelID, ', calculating ', num2str(nParam), ' parameters: ', char(params{1})];
                for n = 2:nParam
                    msg = [msg, ', ', char(params{n})];
                end
            elseif tr == 2
                msg = ['Running model identifiability for ', modelID, ', round ', num2str(r),' of ', num2str(nRounds)];
            end
            disp(msg) % show details in command window
            
            % Set parameters to simulate
            % -------------------------------------------- %
            
            if type == 1 % if using a grid of values
                noise = 0.05; % level of noise added to grid of starting values **
                grid.k = [kmin:0.3:kmax]; % define grid values **
                grid.beta = [betamin:1:betamax]; % define grid values **
                
                for ip=1:length(params)
                    thisp=params{ip};
                    if contains(thisp, 'k') == 1
                        grid.all{ip} = grid.k;
                    elseif contains(thisp, 'beta') == 1
                        grid.all{ip} = grid.beta;
                    else
                        error('Define parameter as one of above cases');
                    end
                end
                allCombs = combvec(grid.all{1:end})';
                nSubj = size(allCombs,1);
            elseif type == 2 % if using a distribution of values
                for sub = 1:nSubj
                    kcount = [];
                    for ip = 1:length(params)
                        thisp=params{ip};
                        if contains(thisp, 'k') == 1
                            allCombs(sub,ip) = rand * kmax; %  draw random value up to k max (if min != 0 edit to account for) **
                            % can also define distribution other than normal e.g. betarnd() / gamrnd()
                            %                             kcount = [kcount, ip];
                            %                             if length(kcount) > 1
                            %                                 kdiff = abs(allCombs(sub,ip) - allCombs(sub,kcount(1)));
                            %                                 while allCombs(sub,ip) > (kmax) || allCombs(sub,ip) < (kmin) % || kdiff < 0.2
                            %                                     allCombs(sub,ip) = rand * kmax;
                            %                                 end
                            %                             else
                            while allCombs(sub,ip) > (kmax) || allCombs(sub,ip) < (kmin)
                                allCombs(sub,ip) = rand * kmax;
                            end
                            %                             end
                        elseif contains(thisp, 'beta') == 1
                            allCombs(sub,ip) = rand * betamax; %  draw random value up to beta max (if min != 0 edit to account for) **
                            % can also define distribution other than normal e.g. betarnd() / gamrnd()
                            while allCombs(sub,ip) > (betamax) || allCombs(sub,ip) < (betamin)
                                allCombs(sub,ip) = rand * betamax;
                            end
                        else
                            error('Define param as one of above cases');
                        end
                    end
                end
                noise = 0;
            end
            
            % Transform parameters
            % -------------------------------------------- %
            
            allCombsNorm = NaN(size(allCombs,1),size(allCombs,2));
            for ip=1:length(params)
                thisp=params{ip};
                if contains(thisp, 'k') == 1
                    allCombsNorm(:,ip)=allCombs(:,ip);
                elseif contains(thisp, 'beta') == 1
                    allCombsNorm(:,ip)=allCombs(:,ip);
                else
                    error(['Can`t detect whether parameter ', thisp, ' is k or beta']);
                end
            end
            
            % Plot the distribution of parameters we are using to simulate behaviour
            % -------------------------------------------- %
            
            if r == 1 % plot for the first round only to avoid lots of figures
                figure('color','w');
                for param=1:nParam
                    subplot(1,nParam,param);
                    thisp=params{param};
                    if contains(thisp, 'k') == 1
                        histogram(allCombsNorm(:,param)+noise*randn(length(allCombsNorm),1),'FaceColor',[0.5 0.5 0.5]);
                    elseif contains(thisp, 'beta') == 1
                        histogram(allCombsNorm(:,param)+noise*randn(length(allCombsNorm),1),'FaceColor',[0.5 0.5 0.5]);
                    end
                    hold on;box off;title(params{param});
                end
            else
            end
            
            % Simulate all combinations of parameters
            % -------------------------------------------- %
            for simS=1:nSubj
                
                Data(simS).ID        = sprintf('Subj %i',simS);
                Data(simS).data      = zeros(nTrls,1); % save choices
                Data(simS).agent     = data.agent(:,1);
                Data(simS).effort    = data.effort(:,1);
                Data(simS).reward    = data.reward(:,1); %already in 1/0, outcomes
                Data(simS).trueModel = modelID;
                
                for param=1:nParam % Add some noise to grid parameters
                    thisp=params{param};
                    if contains(thisp, 'k') == 1
                        pmin = min(bounds.k);
                        pmax = abs(max(bounds.k));
                    elseif contains(thisp, 'beta') == 1
                        pmin = min(bounds.beta);
                        pmax = max(bounds.beta);
                    end
                    truep(param) = allCombsNorm(simS,param) + noise*randn(1);
                    while truep(param) < pmin || truep(param) > pmax
                        truep(param) = allCombsNorm(simS,param) + noise*randn(1);
                    end
                end
                
                Data(simS).trueParam = truep;
                
                simfunc = str2func('all_simulate');
                
                %try
                [f,allout] = simfunc(Data(simS).effort, Data(simS).reward, Data(simS).agent, Data(simS).trueParam, modelID, bounds, bounds); %%%% VARIABLES TO FEED INTO THE MODEL IN ORDER TO SIMULATE CHOICES
                %catch
                %    disp('Error in call to simulate - possibly argument "allout" (and maybe others) not assigned')
                %end
                
                Data(simS).data = allout.choice';
                s.PM.beh{1,simS}.choice = allout.choice';
                s.PM.beh{1,simS}.agent = allout.agent';
                s.PM.beh{1,simS}.effort = allout.effort';
                s.PM.beh{1,simS}.reward = allout.reward';
                s.PM.ID{1,simS}.ID = simS;
                
                if tr == 1
                    
                    disp(['Combination ',num2str(simS) ' of ',num2str(nSubj)]);
                    
                    if mle_em == 1 % if using maximum likelihood for PR, also fit for each subject as simulate
                        
                        % start from multiple (number defined by nrep at top) random configurations in case of local maxima - arbitrary
                        fvalPre = 10000;
                        iter = 1;
                        maxit = 1000; % if not fitted after this many iterations then stop **
                        fitted = 0;
                        while iter < nrep || fitted ~= 1 % if not fitted within 10 iterations keep going
                            for param=1:nParam
                                thisp=params{param};
                                if contains(thisp, 'k') == 1
                                    pmin = kmin;
                                    pmax = abs(kmax);
                                elseif contains(thisp, 'beta') == 1
                                    pmin = betamin;
                                    pmax = betamax;
                                end
                                p(param) =pmax*rand(1)*0.5;
                                while p(param) < pmin || p(param) > pmax
                                    p(param) =pmax*rand(1)*0.5;
                                end
                            end
                            
                            if contains(modelID, 'one_k')
                                lbk = bounds.k(1);
                                ubk = bounds.k(2);
                            elseif contains(modelID, 'two_k')
                                lbk = [bounds.k(1), bounds.k(1)];
                                ubk = [bounds.k(2), bounds.k(2)];
                            else
                                error(['Cant`t determine number of k parameters from model name: ', modelID])
                            end
                            
                            if contains(modelID, 'one_beta')
                                lbbeta = bounds.beta(1);
                                ubbeta = bounds.beta(2);
                            elseif contains(modelID, 'two_beta')
                                lbbeta = [bounds.beta(1), bounds.beta(1)];
                                ubbeta = [bounds.beta(2), bounds.beta(2)];
                            else
                                error(['Cant`t determine number of beta parameters from model name: ', modelID])
                            end
                            
                            lb = [lbk, lbbeta];   %lower bounds on parameters
                            ub = [ubk, ubbeta];
                            fit.objfunc = str2func('all_real');
                            
                            max_evals       = 1000000;
                            options         = optimset('MaxIter', max_evals,'MaxFunEvals', max_evals*100, 'Display', 'off');
                            
                            outtype = 1;
                            [p,fval,ex] = fmincon(@all_real, p,[],[],[],[],lb,ub,[], options, allout.choice, allout.effort, allout.reward, allout.agent, modelID, outtype);
                            
                            if fval<fvalPre && all(p<100) % for smallest fval and ensuring parameters in reasonable range
                                
                                if ~any(p>10)
                                    Data(simS).fittedParam = p;
                                    fitted = 1;
                                else
                                end
                                fvalPre = fval;
                            end
                            iter = iter + 1;
                            if iter > maxit
                                fitted = 1;
                            end
                        end
                    else
                    end
                else
                end
            end
            
            if tr == 1 && mle_em == 2 % if using em for PR, fit all subjects
                
                [s, p] = em_PR(s, models(modelsTR), params, bounds);
                for simS=1:nSubj
                    Data(simS).fittedParam = p(simS,:);
                end
                
            end
            
            if tr == 1 % for PR create plots then confusion matrix & save
                
                % Plot recovery of params
                % -------------------------------------------- %
                trueParam = []; fittedParam = []; missParam = [];
                for simS=1:nSubj
                    trueParam = [trueParam;Data(simS).trueParam];
                    fittedParam = [fittedParam;Data(simS).fittedParam];
                    if isempty(Data(simS).fittedParam)
                        %disp('empty');
                        missParam = [missParam;Data(simS).trueParam'];
                        trueParam(end,:)=[];
                    end
                end
                
                fitSubj = size(trueParam,1);
                
                figure('color','w');
                for param=1:nParam % plot correlations
                    subplot(1,nParam,param);
                    thisp=params{param};
                    if contains(thisp, 'k') == 1
                        trueKsBetas(1:fitSubj,param) = trueParam(:,param);
                        if mle_em == 1
                            fittedKsBetas(1:fitSubj,param) = fittedParam(:,param);
                        else
                            fittedKsBetas(1:fitSubj,param) = norm2positive(fittedParam(:,param), bounds.k);
                        end
                        plot(trueKsBetas(:,param),fittedKsBetas(:,param),'k.','MarkerSize',12);
                        all_corr(param,:) = corr(trueKsBetas(:,param),fittedKsBetas(:,param));
                        xlim(bounds.k);ylim(bounds.k);
                    elseif contains(thisp, 'beta') == 1
                        trueKsBetas(1:fitSubj,param) = trueParam(:,param);
                        if mle_em == 1
                            fittedKsBetas(1:fitSubj,param) = fittedParam(:,param);
                        else
                            fittedKsBetas(1:fitSubj,param) = norm2positive(fittedParam(:,param), bounds.beta);
                        end
                        plot(trueKsBetas(:,param),fittedKsBetas(:,param),'k.','MarkerSize',12);
                        all_corr(param,:) = corr(trueKsBetas(:,param),fittedKsBetas(:,param));
                    end
                    hold on;box off;title(params{param});xlabel('true param');ylabel('fitted param');
                end
                
                figure;
                for param=1:nParam % plot individal parameters
                    thisp=params{param};
                    thisp = strrep(thisp, '_', ' ');
                    if contains(thisp, 'k') == 1
                        subplot(nParam,2,(param*2-1))
                        plot(trueKsBetas(:,param))
                        title(['true ', thisp])
                        subplot(nParam,2,param*2)
                        plot(fittedKsBetas(:,param))
                        title(['fitted ', thisp])
                    elseif contains(thisp, 'beta') == 1
                        subplot(nParam,2,(param*2-1))
                        plot(trueKsBetas(:,param))
                        title(['true ', thisp])
                        subplot(nParam,2,param*2)
                        plot(fittedKsBetas(:,param))
                        title(['fitted ', thisp])
                    end
                end
                
                % Generate confusion matrix of all parameters correlated with eachother
                % -------------------------------------------- %
                
                row = 1;
                for param=1:nParam
                    for param2=1:nParam
                        confusion(row,1) = param;
                        confusion(row,2) = param2;
                        confusion(row,3) = corr(trueKsBetas(:,param), fittedKsBetas(:,param2));
                        row = row  + 1;
                    end
                end
                
                msg = ['Finished parameter recovery for ', modelID, ', calculated ', num2str(nParam), ' parameters.', newline, 'Correlations between true and fitted parameters are: ', newline, char(params{1}), ': ', num2str(all_corr(1))];
                for n = 2:nParam
                    msg = [msg, newline, char(params{n}), ': ', num2str(all_corr(n))];
                end
                
                if mle_em == 1
                    conftab = cell2table(num2cell(confusion), 'VariableNames', {'Simulated', 'Recovered', 'MLCorr'});
                    writetable(conftab,['../PM_R_code/data/Parameter_recovery_mle.csv'],'WriteVariableNames',true)
                elseif mle_em == 2
                    conftab = cell2table(num2cell(confusion), 'VariableNames', {'Simulated', 'Recovered', 'HCorr'});
                    writetable(conftab,['../PM_R_code/data/Parameter_recovery_em.csv'],'WriteVariableNames',true)
                end
                
                
            elseif tr == 2
                
                maxK = maxValue(data, 'k', 'all'); % maximum k calculated as
                bounds.k = [0, maxK]; % enter bounds on k values here **
                kmin = min(bounds.k);
                kmax = max(bounds.k);
                
                if mle_em == 1
                    
                    msg = ['Finished mle model identifiability for ', modelID, ', round ', num2str(r),' of ', num2str(nRounds)];
                    
                    [s, fits, fitMeasures] = mle_MI(s, models(modelsTR), 'bic', kbounds, betabounds, nrep);
                    all_s{r,m} = s;
                    all_fits{r,m} = fits;
                    MIname = ['../PM_R_code/data/Model_identifiability_mle.csv'];
                    
                elseif  mle_em ~= 1
                    
                    msg = ['Finished em model identifiability for ', modelID, ', round ', num2str(r),' of ', num2str(nRounds)];
                    
                    [s, fits, fitMeasures] = em_MI(s, models(modelsTR), 'xp', bounds);
                    all_s{r,m} = s;
                    all_fits{r,m} = fits;
                    MIname = ['../PM_R_code/data/Model_identifiability_em.csv'];
                    
                end
                
            end
            
            disp(msg)
            
        end
        
    end
    
    if tr == 2
        
        wincol = find(contains(fitMeasures, 'wins'));
        
        for mod = modelsTR
            
            endrow = length(modelsTR) * mod;
            startrow = endrow - length(modelsTR) + 1;
            
            MItosave(startrow:endrow,1) = mod;
            MItosave(startrow:endrow,2) = modelsTR;
            
            for r = 1:nRounds
                winner = all_fits{r,mod}(:,wincol);
                [~, wins(r,mod)] = max(winner);
                
                if r > 2
                    fitsLong = cat(3,fitsLong,all_fits{r,mod});
                elseif r > 1
                    fitsLong = cat(3,all_fits{1,mod}, all_fits{2,mod});
                else
                end
                
            end
            
            av_fits = mean(fitsLong,3);
            MItosave(startrow:endrow,3:(3+length(fitMeasures)-1)) = mean(fitsLong,3);
            
            for mi = modelsTR
                MItosave((startrow + mi - 1),(3+length(fitMeasures))) = sum(wins(:,mod)==mi);
            end
            
        end
        
        MItab = cell2table(num2cell(MItosave), 'VariableNames', ['Simulated', 'Estimated', fitMeasures, 'best']);
        writetable(MItab,MIname,'WriteVariableNames',true)
        
    end
    
    if type == 1
        name = ['workspaces/',toRunOptions{tr},'_',mleOptions{mle_em},'_k_',num2str(grid.k(1)),'_',num2str(grid.k(end)),'_b_',num2str(grid.beta(1)),'_',num2str(grid.beta(end)),'_n_',num2str(noise),'_',num2str(nSubj),'_subs.mat'];
    elseif type == 2
        name = ['workspaces/',toRunOptions{tr},'_',mleOptions{mle_em},'_',num2str(nSubj),'_subjects_',num2str(nRounds),'_rounds_from_distrib'];
    end
    save(name)
    
end