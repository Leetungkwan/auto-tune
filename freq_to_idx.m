function r = freq_to_idx(f, len, Fs)

r = round(f * len / Fs) + 1;

return