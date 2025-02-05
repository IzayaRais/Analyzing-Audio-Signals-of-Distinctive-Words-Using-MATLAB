clc;
clear all;
close all;

%% Load ideal "tiin" and "chaar" voice files
[tiin, fs_tiin] = audioread("I:\PRE UPLOAD 3-2\EECE 312\dsp aSSIGNMENT\Assignment1\2.Audio Files\Ideal\tiin.wav");
[chaar, fs_chaar] = audioread("I:\PRE UPLOAD 3-2\EECE 312\dsp aSSIGNMENT\Assignment1\2.Audio Files\Ideal\chaar.wav");

% Load vowel sounds "aa" and "ii"
[aa, fs_aa] = audioread("I:\PRE UPLOAD 3-2\EECE 312\dsp aSSIGNMENT\Assignment1\2.Audio Files\Ideal\aa.wav");
[ii, fs_ii] = audioread("I:\PRE UPLOAD 3-2\EECE 312\dsp aSSIGNMENT\Assignment1\2.Audio Files\Ideal\ii.wav");

% Load the test voice file
[test_audio, fs_test] = audioread("I:\PRE UPLOAD 3-2\EECE 312\dsp aSSIGNMENT\Assignment1\2.Audio Files\Test\Sister\tiin_Sister.wav");

%% Convert all signals to mono if they are multi-channel
if size(tiin, 2) > 1
    tiin = mean(tiin, 2);
end
if size(chaar, 2) > 1
    chaar = mean(chaar, 2);
end
if size(aa, 2) > 1
    aa = mean(aa, 2);
end
if size(ii, 2) > 1
    ii = mean(ii, 2);
end
if size(test_audio, 2) > 1
    test_audio = mean(test_audio, 2);
end

% Ensure all files have the same sampling rate (resample if necessary)
if fs_tiin ~= fs_chaar || fs_aa ~= fs_tiin || fs_ii ~= fs_tiin
    error('Sampling rates of all input files must match.');
end
if fs_test ~= fs_tiin
    test_audio = resample(test_audio, fs_tiin, fs_test);
end
fs = fs_tiin; % Use the consistent sampling rate

% Normalize the signals
tiin = tiin / max(abs(tiin));
chaar = chaar / max(abs(chaar));
aa = aa / max(abs(aa));
ii = ii / max(abs(ii));
test_audio = test_audio / max(abs(test_audio));

%% Plot time-domain signals of test audio
figure;
plot((0:length(test_audio)-1)/fs, test_audio);
title('Time-Domain Signal of Test Audio');
xlabel('Time (s)');
ylabel('Amplitude');

%% Compute and compare FFT of the test audio with "tiin" and "chaar"
N_test = length(test_audio);
fft_test = fft(test_audio);
f_test = (0:N_test-1)*(fs/N_test); % Frequency axis
magnitude_test = abs(fft_test);

% Compute FFT of "tiin"
N_tiin = length(tiin);
fft_tiin = fft(tiin);
f_tiin = (0:N_tiin-1)*(fs/N_tiin); % Frequency axis
magnitude_tiin = abs(fft_tiin);

% Compute FFT of "chaar"
N_chaar = length(chaar);
fft_chaar = fft(chaar);
f_chaar = (0:N_chaar-1)*(fs/N_chaar); % Frequency axis
magnitude_chaar = abs(fft_chaar);

% Plot frequency spectra comparison
figure;
subplot(3, 1, 1);
plot(f_test(1:N_test/2), magnitude_test(1:N_test/2)); % Only show positive frequencies
xlim([0 2000]); % Limit to 2 kHz for better visualization
title('Frequency Spectrum of Test Audio');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

subplot(3, 1, 2);
plot(f_tiin(1:N_tiin/2), magnitude_tiin(1:N_tiin/2)); % Only show positive frequencies
xlim([0 2000]); % Limit to 2 kHz for better visualization
title('Frequency Spectrum of "tiin"');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

subplot(3, 1, 3);
plot(f_chaar(1:N_chaar/2), magnitude_chaar(1:N_chaar/2)); % Only show positive frequencies
xlim([0 2000]); % Limit to 2 kHz for better visualization
title('Frequency Spectrum of "chaar"');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% Identify peak frequencies
[~, peak_test] = max(magnitude_test(1:N_test/2));
[~, peak_tiin] = max(magnitude_tiin(1:N_tiin/2));
[~, peak_chaar] = max(magnitude_chaar(1:N_chaar/2));

fprintf('Peak frequency for test audio: %.2f Hz\n', f_test(peak_test));
fprintf('Peak frequency for "tiin": %.2f Hz\n', f_tiin(peak_tiin));
fprintf('Peak frequency for "chaar": %.2f Hz\n', f_chaar(peak_chaar));

%% Cross-correlation: Test audio with "tiin" and "chaar"
[corr_test_tiin, lags_test_tiin] = xcorr(test_audio, tiin); % Test vs "tiin"
[corr_test_chaar, lags_test_chaar] = xcorr(test_audio, chaar); % Test vs "chaar"

% Plot cross-correlation results
figure;
subplot(2, 1, 1);
plot(lags_test_tiin/fs, corr_test_tiin);
title('Cross-Correlation: Test Audio vs "tiin"');
xlabel('Lag (s)');
ylabel('Correlation');

subplot(2, 1, 2);
plot(lags_test_chaar/fs, corr_test_chaar);
title('Cross-Correlation: Test Audio vs "chaar"');
xlabel('Lag (s)');
ylabel('Correlation');

%% Identify peaks in correlation
[peak_corr_tiin, loc_corr_tiin] = max(corr_test_tiin);
[peak_corr_chaar, loc_corr_chaar] = max(corr_test_chaar);

fprintf('Peak correlation with "tiin": %.2f at lag %.2f s\n', peak_corr_tiin, lags_test_tiin(loc_corr_tiin)/fs);
fprintf('Peak correlation with "chaar": %.2f at lag %.2f s\n', peak_corr_chaar, lags_test_chaar(loc_corr_chaar)/fs);

%% Determine match based on correlation
if peak_corr_tiin > peak_corr_chaar
    fprintf('Test audio matches more closely with "tiin".\n');
else
    fprintf('Test audio matches more closely with "chaar".\n');
end
