
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

shinyUI(fluidPage(theme = "yeti.css",
  tags$style(type = "text/css",
             ".shiny-output-warning { visibility: hidden; }",
             ".shiny-output-warning:before { visibility: hidden; }"
  ),
  # Application title
  titlePanel(title = div("YellowJacket",
             img(src = "yj_image.jpg", height = 80, width = 80)
             )),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      h3("Sensor Analysis"),
      includeMarkdown("help.md"),
      h4("Select Data Directory"),
      shinyDirButton('file', 'Load Dataset', FALSE),
      # Copy the line below to make a slider range 
      h3("Options"),
      uiOutput("slider"),
#       sliderInput("timeSlider",  
#                   label = h4("Time"),
#                   min = 0, max = 1,
#                   value = c(0,1),
#                   timeFormat = "%T",
#                   animate = TRUE),
#       
      radioButtons("facet",
                   label = h4("Facet On"),
                   choices = list("On" = "On",
                                  "Off" = "Off"),
                   selected = "On"),
      radioButtons("free_bird",
                  label = h4("Free Y Scale"),
                  choices = list("On" = "On",
                            "Off" = "Off"),
                  selected = "On"),
      radioButtons("resample_perct",
                  label = h4("Resample Percentage"),
                  choices = list("0.5%" = 0.005,
                                 "1%" = 0.010,
                                 "25%" = 0.25,
                                 "50%" = 0.50,
                                 "None" = 1),
                  selected = 0.005)
    ),

    # Show a plot of the generated distribution
    mainPanel(
      #Each of the *Output functions require a single argument: a character 
      #string that Shiny will use as the name of your reactive element. Your 
      #users will not see this name. Then buid the object in server.R by 
      #output$text1 in server.R matches textOutput("text1") in ui.R 
      #plotOutput("plot", width = "900px", height = "800px")
      tabsetPanel(id = "tabs", 
                  tabPanel("IMU1", plotOutput("imu1_plot", height = 600)),
                  tabPanel("IMU2", plotOutput("imu2_plot", height = 600)),
                  tabPanel("PulseOx", plotOutput("pox_plot", height = 900)),
                  tabPanel("GSR", plotOutput("gsr_plot", height = 600)),
                  tabPanel("Temp1", plotOutput("temp1_plot", height = 600)),
                  tabPanel("Temp2", plotOutput("temp2_plot", height = 600)),
                  tabPanel("Microphone",
                           fluidPage(
                             radioButtons("mic_subset",
                                          label = h3("Select Recording Period"),
                                          choices = list("10 Min" = "Mic_10",
                                                         "20 Min" = "Mic_20",
                                                         "30 Min" = "Mic_30",
                                                         "40 Min" = "Mic_40",
                                                         "50 Min" = "Mic_50",
                                                         "60 Min" = "Mic_60"),
                                          selected = "Mic_10"),
                             plotOutput("mic_plot", height = 900),
                             hr(),
                             radioButtons("FFT", label = "Perform FFT? CAUTION: This may take a while", choices = list("On" = "On", "Off" = "Off"), selected = "Off")
                           )
                  )
                  
                  )
    )
  )
))
