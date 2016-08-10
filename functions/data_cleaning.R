require(dplyr)
require(ggplot2)
require(reshape2)
require(shinyFiles)
require(stringr)
require(tuneR)
require(lubridate)
options(digits.secs=6)

micImport <- function(sensor_data_path){
  audioWave <- readWave(sensor_data_path)
  time_span <- length(audioWave@left)/audioWave@samp.rate
  results <- data.frame(Left = audioWave@left, Right = audioWave@right, time = seq(from = 0,  to = time_span, along.with = audioWave@left))
  return(results)
}
dataImport <- function(sensor_data_path){
  data <- read.csv(sensor_data_path, header = TRUE, colClasses=c(time = "character"))
  data$time <- as.POSIXct(as.numeric(data$time), origin = "1970-01-01")
  #data$time <- fast_strptime(as.character(data$time), "%Y-%m-%d %H:%M:%OS")
#   #p <- readLines(sensor_data_path)
#   fileName <- sensor_data_path
#   temp <- readChar(fileName, file.info(fileName)$size)
#   sections <- strsplit(temp, split = "!@#/n")
#   
#   end_meta <- which(grepl("!@#", p))
#   if (length(end_meta) > 1) {
#     end_meta <- end_meta[2]
#   }
#     
#   header_indicator <- end_meta + 1
#   headerNames <- gsub("\t", replacement = "", p[header_indicator])
#   headerNames <- gsub("0", replacement = "", headerNames)
#   headerNames <- gsub("_", replacement = "", headerNames)
#   headerNames <- gsub(" ", replacement = "", headerNames)
#   data <- data.frame(do.call('rbind', strsplit(p[(end_meta + 1) : length(p)], split = ",", fixed = TRUE)), stringsAsFactors = FALSE)
#   colnames(data) <- unlist(strsplit(headerNames, split = ","))
#   data <- data.frame(lapply(data, function(x) as.numeric(x)))
  return(data)
}

aggregateData <- function(data_path){
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
    if (x[["sensor_type"]] == "Microphone") {
      return(try(micImport(x[["file_path"]])))
    }
    if (x[["sensor_type"]] == "Undecided") {
      return(try(warning("Unrecognized file formating. Sensor data not imported")))
    }
    else {dataImport(x[["file_path"]])}
  })
  names(data_read) <- sensor_file_names[["sensor_type"]]
  
  return(data_read)
}




                   
                   
                   