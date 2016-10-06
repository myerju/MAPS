#[y,Fs] = audioread('aug_18_beep.mp3','native'); #make an array of y = aug..., Fs= native? 
#native explanation: 
    #http://stackoverflow.com/questions/16765612/understanding-native-option-for-wavread-function-of-matlab
    #Matlab reads wav files in signed double precision normalized format, which means the values returned by wavread are between -1 and 1
    #native lets us import the raw data in wav file as signed integer numbers
Fs <- readWave("/Volumes/MAPS1/Participant Recordings/MAPS-005/raw/MAPS-005.wav", from=0, to= Inf, units = "seconds")
y <- matlab_native

#x=double(y(:,2)); 
    #Read columns 1-2 of all rows in y; double returns the double-precision value for x; 	
    #native argument returns "Samples in the native data type found in the file." 
    #because it probably detects this from the wav file header and in my case it returns int16. 
    #double solves this by performing a type cast to double like in C?
x <- double(y[ ,2])

#t=linspace(0,length(y)/Fs,length(y));
   #Create a vector of 7 evenly spaced points (determined by length(y)) in the interval [0,length(y)/Fs]
t <- seq(0, (nrow(y)/Fs), len=nrow(y))

#figure;plot(t,x);xlabel('time (s)');ylabel('Amplitude'); title('Audio signal') # plot audio signal
qplot(x=t, y = x, geom = "auto", xlab = 'time (s)', ylab = 'Amplitude', main = 'Audio signal')


#j=1;
#for i=1:blockSize:length(x)-blockSize  
         #for i in a sequence of numbers from 1 to end of x - blocksize give evenly spread out points in the block size 
#x1=x(i:(i+blockSize-1));
#N=length(x1);
#[maxValue,indexMax] = max(abs(fft(x1-mean(x1))));
#if ~isempty(indexMax)
#f=4175;
#freq_indices = round(f/Fs*N) + 1;
#mag(j)=abs(goertzel(x1,freq_indices));
#else
#  mag(j)=0;
#end
#j=j+1;
#end

j <- 1
for(i in seq(1, nrow(x)-block_size, block_size)) 
  {
  x1 <- samples[i:(i + block_size - 1)]
  N <- nrow(x1)
  #[maxValue,indexMax] = max(abs(fft(x1-mean(x1))));
  if(!emptyenv(index_max),
     f <- 4175
     freq_indices <- round(f/Fs*N) + 1
     magnitude[j] <- abs(goertzel(x1, freq_indices)),  
     else(
       magnitude[j] <- 0
  }
j <- j + 1



readAudio <- function(){
  
  magnitude <- numeric(size / blockSize)      #Pre-allocate arrays to improve performance
  timer <- numeric(size / blockSize)
  beep <- 0
  j <- 1
  
  for(i in seq(1, block_size, length(x)-block_size)){          #Perform Goertzel on block of samples, results in "Goertzeled" sampling rate equal to Shimmer sampling rate
    magnitude[j] <- goertzel(hann(samples[i:(i + blockSize - 1)]))  
    timer[j] <- i / samplingRate 
    j <- j + 1
  }
  plot(magnitude, type = "l")
  # audioData <- data.frame(timer, magnitude)
  # plot(audioData, type = "l")        
  return(magnitude)
}


[S1,I1] = max(mag); #search for the peak
t1=t(1:blockSize:length(x)-blockSize); #time scale for the samples version of audio
disp(['Beep detected ' num2str(t1(I1)),' seconds after video was started']);

audio=zeros(length(mag),1);
audio(I1)=1; #single peak representing beep in audio signal 

figure; #plot single peak representations
plot(t1,audio);title('audio time');xlabel('time (s)');

