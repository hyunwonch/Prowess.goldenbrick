
> Prowess Goldenbrick Repository
___
# Kernel Information
- OFDM Estimation
    - Two versions
        1. DAP              -> fir, autocorr, fft, channel estimation, demodulation
        2. Spectrum Sensing -> Conjugate, multiplication, maximum
- Instantaneous Amplitude
    - Doing hilbert and absolute value
-Max PSD
    - IA, average, fft, squre, absolute
- QAM Estimation
    - Equalization
- PSK classification
- Chirp Detection / Estimation
    - FFT, FFTshift, abs, max


|Kernel|Description|
|--|--|
|OFDM| conjgate, matmul, maximum|
|IA| hilbert, abs|
|PSD| IA, mean, fft, square, abs|
|QAM| Equalization|
|PSK|
|Chirp| FFT, FFTshift, abs, max|

___
# To-dos
    - [ ] OFDm Estimation
    - [ ] IA
    - [ ] PSD
    - [ ] QAM Estimation
    - [ ] PSK Classification
    - [ ] Chirp Estimation & Detection
    - [ ] Need to change overall flow
        - .py file for kernel definition
        - single ipynb file for kernel execution