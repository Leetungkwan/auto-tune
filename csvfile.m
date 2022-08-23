M = xlsread('newf0_frame.csv');
M = interp1(M(:,1),M(:,2),512:512:max(M(:,1)));
M=[512:512:max(M(:,1));M];
M1 = xlsread('auto_512_frame.csv');
plot