% Define the directory where the .edf files are located
data_dir = '\\......\Tong_computer\Dissertation Study 2\Raw Data\Emotiv Data\';

% Get the list of all .edf files in the directory
file_list = dir(fullfile(data_dir, '*.edf'));

% Check if there are any .edf files found
if isempty(file_list)
    disp('No .edf files found in the specified directory.');
    return;
else
    disp([num2str(length(file_list)) ' .edf files found.']);
end

% Loop through each file
for i = 1:length(file_list)
    % Get the full file name and path
    original_file_name = file_list(i).name;
    original_file_path = fullfile(data_dir, original_file_name);
    
    % Extract the 10th and 11th characters from the file name
    try
        new_file_name = [original_file_name(10:11), '.edf'];
        new_file_path = fullfile(data_dir, new_file_name);
        
        % Rename the file
        disp(['Renaming file: ' original_file_name ' to ' new_file_name]);
        movefile(original_file_path, new_file_path);
        disp('File renamed successfully.');
        
    catch ME
        disp(['Error renaming file: ' original_file_name]);
        disp(ME.message);
    end
end

disp('Renaming process completed.');
