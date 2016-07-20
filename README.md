#Installation
## Linux
### R
From the terminal add an R repositry using the following command

`sudo echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | sudo tee -a /etc/apt/sources.list`

Then add R to the Ubuntu Keyring  

`gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9`

and sudo add

`gpg -a --export E084DAB9 | sudo apt-key add -`

finally install base R 

`sudo apt-get update`  
`sudo apt-get install r-base r-base-dev`

### RStudio
It's easy enough to install the updated RStudio from the terminal. For the preview release just run:

`sudo apt-get install gdebi-core`  
`wget https://s3.amazonaws.com/rstudio-dailybuilds/rstudio-0.99.1251-amd64.deb`  
`sudo gdebi -n rstudio-0.99.1251-amd64.deb`  
`rm rstudio-0.99.1251-amd64.deb`

###Shiny
There are a few dependencies that must be installed for the app to run. The script `install_and_source_dependencies.R` will install and source any dependencies that have not currently been installed or loaded into the environment.

#Running the App

