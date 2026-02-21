clc; clear; close all;

N = 1e5;                       % Number of bits
SNR_dB = 0:2:12;               % SNR range
BER_sim = zeros(size(SNR_dB));
BER_theory = zeros(size(SNR_dB));

for i = 1:length(SNR_dB)

    bits = randi([0 1], N, 1);         % Generate random bits
    tx = 2*bits - 1;                   % BPSK modulation

    rx = awgn(tx, SNR_dB(i), 'measured');  % Add AWGN noise
    detected = rx > 0;                 % Demodulation

    BER_sim(i) = sum(bits ~= detected) / N;

    SNR_linear = 10^(SNR_dB(i)/10);
    BER_theory(i) = 0.5 * erfc(sqrt(SNR_linear));
end

semilogy(SNR_dB, BER_sim, 'o-', SNR_dB, BER_theory, '*-');
legend('Simulated','Theoretical');
xlabel('SNR (dB)');
ylabel('Bit Error Rate');
title('BPSK BER Performance');
grid on;