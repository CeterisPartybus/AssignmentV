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
#'
#' 2. Getting to know the API
#' 
#' * Visit the documentation website for the API provided by ticketmaster.com
#' * Familiarize yourself with the features and functionalities of the Ticketmaster 
#'   Discovery API. 
#'   Have a particular look at rate limits.
#' * Whithin the scope of this assignment, you do not have to request your own API key. 
#'   Instead retrieve a valid key from the API Explorer. 
#'   This API key enables you to perform the GET requests needed throughout this assignment.
#' * Even though this API key is not secret per se (it is publicly visible on the 
#'   API Explorer website), please comply to the common secrecy practices discussed 
#'   in the lecture and the tutorial: Treat the API key as a secret token. 
#'   Your API key I key should neither appear in the code that you are submitting 
#'   nor in your public GitHub repository.
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
#' # GitHub
#' 
#' My GitHub repository: https://github.com/IsabellGoebel/AssignmentV
#' 
#' 
#' 
#' # API
#' 
#' 
#' All API calls follow this format: 
#' https://app.ticketmaster.com/{package}/{version}/{resource}.json?apikey=**{API key}
#' 
#' 
#' **Rate Limit**
#' 
#' * All API keys are issued with a default quota of 5000 API calls per day and 
#'   rate limitation of 5 requests per second. 
#' * We do increase rate limits on case-by-case basis. In order to increase the 
#'   rate limit for a particular application, we need to verify the following:
#'   * The application is in compliance with our Terms of Service
#'   * The application is in compliance with our branding guide
#'   * The application is representing the Ticketmaster data properly
#'   
#'   Once these three criteria are verified, the rate limit is increased to what 
#'   Ticketmaster and the developer determine to be appropriate.
#' 
#' 
#' **Rate Limit Info in Response Header**
#' 
#' You can see how much of your quota has been used by checking the following response headers:
#' 
#' * Rate-Limit: What’s the rate limit available to you. The default is 5000.
#' * Rate-Limit-Available: How many requests are available to you. This will be 5000 minus all the requests you’ve done.
#' * Rate-Limit-Over: How many requests over your quota you’ve made.
#' * Rate-Limit-Reset: The UTC date and time of when your quota will be reset.
#' * `curl -I 'http://app.ticketmaster.com/discovery/v1/events.json?keyword=Queen&apikey=xxx'`
#' 
#' 
#' API Response When Quota is Reached
#' 
#' When you do go over your quota, you will get an HTTP status code 429 indicating 
#' you’ve made too many requests. 
#' The following is the API response you will receive:
#' 
#' `{
#'     "fault": {
#'          "faultstring": "Rate limit quota violation. Quota limit  exceeded. Identifier : {apikey}",
#'                "detail": {
#'                       "errorcode": "policies.ratelimit.QuotaViolation"
#'   }}}`
#' 
#' 
#' **API Explorer**
#' 
#' see https://developer.ticketmaster.com/api-explorer/v2/
#' 
#' Source key from file key.R into this file
#+
source("key.R")
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' <br><br>
#' 
#' <a href="#top">Back to top</a>