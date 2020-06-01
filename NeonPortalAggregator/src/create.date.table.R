# Thank you StackOverFlow user Imo
# https://stackoverflow.com/questions/41201629/how-to-select-the-last-day-of-the-month-in-r

# construct a vector of dates for 10 years, 2001 through 2010
myDates <- seq(as.Date("2017-12-01"), as.Date("2020-04-01"), by="day")

# pull off the final days of the month
finalDays <-
  myDates[myDates %in% unique(as.Date(format(myDates + 28, "%Y-%m-01")) - 1)]

# Take a look at first 5 and last 5
c(head(finalDays, 5), tail(finalDays, 5))

startDays <- seq(as.Date("2017-12-01"), as.Date("2020-03-01"), by="month")

dateTable <- as.data.frame(cbind(startDays,finalDays))
dateTable$startDays <- as.Date(dateTable$startDays, origin = "1970-01-01")
dateTable$finalDays <- as.Date(dateTable$finalDays, origin = "1970-01-01")

dateTable <- dateTable %>%
  mutate(startDays = startDays -1)

saveRDS(object = dateTable, file = "data/lookup/dateTable.RDS")
