
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

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
      radioButtons("sensor",
                         label = h3("Display Sensor"),
                         choices = list("IMU 1" = "IMU1",
                                        "IMU 2" = "IMU2",
                                        "GSR" = "GSR",
                                        "Pulse Ox" = "PulseOx",
                                        "Temperature 1" = "Temp1",
                                        "Temperature 2" = "Temp2",
                                        "Microphone" = "Microphone"),
                         selected = "IMU1"),
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
      plotOutput("plot", width = "900px", height = "800px")
    )
  )
))
