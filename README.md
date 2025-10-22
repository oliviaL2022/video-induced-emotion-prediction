# video-induced-emotion-prediction
# Video induced emotion and empathy study
## A. Facial-Expression & Behavioral Ratings

### 1. Run Noldus FaceReader on all videos

Software: FaceReader

Export per-frame expression metrics (valence + basic emotions).

### 2. Fix / annotate video timestamps

Notebook: add_times_to_Video.ipynb

Goal: add correct timestamps to FaceReader output (align with PsychoPy timing).

### 3. Combine FaceReader output + behavioral ratings from PsychoPy

Notebook: Combine_files.ipynb

Purpose: create per-trial/per-video tables with time-aligned expressions and ratings.

## B. EEG: From Raw EDF to Cleaned, TTL-Aligned Sets

### 1. Rename raw EDFs to participant IDs

Script: rename_original_edf.m

Result: files renamed with participant number only.

### 2. Convert EDF → EEGLAB .set

Script: edf_to_eeg.m

Output: .set files saved to preprocessing folder.

### 3. Clean data with HAPPE v4

Download HAPPE: Plasticity in Neurodevelopment Lab – HAPPE

Run HAPPE on .set files to remove artifacts.

### 4. Extract original event markers (empathy vs neutral video)

Script: get_original_event_marker.m

### 5. Create new event markers based on user responses

Notebook: Make_4qs_ttls.ipynb

Explanation of variables:

Q1_slider.response: How does the person/people feel? (emotion perception)

Q2_slider.response: How do you feel? (self-emotion)

Q3_slider.response: How much empathy do you feel for the person/people? (empathy)

Q4: original video type (empathy vs neutral)

### 6. Apply new event markers to EEG data

Scripts:

make_q1_eeg_study2.m

make_q2_eeg_study2.m

make_q3_eeg_study2.m

make_q4_eeg_study2.m

Result: cleaned, TTL-adjusted .set files per question.

### 7. Baseline correction

Notebook: Study2_baseline_correction.ipynb

## C. EEG Feature Extraction

### 1. Band-power time series

Script: make_power_time_series.m

### 2. Entropy time series

Script: make_time_series_entropy_final.m

### 3. Channel re-labeling

Notebook: rename_channel_and_combine.ipynb

Purpose: map channel indices to EEG labels (e.g., 'Channel 1' → 'AF3').

## D. Multimodal Alignment & Cleaning

### 1. Align EEG features with FaceReader + ratings

Script: Combine_study2_features

### 2. Final individual-level cleaning

Notebook: Clean_combined_files_v2.ipynb

Tasks:

Perform final quality control (QC) checks.

Drop irrelevant variables ("Channel 1 - Event_Number", "Quality", "Correct Time", "Chunk Index").

Standardize variables for modeling.

## E. Modeling & Statistics

### 1. Within-subject prediction

Scripts:

Study2 within prediction train test split.ipynb: helper code to create train/test split files and save them separately to avoid data leakage.

Prediction_model_within_subject_v6.ipynb: single-modality prediction.

Prediction_model_within_subject_v7.ipynb: compute and summarize statistics (accuracy, F1, permutation tests).

### 2. Cross-subject prediction

Script: Prediction_model_cross_subject_v2.ipynb

Strategy: leave-one-subject-out (LOSO) cross-validation; report evaluation metrics.




