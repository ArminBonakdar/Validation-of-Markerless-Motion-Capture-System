clc;
clear;
close all;

%% -------------------------- Joint Angle Comparison ----------------------------

% Define segments for three activity phases for each system
imu_segments = {581:887, 887:955, 955:1319};
cam_segments = {171:245, 245:282, 282:373};
mocap_segments = {558:849, 849:939, 939:1281};

% Load motion data from each system
MotionIMU = MotionIMU8;
MotionCAM = MotionCAM8;
MotionMoCap = MotionMoCap8;

% Extract IMU joint angles
IMU_signals = cellfun(@(p) MotionIMU(p,30), imu_segments, 'UniformOutput', false);
IMU_lengths = cellfun(@numel, IMU_signals);

% Extract and resize CAM joint angles
CAM_signals = cellfun(@(p, n) interp1(linspace(0,1,numel(MotionCAM(p,8))), ...
    MotionCAM(p,8), linspace(0,1,n)), cam_segments, num2cell(IMU_lengths), 'UniformOutput', false);

% Extract and resize MoCap joint angles
MoCap_signals = cellfun(@(p, n) interp1(linspace(0,1,numel(MotionMoCap(p,49))), ...
    MotionMoCap(p,49), linspace(0,1,n)), mocap_segments, num2cell(IMU_lengths), 'UniformOutput', false);

% Combine segments
IMU = vertcat(IMU_signals{:});
CAM = vertcat(CAM_signals{:})';
MoCap = vertcat(MoCap_signals{:})';

% Normalize only once (removed redundant scaling)
CAM = CAM / 2;
MoCap = MoCap / 2;

%% -------------------------- Filtering ----------------------------

Fs = 100;       % Sampling frequency
Fc = 1;         % Cutoff frequency (Hz)
[b, a] = butter(6, Fc / (Fs/2), 'low');  % Low-pass Butterworth filter

IMUfiltered = filtfilt(b, a, IMU);
CAMfiltered = filtfilt(b, a, CAM);
MoCapfiltered = filtfilt(b, a, MoCap);

%% -------------------------- Plot ----------------------------

figure;
plot(IMUfiltered, 'LineWidth', 2); hold on;
plot(CAMfiltered, 'LineWidth', 2);
plot(MoCapfiltered, 'LineWidth', 2);
xlabel('Time samples');
ylabel('Joint Angle');
legend('IMU','PoseChecker','MoCap');
title('Filtered Joint Angles');

%% -------------------------- Summary Statistics ----------------------------

% Helper function to compute stats
getStats = @(data) [max(data), mean(data), std(data), range(data)];

imu_stats = getStats(IMUfiltered);
cam_stats = getStats(CAMfiltered);
mocap_stats = getStats(MoCapfiltered);

fprintf('IMU: Max=%.2f, Mean=%.2f, Std=%.2f, Range=%.2f\n', imu_stats);
fprintf('PoseChecker: Max=%.2f, Mean=%.2f, Std=%.2f, Range=%.2f\n', cam_stats);
fprintf('MoCap: Max=%.2f, Mean=%.2f, Std=%.2f, Range=%.2f\n', mocap_stats);

% Correlation & RMSE
fprintf('Correlation (IMU vs MoCap): %.2f\n', corr(IMUfiltered, MoCapfiltered));
fprintf('Correlation (PoseChecker vs MoCap): %.2f\n', corr(CAMfiltered, MoCapfiltered));

rmse_imu = sqrt(mean((IMUfiltered - MoCapfiltered).^2));
rmse_cam = sqrt(mean((CAMfiltered - MoCapfiltered).^2));

fprintf('RMSE (IMU vs MoCap): %.2f\n', rmse_imu);
fprintf('RMSE (PoseChecker vs MoCap): %.2f\n', rmse_cam);

%% -------------------------- Joint Reaction Force Analysis ----------------------------

weight = 1200;  % Body weight in Newtons or N·m

% Combine all 3 lifting segments for each source
X1 = ArminIMU([230:507, 507:729, 729:900], 39) / weight;
X2 = ArminCAM([230:507, 507:729, 729:900], 39) / weight;
X3 = ArminMoCap([230:507, 507:729, 729:900], 39) / weight;

% Segment-wise resizing
seg_lengths = [278, 223, 172];  % Number of points per segment
start_idxs = [1, 279, 502];

CAMresized = cell(1,3);
MoCapresized = cell(1,3);
for i = 1:3
    idx = start_idxs(i):(start_idxs(i)+seg_lengths(i)-1);
    CAMresized{i} = interp1(linspace(0,1,numel(X2(idx))), X2(idx), linspace(0,1,numel(X1(idx))));
    MoCapresized{i} = interp1(linspace(0,1,numel(X3(idx))), X3(idx), linspace(0,1,numel(X1(idx))));
end

% Combine
IMU_JRF = X1;
CAM_JRF = vertcat(CAMresized{:})';
MoCap_JRF = vertcat(MoCapresized{:})';

% Filtering
Fc = 2.8;  % Hz
[b, a] = butter(6, Fc / (Fs/2), 'low');

IMUfiltered = filtfilt(b, a, IMU_JRF);
CAMfiltered = filtfilt(b, a, CAM_JRF);
MoCapfiltered = filtfilt(b, a, MoCap_JRF);

% Plot
figure;
plot(IMUfiltered, 'LineWidth', 2); hold on;
plot(CAMfiltered, 'LineWidth', 2);
plot(MoCapfiltered, 'LineWidth', 2);
xlabel('Time samples');
ylabel('Joint Reaction Force [BW]');
legend('IMU','PoseChecker','MoCap');
title('Filtered JRF');

% Statistics
fprintf('\n-- JRF Comparison --\n');
disp('MoCap:'), disp(getStats(MoCapfiltered));
disp('IMU:'), disp(getStats(IMUfiltered));
disp('PoseChecker:'), disp(getStats(CAMfiltered));

fprintf('Correlation (IMU vs MoCap): %.2f\n', corr(IMUfiltered, MoCapfiltered));
fprintf('Correlation (PoseChecker vs MoCap): %.2f\n', corr(CAMfiltered, MoCapfiltered));

fprintf('RMSE (IMU vs MoCap): %.2f\n', sqrt(mean((IMUfiltered - MoCapfiltered).^2)));
fprintf('RMSE (PoseChecker vs MoCap): %.2f\n', sqrt(mean((CAMfiltered - MoCapfiltered).^2)));
