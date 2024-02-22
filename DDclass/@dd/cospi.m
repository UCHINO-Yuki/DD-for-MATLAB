function a = cospi(a)
% COSPI   Compute cos(X*pi) accurately
%
%   See also COSPI
%
%   cos(a*pi) = cos(k*pi/1024).*cos(r) - sin(k*pi/1024).*sin(r)
%   with a*pi =: k*pi/1024 + r
%
%   written ... 2024-02-23 ... UCHINO Yuki

arguments (Input)
    a dd
end

%% the exception cases
if isempty(a)
    return
end

% if a = nan, return nan (= a)
finflag = isnan(a.v1);

% if a = n/2 for odd n, return 0
aa = ldexp(a,-1);
i = (aa==round(aa)) & ~finflag;
if any(i,'all')
    a.v1(i) = 0;
    a.v2(i) = 0;
    finflag = finflag | i;
end

% if a = inf or -inf, return nan
i = isinf(a.v1);
if any(i,'all')
    a.v1(i) = NaN;
    a.v2(i) = NaN;
    finflag = finflag | i;
end

if all(finflag,'all')
    return;
end

%% other cases
anyflag = any(finflag,'all');
if anyflag
    r = a(~finflag);
    if isrow(r)
        r = r.';
    end
else
    if isrow(a)
        r = a.';
    else
        r = a;
    end
end

% Argument reduction k*pi/1024 + r := a
k = round(pow2(r.v1,10));                   % r*1024
r = (r - pow2(k,-10)) .* dd.ddpi;           % r*pi - k*pi/1024
j1 = k-pow2(floor(pow2(k,-11)),11);         % j1 = mod(k,2048)
j2 = k-pow2(floor(pow2(k,-10)),10);         % j2 = mod(k,1024)

% sink := sin(k.*pi/1024) using table
sgn = -1.*(j1>1024)+(j1<=1024);
idx = (j2>=512).*(1024-j2) + (j2<512).*j2 + 1;
sink = sgn.*dd.sin_tab(idx);

% cosk := cos(k.*pi/1024) using table
l = (512<=j1 & j1<1536);
sgn = -1.*l+(~l);
idx = (j2>=512).*(1024-j2) + (j2<512).*j2 + 1;
cosk = sgn.*dd.cos_tab(idx);

% sinr := sin(r)
r2 = r.*r;
sinr = r2.*dd.sinfact_tab.v1(4);
sinr = r2.*(sinr+dd.sinfact_tab.v1(3));
sinr = r2.*(sinr+dd.sinfact_tab(2));
sinr = r2.*(sinr+dd.sinfact_tab(1));
sinr = r + r.*sinr;

% cosr := cos(r)
cosr = r2.*dd.cosfact_tab.v1(3);
cosr = r2.*(cosr+dd.cosfact_tab.v1(2));
cosr = r2.*(cosr+dd.cosfact_tab(1));
cosr = 1 + ldexp(-r2,-1) + r2.*cosr;

% cos(a) := cosk.*cosr - sink.*sinr
if anyflag
    a(~finflag) = cosk.*cosr - sink.*sinr;
else
    a = cosk.*cosr - sink.*sinr;
end
end