function [ npar ] = get_npar( modelID)
% Lookup table to get number of free parameters per model
% MKW 2018


%%%%%
%Parabolic models
if       strcmp(modelID,'two_k_two_beta'),               npar = 4;
elseif   strcmp(modelID,'one_k_one_beta'),               npar = 2;
elseif   strcmp(modelID,'two_k_one_beta'),               npar = 3;
elseif   strcmp(modelID,'one_k_two_beta'),               npar = 3;
    
%linear models
elseif   strcmp(modelID,'two_k_two_beta_linear'),        npar = 4;
elseif   strcmp(modelID,'one_k_one_beta_linear'),        npar = 2;
elseif   strcmp(modelID,'two_k_one_beta_linear'),        npar = 3;
elseif   strcmp(modelID,'one_k_two_beta_linear'),        npar = 3;
    
%hyperbolic models        
elseif   strcmp(modelID,'two_k_two_beta_hyperbolic'),    npar = 4;
elseif   strcmp(modelID,'one_k_one_beta_hyperbolic'),    npar = 2;
elseif   strcmp(modelID,'two_k_one_beta_hyperbolic'),    npar = 3;
elseif   strcmp(modelID,'one_k_two_beta_hyperbolic'),    npar = 3;
    
    
end

end

