function y = FFTdelay(x,tau,fs)
%returns a vector y which is x delayed by a factor T
%OUTPUT
%y: output time vector
%INPUT
%x: input time vector (mono)
%tau: delay in seconds
%fs: sample rate of x

%created by Luke Baltzell, modified 04/20/2021

[~,dim] = min(size(x));
if dim == 1
    x = x';
end

N = length(x);
f = [0:fs/N:floor(fs/2)]';

X = fft(x);
X(1:length(f)) = X(1:length(f)).*exp(-2*pi*1i*f*tau);
y = ifft(X,'symmetric');

end
