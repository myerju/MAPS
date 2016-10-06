close all;clear all;clc;

%%%%%%%%%%%%%%%%% Shimmer %%%%%%%%%%%%%%%%%%%
%M=xlsread('beep_audio_Session1_sync_button_Calibrated_SD.csv');
M=xlsread('beep_sh_Session1_sync_button_Calibrated_SD.csv');

figure; %% plot shimmer signal
plot((M(:,1)-M(1,1))./1000,M(:,16),'r');ylabel('V');xlabel('time (s)');title('Shimmer signal');

[S,I]=max(M(:,16)); %% Detect the peak from port A13 (PPG signal)
disp(['Beep detected ',num2str(((M(I,1)-M(1,1))./1000)), ' seconds after the shimmer was started']);

shimmer=zeros(length(M),1); 
shimmer(I)=1;%% single peak representing beep in audio signal 


%%%%%%%%%%%%%%%%% Audio %%%%%%%%%%%%%%%%%%%%%%

%[y,Fs] = audioread('audio_first_final.wav','native');
[y,Fs] = audioread('beep_sh_audio.wav','native');
x=double(y(:,2));

t=linspace(0,length(y)/Fs,length(y));
figure;plot(t,x);xlabel('time (s)');ylabel('Amplitude'); title('Audio signal');%% plot audio signal

samplingRate = 44100 ; %% audio sampling rate
shimmerSamplingRate = 51.2;
blockSize= round(samplingRate / shimmerSamplingRate);%%gives number of audio samples for every shimmer sample

%%% Get the peak from audio signal (look for 4175Hz signal)
j=1;
for i=1:blockSize:length(x)-blockSize 
    x1=hanning(x(i:(i+blockSize-1)));
    N=length(x1);
    [maxValue,indexMax] = max(abs(fft(x1-mean(x1))));
    if indexMax>10
        f=4175;
        freq_indices = round(f/Fs*N) + 1;
        mag(j)=abs(goertzel(x1,freq_indices));
    else
        mag(j)=0;
    end
    j=j+1;
end

[S1,I1] = max(mag);%% search for the peak
t1=t(1:blockSize:length(x)-blockSize); %% time scale for the samples version of audio
disp(['Beep detected ' num2str(t1(I1)),' seconds after video was started']);

audio=zeros(length(mag),1);
audio(I1)=1;%% single peak representing beep in audio signal 

figure; %% plot single peak representations
subplot(2,1,1);plot((M(:,1)-M(1,1))./1000,shimmer);title('shimmer time');xlabel('time (s)');
subplot(2,1,2);plot(t1,audio);title('audio time');xlabel('time (s)');


%%%%%%%%%%%%% calclulate and corect for the lag %%%%%%

lag=((M(I,1)-M(1,1))./1000)-t1(I1); %% calculate lag

if lag < 0 
    disp(['Audio is leading by ', num2str(abs(lag)),' seconds']);
else
    disp(['Shimmer is leading by ', num2str(abs(lag)),' seconds']);
end

figure;
subplot(2,1,1);plot(shimmer);title('shimmer');xlabel('samples');
subplot(2,1,2);plot(audio);title('audio');xlabel('samples');

%%% correct for the lag by padding zeros to the lagging signal
if lag<0
    ap=round(abs(lag)*shimmerSamplingRate);
    new_M=padarray(shimmer,[ap 0],'pre');
    figure;
    subplot(2,1,1);plot(new_M);title('shimmer adjusted');xlabel('samples');
    subplot(2,1,2);plot(audio);title('audio');xlabel('samples');
else 
    ap=round(abs(lag)*shimmerSamplingRate);
    new_y=padarray(audio,[ap 0],'pre');
    figure;
    subplot(2,1,1);plot(shimmer);title('shimmer');xlabel('samples');
    subplot(2,1,2);plot(new_y);title('audio adjusted');xlabel('samples');
       
end

%%%correct for lag in real data 
if lag<0
    ap=round(abs(lag)*shimmerSamplingRate);
    new_M1=padarray(M,[ap 0],'pre');
    new_M1(1:ap,1)=M(1,1)-abs(lag*1000):1000/shimmerSamplingRate:M(1,1);
    
    figure;
    subplot(3,1,1);plot((M(:,1)-M(1,1))./1000,M(:,16));title('shimmer original');xlabel('time (s)');
    subplot(3,1,2);plot((new_M1(:,1)-new_M1(1,1))./1000,new_M1(:,16));title('shimmer adjusted');xlabel('time (s)');
    subplot(3,1,3);plot(t1,audio);title('audio original');xlabel('time (s)');
else
    ap=round(abs(lag)*samplingRate);
    new_y1=padarray(y,[ap 0],'pre');
    t2=linspace(0,length(new_y1)/Fs,length(new_y1));

    figure;
    subplot(3,1,1);plot((M(:,1)-M(1,1))./1000,M(:,16));title('shimmer original');xlabel('time (s)');
    subplot(3,1,2);plot(t,y(:,1));title('audio original');xlabel('time (s)');
    subplot(3,1,3);plot(t2,new_y1(:,1));title('audio adjusted');xlabel('time (s)');
end

