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
#' 
#' 3. Interacting with the API - the basics
#' 
#' * Load the packages needed to interact with APIs using R.
#' * Perform a first GET request, that searches for event venues in Germany (countryCode = "DE"). 
#'   Extract the content from the response object and inspect the resulting list. 
#'   Describe what you can see.
#' * Extract the name, the city, the postalCode and address, as well as the url 
#'   and the longitude and latitude of the venues to a data frame.
#'   
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
if (!require("tidyr")) install.packages("tidyr")
if (!require("dplyr")) install.packages("dplyr")
if (!require("knitr")) install.packages("knitr")
if (!require("formatR")) install.packages("formatR")
if (!require("jsonlite")) install.packages("jsonlite")
if (!require("rvest")) install.packages("rvest")
if (!require("xml2")) install.packages("xml2")
if (!require("httr")) install.packages("httr")
if (!require("rlist")) install.packages("rlist")
if (!require("ggplot2")) install.packages("ggplot2") 

# call package libraries
library(tidyr)
library(dplyr)
library(knitr)
library(formatR)
library(jsonlite)
library(rvest)
library(xml2)
library(httr)
library(rlist)
library(ggplot2)

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
#' My GitHub repository: https://github.com/CeterisPartybus/AssignmentV
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
#' # Interacting with the API - the basics
#' 
#' 
#' * Load the packages needed to interact with APIs using R: see preamble
#' 
#' * Perform a first GET request, that searches for event venues in Germany (countryCode = "DE"). 
#'   Extract the content from the response object and inspect the resulting list. 
#'   Describe what you can see.
#+
# since the country will vary
country <- "DE"

# locale : The locale in ISO code format. Multiple comma-separated values can be provided. 
# When omitting the country part of the code (e.g. only 'en' or 'fr') then the 
# first matching locale is used. When using a '*' it matches all locales. '*' can 
# only be used at the end (e.g. 'en-us,en,*')

cntry <- c("DE", "DK")

for (c in cntry){
  #print(c)
  #nam <- paste("cntry", c, sep = "")
  #paste("cntry2", c, sep = "")
  #assign(paste0('ctry', c), NULL)
}

# generate response object
ticketmaster <- GET("https://app.ticketmaster.com/discovery/v2/venues.json?",
                      query = list(apikey = key,
                                   countryCode = country,
                                   locale = "*"))

# show content & status code of object
  ticketmaster

# extract content of response object
  venuesDE <- jsonlite::fromJSON(content(ticketmaster, as="text"))

# inspect content
  glimpse(venuesDE)

#'
#' The extracted list consist of 3 elements.
#' In `_embedded$venues` there is a data frame consisting of 20 rows of 19 columns.
#' Further, `_links` contains links to the first, next, and last page found on the
#' main page "/discovery/v2/venues.json", from where I extracted the data.
#' Lastly, `page` contains information on the size 
#' (`r as.numeric(venuesDE$page$size)`), total elements 
#' (`r as.numeric(venuesDE$page$totalElements)`), 
#' total pages 
#' (`r as.numeric(venuesDE$page$totalPages)`) and current page number
#' (`r as.numeric(venuesDE$page$number)`) of the extracted data. 
#'
#'
#'
#' * Extract the name, the city, the postalCode and address, as well as the url 
#'   and the longitude and latitude of the venues to a data frame.
#'
#+
# venue content
venue_df <- data.frame(venuesDE$'_embedded'$venues)
glimpse(venue_df)

# extract variables from data frame 'venue_df'
vars <- c("name", "postalCode", "url")

# combine in new data frame 'venue_data'
venue_data <- data.frame(venue_df[vars])

# add variables from data frame within data frame 'venue_df'
venue_data$city = venue_df[["city"]][["name"]]
venue_data$address = venue_df[["address"]][["line1"]]
venue_data$longitude = venue_df[["location"]][["longitude"]]
venue_data$latitude = venue_df[["location"]][["latitude"]]

# adjust order
order <- c("name", "city", "postalCode", "address", "url", "longitude", "latitude")
venue_data <- venue_data[, order]

# check new data frame
glimpse(venue_data)

#' 
#' 
#' 
#' 
#' # Interacting with the API - advanced
#' 
#' * Have a closer look at the list element named page. 
#'   Did your GET request from exercise 3 return all event locations in Germany? 
#'   Obviously not - there are of course much more venues in Germany than those 
#'   contained in this list. 
#'   Your GET request only yielded the first results page containing the first 20 
#'   out of several thousands of venues.
#'   
#' * Check the API documentation under the section Venue Search. 
#'   How can you request the venues from the remaining results pages?
#'   
#' * Write a for loop that iterates through the results pages and performs a GET 
#'   request for all venues in Germany. 
#'   After each iteration, extract the seven variables name, city, postalCode, 
#'   address, url, longitude, and latitude. 
#'   Join the information in one large data frame.
#'   
#+
# number of results per page
perpage <- as.numeric(venuesDE$page$size)
perpage

# total results
n <- as.numeric(venuesDE$page$totalElements)
n

# number of complete pages
pages <- floor(n/perpage)-1  # adjustment since page 1 is page 0
pages

# number of entries on the last incomplete page
remainder <- n-perpage*floor(n/perpage)
remainder

# initiate a data frame in correct dimensions to speed up our loop:
venueDE_all <- data.frame(
  name = character(n), 
  city = character(n), 
  postalCode = character(n), 
  address = character(n),
  url = character(n), 
  longitude = character(n),
  latitude = character(n)
  )

# not sure whether issue bc page 1 is actually page 0 ...
#pages0 <- pages-1

# should start with 0 instead of one, but index issue...
# loop over complete pages with 20 entries each

for (i in 0:pages) {

  # generate response object
  ticketmaster <- GET("https://app.ticketmaster.com/discovery/v2/venues.json?",
                      query = list(apikey = key,
                                   countryCode = country,
                                   locale = "*",
                                   page = i))
  
  # extract content of response object
  venuesDE_content <- jsonlite::fromJSON(content(ticketmaster, as="text"))
  
  # adjust index, since the first page is page 0
  k <- i+1
  
  # gradually fill data frame page by page 
  index <- (perpage * k - (perpage-1)):(perpage * k)

  # if the object name exists
  if (!is.null(venuesDE_content$'_embedded'$venues$name)) {
    venueDE_all[index,"name"] <- data.frame(venuesDE_content$'_embedded'$venues$name)
  } else { # if the object address does not exist
    venueDE_all[index,"name"] <- rep(NA, perpage)
  } 
  
  # if the object url exists
  if (!is.null(venuesDE_content$'_embedded'$venues$url)) {
    venueDE_all[index,"url"] <- data.frame(venuesDE_content$'_embedded'$venues$url)
  } else { # if the object address does not exist
    venueDE_all[index,"url"] <- rep(NA, perpage)
  } 
  
  # if the object postalCode exists
  if (!is.null(venuesDE_content$'_embedded'$venues$postalCode)) {
    venueDE_all[index,"postalCode"] <- data.frame(venuesDE_content$'_embedded'$venues$postalCode)
  } else { # if the object address does not exist
    venueDE_all[index,"postalCode"] <- rep(NA, perpage)
  } 
  
  # if the object city$name exists
  if (!is.null(venuesDE_content$'_embedded'$venues$city$name)) {
    venueDE_all[index,"city"] <- data.frame(venuesDE_content$'_embedded'$venues$city$name)
  } else { # if the object address does not exist
    venueDE_all[index,"city"] <- rep(NA, perpage)
  } 
  
  # if the object address$line1 exists
  if (!is.null(venuesDE_content$'_embedded'$venues$address$line1)) {
    venueDE_all[index,"address"] <- data.frame(venuesDE_content$'_embedded'$venues$address$line1)
  } else { # if the object address does not exist
    venueDE_all[index,"address"] <- rep(NA, perpage)
  } 
  
  # if the object location§longtude exists (assuming then latitude exists as well)
  if (!is.null( venuesDE_content$'_embedded'$venues$location$longitude)) {
    venueDE_all[index,"longitude"] <- data.frame(venuesDE_content$'_embedded'$venues$location$longitude)
    venueDE_all[index,"latitude"] <- data.frame(venuesDE_content$'_embedded'$venues$location$latitude)
  } else { # if the object location (containing longi- and latitude) does not exist
    venueDE_all[index,"longitude"] <- rep(NA, perpage)
    venueDE_all[index,"latitude"] <- rep(NA, perpage)
  } 
  
  # obey rate limit (request per second < 5)
  Sys.sleep(0.25)
}

# last page
i <- i + 1

ticketmaster <- GET("https://app.ticketmaster.com/discovery/v2/venues.json?",
                    query = list(apikey = key,
                                 countryCode = country,
                                 locale = "*",
                                 page = i))

# extract content of response object
venuesDE_content <- jsonlite::fromJSON(content(ticketmaster, as="text"))

# adjust index, since the first page is page 0
k <- i+1

# gradually fill data frame page by page 
index <- (perpage * k - (perpage-1)):(n)

# if the object name exists
if (!is.null(venuesDE_content$'_embedded'$venues$name)) {
  venueDE_all[index,"name"] <- data.frame(venuesDE_content$'_embedded'$venues$name)
} else { # if the object address does not exist
  venueDE_all[index,"name"] <- rep(NA, remainder)
} 

# if the object url exists
if (!is.null(venuesDE_content$'_embedded'$venues$url)) {
  venueDE_all[index,"url"] <- data.frame(venuesDE_content$'_embedded'$venues$url)
} else { # if the object address does not exist
  venueDE_all[index,"url"] <- rep(NA, remainder)
} 

# if the object postalCode exists
if (!is.null(venuesDE_content$'_embedded'$venues$postalCode)) {
  venueDE_all[index,"postalCode"] <- data.frame(venuesDE_content$'_embedded'$venues$postalCode)
} else { # if the object address does not exist
  venueDE_all[index,"postalCode"] <- rep(NA, remainder)
} 

# if the object city$name exists
if (!is.null(venuesDE_content$'_embedded'$venues$city$name)) {
  venueDE_all[index,"city"] <- data.frame(venuesDE_content$'_embedded'$venues$city$name)
} else { # if the object address does not exist
  venueDE_all[index,"city"] <- rep(NA, remainder)
} 

# if the object address$line1 exists
if (!is.null(venuesDE_content$'_embedded'$venues$address$line1)) {
  venueDE_all[index,"address"] <- data.frame(venuesDE_content$'_embedded'$venues$address$line1)
} else { # if the object address does not exist
  venueDE_all[index,"address"] <- rep(NA, remainder)
} 

# if the object location§longtude exists (assuming then latitude exists as well)
if (!is.null( venuesDE_content$'_embedded'$venues$location$longitude)) {
  venueDE_all[index,"longitude"] <- data.frame(venuesDE_content$'_embedded'$venues$location$longitude)
  venueDE_all[index,"latitude"] <- data.frame(venuesDE_content$'_embedded'$venues$location$latitude)
} else { # if the object location (containing longi- and latitude) does not exist
  venueDE_all[index,"longitude"] <- rep(NA, remainder)
  venueDE_all[index,"latitude"] <- rep(NA, remainder)
} 

# check data
glimpse(venueDE_all)

#' 
#' 
#' 
#' # Visualizing the extracted data
#' 
#' 
#' * Below, you can find code that produces a map of Germany. 
#'   Add points to the map indicating the locations of the event venues across Germany.
#' * You will find that some coordinates lie way beyond the German borders and can 
#'   be assumed to be faulty. 
#'   Set coordinate values to NA where the value of longitude is outside the range 
#'   (5.866944, 15.043611) or where the value of latitude is outside the range 
#'   (47.271679, 55.0846) (these coordinate ranges have been derived from the extreme 
#'   points of Germany as listed on Wikipedia (see here). 
#'   For extreme points of other countries, see here).
#' 
#+
# convert longi- and latitude from chr to num
venueDE_all$longitude <- as.numeric(venueDE_all$longitude)
venueDE_all$latitude <- as.numeric(venueDE_all$latitude)

# replace values
venueDE_all$longitude[venueDE_all$longitude < 5.866944] <- NA
venueDE_all$longitude[venueDE_all$longitude > 15.043611] <- NA
venueDE_all$latitude[venueDE_all$latitude < 47.271679] <- NA
venueDE_all$latitude[venueDE_all$latitude > 55.0846] <- NA

# plot map with event locations
ggplot(data = venueDE_all, 
       mapping = aes(x = longitude, y = latitude)) +
  geom_polygon(
    aes(x = long, y = lat, group = group), 
    data = map_data("world", region = "Germany"),
    fill = "grey90",color = "black") +
  theme_void() + 
  coord_quickmap() +
  labs(title = "Event locations across Germany", 
       caption = "Source: ticketmaster.com") + 
  theme(title = element_text(size=8, face='bold'),
        plot.caption = element_text(face = "italic")) +
  geom_point(alpha = 0.5)

#' 
#' 
#' 
#' 
#' # Event locations in other countries
#' 
#' * Repeat exercises 2 to 5 for another European country of your choice. 
#'   (Hint: Clean code pays off! If you have coded the exercises efficiently, only 
#'   very few adaptions need to be made.)
#' 
#' *Note*: I attempted to use a loop with 
#' `cntry <- c("DE", "DK")` and 
#' `for (c in cntry){ ... }` to not have to submit such a lengthy file, but I did
#' not work out.
#' 
#+
#

# since the country will vary -> now I'm checking events for Denmark (DK)
country <- "CH"

# generate response object
ticketmaster <- GET("https://app.ticketmaster.com/discovery/v2/venues.json?",
                        query = list(apikey = key,
                                     countryCode = country,
                                     locale = "*"))

# show content & status code of object
ticketmaster

# extract content of response object
venuesDE <- jsonlite::fromJSON(content(ticketmaster, as="text"))

#'
#' The extracted list consist of 3 elements.
#' In `_embedded$venues` there is a data frame consisting of 20 rows of 19 columns.
#' Further, `_links` contains links to the first, next, and last page found on the
#' main page "/discovery/v2/venues.json", from where I extracted the data.
#' Lastly, `page` contains information on the size 
#' (`r as.numeric(venuesDE$page$size)`), total elements 
#' (`r as.numeric(venuesDE$page$totalElements)`), 
#' total pages 
#' (`r as.numeric(venuesDE$page$totalPages)`) and current page number
#' (`r as.numeric(venuesDE$page$number)`) of the extracted data. 
#'
#'
#'
#' * Extract the name, the city, the postalCode and address, as well as the url 
#'   and the longitude and latitude of the venues to a data frame.
#'
#+
# venue content
venue_df <- data.frame(venuesDE$'_embedded'$venues)

# extract variables from data frame 'venue_df'
vars <- c("name", "postalCode", "url")

# combine in new data frame 'venue_data'
venue_data <- data.frame(venue_df[vars])

# add variables from data frame within data frame 'venue_df'
venue_data$city = venue_df[["city"]][["name"]]
venue_data$address = venue_df[["address"]][["line1"]]
venue_data$longitude = venue_df[["location"]][["longitude"]]
venue_data$latitude = venue_df[["location"]][["latitude"]]

#' 
#'   
#' * Write a for loop that iterates through the results pages and performs a GET 
#'   request for all venues in Germany. 
#'   After each iteration, extract the seven variables name, city, postalCode, 
#'   address, url, longitude, and latitude. 
#'   Join the information in one large data frame.
#'   
#+
# number of results per page
perpage <- as.numeric(venuesDE$page$size)

# total results
n <- as.numeric(venuesDE$page$totalElements)

# number of complete pages
pages <- floor(n/perpage)-1  # adjustment since page 1 is page 0

# number of entries on the last incomplete page
remainder <- n-perpage*floor(n/perpage)

# initiate a data frame in correct dimensions to speed up our loop:
venueDE_all <- data.frame(
  name = character(n), 
  city = character(n), 
  postalCode = character(n), 
  address = character(n),
  url = character(n), 
  longitude = character(n),
  latitude = character(n)
)

# loop
for (i in 0:pages) {
  
  # generate response object
  ticketmaster <- GET("https://app.ticketmaster.com/discovery/v2/venues.json?",
                      query = list(apikey = key,
                                   countryCode = country,
                                   locale = "*",
                                   page = i))
  
  # extract content of response object
  venuesDE_content <- jsonlite::fromJSON(content(ticketmaster, as="text"))
  
  # adjust index, since the first page is page 0
  k <- i+1
  
  # gradually fill data frame page by page 
  index <- (perpage * k - (perpage-1)):(perpage * k)
  
  # if the object name exists
  if (!is.null(venuesDE_content$'_embedded'$venues$name)) {
    venueDE_all[index,"name"] <- data.frame(venuesDE_content$'_embedded'$venues$name)
  } else { # if the object address does not exist
    venueDE_all[index,"name"] <- rep(NA, perpage)
  } 
  
  # if the object url exists
  if (!is.null(venuesDE_content$'_embedded'$venues$url)) {
    venueDE_all[index,"url"] <- data.frame(venuesDE_content$'_embedded'$venues$url)
  } else { # if the object address does not exist
    venueDE_all[index,"url"] <- rep(NA, perpage)
  } 
  
  # if the object postalCode exists
  if (!is.null(venuesDE_content$'_embedded'$venues$postalCode)) {
    venueDE_all[index,"postalCode"] <- data.frame(venuesDE_content$'_embedded'$venues$postalCode)
  } else { # if the object address does not exist
    venueDE_all[index,"postalCode"] <- rep(NA, perpage)
  } 
  
  # if the object city$name exists
  if (!is.null(venuesDE_content$'_embedded'$venues$city$name)) {
    venueDE_all[index,"city"] <- data.frame(venuesDE_content$'_embedded'$venues$city$name)
  } else { # if the object address does not exist
    venueDE_all[index,"city"] <- rep(NA, perpage)
  } 
  
  # if the object address$line1 exists
  if (!is.null(venuesDE_content$'_embedded'$venues$address$line1)) {
    venueDE_all[index,"address"] <- data.frame(venuesDE_content$'_embedded'$venues$address$line1)
  } else { # if the object address does not exist
    venueDE_all[index,"address"] <- rep(NA, perpage)
  } 
  
  # if the object location§longtude exists (assuming then latitude exists as well)
  if (!is.null( venuesDE_content$'_embedded'$venues$location$longitude)) {
    venueDE_all[index,"longitude"] <- data.frame(venuesDE_content$'_embedded'$venues$location$longitude)
    venueDE_all[index,"latitude"] <- data.frame(venuesDE_content$'_embedded'$venues$location$latitude)
  } else { # if the object location (containing longi- and latitude) does not exist
    venueDE_all[index,"longitude"] <- rep(NA, perpage)
    venueDE_all[index,"latitude"] <- rep(NA, perpage)
  } 
  
  # obey rate limit (request per second < 5)
  Sys.sleep(0.25)
}

# last page
i <- i + 1

ticketmaster <- GET("https://app.ticketmaster.com/discovery/v2/venues.json?",
                    query = list(apikey = key,
                                 countryCode = country,
                                 locale = "*",
                                 page = i))

# extract content of response object
venuesDE_content <- jsonlite::fromJSON(content(ticketmaster, as="text"))

# adjust index, since the first page is page 0
k <- i+1

# gradually fill data frame page by page 
index <- (perpage * k - (perpage-1)):(n)

# if the object name exists
if (!is.null(venuesDE_content$'_embedded'$venues$name)) {
  venueDE_all[index,"name"] <- data.frame(venuesDE_content$'_embedded'$venues$name)
} else { # if the object address does not exist
  venueDE_all[index,"name"] <- rep(NA, remainder)
} 

# if the object url exists
if (!is.null(venuesDE_content$'_embedded'$venues$url)) {
  venueDE_all[index,"url"] <- data.frame(venuesDE_content$'_embedded'$venues$url)
} else { # if the object address does not exist
  venueDE_all[index,"url"] <- rep(NA, remainder)
} 

# if the object postalCode exists
if (!is.null(venuesDE_content$'_embedded'$venues$postalCode)) {
  venueDE_all[index,"postalCode"] <- data.frame(venuesDE_content$'_embedded'$venues$postalCode)
} else { # if the object address does not exist
  venueDE_all[index,"postalCode"] <- rep(NA, remainder)
} 

# if the object city$name exists
if (!is.null(venuesDE_content$'_embedded'$venues$city$name)) {
  venueDE_all[index,"city"] <- data.frame(venuesDE_content$'_embedded'$venues$city$name)
} else { # if the object address does not exist
  venueDE_all[index,"city"] <- rep(NA, remainder)
} 

# if the object address$line1 exists
if (!is.null(venuesDE_content$'_embedded'$venues$address$line1)) {
  venueDE_all[index,"address"] <- data.frame(venuesDE_content$'_embedded'$venues$address$line1)
} else { # if the object address does not exist
  venueDE_all[index,"address"] <- rep(NA, remainder)
} 

# if the object location§longtude exists (assuming then latitude exists as well)
if (!is.null( venuesDE_content$'_embedded'$venues$location$longitude)) {
  venueDE_all[index,"longitude"] <- data.frame(venuesDE_content$'_embedded'$venues$location$longitude)
  venueDE_all[index,"latitude"] <- data.frame(venuesDE_content$'_embedded'$venues$location$latitude)
} else { # if the object location (containing longi- and latitude) does not exist
  venueDE_all[index,"longitude"] <- rep(NA, remainder)
  venueDE_all[index,"latitude"] <- rep(NA, remainder)
} 

#' 
#' 
#' * Below, you can find code that produces a map of Germany. 
#'   Add points to the map indicating the locations of the event venues across Germany.
#' * You will find that some coordinates lie way beyond the German borders and can 
#'   be assumed to be faulty. 
#'   Set coordinate values to NA where the value of longitude is outside the range 
#'   (5.866944, 15.043611) or where the value of latitude is outside the range 
#'   (47.271679, 55.0846) (these coordinate ranges have been derived from the extreme 
#'   points of Germany as listed on Wikipedia (see here). 
#'   For extreme points of other countries, see here).
#' 
#+
# convert longi- and latitude from chr to num
venueDE_all$longitude <- as.numeric(venueDE_all$longitude)
venueDE_all$latitude <- as.numeric(venueDE_all$latitude)

# replace values
#  45°49'05 and 47°48'30 lat.
#  5° 57'23 and 10°29'31 long
venueDE_all$longitude[venueDE_all$longitude < 5] <- NA
venueDE_all$longitude[venueDE_all$longitude > 10] <- NA
venueDE_all$latitude[venueDE_all$latitude < 45] <- NA
venueDE_all$latitude[venueDE_all$latitude > 57] <- NA

# plot map with event locations
ggplot(data = venueDE_all, 
       mapping = aes(x = longitude, y = latitude)) +
  geom_polygon(
    aes(x = long, y = lat, group = group), 
    data = map_data("world", region = "Switzerland"),
    fill = "grey90",color = "black") +
  theme_void() + 
  coord_quickmap() +
  labs(title = "Event locations across Switzerland", 
       caption = "Source: ticketmaster.com") + 
  theme(title = element_text(size=8, face='bold'),
        plot.caption = element_text(face = "italic")) +
  geom_point(alpha = 0.5)

#' 
#' 
#' 
#' 
#' 
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