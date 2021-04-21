function y = inv_hp_filt_mono(stim,stim_fs,hdph_x,hdph_fr,hdph_fs,uflg,fs_flg,flims,dBlims)
%This function outputs an inverse heaphone filtered signal for a given
%stimulus and a given headphone response, with 1/9th octave smoothing
%stim: input stimulus to be filtered (mono)
%stim_fs: sampling rate of stimulus
%hdph_x: in Hz, frequency vector (x-axis) for frequency response 
%hdph_fr: frequency response amplitude (could be in power, magnitude, or
%dB). Expecting "positive" frequencies only.
%hdph_fs: sampling rate of headphone response
%uflg: flag indicating units of hdph_fr, where 0 indicates dB and 1 indicates
%magnitude
%fs_flg: if 0, let y assume sampling rate of headphone response, and if 1,
%resample y to original sampling rate
%flims: in Hz, lower and upper limit of spectrum over which to normalize
%dBlims: in dB, limits on maximum headphone correction

%created by Luke Baltzell 06/25/20

if nargin == 4
    hdph_fs = max(hdph_x)*2;
    uflg = 0;
    fs_flg = 1;
    flims = [100 12000];
    dBlims = [-12 12];
elseif nargin == 5
    uflg = 0;
    fs_flg = 1;
    flims = [100 12000];
    dBlims = [-12 12];
end

if uflg == 0
    hdph_dB = hdph_fr; %units of dB
elseif uflg == 1
    hdph_dB = 20*log10(hdph_fr); %units of magnitude to dB
end

df = diff([hdph_x(1) hdph_x(2)]);
df_all = mean(diff(hdph_x));
if abs(df - df_all) >= 1e-6
    error('headphone response not equally spaced')
end

if max(hdph_x) < flims(2)
    error('change flims to match sampling rate')
end

if sum(hdph_x < 0) ~= 0
    error('combine positive and negative frequencies into single magnitude vector')
end

%remove DC if present
if hdph_x(1) == 0
    hdph_x = hdph_x(2:end);
end

%resample stimulus
if stim_fs ~= hdph_fs
    stim = resample(stim,hdph_fs,stim_fs);
end

Nf = round((1/df)*max(hdph_x)); %number of "positive" frequencies

lo = floor((1/df)*flims(1)); 
hi = floor((1/df)*flims(2));
hdph_dB_ref = mean(hdph_dB(lo:hi)); %get average from perceptually relevant portion of hr spectrum
hdph_dB_norm = hdph_dB - hdph_dB_ref; %normalize to average (add back average after clipping if you would like)
hdph_dB_norm(hdph_dB_norm > dBlims(2)) = dBlims(2);
hdph_dB_norm(hdph_dB_norm < dBlims(1)) = dBlims(1);

%smooth dB spectrum
oct = 1/9;
hdph_dB_norm_smooth = zeros(1,Nf);
for i = 1:Nf
    flims = [hdph_x(i)/2^(0.5*oct) hdph_x(i)*2^(0.5*oct)];
    slims = round((1/df)*flims);
    slims(2) = min([slims(2),Nf]);
    hdph_dB_norm_smooth(i) = mean(hdph_dB_norm(slims(1):slims(2)));
end

%take inverse and convert to magnitude spectrum
hdph_msd_inv = 10.^(-hdph_dB_norm_smooth/20);
hdph_msd_inv = [0 hdph_msd_inv fliplr(hdph_msd_inv(1:end-1))]; %add 0 dc and negative frequency components

%generate minimum-phase inverse filter
hdph_inv = ifftshift(ifft(hdph_msd_inv,'symmetric'));
[~,hdph_minph] = rceps(hdph_inv);

%apply inverse filter to stimulus
y = conv(stim,hdph_minph,'full');
y = y(1:length(stim)); % truncate to original length

if fs_flg == 1
    y = resample(y,stim_fs,hdph_fs);
end

end