clc;
clear all;

% Define parameters

M = 4; % Number of symbols

Fs = 1000; % Sampling frequency

T = 1; % Symbol duration in seconds

t = 0:1/Fs:T-1/Fs; % Time vector

% Create the symbols

symbols = randi([1, M], 1, length(t));

% Define the frequencies for each symbol

frequencies = [100, 200, 300, 400]; % Adjust as needed

% Generate MFSK signal

signal = zeros(1, length(t));

for i = 1:length(t)

signal(i) = exp(2j * pi * frequencies(symbols(i)) * t(i));

end

% Plot the MFSK signal

plot(t, signal);

xlabel('Time');

ylabel('Amplitude');

title('4-ary MFSK Signal');

