clc; clear; close all;

fs = 1000;                         % Sampling frequency
t = 0:1/fs:1;                      

signal = sin(2*pi*50*t);            % Clean signal
noise = 0.5*randn(size(t));         % Noise
noisy_signal = signal + noise;      % Noisy signal

mu = 0.01;                          % Step size
order = 4;                          % Filter order
w = zeros(order,1);                 
y = zeros(size(t));
e = zeros(size(t));

for n = order:length(t)
    x = noisy_signal(n:-1:n-order+1).';
    y(n) = w.' * x;
    e(n) = noisy_signal(n) - y(n);
    w = w + mu * e(n) * x;
end

figure;
plot(t, noisy_signal, 'r');
hold on;
plot(t, e, 'b');
legend('Noisy Signal','Filtered Output');
title('Adaptive LMS Noise Cancellation');
xlabel('Time');
grid on;