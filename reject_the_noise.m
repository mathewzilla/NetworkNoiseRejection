function [Data,Rejection] = reject_the_noise(A,pars,optionsModel,optionsReject)

% REJECT_THE_NOISE batch version of noise rejection script
% [DATA,REJECTION] = REJECT_THE_NOISE(A,PARS)
%
% Mark Humphries & Mat Evans

% Prepare A for Noise Rejection
[Data.A,Data.ixRetain,Data.Comps,Data.CompSizes] = prep_A(A);

% get expected distribution of eigenvalues under null model (here, WCM)
switch pars.Model
    case 'Poiss'
        [Data.Emodel,diagnostics,Vmodel,Data.ExpA] = RndPoissonConfigModel(Data.A,pars.N,pars.C,optionsModel);
    case 'WCM'
        [Data.Emodel,diagnostics,Vmodel,Data.ExpA] = WeightedConfigModel(Data.A,pars.N,pars.C,optionsModel);
    otherwise
        error('Unrecognised null model specified')
end

B = Data.A - Data.ExpA;  % modularity matrix using chosen null model

% find low-dimensional projection
[Data.Dspace,~,Data.Dn,Data.EigEst] = LowDSpace(B,Data.Emodel,pars.alpha); % to just obtain low-dimensional projection; Data.Dn = number of retained eigenvectors

% node rejection within low-dimensional projection
Rejection = NodeRejection(B,Data.Emodel,pars.alpha,Vmodel,optionsReject); % N.B. also calls LowDSpace function to find projections

% keyboard

% new signal matrix
Data.Asignal = Data.A(Rejection.ixSignal,Rejection.ixSignal);

% connected signal matrix: find largest component, and use that - store
% others
[Data.Asignal_comp,ixRetain,Data.SignalComps,Data.SignalComp_sizes] = prep_A(Data.Asignal); 
Data.ixSignal_comp = Rejection.ixSignal(ixRetain);  % original node indices

% and then strip out leaves - nodes with single links
K = sum(Data.Asignal_comp);
ixLeaves = find(K==1); ixKeep = find(K > 1);

Data.ixSignal_Final = Data.ixSignal_comp(ixKeep);
Data.ixSignal_Leaves = Data.ixSignal_comp(ixLeaves);
Data.Asignal_final = Data.Asignal_comp(ixKeep,ixKeep);

