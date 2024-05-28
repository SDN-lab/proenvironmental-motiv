function [ npar ] = get_npar( modelID)
% Lookup table to get number of free parameters per model
% JC 2022 (from MKW 2018)

%%%%%
if       contains(modelID,'two_k'),               nk = 2;
elseif   contains(modelID,'one_k'),               nk = 1;
else                                              nk = 0;
end

if   contains(modelID,'one_beta'),                nb = 1;
elseif   contains(modelID,'two_beta'),            nb = 2;
end

npar = nk + nb;

end

