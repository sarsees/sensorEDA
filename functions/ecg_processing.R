
#' Calculate ECG signal using input from both ECG sensors
#' 
#' @param ecg1 object with column names time and volt
#' @param ecg2 object with column names time and volt
ecg_processing <- function(ecg1, ecg2){
  Hz <- 60 # assuming sampling is at 60Hz
  min_t <- max(min(ecg1$time), min(ecg2$time))
  max_t <- min(max(ecg1$time), max(ecg2$time))
  
  # create vector of time points for evaluating ECG curves
  ts <- seq(from = min_t, to = max_t, length = Hz*(max_t - min_t)) 
  
  # fit each curve with a linear interpolating function
  ecg1_fit <- approxfun(ecg1$time, ecg1$volt)
  ecg2_fit <- approxfun(ecg2$time, ecg2$volt)
  
  # compute fitted values for each curve
  fit_ecg1 <- ecg1_fit(ts)
  fit_ecg2 <- ecg2_fit(ts)
  ecg_diff <- fit_ecg1 - fit_ecg2
  
  res <- data.frame(time = ts, ecg1 = fit_ecg1, ecg2 = fit_ecg2, ecg_diff = ecg_diff)
  return(res)
}

