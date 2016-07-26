
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
    if (is.null(input$file))
      return(aggregateData(data_path = "./data/2016_7_11_19_0_16/"))
    return(aggregateData(parseDirPath(roots=c(wd='.'), input$file)))
  })
  output$slider <- renderUI({
    sliderInput("timeSlider",  
                label = h4("Time"),
                min=min(datasetInput()[["IMU1"]]$time), max=max(datasetInput()[["IMU1"]]$time), 
                value=c(min(datasetInput()[["IMU1"]]$time), max(datasetInput()[["IMU1"]]$time)))
  })
  data <- reactive({
    filteredData <- datasetInput()
    if(!is.null(input$timeSlider) & !is.null(input$sensor)){
      filteredData <- filteredData[[as.character(input$sensor)]] %>%
        filter(time >= input$timeSlider[1] ,
               time <= input$timeSlider[2] )
    }
    filteredData
  })
  
  output$plot <- renderPlot({
    # generate plot data based on input$activity from ui.R
    plot_data <- melt(data(), id.vars = "time")

    # draw the plot
    if (input$facet == "On"){
############# work on microphone data ################
      if (input$sensor == "Microphone"){
        p <- tuneR::plot(data())
        return(p)
      }else{
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
    }
############# work on microphone data ################
    if (input$facet == "Off"){
      ############# work on microphone data ################
      if (input$sensor == "Microphone"){
        p <- tuneR::plot(data())
        return(p)
      }else{
          p <- ggplot(plot_data, aes(x = time, y = value, color = variable, group = variable))+
            geom_line()+
            theme_custom()+
            theme(axis.text.x = element_text(angle = 90))
          return(p)
        }
      }
  })

})
