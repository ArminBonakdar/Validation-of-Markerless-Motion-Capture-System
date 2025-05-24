clc;
clear;
close all;

%% -------------------- Compare Max Joint Angles --------------------
% Joint indices:
% MotionCAM: [2=back, 3=knee, 4=elbow, 8=shoulder, 6=neck]
% MotionMoCap: [8=back, 12=knee (negative), 49=elbow, 46=shoulder]
% MotionIMU: [8=back, 12=knee (negative), 30=elbow, 27=shoulder]

% Extract max joint angles from PoseChecker (ML-OMC)
max_CAM = [
    max(MotionCAM3(:,2)),  % back
    max(MotionCAM3(:,3)),  % knee
    max(MotionCAM3(:,4)),  % elbow
    max(MotionCAM3(:,8)),  % shoulder
    max(MotionCAM3(:,6))   % neck
];

% Extract max joint angles from MoCap
max_MoCap = [
    max(MotionMoCap3(:,8)),     % back
    max(-MotionMoCap3(:,12)),   % knee (inverted)
    max(MotionMoCap3(:,49)),    % elbow
    max(MotionMoCap3(:,46))     % shoulder
];

% Extract max joint angles from IMU
max_IMU = [
    max(MotionIMU3(:,8)),       % back
    max(-MotionIMU3(:,12)),     % knee (inverted)
    max(MotionIMU3(:,30)),      % elbow
    max(MotionIMU3(:,27))       % shoulder
];

% Round results to whole degrees
max_CAM = round(max_CAM);
max_MoCap = round(max_MoCap);
max_IMU = round(max_IMU);

% Create comparison matrix
% Row 1: MoCap
% Row 2: IMU
% Row 3: PoseChecker (CAM)
result = [
    0,         max_MoCap;
    0,         max_IMU;
    max_CAM          % includes 5 joints
];

% Optional: display results
disp('Max Joint Angles Comparison:');
disp(array2table(result, ...
    'VariableNames', {'Padding', 'Back', 'Knee', 'Elbow', 'Shoulder', 'Neck'}, ...
    'RowNames', {'MoCap', 'IMU', 'PoseChecker'}));
