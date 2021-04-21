function y = rampdamp(x,tc,fs)
%x: mono or stereo input
%tc: duration of ramp/damp in seconds
%fs: sampling rate of x

%created by Luke Baltzell 05/12/18

[nch, dim] = min(size(x));
if nch > 2
    error('Mono/Stereo input');
end

if dim == 2
    x = x.';
end

y = x;
if tc~=0
    ramp=sin(2*pi*(1/(4*tc))*(1:round(fs*tc))/fs).^2;
    damp=fliplr(ramp);
    for i = 1:nch
        y(i,1:length(ramp))=y(i,1:length(ramp)).*ramp;
        y(i,end-length(ramp)+1:end)=y(i,end-length(ramp)+1:end).*damp;
    end
end

end