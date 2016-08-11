#!/usr/bin/env Rscript

#Get a copy of the command line arguments supplied when the R session was invoked
initial.options <- commandArgs(trailingOnly = FALSE)

#return files only
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])

#get the working directory 
script.basename <- dirname(script.name)

#find the "launch_app.R script"
other.name <- paste(sep="/", script.basename, "install_and_source_dependencies.R")
print(paste("Sourcing",other.name,"from",script.name))

#Launch the app
source(other.name)
shiny::runApp(as.character(script.basename), launch.browser=TRUE)