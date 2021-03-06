#BEST WEBSITE EVER:
#http://mathesaurus.sourceforge.net/octave-r.html

#Include
require(pracma)

getSpo2 <- function(data){

  #Inputs

  ir_total <- dplyr::filter(data, variable %in% c("ir"))$value
  l_total <- length(ir_total)
  t_total <- as.numeric(seconds(unique(data$time)))
  red_total <- dplyr::filter(data, variable %in% c("red"))$value
  #temp_total <- dplyr::filter(data, variable %in% c("temperature"))$value

  #Calculate windowing values
  window_tspan = 5 # in seconds
  window_overlap_ratio = .5 # .5 = 50%
  T_s = (t_total[length(t_total)]-t_total[1])/(length(t_total)-1)
  window_width = floor(window_tspan/T_s)
  window_overlap = floor(window_width*window_overlap_ratio)
  number_of_spo2_points = floor((length(t_total)-window_width)/(window_width-window_overlap))
  
  #Check to make sure that the window width is fine
  #Make sure that there are a decent number of windows and that the windows aren't too small
  if (((4*(window_width-window_overlap)+window_width)>l_total)|(window_width < 5)){
    print('WARNING: Not enough data to calculate SPO2 Values.')
    return(NULL)
  }
  
  #Peak detection constants
  peak_distance = 20
  
  #Molar extinction coefficients of Hemoglobin in water, obtained from an
  #reference. It has been reported in the literature that these values have
  #uncertainties associated with them. There are papers that show some of
  #them. In the end, to make things simpler, we will probably need to pick
  #fixed values that seem more or less ok with several references. The
  #MAX30100 sensor has 'typical' wavelength values of 880 nm for IR and 660
  #for Red.
  #Extionction coefficients
  e_ro <- 319.6 #at 660nm
  e_rd <- 3226.56 #at 660nm
  e_iro <- 1154 #at 880 nm
  e_ird <- 726.44#at 880nm
  
  #Loop through each window and save the following values
  t_final = seq(0,0,length=number_of_spo2_points)
  spo2_final = seq(0,0,length=number_of_spo2_points)
#   spo2_2_final = seq(0,0,length=number_of_spo2_points)
#   spo2_cap_final = seq(0,0,length=number_of_spo2_points)
#   spo2_3_final = seq(0,0,length=number_of_spo2_points)
#   spo2_4_final = seq(0,0,length=number_of_spo2_points)
  spo2_median_final = seq(0,0,length=number_of_spo2_points)
  spo3_median_final = seq(0,0,length=number_of_spo2_points)
  HR_final = seq(0,0,length=number_of_spo2_points)
#   irwin = seq(0,0,length=number_of_spo2_points)
#   redwin = seq(0,0,length=number_of_spo2_points)
#   twin = seq(0,0,length=number_of_spo2_points)
  for (window in seq(1,number_of_spo2_points)) {
    #Get the current window's values
    ind1 = 1 + (window-1)*(window_width-window_overlap)
    ind2 = ind1 + window_width
    t_current = t_total[ind1:ind2]
    ir = ir_total[ind1:ind2]
    red = red_total[ind1:ind2]
    
    #Creating interpolations. I am doing this to have a smooth signal to read
    #from at uniform time intervals. If the signal is sampled accurately, at
    #fixed (more or less) intervals then we should be able to save some time
    #and not do this step, since output from this step is only used to
    #calculate peaks and valleys of the signal.
    #Make a new time scale and interpolate
    line_points = 2*length(t_current)
    t2 = seq(t_current[1],t_current[length(t_current)],length=line_points)
    ir_interp = pchip(t_current, ir, t2)
    red_interp = pchip(t_current,red,t2)
    
    #Find peaks
    ir_peaks_raw = findpeaks(ir_interp,minpeakdistance = peak_distance)
    ir_peaks_values = ir_peaks_raw[,1]
#     ir_peaks_location = ir_peaks_raw[,2]
    red_peaks_raw = findpeaks(red_interp,minpeakdistance = peak_distance)
    red_peaks_values = red_peaks_raw[,1]
#     red_peaks_location = red_peaks_raw[,2]
    
    #Find valleys
    # ir_valleys_raw = findpeaks(-ir_interp,minpeakdistance = peak_distance)
    # ir_valleys_values = -ir_valleys_raw[,1]
#     ir_valleys_location = ir_valleys_raw[,2]
    # red_valleys_raw = findpeaks(-red_interp,minpeakdistance = peak_distance)
    # red_valleys_values = -red_valleys_raw[,1]
#     red_valleys_location = red_valleys_raw[,2]
    
    #Calculate the heart Rate
    tspan = t2[length(t2)]-t2[1]
    HR_ir = 60*length(ir_peaks_values)/tspan
    HR_red = 60*length(red_peaks_values)/tspan
    HR = .5*(HR_ir + HR_red)
    
    #Calculate the AC and DC values for each of the intensities
    I_ir_ac = diff(ir)
    a <- ir[-length(ir)]
    b <- na.omit(lead(ir, 1))
    tempir1 = data.frame(a,b)
    irRatio = I_ir_ac/rowMeans(tempir1)
    
    I_red_ac = diff(red)
    a1 <- red[-length(red)]
    b1 <- na.omit(lead(red, 1))
    tempred1 = data.frame(a1,b1)
    redRatio = I_red_ac/rowMeans(tempred1)
    
    R = redRatio[redRatio != 0 & irRatio != 0]/irRatio[redRatio != 0 & irRatio != 0]
    R = abs(R)
#     R2 = R
    #I_ir_ac = mean(ir_peaks_values) + mean(ir_peaks_values)
    #I_ir_dc = mean(ir_interp)
    #I_red_ac = mean(red_peaks_values) + mean(red_peaks_values)
    #I_red_dc = mean(red_interp)
    
    #Calculate R and spo2
#     R_cap = (I_red_ac*mean(ir_valleys_values))/(I_ir_ac*mean(red_valleys_values))
#     spo2_cap = 98.283+26.871*R_cap-52.887*R_cap^2+10.0002*R_cap^3
   # R = (I_red_ac/I_red_dc)/(I_ir_ac/I_ir_dc)
#    spo2 = 100*(e_rd-R*e_ird)/(R*(e_iro-e_ird)-(e_ro-e_rd))
    spo2_median = 110 - 25*median(R)
    spo3_median = 112.7783-32.811*median(R)
    
#     spo2_2 = 110-25*R
#     spo2_3 = 112.7783-32.811*R
#     spo2_4 = 241.0519*R
    
    
    #Save windowing values
    t_final[window] = t_current[length(t_current)]
#    spo2_final[window] = spo2
#     spo2_2_final[window] = spo2_2
#     spo2_cap_final[window] = spo2_cap
#     spo2_3_final[window] = spo2_3
#     spo2_4_final[window] = spo2_4
    spo2_median_final[window] = spo2_median
    spo3_median_final[window] = spo3_median
    HR_final[window] = HR
  }
  
  final = data.frame(cbind(#t(t(spo2_final)),
#                            t(t(spo2_2_final)),
#                            t(t(spo2_cap_final)),
#                            t(t(spo2_3_final)),
#                            t(t(spo2_4_final)),
                           t(t(spo2_median_final)),
                           t(t(spo3_median_final)),
                           t(t(HR_final)),
                           t(t(t_final))))
#   colnames(final) <- c("spo2", "spo2_2", "spo2_3", "spo2_4", "spo2_cap", "spo2_median", "spo3_median","HR", "time")
  colnames(final) <- c("spo2_median", "spo3_median","HR", "time")
  final$time <- as.POSIXct(as.numeric(final$time), origin = "1970-01-01") 
  return(final)
}