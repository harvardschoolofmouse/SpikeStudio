if exist('intan_or_muxi')==0
intan_or_muxi='Intan';
headstage_source='Intan'; 
disp(['***Using the Intan 128 ch amplifier board***'])
end

if strcmpi(intan_or_muxi, 'muxi')
headstage_source='UCLA';  %options: 'UCLA' or 'Intan'.  Value must be entered as a string.
elseif strcmpi(intan_or_muxi, 'intan')
headstage_source='Intan';  
end
   

headstage_source = 'Intan';