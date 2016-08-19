computeFrequencyContent <- function(one_channel, sampling_rate){
  #' see http://samcarcagno.altervista.org/blog/basic-sound-processing-r/
  #'@param one_channel: one channel of an audio wave converted to floating point
  #'@param sampling_rate: wav file sampling frequency
  
  n <- length(one_channel)
  p <- fft(one_channel)
  #first half since the second half is a mirror image of the first
  nUniquePts <- ceiling((n+1)/2)
  p <- p[1:nUniquePts] 
  #take the absolute value, or the magnitude
  p <- abs(p) 
  p <- p / n #scale by the number of points so that
  # the magnitude does not depend on the length 
  # of the signal or on its sampling frequency  
  p <- p^2  # square it to get the power 
  
  # multiply by two (see technical document for details)
  # odd nfft excludes Nyquist point
  if (n %% 2 > 0){
    p[2:length(p)] <- p[2:length(p)]*2 # we've got odd number of points fft
  } else {
    p[2: (length(p) -1)] <- p[2: (length(p) -1)]*2 # we've got even number of points fft
  }
  freqArray <- (0:(nUniquePts-1)) * (sampling_rate / n) #  create the frequency array 
  return(data.frame(freqArray, p))
} 
