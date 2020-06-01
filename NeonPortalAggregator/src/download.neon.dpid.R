download.neon.dpid.func <- function(dpid, sites = NULL){
  
  # library(neonUtilities)
  library(tidyverse)
  library(lubridate)
  library(here)
  
  # dateTable <- readRDS(file = paste0(here::here(), "/data/lookup/dateTable.RDS"))
  dpLookup <- base::readRDS(file = base::paste0(here::here(), "/data/lookup/dpLookup.RDS"))
  siteList <- data.table::as.data.table(base::readRDS(file = base::paste0(here::here(), "/data/lookup/siteList.RDS")))
  names(siteList) <- "siteID"
  
  if(is.null(sites) == TRUE){
    base::message(base::paste0("Pull all sites for ", dpid))
  } else {
    base::message(base::paste0("Pulling ", dpid , " for ",sites,"\n"))
    base::message(base::paste0("Pulling ", length(sites), " sites."))
    siteList <- siteList %>%
      dplyr::filter(siteID %in% sites)
  }
  
  # For core site sensors.. hacky but we will make it better one day.
  # siteList <- list("HARV","SCBI","OSBS",
  #                           "GUAN","UNDE","KONZ","ORNL","TALL",
  #                           "WOOD","CPER","NIWO","CLBJ","YELL",
  #                           "ONAQ","SRER","WREF","SJER","TOOL",
  #                           "BARR","BONA","PUUM")
  
  # i <- "BART"
  # dpid <- "DP1.00014.001"
  for(i in siteList$siteID){
    # Grab data from neon portal
    base::message(base::paste0("Grabbing ", i, "'s Data now..."))
    t <-neonUtilities::loadByProduct(dpID = dpid,
                                     site = i,
                                     # startdate = as.character(dateTable$startDays[i]),
                                     startdate = "2017-12-25",
                                     # enddate = as.character(dateTable$finalDays[i]),
                                     check.size = FALSE ,
                                     avg = "30"
    )
    # Grab just the 30 min avg'ed wind data
    if(dpid == "DP1.00005.001"){ # IR Biotemp
      t1 <- t$IRBT_30_minute 
    } else if(dpid == "DP1.00095.001"){ # Soil Co2
      t1 <- t$SCO2C_30_minute
    } else {
    # look for the 30 minute variable!
    names.t <- base::as.data.frame(base::names(t)) %>%
      dplyr::filter(stringr::str_detect(string = base::names(t), pattern = "30min", negate = FALSE) == TRUE)
    # Make that 30 min variable into a character
    var30min <- base::as.character(names.t$`base::names(t)`)
    
    # Grab out just the 30 minute data
    t1 <- t[[var30min]]
    }

    # Format the columns and save!
    t1$endDateTime <- lubridate::ymd_hms(t1$endDateTime,tz = "UTC") # some files are already posixct tbh
    t1$domainID <- base::as.factor(t1$domainID )
    t1$siteID <- base::as.factor(t1$siteID)
    t1$verticalPosition <- base::as.factor(t1$verticalPosition)
    
    # Construct File Name 
    firstDate <- base::min(base::as.Date(t1$startDateTime, format = "%Y-%m-%d"), na.rm = TRUE)
    lastDate <- base::max(base::as.Date(t1$startDateTime, format = "%Y-%m-%d"), na.rm = TRUE)
    
    filename <- base::paste0(t1$domainID[1], "_",t1$siteID[1], "_", dpid)
    saveDir <- base::paste0(here::here(), "/data/",dpid,"/")
    
    # Check if dp folder exists
    if(base::dir.exists(paths = base::paste0(saveDir)) == TRUE ){
      
      # Write file
      fst::write.fst(x = t1, path = base::paste0(saveDir,filename, ".fst"))
      base::message(base::paste0(i," wrote successful!."))
      
    } else if(base::dir.exists(paths = base::paste0(saveDir)) == FALSE ){
      
      # Create Directory 
      base::dir.create(base::paste0(saveDir))
      base::message(base::paste0("Dir created for ", i))
      # Write file
      fst::write.fst(x = t1, path = base::paste0(saveDir,filename, ".fst"))
      base::message(base::paste0(i," wrote successful!."))
      
    } else {
      base::message("Dir creation failed")
    }
    
  }

}
dpList <- c("DP1.00095.001")

# Stopped at Yell! 2020-05-26 3:52Pm
for(i in dpList){
  download.neon.dpid.func(dpid = i)
}


domainCoreSiteList <- list("HARV","SCBI","OSBS",
                            "GUAN","UNDE","KONZ","ORNL","TALL",
                            "WOOD","CPER","NIWO","CLBJ","YELL",
                            "ONAQ","SRER","WREF","SJER","TOOL",
                            "BARR","BONA","PUUM")
