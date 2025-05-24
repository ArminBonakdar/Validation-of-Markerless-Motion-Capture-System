clc;
clear;
close all;

%% -------------------- Joint Angle (Hip) Mean ± SD Plot --------------------

desired_size = 100;
X = 1:desired_size;
num_signals = 9;

Y = zeros(num_signals, desired_size); % PoseChecker
Z = zeros(num_signals, desired_size); % IMU
K = zeros(num_signals, desired_size); % MoCap

% Resize and assign signals (example: hip angle column = 8)
for i = 1:num_signals
    imu = eval(sprintf("ikIMU%d", i));
    cam = eval(sprintf("ikCAM%d", i));
    mocap = eval(sprintf("ikMoCap%d", i));
    
    range = get_range(i); % helper function you'd define for indices per trial
    Y(i,:) = interp1(linspace(0, 1, numel(cam(range,8))), cam(range,8)', linspace(0, 1, desired_size));
    Z(i,:) = interp1(linspace(0, 1, numel(imu(range,8))), imu(range,8)', linspace(0, 1, desired_size));
    K(i,:) = interp1(linspace(0, 1, numel(mocap(range,8))), mocap(range,8)', linspace(0, 1, desired_size));
end

% Compute mean and std
mean_Y = filtfilt(butter_filt(), 1, mean(Y));
mean_Z = filtfilt(butter_filt(), 1, mean(Z));
mean_K = filtfilt(butter_filt(), 1, mean(K));

std_Y = std(Y);
std_Z = std(Z);
std_K = std(K);

% Plot mean ± SD
figure;
plot(X, mean_Y, 'b', 'LineWidth', 2); hold on;
plot(X, mean_Z, 'r', 'LineWidth', 2);
plot(X, mean_K, 'g', 'LineWidth', 2);

% Add error bars every 5%
whisker_interval = 5;
for i = 1:whisker_interval:length(X)
    errorbar(X(i), mean_Y(i), std_Y(i), 'b', 'LineWidth', 1);
    errorbar(X(i), mean_Z(i), std_Z(i), 'r', 'LineWidth', 1);
    errorbar(X(i), mean_K(i), std_K(i), 'g', 'LineWidth', 1);
end

xlabel('Lifting Cycle (%)');
ylabel('Hip Joint Angle (°)');
legend('PoseChecker', 'IMU', 'MoCap');
title('Mean Hip Joint Angle ± SD');

%% -------------------- JRF Mean ± SD Plot --------------------

% Normalization factors per trial
norm_factors = [950, 550, 650, 630, 650, 570, 520, 650] * 1.5;
Y = zeros(8, desired_size); Z = Y; K = Y;

for i = 1:8
    norm_val = norm_factors(i);

    imu_raw = eval(sprintf("JRFIMU%d", i));
    cam_raw = eval(sprintf("JRFCAM%d", i));
    mocap_raw = eval(sprintf("JRFMoCap%d", i));

    col = 210;
    imu_sig = preprocess_JRF(imu_raw, col, norm_val);
    cam_sig = preprocess_JRF(cam_raw, col, norm_val);
    mocap_sig = preprocess_JRF(mocap_raw, col, norm_val);

    Z(i,:) = imu_sig;
    Y(i,:) = cam_sig;
    K(i,:) = mocap_sig;
end

% Absolute value and smoothing
Y = abs(Y); Z = abs(Z); K = abs(K);

mean_Y = filtfilt(butter_filt(), 1, mean(Y));
mean_Z = filtfilt(butter_filt(), 1, mean(Z));
mean_K = filtfilt(butter_filt(), 1, mean(K));

std_Y = std(Y);
std_Z = std(Z);
std_K = std(K);

% Plot JRF
figure;
plot(X, mean_Y, 'b', 'LineWidth', 2); hold on;
plot(X, mean_Z, 'r', 'LineWidth', 2);
plot(X, mean_K, 'g', 'LineWidth', 2);

for i = 1:whisker_interval:length(X)
    errorbar(X(i), mean_Y(i), std_Y(i), 'b');
    errorbar(X(i), mean_Z(i), std_Z(i), 'r');
    errorbar(X(i), mean_K(i), std_K(i), 'g');
end

xlabel('Lifting Cycle (%)');
ylabel('Elbow Joint Reaction Force [BW]');
legend('PoseChecker', 'IMU', 'MoCap');
title('Mean Elbow JRF ± SD');

%% -------------------- Helper Functions --------------------

function [b, a] = butter_filt()
    Fs = 100; Fc = 10;
    [b, a] = butter(4, Fc / (Fs/2), 'low');
end

function signal = preprocess_JRF(data, col, norm_val)
    % Safely extracts, filters, and resizes a JRF signal
    idx = find(~all(isnan(data),2));  % robust start-end
    segment = data(idx(1):idx(end), col)';
    segment = filtfilt(butter_filt(), 1, segment) / norm_val;
    signal = interp1(linspace(0, 1, numel(segment)), segment, linspace(0, 1, 100));
end
