clc; clear; close all;

%% Parameters
N = 64;
numSymbols = 500;
SNR_dB = 0:2:20;

BER_OFDM = zeros(size(SNR_dB));
BER_OTFS = zeros(size(SNR_dB));

for snrIdx = 1:length(SNR_dB)

    bits = randi([0 1], N*numSymbols, 1);
    symbols = 2*bits - 1;   % BPSK (no toolbox)

    %% OFDM
    X = reshape(symbols, N, []);
    x_ifft = ifft(X, N);
    tx_ofdm = x_ifft(:);

    h = (randn(size(tx_ofdm)) + 1j*randn(size(tx_ofdm)))/sqrt(2);
    rx = tx_ofdm .* h;
    rx = rx + (randn(size(rx)) + 1j*randn(size(rx))) ...
        * 10^(-SNR_dB(snrIdx)/20);

    rx_eq = rx ./ h;
    rx_matrix = reshape(rx_eq, N, []);
    X_fft = fft(rx_matrix, N);

    detected = real(X_fft(:)) > 0;
    BER_OFDM(snrIdx) = sum(bits ~= detected)/length(bits);

    %% OTFS (2D transform approximation)
    X_dd = fft2(X);
    x_otfs = ifft2(X_dd);
    tx_otfs = x_otfs(:);

    h2 = (randn(size(tx_otfs)) + 1j*randn(size(tx_otfs)))/sqrt(2);
    rx2 = tx_otfs .* h2;
    rx2 = rx2 + (randn(size(rx2)) + 1j*randn(size(rx2))) ...
        * 10^(-SNR_dB(snrIdx)/20);

    rx2_eq = rx2 ./ h2;
    X_rx = reshape(rx2_eq, N, []);
    X_dd_rx = fft2(X_rx);

    detected2 = real(X_dd_rx(:)) > 0;
    BER_OTFS(snrIdx) = sum(bits ~= detected2)/length(bits);
end

semilogy(SNR_dB, BER_OFDM, '-o'); hold on;
semilogy(SNR_dB, BER_OTFS, '-s');
legend('OFDM','OTFS');
xlabel('SNR (dB)');
ylabel('BER');
title('OFDM vs OTFS under Rayleigh Fading');
grid on;