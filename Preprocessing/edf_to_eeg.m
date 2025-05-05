% Change directory and verify it
cd('\\......\Tong_computer\Dissertation Study 2\');

% Define the data and save directories
data_dir = '\\......\Tong_computer\Dissertation Study 2\Raw Data\Emotiv Data\edf_plus';
save_dir ='\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing1'

% List all .edf files in the data directory
disp(['Looking for .edf files in: ' data_dir]);
file_list = dir(fullfile(data_dir, '*.edf'));

% Print the number of files found
disp(['Found ' num2str(length(file_list)) ' .edf files.']);
if isempty(file_list)
    disp('No files found. Exiting script.');
    return;
end

% Display the list of files
disp('Files found:');
for f = 1:length(file_list)
    disp(file_list(f).name);
end

% Start EEGLAB
disp('Starting EEGLAB...');
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
disp('EEGLAB started.');

% Loop through each .edf file
for i = 1:length(file_list)
    try
        disp(['Processing file ' num2str(i) ' of ' num2str(length(file_list)) '...']);
        
        % Get the full file name and path
        file_name = file_list(i).name;
        file_path = fullfile(data_dir, file_name);
        disp(['Loading .edf file: ' file_name]);
        disp(['File path: ' file_path]);
        
        % Load the .edf file using pop_biosig
        EEG = pop_biosig(file_path);
        disp('File loaded successfully.');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', file_name, 'gui', 'off'); 
        
        % Select only the specified EEG channels
        disp('Selecting EEG channels...');
        EEG = pop_select(EEG, 'channel', {'AF3', 'F7', 'F3', 'FC5', 'T7', 'P7', 'O1', 'O2', 'P8', 'T8', 'FC6', 'F4', 'F8', 'AF4'});
        disp('Channel selection successful.');
        
        % Remove the baseline
        disp('Removing baseline...');
        EEG = pop_rmbase(EEG, [], []);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'overwrite', 'on', 'gui', 'off');
        EEG = eeg_checkset(EEG);
        disp('Baseline removed successfully.');
        
        % Load the channel locations using chanedit
        disp('Loading channel locations...');
        EEG = pop_chanedit(EEG, 'lookup', '\\......\Tong_computer\Dissertation Study 2\emotiv.ced');
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = eeg_checkset(EEG);
        disp('Channel locations loaded successfully.');
        
        % Edit the channels (optional step)
        disp('Editing channels...');
        EEG = pop_chanedit(EEG, 'lookup', '\\......\Tong_computer\Dissertation Study 2\emotiv.ced', 'rplurchanloc', 1);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = eeg_checkset(EEG);
        disp('Channel editing successful.');
        
        % Re-reference the data
        disp('Re-referencing data...');
        EEG = pop_reref(EEG, []);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'overwrite', 'on', 'gui', 'off');
        disp('Re-referencing completed successfully.');
        
        % Extract subject ID from file_name
        tokens = regexp(file_name, 'Psychopy_(\d+)_', 'tokens');
        if ~isempty(tokens)
            subject_id = tokens{1}{1}; % Extract subject ID (e.g., "01")
            file_name_set = [subject_id, '.set']; % Construct new file name
        else
            error(['Subject ID not found in filename: ' file_name]);
        end
        
        disp(['Saving file as: ', file_name_set]);
        
        % Save the .set file
        EEG = pop_saveset(EEG, 'filename', file_name_set, 'filepath', save_dir);
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

        
       
    end
end

disp('Processing complete.');
