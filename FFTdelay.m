function y = FFTdelay(x,tau,fs)
%returns a vector y which is x delayed by a factor T
%y: output time vector
%x: input time vector (mono)
%tau: delay in seconds
%fs: sample rate of x

%created by Luke Baltzell 2021/04/20
[~,dim] = min(size(x));
if dim == 1
    x = x';
end

N = length(x);
f = [0:fs/N:fs/2]';

X = fft(x);
X(1:length(f)) = X(1:length(f)).*exp(-2*pi*1i*f*tau);
y = ifft(X,'symmetric');

end