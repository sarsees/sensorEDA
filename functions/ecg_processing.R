
#' Calculate ECG signal using input from both ECG sensors
#' 
#' @param ecg object with column names time and volt1 and volt2
ecg_processing <- function(ecg){
  ecg_diff <- ecg$volt1 - ecg$volt2
  res <- data.frame(time = ecg$time, ecg1 = ecg$volt1, ecg2 = ecg$volt2, ecg_diff = ecg_diff)
  return(res)
}

