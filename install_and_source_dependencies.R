InstalledPackage <- function(package) 
{
  available <- suppressMessages(suppressWarnings(sapply(package, require, quietly = TRUE, character.only = TRUE, warn.conflicts = FALSE)))
  missing <- package[!available]
  if (length(missing) > 0) return(FALSE)
  return(TRUE)
}
CRANChoosen <- function()
{
  return(getOption("repos")["CRAN"] != "@CRAN@")
}
UsePackage <- function(package, defaultCRANmirror = "http://cran.at.r-project.org") 
{
  if(!InstalledPackage(package))
  {
    if(!CRANChoosen())
    {       
      chooseCRANmirror()
      if(!CRANChoosen())
      {
        options(repos = c(CRAN = defaultCRANmirror))
      }
    }
    
    suppressMessages(suppressWarnings(install.packages(package)))
    if(!InstalledPackage(package)) return(FALSE)
  }
  return(TRUE)
}

libraries <-  c("ggplot2", "shiny", "dplyr", "tuneR", "reshape2", "shinyFiles", "stringr", "lubridate", "markdown","pracma","plyr")
for(library in libraries) 
{ 
  if(!UsePackage(library))
  {
    stop("Error!", library)
  }
}

