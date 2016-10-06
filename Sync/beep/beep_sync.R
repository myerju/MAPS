# install.packages("tuneR")
# install.packages("signal")
# library(signal)
# library(tuneR)

audio <- readWave("C:/Users/Kevin/Desktop/cryingbeep2.wav", from = 0, to = Inf, units = "minutes")
samplingRate <- 44100 - (44100 %% shimmerSamplingRate)        #Largest multiple of shimmer sampling rate under 44100 
shimmerSamplingRate <- 512
blockSize <- samplingRate / shimmerSamplingRate
targetFrequency <- 4100  
downsamples <- downsample(audio, samplingRate)
samples <- downsamples@left
size <- dim(array(samples))

goertzel <- function(samples){          #Single bin Fourier Transform, returns magnitude of signal at target frequency for block of samples
  N <- 200                              #FFT Points
  k <- round(0.5 + (N * targetFrequency / samplingRate))
  w <- (2 * pi * k) / N
  cosine <- cos(w)
  sine <- sin(w)
  coeff <- 2 * cosine
  Q0 <- 0
  Q1 <- 0
  Q2 <- 0
  
  for(i in seq(1, dim(array(samples)), 1))
  {
    Q0 <- coeff * Q1 - Q2 + samples[i]
    Q2 <- Q1
    Q1 <- Q0
  }
  
  #   Re <- (Q1 - Q2 * cosine)            
  #   Im <- (Q2 * sine)
  #   magnitude <- Re^2 + Im^2
  magnitude <- sqrt(Q1^2 + Q2^2 - Q1 * Q2 * coeff)          #optimized Goertzel for magnitude only
  scale <- log(magnitude)
  Q0 <- 0
  Q1 <- 0
  Q2 <- 0
  return(scale)
}

hann <- function(samples){              #Windowing
  windowed <- numeric()
  for(i in seq(1, dim(array(samples)), 1)){
    windowed[i] <- .5 * (1 - cos(2 * pi * i / dim(array(samples)))) * samples[i]
  }
  return(windowed)
}

readAudio <- function(){
  
  magnitude <- numeric(size / blockSize)      #Pre-allocate arrays to improve performance
  timer <- numeric(size / blockSize)
  beep <- 0
  j <- 1
  
  for(i in seq(1, size, blockSize)){          #Perform Goertzel on block of samples, results in "Goertzeled" sampling rate equal to Shimmer sampling rate
    magnitude[j] <- goertzel(hann(samples[i:(i + blockSize - 1)]))  
    timer[j] <- i / samplingRate 
    j <- j + 1
  }
  plot(magnitude, type = "l")
  # audioData <- data.frame(timer, magnitude)
  # plot(audioData, type = "l")        
  return(magnitude)
}

parseShimmerData <- function(){
  header <- scan("C:/Users/Kevin/Desktop/ShimmerData.csv", skip = 3, nlines = 1, sep = ",", what = character())         #Too many header lines
  data <- read.csv("C:/Users/Kevin/Desktop/ShimmerData.csv", skip = 4, header = FALSE)
  names(data) <- header
  data[,c(1,3,5:9)] <- list(NULL)
  for(i in seq(1, nrow(data), 1)){                      #ccf() can give errors for unchanging series
    if(data$mVolts[i] == 0){
      data$mVolts[i] <- sample(0:1, 1)
    }
  }
  # data$mSecs <- data$mSecs - data$mSecs[1]            #Shimmer3 timestamp does not begin when recording starts, but when data collection starts
  # plot(data$mVolts, type = "l")
  return(data$mVolts)
}

maxCCF<- function(a,b)                  #Use cross correlation to find lag
{
  d <- ccf(a, b, plot = TRUE, na.action = na.pass, lag.max = size / blockSize)
  cor = d$acf
  lag = d$lag
  res = data.frame(cor,lag)
  res_max = lag[which.max(res$cor)]
  return(res_max)
} 

offset <- round(maxCCF(parseShimmerData(), readAudio()) / shimmerSamplingRate, 3)

if(offset < 0){
  print(paste0("The microphone began recording ", abs(offset), " seconds before the Shimmer3" ))
}else{
  print(paste0("The microphone began recording ", abs(offset), " seconds after the Shimmer3" ))
}

