function [modelresults] = fit_PM_model(data, modelID, bounds, iteration)

% INPUT:     - data
%           - sample
%           - modelID: string identifying which model to run
% OUPUT:    - modelresults: fitted model including parameter values, fval, etc.

% some optional settings for fminsearch
max_evals       = 1000000;
options         = optimset('MaxIter', max_evals,'MaxFunEvals', max_evals*100, 'Display', 'off');

modelresults={};

%% Loop through subjects.
for j = 1:length(data.PM.ID) % j indexs which subject it is, and each subjects data is stored in cell in the structure
    clear chosen
    clear effort
    clear reward
    clear agent
    
    %%% 0.) Load information for that subject:    % load in each subjects variables for the experiment
    chosen = data.PM.beh{1, j}.choice; %matrix of choices on each trial
    effort = data.PM.beh{1, j}.effort; %matrix of efforst levels for each trial
    reward = data.PM.beh{1, j}.reward; %matrix of reward levels for each trial
    agent  = data.PM.beh{1, j}.agent; %matrix of condition (self or other) for each trial
    
    
    for i=1:length(chosen)
        
        if chosen(i)==2 %% if its a missed trial chosen = 2 so remove thes trials
            
            chosen(i)=NaN;
            reward(i)=NaN;
            effort(i)=NaN;
            agent(i)=NaN;
            
        else
            
            chosen(i)=chosen(i);
            reward(i) =reward(i);
            effort(i) =effort(i);
            agent(i)  =agent(i);
            
        end
        
    end
    
    chosen = chosen(~isnan(chosen));
    reward = reward(~isnan(reward));
    effort = effort(~isnan(effort));
    agent  = agent(~isnan(agent));
    
    %%%constrain parameters:
    
    if contains(modelID, 'one_k')
        lbk = bounds.k(1);
        ubk = bounds.k(2);
    elseif contains(modelID, 'two_k')
        lbk = [bounds.k(1), bounds.k(1)];
        ubk = [bounds.k(2), bounds.k(2)];
    elseif ~contains(modelID, 'k')
        lbk = [];
        ubk = [];
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
        error(['Can`t determine number of beta parameters from model name: ', modelID])
    end
    
    lb = [lbk, lbbeta];   %lower bounds on parameters
    ub = [ubk, ubbeta];   %upper bounds on parameters
    
    objfunc = str2func(modelID);
    
    %%% I.) First fit the model:
    outtype=1;
    out.xnames = get_params(['ms_', modelID]);
    Parameter=repmat(0.1,1,length(out.xnames));  % starting values for each parameter
    [out.x, out.fval, exitflag] = fmincon(@all_real, Parameter,[],[],[],[],lb,ub,[], options, chosen, effort, reward, agent, modelID, outtype);
    out.modelID=modelID;
    
    %%% II.) Get modeled schedule:
    outtype=2;
    Parameter=out.x;
    modelout = out;
    modelout=all_real(Parameter, chosen, effort, reward, agent, modelID, outtype);
    
    %%% III.) Now save:
    
    if  iteration == 1
        modelresults{j}=out;
        modelresults{j}.info=modelout;
    else
        if out.fval < data.PM.ml.(modelID){j}.fval
            out.xnames = data.PM.ml.(modelID){j}.xnames;
            modelresults{j}=out;
            modelresults{j}.info=modelout;
            
            % just for information:
            fvaldiff = data.PM.ml.(modelID){j}.fval - out.fval;
            %             if fvaldiff > 0.1
            disp([modelID ' : better model found :-) Fval difference: '  num2str(fvaldiff)]);
            %             end
        else
            modelresults{j}=data.PM.ml.(modelID){j};
%             disp([modelID ' : no change'])
        end
    end
end
