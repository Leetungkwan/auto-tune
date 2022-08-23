[X, Fs] = audioread('mary.wav'); % Read input from .wav
out = autotune(X, 50, 2756,256, Fs); % Process signal
audiowrite('mary_mod.wav',out, Fs); % Write output to .wav

