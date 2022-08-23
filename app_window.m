function R = app_window(X, W, n)

% Shift n samples
R = repmat(X(n : n + length(W) - 1), 1, 1);

% Apply
R = R .* W;


return