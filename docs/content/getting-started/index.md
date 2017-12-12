---
date: 2016-04-23T15:57:19+02:00
menu: "main"
title: Getting Started
weight: 10
---

## Installation

### Install R and RStudio

The first dependency of the project is R because everything is made on it. All the development was done on a unix compatible system so you can expect some inconsistencies if you are gonna use this project on another box.

```
# Example using a Ubuntu Trusty box

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu trusty/'
sudo apt-get update
sudo apt-get install r-base

sudo apt-get install gdebi-core
wget https://download1.rstudio.org/rstudio-1.1.383-i386.deb
sudo gdebi rstudio-1.1.383-i386.deb

# Using macOS

brew install r
brew cask install rstudio
```

### Install Shiny

Shiny is a web framework for R and you can install it using the standard method for getting the packages.

```
install.packages("shiny")
```

### Install project dependencies

Once you have the standard environment to start shiny apps the next step is adding the related packages to the project.

```
install.packages("shinydashboard",
                 "leaflet",
                 "dplyr",
                 "spdplyr",
                 "viridis",
                 "reshape2")
```

#### Description of packages

- _shinydashboard_ builds the UI and integrates the Twitter Bootstrap framework using a AdminLTE control panel template.
- _leaflet_ is the new standard method to show maps on the web. In the app adds the legends, layer controls, tiles from mapbox and shapes.
- _dplyr_ permits the operations over data.frames.
- _spdplyr_ adds support for spatial polygons to dplyr.
- _viridis_ is a nice color palette with good contrast.
- _reshape2_ add more operations over data.frames.

Now you're ready to run the app locally! Just press the "Run app!" button in RStudio and boom! 


