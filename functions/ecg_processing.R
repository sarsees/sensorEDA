
#' Calculate ECG signal using input from both ECG sensors
#' 
#' @param ecg1 object with column names time and volt
#' @param ecg2 object with column names time and volt
ecg_processing <- function(ecg){
  Hz <- 60 # assuming sampling is at 60Hz
  min_t <- max(min(ecg$time), min(ecg$time))
  max_t <- min(max(ecg$time), max(ecg$time))
  
  # create vector of time points for evaluating ECG curves
  #ts <- seq(from = min_t, to = max_t, length = Hz*(max_t - min_t)) 
  ts <- ecg$time 
  
  # fit each curve with a linear interpolating function
  ecg1_fit <- approxfun(ecg$time, ecg$volt1)
  ecg2_fit <- approxfun(ecg$time, ecg$volt2)
  
  # compute fitted values for each curve
  fit_ecg1 <- ecg1_fit(ts)
  fit_ecg2 <- ecg2_fit(ts)
  ecg_diff <- fit_ecg1 - fit_ecg2
  
  res <- data.frame(time = ts, ecg1 = fit_ecg1, ecg2 = fit_ecg2, ecg_diff = ecg_diff)
  return(res)
}

