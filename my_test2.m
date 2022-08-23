[X, Fs] = audioread('singing_test.wav'); % Read input from .wav

X = sum(X, 2);
w = 2048;
pMin=60;
pMax=1050;
% Generate window
Len = 2^nextpow2(w);
W = window(@hamming, Len);
%W = ones(len, 1);

% Main loop: take a window, process it, and save in the final result
% R = zeros(length(X), 1);
% Xwin = zeros(len, 1);
% Rwin = zeros(len, 1);
% Xfreq = zeros(len, 1);
% Xmag = zeros(len, 1);
num_windows = floor(length(X) / Len*4);
Nfreq = Fs * 2;
for i = 0 : num_windows - 1-3
    % Take window
    n = i * Len/4 + 1;
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
    Fpeak(i+1) = idx_to_freq(peakIdx, len, Fs);
     
end



[X, Fs] = audioread('singing_test_autotune.wav'); % Read input from .wav

X = sum(X, 2);
w = 2048;
pMin=60;
pMax=1050;
% Generate window
Len = 2^nextpow2(w);
W = window(@hamming, Len);
%W = ones(len, 1);

% Main loop: take a window, process it, and save in the final result
% R = zeros(length(X), 1);
% Xwin = zeros(len, 1);
% Rwin = zeros(len, 1);
% Xfreq = zeros(len, 1);
% Xmag = zeros(len, 1);
num_windows = floor(length(X) / Len*4);
Nfreq = Fs * 2;
for i = 0 : num_windows - 1-3
    % Take window
    n = i * Len/4 + 1;
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
    Fpeak_at(i+1) = idx_to_freq(peakIdx, len, Fs);
     ratio(i+1) = get_ratio(Xmag, pMin, pMax, Fs); 
end
return

% 原来是注释的
% ks = ratio; ks = lowpass(ks,2900,Fs);
% 
% ks = Fpeak_at./Fpeak;
% ks = lowpass(Fpeak,1900,Fs)./Fpeak;

%%

% 原始内容，原本是注释的
 alpha=0.9;
 beta=0.1;
 dt=2;
 xk=Fpeak(2);
 vk=Fpeak(3)-Fpeak(2) - Fpeak(1);
 XK(1,:) = Fpeak(1);
 VK(1,:) = 0;
  
for t = 2:length(Fpeak)
       if  abs(Fpeak(t)- Fpeak(t-1))<8
           xm = Fpeak(t);  % true position (A circle)
           [xkp,vkp,rk] = alphaBetaFilter(xm, dt, xk, vk, alpha, beta);
           xk = xkp;
           vk = vkp;
           XK(t,:) = xkp; VK(t,:) = vkp; RK(t,:) = rk;
       else
           XK(t,:) = Fpeak(t);
           vk=0;
       end
end
%XK = wdenoise(Fpeak,9,NoiseEstimate=='LevelDependent');
XK = wdenoise(Fpeak,9);
XK = medfilt2(XK, 'symmetric')
% XK = fspecial('average')

% plot(1:length(XK),XK,'r');
% hold on;
plot(1:length(XK),Fpeak_at,'b');
hold on;
plot(1:length(XK),Fpeak,'k');


% 新增内容，仅具有参考意义
% mean_F =Fpeak(1);
% cnt_F =1;
% XK(1)=Fpeak(1);
% nn=15;
% for i =2:length(Fpeak)
%     if abs(Fpeak(i)-Fpeak(i-1))<1.5 
%         if cnt_F < nn
%             mean_F = (mean_F*cnt_F+Fpeak(i))/(cnt_F+1);
%             XK(i) =  mean_F;
%             cnt_F=cnt_F+1;
%         else
%             XK(i)= sum(Fpeak(i-nn:i))/(nn+1);
%             mean_F = XK(i);
%             cnt_F =cnt_F+1;
%         end            
%     else
%         XK(i) = Fpeak(i);
%         mean_F = Fpeak(i);
%         cnt_F = 1;
%     end 
% end
% % plot(1:length(Fpeak),XK,'r');
% % hold on;
% % plot(1:length(Fpeak_at),Fpeak_at,'b');
% XK = wdenoise(XK,9);
% plot(1:length(XK),Fpeak_at,'b');
% hold on;
% plot(1:length(XK),Fpeak,'k');
% 
% return

%%
for i = 1:length(ks)
    if ks(i)<1.1 && ks(i) >0.9
        ks(i)=ks(i);
    else
        ks(i)=1;
    end
end
save('ks.mat','ks');