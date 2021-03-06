
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
shinyServer(function(input, output, session) {
  # input: stores the current values of all of the widgets in the app. These values
  # will be saved under the names given to the widget in ui.R
  source("functions/data_cleaning.R")
  source("styles/ggplot_custom_theme.R")
  source("functions/multiplot.R")
  source("functions/getSpo2.R")
  source('functions/computeFrequencyContent.R')

  #------------ Choose a directory to source data ------------#
  shinyDirChoose(input,'file', session = session, roots = c(wd = '/media/yellowjacket/data'))

  #------------ Read and preprocess all the data in dir input$file ------------#
  datasetInput <- reactive({
    if (is.null(input$file)) {
      return(NULL)
    }
    if (!is.null(input$file)) {
      #Full folder path
      data_folder_path = paste(parseDirPath(roots = c(wd = '/media/yellowjacket/data'), input$file))

      #Run CSV Converter
      csv_command <- paste("python ", getwd(),'/utilities/unpack_driver.py ', data_folder_path, sep = "")
      system(csv_command)
      
      #Process data
      unmelted_data <- aggregateData(data_folder_path)
     
      melted_data <- lapply(unmelted_data, function(x){
        melt(x, id.vars = "time")
      })
      
      #melted_data[["Microphone"]] <- unmelted_data[["Microphone"]]
      #Remove all csv and txt files
      rm_csv_command <- paste("rm ",data_folder_path,"/*.csv",sep="")
      rm_txt_command <- paste("rm ",data_folder_path,"/*.txt",sep="")
      system(rm_txt_command)
      system(rm_csv_command)
      
      #Return unmelted
      return(melted_data)
    }
  })
  

  #------------ Allow for time subsetting with a slider dependent upon the ui's timeSlider ----#
  output$slider <- renderUI({
    if (is.null(datasetInput())) {
      return(NULL)
    }
    if (!is.null(datasetInput())) {
      if (input$tabs == "Microphone") {
        return(NULL)}
      inputData <- datasetInput()
      sliderInput("timeSlider",  
                  label = h4("Time"),
                  min=min(inputData[[input$tabs]]$time), max=max(inputData[[input$tabs]]$time), 
                  value=c(min(inputData[[input$tabs]]$time), median(inputData[[input$tabs]]$time)),
                  timeFormat = "%T",
                  animate = TRUE)
    }
    

  })
  
  #------------ Subset data by tab and time slider inputs ----#
  data <- reactive({
    if (is.null(input$timeSlider)) {
      return(NULL)
    }
    if (!is.null(input$timeSlider)) {
      if ( input$tabs != "Microphone") {
        filteredData <- datasetInput()[[input$tabs]] %>%
          dplyr::filter(time >= input$timeSlider[1],
                        time <= input$timeSlider[2])
        return(filteredData) 
      }
      if (input$tabs == "Microphone") {
        data_folder_path <- paste(parseDirPath(roots = c(wd = '/media/yellowjacket/data'), input$file))
        wav_files <- list.files(list.dirs(data_folder_path), pattern = c("*.wav"), full.names =  TRUE)
        wav_names <- c("Mic_10", "Mic_20", "Mic_30", "Mic_40", "Mic_50", "Mic_60") 
        names(wav_files) <- wav_names[1:length(wav_files)]
        mics <- micImport(wav_files[[input$mic_subset]])
        #mics <- lapply(wav_files, function(x) micImport(x))
        #names(mic) <- c("Mic_10", "Mic_20", "Mic_30", "Mic_40", "Mic_50", "Mic_60")
        return(mics)
      } 
    }
    
  }) 
  
  ############  Plots  #################
  
  #---------- IMU1 --------------------#
  output$imu1_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if (is.null(data()))
      (return(NULL))
    if (!is.null(data()))
      plot_data <- data()
    if (input$resample_perct < 1 ) {
      plot_data <- data() %>%
        dplyr::sample_frac(as.numeric(input$resample_perct), replace = FALSE) 
    }
    
    # draw the plot
      if (input$facet == "On"){
      ############# work on microphone data ################
        if (input$free_bird == "On"){
          p <- ggplot(plot_data, aes(x = time, y = value, color = variable, group = variable))+
            geom_line()+
            theme_custom()+
            theme(axis.text.x = element_text(angle = 90))+
            facet_wrap(~variable, scales = "free_y")
          return(p)
        }
        if (input$free_bird == "Off"){
          p <- ggplot(plot_data, aes(x = time, y = value, color = variable, group = variable))+
            geom_line()+
            theme_custom()+
            theme(axis.text.x = element_text(angle = 90))+
            facet_wrap(~variable)
          return(p)
        }
    }
    # draw the plot
      if (input$facet == "Off"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))
        return(p)
      }
    
  })
  
  #---------- IMU2 --------------------#
  output$imu2_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if (is.null(data())) {
      return(NULL)
    }
    if (!is.null(data())) {
      plot_data <- data()
    }
    if (input$resample_perct < 1 ) {
      plot_data <- data() %>%
        dplyr::sample_frac(as.numeric(input$resample_perct), replace = FALSE) 
    }
      
    # draw the plot
    if (input$facet == "On"){
      ############# work on microphone data ################
      if (input$free_bird == "On"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable)
        return(p)
      }
    }
    # draw the plot
    if (input$facet == "Off"){
      ############# work on microphone data ################
      p <- ggplot(plot_data, aes(x = time, y = value, color = variable, group = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
  })
  
  #---------- PulseOx --------------------#
  output$pox_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if (is.null(data())) {
      return(NULL)
    }
    if (!is.null(data())) {
    #Save the data into a variable
    pox_data = data() %>%
        dplyr::group_by(variable) %>%
        dplyr::arrange(time)
    #Get the spo2 values
    spo2_data = getSpo2(pox_data)
    plot_data <- pox_data
    spo2_data_plot <- spo2_data
    if (input$resample_perct < 1 ) {
      plot_data <- pox_data %>%
        dplyr::sample_frac(as.numeric(input$resample_perct), replace = FALSE)
      if(!is.null(spo2_data))
      spo2_data_plot <- spo2_data %>%
        dplyr::sample_frac(as.numeric(input$resample_perct), replace = FALSE) 
    }
    
    # draw the plot
    if (input$facet == "On"){
      if (input$free_bird == "On"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        if(!is.null(spo2_data)){
          melted_spo2_data <- melt(spo2_data_plot, id.vars = "time")
          q <- ggplot(melted_spo2_data, aes(x = time, y = value, color = variable))+
            geom_line()+
            #geom_hline(yintercept=c(90,100), linetype = 'dotted', color = 'red') +
            theme_custom()+
            theme(axis.text.x = element_text(angle = 90))+
            facet_wrap(~variable, scales = "free_y")
        }
        if(is.null(spo2_data)){
          q <- NULL
        }
      }
      if (input$free_bird == "Off"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable)
        if(!is.null(spo2_data)){
          melted_spo2_data <- melt(spo2_data_plot, id.vars = "time")
          q <- ggplot(melted_spo2_data, aes(x = time, y = value, color = variable))+
            geom_line()+
            #geom_hline(yintercept=c(90,100), linetype = 'dotted', color = 'red') +
            theme_custom()+
            theme(axis.text.x = element_text(angle = 90))+
            facet_wrap(~variable)
        }
        if(is.null(spo2_data)){
          q <- NULL
        }
      }
    }
    # draw the plot
    if (input$facet == "Off"){
      ############# work on microphone data ################
      p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      if(!is.null(spo2_data)){
        melted_spo2_data <- melt(spo2_data_plot, id.vars = "time")
        q <- ggplot(melted_spo2_data, aes(x = time, y = value, color = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))
      }
      if(is.null(spo2_data)){
        q <- NULL
      }
    }
    
    return(multiplot(p,q))
    }
  })
  
  #---------- GSR --------------------#
  output$gsr_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if (is.null(data())) {
      return(NULL)
    }
    if (!is.null(data())) {
      plot_data <- data()
    }
    if (input$resample_perct < 1 ) {
      plot_data <- plot_data %>%
        dplyr::sample_frac(as.numeric(input$resample_perct), replace = FALSE) 
    }
    # draw the plot
    if (input$facet == "On"){
  
      if (input$free_bird == "On"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable)
        return(p)
      }
    }
    # draw the plot
    if (input$facet == "Off"){

      p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
    
  })
  
  #---------- Temp1 --------------------#
  output$temp1_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if (is.null(data())) {
      return(NULL)
    }
    if (!is.null(data())) {
      plot_data <- data()
    }
    if (input$resample_perct < 1 ) {
      plot_data <- plot_data %>%
        dplyr::sample_frac(as.numeric(input$resample_perct), replace = FALSE) 
    }
    # draw the plot
    if (input$facet == "On"){
      ############# work on microphone data ################
      if (input$free_bird == "On"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable)
        return(p)
      }
    }
    # draw the plot
    if (input$facet == "Off"){
      ############# work on microphone data ################
      p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
  })
  
  #---------- Temp2 --------------------#
  output$temp2_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if (is.null(data())) {
      return(NULL)
    }
    if (!is.null(data())) {
      plot_data <- data()
    }
    if (input$resample_perct < 1 ) {
      plot_data <- plot_data %>%
        dplyr::sample_frac(as.numeric(input$resample_perct), replace = FALSE) 
    }
    # draw the plot
    if (input$facet == "On"){
      ############# work on microphone data ################
      if (input$free_bird == "On"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable)
        return(p)
      }
    }
    # draw the plot
    if (input$facet == "Off"){
      ############# work on microphone data ################
      p <- ggplot(plot_data, aes(x = time, y = value, color = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
  })
  
  #---------- Mic --------------------#
  
#   output$mic_plot <- renderPlot({
#     if (is.null(data())) {
#             return(NULL)
#           }
#           
#           if (!is.null(data())){
#             left <- data() %>%
#               select(Left, time)
#             right <- data() %>%
#               select(Right, time)
#           }
#     p <- plot_ly(dplyr::sample_frac(left,as.numeric(input$resample_perct), replace = FALSE), x = time, y = Left, name = "Head Mic")
#     return(p)
#   })
  output$mic_plot <- renderPlot({
    if (is.null(data())) {
      return(NULL)
    }
    
    if (!is.null(data())){
      left <- data() %>%
        select(Left, time)
      right <- data() %>%
        select(Right, time)
    }
    
    jeff <- ggplot(left, aes(x = time, y = Left))+
      geom_line(data = dplyr::sample_frac(left, as.numeric(input$resample_perct)/10, replace = FALSE) )+
      theme_custom()+
      theme(axis.text.x = element_text(angle = 90))+
      xlab("Time (ms)")+
      ylab("Amplitude")+
      ggtitle("Left Channel")
    
    gold <- ggplot(right, aes(x = time, y = Right))+
      geom_line(data = dplyr::sample_frac(right, as.numeric(input$resample_perct)/10, replace = FALSE) )+
      theme_custom()+
      theme(axis.text.x = element_text(angle = 90))+
      xlab("Time (ms)")+
      ylab("Amplitude")+
      ggtitle("Right Channel")
    
    if (input$FFT == "On") {
      left_fft <- computeFrequencyContent(left$Left, 44100)
      right_fft <- computeFrequencyContent(right$Right, 44100)
      
      blum <- ggplot(left_fft, aes(y = p, x = freqArray/1000))+
        geom_line(data = dplyr::sample_frac(left_fft, as.numeric(input$resample_perct), replace = FALSE) )+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))+
        xlab("Frequency (kHz)")+
        ylab("Magnitude")
      
      m <- ggplot(right_fft, aes(y = p, x = freqArray/1000))+
        geom_line(data = dplyr::sample_frac(right_fft, as.numeric(input$resample_perct), replace = FALSE) )+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))+
        xlab("Frequency (kHz)")+
        ylab("Magnitude")
      return(multiplot(jeff, gold, blum, m))
    }
    return(multiplot(jeff, gold))
  })
  
})
