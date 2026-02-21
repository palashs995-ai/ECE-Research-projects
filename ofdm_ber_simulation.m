clc; clear; close all;

N = 64;                 
cp_len = 16;            
numSymbols = 1000;      
SNR_dB = 0:2:20;
M = 4;                  
k = log2(M);

BER = zeros(size(SNR_dB));

for snrIdx = 1:length(SNR_dB)

    data = randi([0 1], numSymbols*N*k, 1);
    symbols = bi2de(reshape(data, k, []).').';
    modSignal = pskmod(symbols, M, pi/M);

    modSignal = reshape(modSignal, N, []);
    ifftSignal = ifft(modSignal, N);
    txSignal = [ifftSignal(end-cp_len+1:end,:); ifftSignal];

    txSerial = txSignal(:);
    rxSerial = awgn(txSerial, SNR_dB(snrIdx), 'measured');

    rxMatrix = reshape(rxSerial, N+cp_len, []);
    rxMatrix = rxMatrix(cp_len+1:end,:);
    fftSignal = fft(rxMatrix, N);

    demodSymbols = pskdemod(fftSignal(:), M, pi/M);
    rxBits = de2bi(demodSymbols, k).';
    rxBits = rxBits(:);

    BER(snrIdx) = sum(data ~= rxBits) / length(data);
end

semilogy(SNR_dB, BER, '-o');
xlabel('SNR (dB)');
ylabel('Bit Error Rate');
title('OFDM BER vs SNR (QPSK)');
grid on;