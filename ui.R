
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(ggplot2)
library(reshape2)
library(shinyFiles)
shinyUI(fluidPage(

  # Application title
  titlePanel(title = div(
             img(src = "yj_image.jpg", height = 80, width = 80),
             "YellowJacket")),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      h3("Sensor Analysis"),
      helpText("Choose a simulated activity and the 
               timespan in which to view the activity's sensor outputs."),
      # Copy the line below to make a slider range 
      uiOutput("slider"),
      shinyDirButton('file', 'Load Dataset', 'Please select a dataset', FALSE),
      #directoryInput('directory', label = h3('Select a Directory'), value = 'COW007/2016_07_11_22_27_40/'),
#       fileInput('sensor_file', 'Choose Sensor Directory',
#                 accept=c('text/csv', 
#                          'text/comma-separated-values,text/plain', 
#                          '.csv')),
      radioButtons("facet",
                   label = h3("Facet On"),
                   choices = list("On" = "On",
                                  "Off" = "Off"),
                   selected = "On"),
      radioButtons("free_bird",
                  label = h3("Free Y Scale"),
                  choices = list("On" = "On",
                            "Off" = "Off"),
                  selected = "On")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      #Each of the *Output functions require a single argument: a character 
      #string that Shiny will use as the name of your reactive element. Your 
      #users will not see this name. Then buid the object in server.R by 
      #output$text1 in server.R matches textOutput("text1") in ui.R 
      #plotOutput("plot", width = "900px", height = "800px")
      tabsetPanel(id = "tabs", 
                  tabPanel("IMU1", value = "IMU1", plotOutput("imu1_plot", height = 600)),
                  tabPanel("IMU2", value = "IMU2", plotOutput("imu2_plot")),
                  tabPanel("PulseOx", value = "PulseOx", plotOutput("pox_plot")),
                  tabPanel("GSR", value = "GSR", plotOutput("gsr_plot")),
                  tabPanel("Temp1", value = "Temp1", plotOutput("temp1_plot")),
                  tabPanel("Temp2", value = "Temp2", plotOutput("temp2_plot")),
                  tabPanel("Microphone", value = "Microphone", plotOutput("mic_plot"))
                  )
    )
  )
))
