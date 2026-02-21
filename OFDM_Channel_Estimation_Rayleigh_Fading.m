clc; clear; close all;

%% Parameters
N = 64;                     % Number of subcarriers
cp_len = 16;                % Cyclic prefix length
numSymbols = 1000;          
SNR_dB = 0:2:20;
M = 4;                      % QPSK
k = log2(M);

BER = zeros(size(SNR_dB));

for snrIdx = 1:length(SNR_dB)

    % Generate random data
    data = randi([0 1], numSymbols*N*k, 1);
    symbols = bi2de(reshape(data, k, []).').';
    modSignal = pskmod(symbols, M, pi/M);

    % Reshape for OFDM
    modSignal = reshape(modSignal, N, []);
    ifftSignal = ifft(modSignal, N);
    txSignal = [ifftSignal(end-cp_len+1:end,:); ifftSignal];

    txSerial = txSignal(:);

    % Rayleigh Fading Channel
    h = (randn(size(txSerial)) + 1j*randn(size(txSerial))) / sqrt(2);
    fadedSignal = txSerial .* h;

    % Add AWGN Noise
    rxSerial = awgn(fadedSignal, SNR_dB(snrIdx), 'measured');

    % Channel Estimation (Perfect Knowledge Assumed)
    rxEqualized = rxSerial ./ h;

    % Reshape back
    rxMatrix = reshape(rxEqualized, N+cp_len, []);
    rxMatrix = rxMatrix(cp_len+1:end,:);
    fftSignal = fft(rxMatrix, N);

    demodSymbols = pskdemod(fftSignal(:), M, pi/M);
    rxBits = de2bi(demodSymbols, k).';
    rxBits = rxBits(:);

    BER(snrIdx) = sum(data ~= rxBits) / length(data);
end

% Plot BER
semilogy(SNR_dB, BER, '-o');
xlabel('SNR (dB)');
ylabel('Bit Error Rate');
title('OFDM BER under Rayleigh Fading Channel');
grid on;