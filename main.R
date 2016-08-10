#!/usr/bin/env Rscript
initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
script.basename <- dirname(script.name)
other.name <- paste(sep="/", script.basename, "launch_app.R")
print(paste("Sourcing",other.name,"from",script.name))
source(other.name)