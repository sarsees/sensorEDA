library(dplyr)
library(ggplot2)
library(reshape2)
library(shinyFiles)
library(stringr)
library(tuneR)
imuImport <- function(sensor_data_path, lorenzoOrdered = TRUE, meta_included = TRUE){
  if (meta_included) {
    formated_IMU_sensor_data <- read.csv(sensor_data_path, header = FALSE, skip = 13)
  }
  if (!(meta_included)) {
    formated_IMU_sensor_data <- read.csv(sensor_data_path, header = FALSE)
  }
  # Rename the columns to contain sensor type information
  if (lorenzoOrdered) {
    colnames(formated_IMU_sensor_data) <- c("X_Accel", "Y_Accel", "Z_Accel",
                                            "X_Magno", "Y_Magno", "Z_Magno",
                                            "X_Gyro", "Y_Gyro", "Z_Gyro", "Time_Sec")
  }
  else {warning("Data columns may be unnamed")}
  
  #remove any columns of all NAs
  formated_IMU_sensor_data <- formated_IMU_sensor_data[, colSums(is.na(formated_IMU_sensor_data)) != nrow(formated_IMU_sensor_data)]
  
  return(formated_IMU_sensor_data)
}
temperatureImport <- function(sensor_data_path, lorenzoOrdered = TRUE, meta_included = TRUE){
  if (!(meta_included)){
    temperature_sensor_data <- read.csv(sensor_data_path, header = FALSE)
  }
  if (meta_included){
    temperature_sensor_data <- read.csv(sensor_data_path, header = FALSE, skip = 12)
  }
  # Rename the columns with headers
  if (lorenzoOrdered) {
    colnames(temperature_sensor_data) <- c("Temp", "Time_Sec")
  }
  else {warning("Data columns may be unnamed")}
  #remove any columns of all NAs
  temperature_sensor_data <- temperature_sensor_data[, colSums(is.na(temperature_sensor_data)) != nrow(temperature_sensor_data)]
  
  return(temperature_sensor_data)
}
pulseOxImport <- function(sensor_data_path, lorenzoOrdered = TRUE, meta_included = TRUE){
  if (meta_included) {
    pOx_sensor_data <- read.csv(sensor_data_path, header = FALSE, skip = 13)
  }
  if (!(meta_included)) {
    pOx_sensor_data <- read.csv(sensor_data_path, header = FALSE)
  }
  # Rename the columns to contain sensor type information
  if (lorenzoOrdered) {
    colnames(pOx_sensor_data) <- c("IR_n", "RED_n", "Max_temp", "Time_Sec")
  }
  else {warning("Data columns may be unnamed")}
  
  #remove any columns of all NAs
  pOx_sensor_data <- pOx_sensor_data[, colSums(is.na(pOx_sensor_data)) != nrow(pOx_sensor_data)]
  
  return(pOx_sensor_data)
}
gsrImport <- function(sensor_data_path, lorenzoOrdered = TRUE, meta_included = TRUE){
  if (meta_included) {
    gsr_sensor_data <- read.csv(sensor_data_path, header = FALSE, skip = 12)
  }
  if (!(meta_included)) {
    gsr_sensor_data <- read.csv(sensor_data_path, header = FALSE)
  }
  # Rename the columns to contain sensor type information
  if (lorenzoOrdered) {
    colnames(gsr_sensor_data) <- c("V_an", "V_bn", "V_cn", "Time_Sec")
  }
  else {warning("Data columns may be unnamed")}
  
  #remove any columns of all NAs
  gsr_sensor_data <- gsr_sensor_data[, colSums(is.na(gsr_sensor_data)) != nrow(gsr_sensor_data)]
  
  return(gsr_sensor_data)
}
micImport <- function(sensor_data_path){
  audioWave <- readWave("~/Documents/Projects/YellowJacket/sensorEDA/working/2016_07_11_22_27_40_MIC_COW129.wav")
  return(audioWave)
}

aggregateData <- function(data_path = "data-raw/simulated_tests/raw/four_leg_walk/"){
  sensor_file_names <-c(list.files(list.dirs(data_path), pattern = c("*.csv"), full.names =  TRUE),
                        list.files(list.dirs(data_path), pattern = c("*.wav"), full.names =  TRUE))%>%
    data.frame(file_path = ., stringsAsFactors = FALSE) %>%
    #dplyr::mutate(activity = str_split_fixed(file_path, pattern = "/", n = 6)[,5]) %>%
    dplyr::mutate(sensor_type = ifelse(grepl("BNO055_N1", file_path), yes = "IMU1", no = "Undecided"))
  sensor_file_names[which(grepl("BNO055_N2", sensor_file_names$file_path)), "sensor_type"] <- "IMU2"
  sensor_file_names[which(grepl("ADS1015", sensor_file_names$file_path)), "sensor_type"] <- "GSR"
  sensor_file_names[which(grepl("MAX30100", sensor_file_names$file_path)), "sensor_type"] <- "PulseOx"
  sensor_file_names[which(grepl("MCP9808_N1", sensor_file_names$file_path)), "sensor_type"] <- "Temp1"
  sensor_file_names[which(grepl("MCP9808_N2", sensor_file_names$file_path)), "sensor_type"] <- "Temp2"
  sensor_file_names[which(grepl("wav", sensor_file_names$file_path)), "sensor_type"] <- "Microphone"
  data_read <- apply(sensor_file_names, 1, function(x){
    if (x[["sensor_type"]] %in% c("IMU1", "IMU2")) {
      return(try(imuImport(x[["file_path"]])))
    }
    if (x[["sensor_type"]] %in% c("Temp1", "Temp2")) {
      return(try(temperatureImport(x[["file_path"]]), silent = TRUE))
    } 
    if (x[["sensor_type"]] == "GSR") {
      return(try(gsrImport(x[["file_path"]])))
    }
    if (x[["sensor_type"]] == "PulseOx") {
      return(try(pulseOxImport(x[["file_path"]])))
    }
    if (x[["sensor_type"]] == "Microphone") {
      return(try(micImport(x[["file_path"]])))
    }
  })
  names(data_read) <- sensor_file_names[["sensor_type"]]
  
  return(data_read)
}
#simulation <- aggregateData()

