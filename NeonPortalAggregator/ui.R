require(fst)
require(shiny)
require(dplyr)
require(plotly)
require(ggplot2)
require(DT)
require(tidyr)
require(data.table)
require(shinycssloaders)
require(shinydashboard)
require(viridis)
require(stringr)
require(leaflet)

domainSiteList2 <- c("BART","HARV","BLAN","SCBI","SERC","OSBS","DSNY","JERC","GUAN","LAJA",
                      "UNDE","STEI","TREE","KONZ","UKFS","KONA","ORNL","MLBS","GRSM",
                      "TALL","LENO","DELA","WOOD","DCFS","NOGP","STER","CPER","RMNP","NIWO",
                      "CLBJ","OAES","YELL","MOAB","ONAQ","SRER","JORN","WREF","ABBY",
                      "SJER","SOAP","TEAK","TOOL","BARR","BONA","DEJU","HEAL","PUUM")

list.dpIDs <- as.data.frame(base::list.dirs(path = "/srv/shiny-server/NeonPortalAggregator/data/", full.names = FALSE))
names(list.dpIDs) <- "dpID"
list.dpIDs <- list.dpIDs %>%
  dplyr::filter(dpID != "" & dpID != "lookup"& dpID != "Aggregations")
dpTable <- base::readRDS("/srv/shiny-server/NeonPortalAggregator/data/lookup/dpLookup.RDS") 
list.dpIDs <- left_join(x = list.dpIDs, y = dpTable, by = "dpID")

name1 <- as.character(list.dpIDs$dpName[1])
name2 <- as.character(list.dpIDs$dpName[2])
id1 <- as.character(list.dpIDs$dpID[1])
id2 <- as.character(list.dpIDs$dpID[2])
  

siteListUI <- readRDS("/srv/shiny-server/NeonPortalAggregator/data/lookup/siteListUI.RDS")

shinyUI(
  shinydashboard::dashboardPage(skin = "black",
    # Header
    shinydashboard::dashboardHeader(title = 'Portal Aggregator',
                                    titleWidth = 170
                                    ),
    
    # Menu bar
    shinydashboard::dashboardSidebar(
      width = 150,
      shinydashboard::sidebarMenu( id = "menu",
      # shinydashboard::menuItem("Home Page", tabName = "home"),
      shinydashboard::menuItem("DP1 Plots",tabName = "DP1", icon = shiny::icon("signal", lib = "font-awesome"))
      )
    ),
    
    # Body
    shinydashboard::dashboardBody(
      tags$head(tags$link(rel = "shortcut icon", href = "favicon.ico")),
      shinydashboard::tabItems(

        shinydashboard::tabItem(tabName = "home",
          shinydashboard::box(width = 12, 
              shiny::column(width = 7,
              shiny::h1("Practice Makes Perfect"),
              shiny::h4("Users can use this app to plot data from a variety of IS Data Products"),
              shiny::icon("signal", lib = "font-awesome"),
              shiny::h4("Daily aggregated data for every site!")
            )
          ) # End Box
        ), # End home tabName
      
      ############################################                                                              ############################################
      ############################################                                                              ############################################
      ############################################                                                              ############################################
      ############################################                  DP1 TIS Data Products                       ############################################
      ############################################                                                              ############################################

      
      shinydashboard::tabItem(tabName = "DP1",
        shinydashboard::box(width = 12,
            shiny::column(width = 12,
                shiny::column(width = 3,
                  shiny::selectInput(inputId = 'dpidID',label =  '1. Data Products',
                                     choices = c(
                 "2D wind speed and direction"                           = "DP1.00001.001",
                 "Single aspirated air temperature"                      = "DP1.00002.001",
                 "Barometric pressure"                                   = "DP1.00004.001",
                 "IR biological temperature"                             = "DP1.00005.001",
                 "Precipitation"                                         = "DP1.00006.001",
                 "Shortwave radiation (direct and diffuse pyranometer)"  = "DP1.00014.001",
                 "Shortwave radiation (primary pyranometer)"             = "DP1.00022.001",
                 "Shortwave and longwave radiation (net radiometer)"     = "DP1.00023.001",
                 "Photosynthetically active radiation"                   = "DP1.00024.001",
                 "Soil heat flux plate"                                  = "DP1.00040.001",
                 "Soil Temperature"                                      = "DP1.00041.001",
                 "Q-Line PAR"                                            = "DP1.00066.001",
                 "Soil Water Content"                                    = "DP1.00094.001",
                 "Soil CO2 concentration"                                = "DP1.00095.001",
                 "Relative humidity"                                     = "DP1.00098.001"
                                       )
                  ),
                  shiny::selectInput(inputId = 'UniqueStreams',label =  '2. Site Selection',
                                     choices =  siteListUI, selected = siteListUI[2]
                  ),
                  shiny::selectInput('stat', label = "3. Chose Statistic",choices = c("dailyMean","dailyMin","dailyMax", "dailySum")),
                  shiny::selectInput(inputId = "dateBreaks", "4. Choose Date Labels",
                                     choices = c("day","week", "month", "year"),selected = "year")
                  ),
                shiny::column(width = 5,
                
                              leaflet::leafletOutput("map")
                                            
                ),
                shiny::column(width = 2,
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00001.001'",
                                          img(src='sensor_2dwind.png', align = "center")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00002.001'",
                                          img(src='sensor_prt.jpg', align = "center", 
                                              width = "80%", height = "80%")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00004.001'",
                                          img(src='sensor_ptb330.jpg', align = "center", 
                                              width = "80%", height = "80%")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00005.001'",
                                          img(src='sensor_irbiotemp.png', align = "center", 
                                              width = "80%", height = "80%")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00006.001'",
                                          img(src='sensor_precip1.gif', align = "center")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00014.001'",
                                          img(src='sensor_spn1.png', align = "center", 
                                              width = "85%", height = "85%")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00022.001'",
                                          img(src='sensor_cmp22.jpg', align = "center", 
                                              width = "80%", height = "80%")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00023.001'",
                                          img(src='sensor_nr01.jpg', align = "center", 
                                              width = "80%", height = "80%")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00024.001'",
                                          img(src='sensor_par.jpg', align = "center")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00040.001'",
                                          img(src='sensor_soilheatflux.png', align = "center", 
                                              width = "80%", height = "80%")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00066.001'",
                                          img(src='sensor_qlinepar.JPG', align = "left", 
                                              width = "120%", height = "120%")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00095.001'",
                                          img(src='sensor_soilco2.jpg', align = "center", 
                                              width = "80%", height = "80%")
                  ),
                  shiny::conditionalPanel(condition = "input.dpidID == 'DP1.00098.001'",
                                          img(src='sensor_hmp155.png', align = "center", 
                                              width = "70%", height = "70%")
                  )
                ), # End Columb of conditional images
                shiny::column(width = 2,
                  shiny::img(src = "favicon.ico",width = "100%", height = "100%",  align = "right")
                  
                )
            ), # End Column 7
            # shiny::column(width = 8            ),
            shinydashboard::tabBox(width = 12,
              shiny::tabPanel("Site Plot",width=12,
                shiny::fluidRow(width = "100%",
                  # shiny::plotOutput("plot")  %>% shinycssloaders::withSpinner(color="#012D74",type="3",color.background = "white"),
                  plotly::plotlyOutput("plot")  %>% shinycssloaders::withSpinner(color="#012D74",type="3",color.background = "white"),
                  shiny::column(width = 3),
                  shiny::column(width = 3,
                    shiny::dateRangeInput(inputId = "dateRange", label = "5. Select Date Range for Plot",
                                          start = "2016-01-01", end = Sys.Date()
                    )
                  ),
                  shiny::p("National Ecological Observatory Network. 2020 Provisional data downloaded from http://data.neonscience.org on 20 May 2020. Battelle, Boulder, CO, USA")
                ),
                shiny::fluidRow(
                  DT::dataTableOutput("table_reactive"),
                  
                )
              ) # End tabPanel
            ) # End tabBox
          ) # End box
        ) # end tabItem
      ) # End Tab Items 
    ) # End Dashboard Body
  ) # End of Page
) # End of UI