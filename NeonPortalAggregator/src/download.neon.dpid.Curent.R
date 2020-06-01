dpid <- "DP1.00041.001"
sites <- "WREF"

download.neon.dpid.func <- function(dpid, sites = NULL){
  
  library(neonUtilities)
  library(tidyverse)
  library(lubridate)

  
  dpLookup <- base::readRDS(file = base::paste0("/srv/shiny-server/NeonPortalAggregator/data/lookup/dpLookup.RDS"))
  siteList <- data.table::as.data.table(base::readRDS(file = base::paste0("/srv/shiny-server/NeonPortalAggregator/data/lookup/siteList.RDS")))
  names(siteList) <- "siteID"
  
  if(is.null(sites) == TRUE){
    base::message(base::paste0("Pull all sites for ", dpid))
  } else {
    base::message(base::paste0("Pulling ", dpid , " for ",sites,"\n"))
    base::message(base::paste0("Pulling ", length(sites), " sites."))
    siteList <- siteList %>%
      dplyr::filter(siteID %in% sites)
  }
  

  for(i in siteList$siteID[12:47]){
    # Grab data from neon portal
    base::message(base::paste0("Grabbing ", i, "'s Data now..."))
    t <-neonUtilities::loadByProduct(dpID = dpid,
                                     site = i,
                                     check.size = FALSE ,
                                     avg = "30"
    )
    # Grab just the 30 min avg'ed wind data
    if(dpid == "DP1.00005.001"){
      t1 <- t$IRBT_30_minute
    
      
    }

    if(dpid == "DP1.00006.001"){
      
      
      if("PRIPRE_30min" %in% names(t)){
        message("prePrecip is here")
        t.priPre <- t$PRIPRE_30min
      } else{
        # Create blank data frame
        message("prePri is not here")
        listOf.t.priPre <- readRDS("/srv/shiny-server/NeonPortalAggregator/data/lookup/priPreNames.RDS")
        t.priPre = data.frame(domainID          =character(),
                              siteID            =character(),
                              horizontalPosition=character(),
                              verticalPosition  =character(),
                              startDateTime     =POSIXct(),
                              endDateTime       =POSIXct(),
                              TFPrecipBulk      =numeric(),
                              TFPrecipExpUncert =numeric(),
                              TFPrecipRangeQF   =numeric(),
                              TFPrecipSciRvwQF  =numeric(),
                              publicationDate   =character())
      }
    
      if("SECPRE_30min" %in% names(t)){
        message("secPrecip is here")
        t.secPre <- t$SECPRE_30min
      } else{
        # Create blank data frame
        message("secPri is not here")
        listOf.t.secPreNames <- readRDS("/srv/shiny-server/NeonPortalAggregator/data/lookup/secPreNames.RDS")
        t.secPre = data.frame(domainID          =character(),
                              siteID            =character(),
                              horizontalPosition=character(),
                              verticalPosition  =character(),
                              startDateTime     =POSIXct(),
                              endDateTime       =POSIXct(),
                              TFPrecipBulk      =numeric(),
                              TFPrecipExpUncert =numeric(),
                              TFPrecipRangeQF   =numeric(),
                              TFPrecipSciRvwQF  =numeric(),
                              publicationDate   =character())
      }
      if("THRPRE_30min" %in% names(t)){
        message("thruPrecip is here")
        t.thrPre <- t$THRPRE_30min
      } else {
        # Create blank data frame
        message("thrPri is not here")
        listOf.t.thrPreNames <- readRDS("/srv/shiny-server/NeonPortalAggregator/data/lookup/thrPreNames.RDS")
        t.thrPre = data.frame(domainID           = character(),
                              siteID             = character(),
                              horizontalPosition = character(),
                              verticalPosition   = character(),
                              startDateTime      = POSIXct(),
                              endDateTime        = POSIXct(),
                              TFPrecipBulk       = numeric(),
                              TFPrecipExpUncert  = numeric(),
                              TFPrecipRangeQF    = numeric(),
                              TFPrecipSciRvwQF   = numeric(),
                              publicationDate    = character())
      }
      
      # Join all the data together!
      t1 <- data.table::rbindlist(l = list(t.priPre, t.secPre, t.thrPre), fill = TRUE)

    } else {
    # look for the 30 minute variable!
    names.t <- base::as.data.frame(base::names(t)) %>%
      dplyr::filter(stringr::str_detect(string = base::names(t), pattern = "30", negate = FALSE) == TRUE)
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
    saveDir <- base::paste0("/srv/shiny-server/NeonPortalAggregator/data/",dpid,"/")
    
    # Check if dp folder exists
    if(base::dir.exists(paths = base::paste0(saveDir)) == TRUE ){
      
      # Write file
      fst::write.fst(x = t1, path = base::paste0(saveDir,filename, ".fst"), compress = 100)
      base::message(base::paste0(i," wrote successful!."))
      
    } else if(base::dir.exists(paths = base::paste0(saveDir)) == FALSE ){
      
      # Create Directory 
      base::dir.create(base::paste0(saveDir))
      base::message(base::paste0("Dir created for ", i))
      # Write file
      fst::write.fst(x = t1, path = base::paste0(saveDir,filename, ".fst"), compress = 100)
      base::message(base::paste0(i," wrote successful!."))
      
    } else {
      base::message("Dir creation failed")
    }
    
  }

}
dpList <- c(
  # "DP1.00004.001",
            # "DP1.00022.001","DP1.00023.001","DP1.00024.001",
            # "DP1.00014.001",
            # "DP1.00040.001" #,
            # "DP1.00041.001" #,
            # "DP1.00066.001",
            "DP1.00094.001" #,"DP1.00095.001"
            # "DP1.00098.001"
  )

for(i in dpList){
  download.neon.dpid.func(dpid = i)
}


# domainCoreSiteList <- list("HARV","SCBI","OSBS",
#                             "GUAN","UNDE","KONZ","ORNL","TALL",
#                             "WOOD","CPER","NIWO","CLBJ","YELL",
#                             "ONAQ","SRER","WREF","SJER","TOOL",
#                             "BARR","BONA","PUUM")
