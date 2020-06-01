# Server.R

# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.


# Load required Libraries
require(shiny)
require(plotly)
require(dplyr)
require(ggplot2)
require(DT)
require(tidyr)
require(data.table)
require(shinycssloaders)
require(shinydashboard)
require(viridis)
require(stringr)
library(fst)
# library(dashboardthemes)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
  base::source(file='server/plot.R',local=T,echo = T)
}