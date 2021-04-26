function [y] = crossfade(x1,x2,s0,fs,tc)
%This function applies a damp to input x1 and a symmetric ramp to input x2
%at sample s0. 

%created by Luke Baltzell, modified 04/26/2021

[r,c] = size(x1);
if c > r
    x1 = x1';
end

[r,c] = size(x2);
if c > r
    x2 = x2';
end

N = round(fs*tc); %number of samples
t = [1:N]/fs; %time vector
damp = 0.5*cos(2*pi*(1/2)*(1/tc)*t) + 0.5; %half-cycle cosine
ramp = fliplr(damp);

seg = round(N/2);
fd1(1:s0-seg+1) = 1;
if mod(length(damp),2) == 1
    fd1(s0-seg+2:s0+seg) = damp;
else
    fd1(s0-seg+1:s0+seg) = damp;
end
fd1(s0+seg+1:length(x1)) = 0;

fd2(1:s0-seg+1) = 0;
if mod(length(ramp),2) == 1
    fd2(s0-seg+2:s0+seg) = ramp;
else
    fd2(s0-seg+1:s0+seg) = ramp;
end
fd2(s0+seg+1:length(x2)) = 1;

yfd1 = x1.*fd1';
yfd2 = x2.*fd2';

y = yfd1 + yfd2;

end