# data plotter server code
ggplot2::theme_set(theme_bw())



m <- reactive({
  fieldSites <- data.table::fread("/srv/shiny-server/NeonPortalAggregator/data/lookup/field-sites.csv") %>%
    tidyr::unite("siteID",`Domain Number`,`Site ID`, sep = "_")
  
  fieldSitesSelected <- data.table::fread("/srv/shiny-server/NeonPortalAggregator/data/lookup/field-sites.csv") %>%
    tidyr::unite("siteID",`Domain Number`,`Site ID`, sep = "_")  %>%
    dplyr::filter(siteID == input$UniqueStreams)
    # dplyr::filter(siteID == "D01_HARV")
  
  leaflet::leaflet() %>%
    addTiles() %>%  # Add default OpenStreetMap map tiles
    addProviderTiles("Stamen.Terrain") %>%
    addMarkers(lng = fieldSites$Longitude, lat = fieldSites$Latitude, label = fieldSites$siteID) %>%
    setView(lng = fieldSitesSelected$Longitude[1], lat = fieldSitesSelected$Latitude[1],zoom = 15) 
    # addMarkers(options=list(center = c(lng=fieldSites$Longitude[1], lat=fieldSites$Latitude[1]))) %>%
    
    
    # addMarkers(lng=fieldSites$Longitude[1], lat=fieldSites$Latitude[1],)
    # addMarkers(lat = "45.99827", lng = "89.70477")
})

output$map <- leaflet::renderLeaflet({
  m()
})



reactiveData <- shiny::reactive({
  req(input$dpidID)
  req(input$UniqueStreams)
  
  # t <- fst::read.fst(paste0("/srv/shiny-server/NeonPortalAggregator/data/",input$dpidID,"/",input$UniqueStreams,"_",input$dpidID,".fst"))
  t <- fst::read.fst(paste0("/srv/shiny-server/NeonPortalAggregator/data/Aggregations/",input$dpidID,"/",input$UniqueStreams,".fst"))%>%
    dplyr::mutate(dpID = paste0(input$dpidID)) %>%
    dplyr::filter(date > input$dateRange[1] & date < input$dateRange[2])
  
  # t <- t %>% 
  #   dplyr::rename_at( 7, ~"mean" ) %>%
  #   dplyr::rename_at( 8, ~"min" ) %>%
  #   dplyr::rename_at( 9, ~"max" ) %>%
  #   dplyr::rename_at( 10, ~"variance" ) %>%
  #   dplyr::rename_at( 11, ~"numPts" ) %>%
  #   dplyr::rename_at( 12, ~"expUncert" ) %>%
  #   dplyr::rename_at( 13, ~"meanStdDev" ) %>%
  #   dplyr::rename_at( 14, ~"qfFinal" ) 

  # t <- t %>%
  #   dplyr::mutate(date = base::as.Date(endDateTime)) %>%
  #   dplyr::filter(date > input$dateRange[1] & date < input$dateRange[2]) %>%
  #   dplyr::group_by(date, verticalPosition, horizontalPosition) %>%
  #   dplyr::summarise(
  #     dailyMean = base::round(base::mean(mean, na.rm = TRUE),2),
  #     dailyMin  = base::round(base::min(min,  na.rm = TRUE),2),
  #     dailyMax  = base::round(base::max(max,  na.rm = TRUE),2),
  #     dailySum  = base::round(base::sum(mean,  na.rm = TRUE),2),
  #     dailyStdDev  = base::round(stats::sd(mean,  na.rm = TRUE),2),
  #     dailyRange = base::round(max(max, na.rm = TRUE)) - base::round(min(min, na.rm = TRUE))
  # )
  
  t <- t  %>%
    dplyr::ungroup() %>%
    dplyr::mutate(horizontalPosition = ifelse(horizontalPosition == "000", "Tower",
                                       no = ifelse(horizontalPosition == "001", "SP 1",
                                       no = ifelse(horizontalPosition == "002", "SP 2",
                                       no = ifelse(horizontalPosition == "003", "SP 3",
                                       no = ifelse(horizontalPosition == "004", "SP 4",
                                       no = ifelse(horizontalPosition == "005", "SP 5",
                                       no = ifelse(horizontalPosition == "900", "DFIR Rain Gauge Station",
                                              no = ""
                                              )))))))
                  ) %>%
    dplyr::mutate(verticalPosition =   ifelse(verticalPosition == "010", "ML 1",
                                       no = ifelse(verticalPosition == "020", "ML 2",
                                       no = ifelse(verticalPosition == "030", "ML 3",
                                       no = ifelse(verticalPosition == "040", "ML 4",
                                       no = ifelse(verticalPosition == "050", "ML 5",
                                       no = ifelse(verticalPosition == "060", "ML 6",
                                       no = ifelse(verticalPosition == "070", "ML 7",
                                       no = ifelse(verticalPosition == "080", "ML 8",
                                       no = ifelse(verticalPosition == "000", "Ground Level",
                                       no = ifelse(verticalPosition == "501", "Depth 1",
                                       no = ifelse(verticalPosition == "502", "Depth 2",
                                       no = ifelse(verticalPosition == "503", "Depth 3",
                                       no = ifelse(verticalPosition == "504", "Depth 4",
                                       no = ifelse(verticalPosition == "505", "Depth 5",
                                       no = ifelse(verticalPosition == "506", "Depth 6",
                                       no = ifelse(verticalPosition == "507", "Depth 7",
                                       no = ifelse(verticalPosition == "508", "Depth 8",
                                       no = ifelse(verticalPosition == "509", "Depth 9",
                                       no = ""
                                              ))))))))))))))))))
                  )
  
  
  
  # Join with dpid's table
  dpTable <- base::readRDS("data/lookup/dpLookup.RDS") 
  
  dt <- left_join(t, dpTable, "dpID")
  
  unitTable <- data.table::fread("/srv/shiny-server/NeonPortalAggregator/data/lookup/unitLookup.csv")
  names(unitTable) <- c("dpID", "Units")
  dt2 <- left_join(dt, unitTable, "dpID")
  dt2
  
})

p <- shiny::reactive({
  req(input$stat)
  req(input$dpidID)
  req(input$UniqueStreams)
  if(input$stat == "dailyMean"){
    
  ggplot2::ggplot(reactiveData(), aes(x = date, y = dailyMean, color = verticalPosition))+
      ggplot2::geom_point(shape = 0, size = 1) +
      # ggplot2::geom_smooth() +
      ggplot2::theme(axis.text.x = element_text(angle = 325))+
      ggplot2::scale_y_continuous(sec.axis = dup_axis(name = "")) +
      ggplot2::scale_x_date(date_breaks = input$dateBreaks, date_labels = "%Y-%m-%d")+
      ggplot2::labs(title = paste0(input$UniqueStreams, ": ", reactiveData()$dpName),
                    y = reactiveData()$Units[1], x = "", color = "Vertical Sensor Position") +
      ggplot2::facet_wrap(~horizontalPosition)
    
  } else if(input$stat == "dailyMin"){
    
  ggplot2::ggplot(reactiveData(), aes(x = date, y = dailyMin, color = verticalPosition))+
      ggplot2::geom_point(shape = 0, size = 1) +
      # ggplot2::geom_smooth() +
      ggplot2::theme(axis.text.x = element_text(angle = 325))+
      ggplot2::scale_y_continuous(sec.axis = dup_axis(name = "")) +
      ggplot2::scale_x_date(date_breaks = input$dateBreaks, date_labels = "%Y-%m-%d")+
      ggplot2::labs(title = paste0(input$UniqueStreams, ": ", reactiveData()$dpName),
                    y = reactiveData()$Units[1], x = "", color = "Vertical Sensor Position") +
      ggplot2::facet_wrap(~horizontalPosition)
    
  } else if(input$stat == "dailyMax"){
    
  ggplot2::ggplot(reactiveData(), aes(x = date, y = dailyMax, color = verticalPosition))+
      ggplot2::geom_point(shape = 0, size = 1) +
      # ggplot2::geom_smooth() +
      ggplot2::theme(axis.text.x = element_text(angle = 325))+
      ggplot2::scale_y_continuous(sec.axis = dup_axis(name = "")) +
      ggplot2::scale_x_date(date_breaks = input$dateBreaks, date_labels = "%Y-%m-%d")+
      ggplot2::labs(title = paste0(input$UniqueStreams, ": ", reactiveData()$dpName),
                    y = reactiveData()$Units[1], x = "", color = "Vertical Sensor Position") +
      ggplot2::facet_wrap(~horizontalPosition)
    
  } else if(input$stat == "dailySum"){
    
    ggplot2::ggplot(reactiveData(), aes(x = date, y = dailySum, color = verticalPosition))+
      ggplot2::geom_point(shape = 0, size = 1) +
      # ggplot2::geom_smooth() +
      ggplot2::theme(axis.text.x = element_text(angle = 325))+
      ggplot2::scale_y_continuous(sec.axis = dup_axis(name = "")) +
      ggplot2::scale_x_date(date_breaks = input$dateBreaks, date_labels = "%Y-%m-%d")+
      ggplot2::labs(title = paste0(input$UniqueStreams, ": ", reactiveData()$dpName),
                    y = reactiveData()$Units[1], x = "", color = "Vertical Sensor Position") +
      ggplot2::facet_wrap(~horizontalPosition)
  }
})

# output$plot <- plotly::renderPlotly({
#   p()
# })
output$plot <- plotly::renderPlotly({
  p()
})

output$table_reactive <- DT::renderDT(
DT::datatable(
  data = reactiveData(),
  filter = "top",
  options = list(
    deferRender = TRUE,
    scrollY = 300,
    scrollCollapse = TRUE,
    scrollX = TRUE,
    paging = TRUE),rownames = FALSE) 
)