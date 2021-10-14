function It = info2(M)
% This m-file calculates the transmitted information (It) of matrix M 
% using natural logarithms (i.e. in natural units or 'nats')
n = sum(sum(M));    % total number of entries
sx = sum(M')';      % row sums
sy = sum(M)';       % column sums
gxy = find(M ~= 0); % indices for non-zero elements
gx = find(sx ~= 0); % indices for non-zero row sums
gy = find(sy ~= 0); % indices for non-zero column sums

Hxy = -sum(M(gxy).*log(M(gxy)))/n; % element entropy
Hx = -sum(sx(gx).*log(sx(gx)))/n;  % row entropy
Hy = -sum(sy(gy).*log(sy(gy)))/n;  % column entropy

It = log(n) + Hx + Hy - Hxy; % Transmitted information