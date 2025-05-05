% Define the input-output folder pairs
folder_pairs = {... 
    {'\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing2\eeg_cleaned_q1', ...
     '\\......\Tong_computer\Dissertation Study 2\EEG data\power_time_series\q1'}, ...
    {'\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing2\eeg_cleaned_q2', ...
     '\\......\Tong_computer\Dissertation Study 2\EEG data\power_time_series\q2'}, ...
    {'\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing2\eeg_cleaned_q3', ...
     '\\......\Tong_computer\Dissertation Study 2\EEG data\power_time_series\q3'}, ...
    {'\\......\Tong_computer\Dissertation Study 2\EEG data\preprocessing2\eeg_cleaned_q4', ...
     '\\......\Tong_computer\Dissertation Study 2\EEG data\power_time_series\q4'} ...
};

% Define frequency bands (in Hz)
freq_bands = struct( ...
    'delta', [1 4], ...
    'theta', [4 8], ...
    'alpha', [8 13], ...
    'beta', [13 30], ...
    'gamma', [30 50] ...
);

% Parameters for time windows (non-overlapping, 1-second intervals)
window_size = 1; % 1 second window

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
        fprintf('Loading EEG data...\n');
        EEG = pop_loadset('filename', input_file, 'filepath', input_folder);
        eeg_data = EEG.data;
        fs = EEG.srate;

        num_channels = size(eeg_data, 1);
        num_samples = size(eeg_data, 2);
        fprintf('Loaded EEG data: %d channels, %d samples\n', num_channels, num_samples);

        % Compute number of 1-second time windows
        samples_per_window = window_size * fs;
        num_windows = floor(num_samples / samples_per_window);
        fprintf('Processing %d time windows...\n', num_windows);

        % Generate time vector
        time_points = (0:num_windows-1); % Time in seconds (1 value per second)

        % Initialize power storage
        power_data = struct();
        for band_name = fieldnames(freq_bands)'
            power_data.(band_name{1}) = zeros(num_channels, num_windows);
        end

        % Time tracking
        tic;

        % Loop through each channel
        for ch = 1:num_channels
            signal = eeg_data(ch, :);
            fprintf('Processing Channel %d...\n', ch);

            % Loop through each 1-second window
            for w = 1:num_windows
                start_idx = (w - 1) * samples_per_window + 1;
                end_idx = start_idx + samples_per_window - 1;

                % Extract segment
                segment = signal(start_idx:end_idx);

                % Compute power for each frequency band
                for band_name = fieldnames(freq_bands)'
                    band = freq_bands.(band_name{1});

                    % Apply bandpass filter
                    filtered_signal = bandpass(segment, band, fs);

                    % Compute PSD using pwelch
                    [pxx, f] = pwelch(filtered_signal, [], [], [], fs);

                    % Compute band power
                    band_power = bandpower(pxx, f, band, 'psd');
                    power_data.(band_name{1})(ch, w) = band_power;
                end
            end
        end

        elapsed_time = toc;
        fprintf('Finished processing %s in %.2f seconds\n', input_file, elapsed_time);

        % Prepare data for export to Excel
        headers = {'Time (s)', 'Delta Power', 'Theta Power', 'Alpha Power', 'Beta Power', 'Gamma Power'};
        excel_data = cell(num_windows + 1, 6 * num_channels); % Each channel gets 6 columns (time, 5 power bands)

        % Fill in the header
        for ch = 1:num_channels
            col_idx = (ch - 1) * 6 + 1;
            for j = 1:length(headers)
                excel_data{1, col_idx + j - 1} = sprintf('Channel %d - %s', ch, headers{j});
            end
        end

        % Fill in the time points and power data for each time window
        for win_idx = 1:num_windows
            for ch = 1:num_channels
                col_idx = (ch - 1) * 6 + 1;
                excel_data{win_idx + 1, col_idx} = time_points(win_idx); % Time
                excel_data{win_idx + 1, col_idx + 1} = power_data.delta(ch, win_idx);
                excel_data{win_idx + 1, col_idx + 2} = power_data.theta(ch, win_idx);
                excel_data{win_idx + 1, col_idx + 3} = power_data.alpha(ch, win_idx);
                excel_data{win_idx + 1, col_idx + 4} = power_data.beta(ch, win_idx);
                excel_data{win_idx + 1, col_idx + 5} = power_data.gamma(ch, win_idx);
            end
        end

        % Save to Excel file for the participant
        output_file = fullfile(output_folder, [name '_power_time_series.xlsx']);
        writecell(excel_data, output_file);

        fprintf('Processed and saved: %s in %s\n', name, output_folder);
    end
end
