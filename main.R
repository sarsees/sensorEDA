library(shiny)
library(shinyFiles)

#Get the main.R directory
cwd = dirname(sys.frame(1)$ofile)
      
#Run the app
shiny::runApp(cwd)