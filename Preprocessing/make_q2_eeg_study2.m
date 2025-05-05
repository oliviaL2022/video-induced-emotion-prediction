%importing new ttls to eeg
% Define folder paths
eeg_folder = '\\\......\\Tong_computer\\Dissertation Study 2\\EEG data\\preprocessing1\\5 - processed';
ttl_folder = '\\\......\\Tong_computer\\Dissertation Study 2\\EEG data\\ttl_from_set\\new_ttl\\emotion_ttl';
new_folder = '\\\......\\Tong_computer\\Dissertation Study 2\\EEG data\\preprocessing2\\eeg_cleaned_q2';

% Get list of all .set files in the EEG folder
files = dir(fullfile(eeg_folder, '*.set'));

% Loop through each .set file
for i = 1:length(files)
    % File paths for the current EEG file and its corresponding TTL file
    eeg_file = fullfile(eeg_folder, files(i).name);
    ttl_file = fullfile(ttl_folder, strrep(files(i).name, '_processed.set', '_modified_events_q2.txt'));
    
    % Load the EEG dataset
    EEG = pop_loadset('filename', {files(i).name}, 'filepath', eeg_folder);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    EEG = eeg_checkset(EEG);
    
    % Import event markers from the corresponding TTL file
    EEG = pop_importevent( EEG, 'append','no','event',ttl_file,'fields',{'number','type','edftype','latency','duration','urevent'},'skipline',1,'timeunit',NaN,'optimalign','off');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );
    
    % Create a new file name with "_q1ttl" appended
    base_name = strrep(files(i).name, '.set', ''); % Remove '.set' from original name
    new_file_name = strcat(base_name, '_q2ttl'); % Append '_q1ttl'
    
    % Save the updated EEG dataset to the new folder
    EEG = pop_saveset(EEG, 'filename', new_file_name, 'filepath', new_folder);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end
