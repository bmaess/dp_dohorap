scalefactor = 20;
sourcepos = [0.1,90,0;0.1,-90,0];

% Loading MEG data
cfg.dataset = '../dh52a/dh52a1_ss.fif';
cfg.channel    = 'MEG';
cfg.continuous = 'yes';
cfg.hpfilter = 'yes';
cfg.hpfreq = 1;
cfg.lpfilter = 'yes';
cfg.lpfreq = 100;
hdr = ft_read_header(cfg.dataset);
data = ft_preprocessing(cfg);
magnetometers = find(sum(hdr.grad.tra,2)>0);

magcount = size(magnetometers,1);
sensorpos = zeros(magcount,3);
for s = 1:magcount
    [azi,ele,dist] = cart2sph(hdr.grad.chanpos(s,2),hdr.grad.chanpos(s,1),hdr.grad.chanpos(s,3));
    sensorpos(s,1) = dist * 0.01 * scalefactor;
    sensorpos(s,2) = azi * (180/pi);
    sensorpos(s,3) = ele * (180/pi);
end;
clear azi ele dist i s

%% Time-stretch sound sources x48

lowstream = [];
clippingThreshold = prctile(max(abs(data.trial{1}(magnetometers,2000:end-2000))'),99.9);
side = 1;
i = 1;
for s = 1:magcount
    stream = data.trial{1}(magnetometers(s),2000:end-2000)' ./ clippingThreshold;
    lowstream = [lowstream, resample(stream,230,1000)];
    if side == 1
        side = 2;
    else
        filename = horzcat(['../dh52a/outstream-',num2str(i),'.wav']);
        wavwrite(lowstream,11025,16,filename);
        lowstream = [];
        i = i+1;
        side = 1;
    end;
end;


% Vplot(sensorpos,sourcepos(1,:),1,102)

%% After paulstretch:

clear data;
audio = [];
stream = wavread('../dh52a/stretched_outstream-1.wav');
refsize = size(stream,1);
% read data from disk into a single array
streams = zeros(magcount, refsize);
for s = 1:magcount/2
    for side = 1:2
        filename = horzcat(['../dh52a/stretched_outstream-',num2str(s),'.wav']);
        stream = wavread(filename);
        streams((s-1)*2 + side,:) = stream(:,side);
    end;
end;

gains = zeros(magcount,2);
delays = zeros(magcount,2);
for side = 1:2
    % calculate spatial effects on attenuation and phase
    gains(:,side) = 1-VDPgain_dist(magcount,sensorpos,sourcepos(side,:));
    delays(:,side) = V_delay(magcount,sensorpos,sourcepos(side,:),11025,340.25);
end;

outstream = zeros(magcount,refsize + floor(max(max(delays))));
audio = zeros(2,refsize + floor(max(max(delays))));
% modify the MEG data accordingly
for s = 1:magcount
    for side = 1:2
        delay = zeros(1,floor(delays(s,side)));
        stream = horzcat(delay,streams(s,:) .* gains(s,side)); % delay in front of the signal
        outstream(s,1:size(stream,2)) = stream;
    end;
    % combine all data streams
    stream = mean(outstream,1);
    audio(side,1:size(stream,2)) = stream;
end;
wavwrite(audio,11025,16,'../dh52a/dh52a.wav');
