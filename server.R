
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(ggplot2)
library(reshape2)
library(shinyFiles)
shinyServer(function(input, output, session) {
  # input: stores the current values of all of the widgets in the app. These values
  # will be saved under the names given to the widget in ui.R
  source("data_cleaning.R")
  source("ggplot_custom_theme.R")

  shinyDirChoose(input,'file', session=session,roots=c(wd='.'))
  datasetInput <- reactive({
    if (is.null(input$file)){
      #unmelted_data <- aggregateData(data_path = "./data/2016_7_11_19_0_16/")
      #melted_data <- lapply(unmelted_data, function(x) melt(x, id.vars = "time"))
      return(NULL)
    }
    if (!is.null(input$file)){
      #Full folder path
      data_folder_path = paste(parseDirPath(roots=c(wd=getwd()),input$file))
      
      #Run CSV Converter
      csv_command <- paste("python ", getwd(),'/utilities/unpack_driver.py ',data_folder_path,sep="")
      system(csv_command)
      
      #Process data
      unmelted_data <- aggregateData(parseDirPath(roots=c(wd='.'), input$file))
      melted_data <- lapply(unmelted_data, function(x) melt(x, id.vars = "time"))
      
      #Remove all csv and txt files
      rm_csv_command <- paste("rm ",data_folder_path,"/*.csv",sep="")
      rm_txt_command <- paste("rm ",data_folder_path,"/*.txt",sep="")
      system(rm_txt_command)
      system(rm_csv_command)
      
      #Return unmelted
      return(melted_data)
    }
  })
  output$slider <- renderUI({
    sliderInput("timeSlider",  
                label = h4("Time"),
                min=min(datasetInput()[[input$tabs]]$time), max=max(datasetInput()[[input$tabs]]$time), 
                value=c(min(datasetInput()[[input$tabs]]$time), median(datasetInput()[[input$tabs]]$time)),
                timeFormat = "%T",
                animate = TRUE)

  })
  data <- reactive({
#     if (is.null(datasetInput()))
#       return(NULL)
      filteredData <- datasetInput()[[input$tabs]] %>%
        filter(time >= input$timeSlider[1] ,
               time <= input$timeSlider[2] ) %>%
        sample_frac(as.numeric(input$resample_perct), replace = FALSE)
    filteredData
  })
  
  output$imu1_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if (is.null(datasetInput()))
      (return(NULL))
    if (!is.null(datasetInput()))
    # draw the plot
      if (input$facet == "On"){
      ############# work on microphone data ################
        if (input$free_bird == "On"){
          p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
            geom_line()+
            theme_custom()+
            theme(axis.text.x = element_text(angle = 90))+
            facet_wrap(~variable, scales = "free_y")
          return(p)
        }
        if (input$free_bird == "Off"){
          p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
            geom_line()+
            theme_custom()+
            theme(axis.text.x = element_text(angle = 90))+
            facet_wrap(~variable)
          return(p)
        }
    }
    # draw the plot
      if (input$facet == "Off"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))
        return(p)
      }
    
  })
  output$imu2_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if(is.null(datasetInput()))
      (return(NULL))
    if (!is.null(datasetInput()))
    # draw the plot
    if (input$facet == "On"){
      ############# work on microphone data ################
      if (input$free_bird == "On"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
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
      p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
  })
  output$pox_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if(is.null(datasetInput()))
      (return(NULL))
    if (!is.null(datasetInput()))
    # draw the plot
    if (input$facet == "On"){
      ############# work on microphone data ################
      if (input$free_bird == "On"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
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
      p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
  })
  output$gsr_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if(is.null(datasetInput()))
      (return(NULL))
    if (!is.null(datasetInput()))
    # draw the plot
    if (input$facet == "On"){
      ############# work on microphone data ################
      if (input$free_bird == "On"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
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
      p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
  })
  output$temp1_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if(is.null(datasetInput()))
      (return(NULL))
    if (!is.null(datasetInput()))
    # draw the plot
    if (input$facet == "On"){
      ############# work on microphone data ################
      if (input$free_bird == "On"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
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
      p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
  })
  output$temp2_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if(is.null(datasetInput()))
      (return(NULL))
    if (!is.null(datasetInput()))
    # draw the plot
    if (input$facet == "On"){
      ############# work on microphone data ################
      if (input$free_bird == "On"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
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
      p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
  })
  output$mic_plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    if (!is.null(datasetInput()))
    
    # draw the plot
    if (input$facet == "On"){
      ############# work on microphone data ################
      if (input$free_bird == "On"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
          geom_line()+
          theme_custom()+
          theme(axis.text.x = element_text(angle = 90))+
          facet_wrap(~variable, scales = "free_y")
        return(p)
      }
      if (input$free_bird == "Off"){
        p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
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
      p <- ggplot(data(), aes(x = time, y = value, color = variable, group = variable))+
        geom_line()+
        theme_custom()+
        theme(axis.text.x = element_text(angle = 90))
      return(p)
    }
  })
  
})
