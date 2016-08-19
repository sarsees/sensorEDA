computeFrequencyContent <- function(one_channel, sampling_rate){
  #' see http://samcarcagno.altervista.org/blog/basic-sound-processing-r/
  #'@param one_channel: one channel of an audio wave converted to floating point
  #'@param sampling_rate: wav file sampling frequency
  
  n <- length(one_channel)
  two_power <- 2^(ceiling(log(length(n))/log(2)))
  for_fft <- rep(0, two_power)
  for_fft[1:n] <- one_channel
  new_n <- length(for_fft)
  p <- fft(for_fft)
  #first half since the second half is a mirror image of the first
  nUniquePts <- ceiling((new_n+1)/2)
  p <- p[1:nUniquePts] 
  #take the absolute value, or the magnitude
  p <- abs(p) 
  p <- p / new_n #scale by the number of points so that
  # the magnitude does not depend on the length 
  # of the signal or on its sampling frequency  
  #p <- p^2  # square it to get the power 
  
  # multiply by two (see technical document for details)
  # odd nfft excludes Nyquist point
  if (new_n %% 2 > 0){
    p[2:length(p)] <- p[2:length(p)]*2 # we've got odd number of points fft
  } else {
    p[2: (length(p) -1)] <- p[2: (length(p) -1)]*2 # we've got even number of points fft
  }
  freqArray <- (0:(nUniquePts-1)) * (sampling_rate / new_n) #  create the frequency array 
  return(data.frame(freqArray, p))
} 
