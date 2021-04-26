function [y] = crossfade(x1,x2,s0,fs,tc)

[r,c] = size(x1);
if c > r
    x1 = x1';
end

[r,c] = size(x2);
if c > r
    x2 = x2';
end

seg = round((tc*fs)/2);
ramp=sin(2*pi*(1/4)*(1/tc)*[1:floor(fs*tc)]/fs).^2;
damp = fliplr(ramp);

fd1(1:s0-seg+1) = 1;
if mod(length(damp),2) == 1
    fd1(s0-seg+2:s0+seg) = damp; %changed 1 to 2 for tc = 0.1;
else
    fd1(s0-seg+1:s0+seg) = damp;
end
fd1(s0+seg+1:length(x1)) = 0;

fd2(1:s0-seg+1) = 0;
if mod(length(ramp),2) == 1
    fd2(s0-seg+2:s0+seg) = ramp; %changed 1 to 2 for tc = 0.1;
else
    fd2(s0-seg+1:s0+seg) = ramp;
end
fd2(s0+seg+1:length(x2)) = 1;

yfd1 = x1.*fd1';
yfd2 = x2.*fd2';

y = yfd1 + yfd2;

end