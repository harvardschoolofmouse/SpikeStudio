% Instructions: Open the main header file (NOT ALL0), make it = data. The
% program prints the additional exclusions.
% 

% I think it's okay to treat 300 same as 500 - we will just delete all of these trials where mouse licked within 500ms of the cue.
clear all
uiopen('*.mat')
AAAA = who;
eval(['data = ' AAAA{1} ';']);


[lick_data_struct.f_ex_licks_with_rxn, lick_data_struct.f_ex_licks_no_rxn] = rxn_lick_or_no_rxn_lick_fx(data.lick_data_struct.all_ex_first_licks, data.lick_data_struct.f_ex_lick_rxn);

EXCL = find(lick_data_struct.f_ex_licks_with_rxn)'

if isfield(data.lick_data_struct, 'f_lick_pavlovian')
    pav = find(data.lick_data_struct.f_lick_pavlovian)';
end