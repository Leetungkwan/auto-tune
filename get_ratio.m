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