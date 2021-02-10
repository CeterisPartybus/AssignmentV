#' ---
#' title: "Assignment V"
#' subtitle: "GitHub and the ticketmaster.com API"
#' author: "Isabell Goebel (Student ID: 5374775)"
#' output: 
#'   html_document:
#'      theme: lumen
#'      highlight: haddock
#'      code_download: true  # download button for code (upper right corner)
#'      toc: true  # table of contents with links
#'      toc_depth: 3  # depth of toc, i.e. subchapters
#'      toc_float:  # toc on the left (always visible, also when scrolling)
#'         collapsed: false  # otherwise not full toc (subchapters) shown
#'      number_sections: true  # numbers sections
#' runtime: shiny
#' ---
#' 
#' <br>
#' 
#' R Version: `r version$version.string`  
#' Last updated: `r Sys.time()`
#' 
#' <br>
#' 
#' I worked with no one. I hereby assure that my submission is in line with the 
#' *Code of Conduct* outlined on the lecture slides.
#' 
#' ------------------------
#' 
#' <details><summary>Task</summary>
#' 
#' In this assignment, you will apply what you have learned about APIs and about 
#' version control with Git(Hub).
#' First, you will acquire data about event venues using the API provided by ticketmaster.com. 
#' You will then use the geospatial data to visualize the extracted data on a map. 
#' Finally, you will repeat the same steps for a different country. 
#' It is further required that the entire project and its version history is documented 
#' in your personal GitHub repository.
#' 
#' 1. Setting up a new GitHub repository
#' 
#' * Register on github.com in case you have not done this already.
#' * Initialize a new public repository for this assignment on GitHub.
#' * For the following exercises of this assignment, follow the standard Git workflow 
#'   (i.e., pull the latest version of the project to your local computer, then stage, 
#'   commit, and push all the modifications that you make throughout the project). 
#'   Every logical programming step should be well documented on GitHub with a meaningful 
#'   commit message, so that other people (e.g., your course instructor) can follow 
#'   understand the development history. 
#'   You can to do this either using Shell commands or a Git GUI of your choice.
#' * In the HTML file that you submit, include the hyperlink to the project repository 
#'   (e.g., https://github.com/yourUserName/yourProjectName)
#'  
#'</details>  
#' 
#' ------------------------
#'
#+ preamble, message = FALSE
# clear current workspace
remove(list = ls())
# directory
#main<-file.path("/Users/isabellheinemann/Documents/UniTübingen/2020/0_DataScienceProject/assignments/assignment4")
#' 
#'<details><summary>Chunk Options / Directory</summary>
#+ setup
# global code chunk options
knitr::opts_chunk$set(echo=TRUE,  # display code
                      options(width=80),  # line length 80 characters
                      tidy=TRUE, tidy.opts=list(width.cutoff=80),  # tidy code
                      # set directory
                      root.dir="/Users/isabellheinemann/Desktop/AssignmentV")
#'</details>
#'
#'
#'<details><summary>Packages and Libraries</summary>
#+ packages, message = FALSE
# Check if packages have been installed before; if not, install them
if (!require("readr")) install.packages("readr")
if (!require("data.table")) install.packages("data.table")
if (!require("tidyr")) install.packages("tidyr")
if (!require("dplyr")) install.packages("dplyr")
if (!require("knitr")) install.packages("knitr")
if (!require("formatR")) install.packages("formatR")
if (!require("lme4")) install.packages("lme4")
if (!require("lattice")) install.packages("lattice")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("arm")) install.packages("arm")
if (!require("broom")) install.packages("broom")
if (!require("shiny")) install.packages("shiny")
if (!require("sjPlot")) install.packages("sjPlot")

# call package libraries
library(readr)
library(data.table)
library(tidyr)
library(dplyr)
library(knitr)
library(formatR)
library(lme4)
library(lattice)
library(ggplot2)
library(arm)
library(broom)
library(shiny)
library(sjPlot)

#'</details>
#' 
#' ------
#' 
#+ spin, echo = FALSE, results = 'hide'
# To receive .Rmd file of this file
spin("Goebel_Isabell_AssignmentV.R", knit = FALSE)
#' 
#' 
#' 
#' My GitHub repository: https://github.com/IsabellGoebel/AssignmentV
#' 
#' 
#' 
#' 
#' 
#' 
#' <br><br>
#' 
#' <a href="#top">Back to top</a>