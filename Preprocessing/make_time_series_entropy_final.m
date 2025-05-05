folder_pairs = {...
    {'\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing2\eeg_cleaned_q1', ...
     '\\......\Tong_computer\Dissertation Study 2\EEG data\entropy\q1'}, ...
    {'\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing2\eeg_cleaned_q2', ...
     '\\......\Tong_computer\Dissertation Study 2\EEG data\entropy\q2'}, ...
    {'\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing2\eeg_cleaned_q3', ...
     '\\......\Tong_computer\Dissertation Study 2\EEG data\entropy\q3'}, ...
    {'\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing2\eeg_cleaned_q4', ...
     '\\......\Tong_computer\Dissertation Study 2\EEG data\entropy\q4'} ...
};

% Define frequency bands
freq_bands = struct(...
    'delta', [1 4], ...
    'theta', [4 8], ...
    'alpha', [8 13], ...
    'beta', [13 30], ...
    'gamma', [30 50] ...
);

% Define parameters for non-overlapping 1-second entropy computation
window_size = 1; % Window size in seconds

% Loop through each folder pair
for pair_idx = 1:length(folder_pairs)
    input_folder = folder_pairs{pair_idx}{1};
    output_folder = folder_pairs{pair_idx}{2};
    
    % Get list of all .set files in the input folder
    file_list = dir(fullfile(input_folder, '*.set'));
    
    % Process each .set file in the folder
    for i = 1:length(file_list)
        input_file = file_list(i).name;
        [~, name, ~] = fileparts(input_file);
        fprintf('Processing file: %s\n', input_file);
        
        % Load EEG data
        EEG = pop_loadset('filename', input_file, 'filepath', input_folder);
        eeg_data = EEG.data;
        fs = EEG.srate;
        num_channels = size(eeg_data, 1);
        num_samples = size(eeg_data, 2);
        
        % Compute number of 1-second time windows
        samples_per_window = window_size * fs;
        num_windows = floor(num_samples / samples_per_window);
        time_points = (0:num_windows-1); % Time in seconds
        
        % Initialize entropy storage
        entropy_data = struct();
        for band_name = fieldnames(freq_bands)'
            entropy_data.(band_name{1}) = zeros(num_channels, num_windows);
        end
        
        % Loop through each channel
        for ch = 1:num_channels
            signal = eeg_data(ch, :);
            
            % Loop through each 1-second window
            for w = 1:num_windows
                start_idx = (w - 1) * samples_per_window + 1;
                end_idx = start_idx + samples_per_window - 1;
                
                % Extract 1-second segment
                segment = signal(start_idx:end_idx);
                
                % Compute entropy for each frequency band
                for band_name = fieldnames(freq_bands)'
                    band = freq_bands.(band_name{1});
                    [pxx, f] = pwelch(segment, [], [], [], fs);
                    freq_indices = (f >= band(1) & f <= band(2));
                    prob_density = pxx(freq_indices) / sum(pxx(freq_indices));
                    entropy_data.(band_name{1})(ch, w) = -sum(prob_density .* log2(prob_density + eps));
                end
            end
        end
        
        % Prepare data for export
        headers = {'Time (s)'};
        for ch = 1:num_channels
            for band_name = fieldnames(freq_bands)'
                headers{end+1} = sprintf('Channel %d - %s Entropy', ch, band_name{1});
            end
        end
        
        % Create cell array for writing to file
        entropy_output = cell(num_windows + 1, length(headers));
        entropy_output(1, :) = headers;
        entropy_output(2:end, 1) = num2cell(time_points');
        
        col_idx = 2;
        for ch = 1:num_channels
            for band_name = fieldnames(freq_bands)'
                entropy_output(2:end, col_idx) = num2cell(entropy_data.(band_name{1})(ch, :)');
                col_idx = col_idx + 1;
            end
        end
        
        % Save to Excel file for the participant
        output_file = fullfile(output_folder, [name '_entropy.xlsx']);
        writecell(entropy_output, output_file);
        fprintf('Processed and saved: %s in %s\n', name, output_folder);
    end
end
