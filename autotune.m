%************************************************************************* 
%* Code by Navaneeth Ravindranath, Blaine Rister, Andrew Tam, and Tanner *
%* Songkakul, provided as-is without warranty.                           *
%*************************************************************************
% 
% Pitch-correct the input signal X, with minimum pitch pMin, maximum pitch
% pMax (both in Hz), using window length w (nearest power of two), 
% sampled at rate Fs.
function R = autotune(X, pMin, pMax, w, Fs)

% Validate inputs
assert (pMin > 0);
assert (pMax < Fs / 2);

% Compress to mono (for efficiency--could do two-channel processing)
X = sum(X, 2);

% Generate window
len = 2^nextpow2(w);
W = window(@hamming, len);
%W = ones(len, 1);

% Main loop: take a window, process it, and save in the final result
R = zeros(length(X), 1);
Xwin = zeros(len, 1);
Rwin = zeros(len, 1);
Xfreq = zeros(len, 1);
Xmag = zeros(len, 1);
num_windows = floor(length(X) / len);
Nfreq = Fs * 2;
for i = 0 : num_windows - 1;
    % Take window
    n = i * len + 1;
    Xwin = app_window(X, W, n);
    
    % Process input--time domain?
    
    % FFT to .5Hz resolution
    Xfreq = fft(Xwin, Nfreq);
    
    % Process input--freq domain?
    
    % Find nearest note
    Xmag = abs(Xfreq);
    len = length(Xmag);

% Find the peak, searching only in the first half of the signal
    minIdx = freq_to_idx(pMin, len, Fs);
    maxIdx = freq_to_idx(pMax, len, Fs);
    [~, peakIdx] = max(Xmag(minIdx : min(floor(length(Xmag) / 2), maxIdx)));

% Find the nearest note
    Fpeak = idx_to_freq(peakIdx, len, Fs);
    
    ratio = get_ratio(Xmag, pMin, pMax, Fs);
    
    % Process signal
    if (ratio ~= 1.0)
%         Rwin = pitchShift(Xwin, 64, 16, ratio);
       
        Rwin = shiftPitch(Xwin,log(ratio)/log(2^(1/12)), ...
                     "Window", kbdwin(64), ...
                     "OverlapLength",0.75*numel(kbdwin(64)), ...
                     "LockPhase",1);
    else
        Rwin = Xwin;
    end
    
    if (i == 1000)
        i = i;
    end
    
    % Save
    R(n : n + len - 1) = Rwin(1:len);
    
end

% ---------------------Helper functions-------------------------%

% Nearest note on a chromatic scale, where f is in Hz.
function r = find_nearest_note(f) 

r = 2^((round(12*log2(f/440)+49)-49)/12)*440;

return
% Linear mapping from DFT index to frequency in Hz. i is the index,
% len is the total DFT length, and Fs is the sampling rate.
function r = idx_to_freq(i, len, Fs)

r = (i - 1) * Fs / len; 

return

% Inverse of above. Rounds downwards.
function r = freq_to_idx(f, len, Fs)

r = round(f * len / Fs) + 1;

return

% Apply window W to vector X at sample n. 
function R = app_window(X, W, n)

% Shift n samples
R = repmat(X(n : n + length(W) - 1), 1, 1);

% Apply
R = R .* W;

return

% Determine the appropriate frequency shift ratio of a 
% spectrum Xmag, given the sampling frequency Fs
function r = get_ratio(Xmag, pMin, pMax, Fs) 

len = length(Xmag);

% Find the peak, searching only in the first half of the signal
minIdx = freq_to_idx(pMin, len, Fs);
maxIdx = freq_to_idx(pMax, len, Fs);
[~, peakIdx] = max(Xmag(minIdx : min(floor(length(Xmag) / 2), maxIdx)));

% Find the nearest note
Fpeak = idx_to_freq(peakIdx, len, Fs);
Fnear = find_nearest_note(Fpeak);

% Return the quotient
if (Fnear == 0 || Fpeak == 0)
   r = 1.0; 
else
    r = Fnear / Fpeak;
end
    
return