% Input and output folders for study 2
inputFolder  = '\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing1';
outputFolder = '\\......\Tong_computer\Dissertation Study 2\EEG data\ttl_from_set\';

% Look for .set files in the input folder
files = dir(fullfile(inputFolder, '*.set'));

% Loop over each .set file found
for i = 1:length(files)
    % Construct full path to the .set file
    file_name = fullfile(inputFolder, files(i).name);
   
    EEG = pop_loadset('filename', files(i).name, 'filepath', inputFolder);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

    EEG = eeg_checkset(EEG);
    if startsWith(files(i).name, 'Psychopy_')
        % Remove 'Psychopy_' (9 characters) and extract two digits
        prefixLength = length('Psychopy_'); % = 9
        participantID = files(i).name(prefixLength+1 : prefixLength+2);
        txtOutputName = [participantID, '_OriginalEventMarker.txt'];
    else
        % Original logic: remove last 4 chars (".ext") and add suffix
        txtOutputName = [files(i).name(1:end-4), '_OriginalEventMarker.txt'];
    end
    
    pop_expevents(EEG, fullfile(outputFolder, txtOutputName), 'samples');

end