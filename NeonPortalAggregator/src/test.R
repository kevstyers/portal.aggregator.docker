# Test plots


data.in1 <- fst::read.fst(path = "X:/1_GitHub/NeonPortalAggregator/data/DP1.00002.001/D18_BARR_DP1.00002.001_2018-01-01_to_2020-04-30.fst")

# ggplot(data = data.in1, aes(x = endDateTime, y = tempSingleMean, color = verticalPosition)) + 
  # geom_point()


data.in2 <- fst::read.fst(path = "X:/1_GitHub/NeonPortalAggregator/data/DP1.00001.001/D18_BARR_DP1.00001.001_2018-01-01_to_2020-04-30.fst") 


# ggplot(data = data.in2, aes(x = endDateTime, y = windSpeedMaximum, color = verticalPosition)) + 
#   geom_point()

names(data.in1)

testJoin <- tidytable::dt_left_join(x = data.in1, y = data.in2, by = "startDateTime")
testJoin$verticalPosition <- as.character(testJoin$verticalPosition)

testAgg <- testJoin %>%
  mutate(date = base::as.Date(startDateTime)) %>%
  group_by(date, verticalPosition) %>%
  summarise(
    meanDayTemp = mean(tempSingleMean, na.rm = TRUE),
    maxDayTemp = max(tempSingleMaximum, na.rm = TRUE),
    minDayTemp = max(tempSingleMinimum, na.rm = TRUE),
    meanDayWind = max(windSpeedMean, na.rm = TRUE),
    maxDayWind = max(windSpeedMaximum, na.rm = TRUE),
    minDayWind = max(windSpeedMinimum, na.rm = TRUE),
  ) %>%
  filter(is.na(verticalPosition) == FALSE)

sum(is.na(testAgg$meanDayTemp))

ggplot(data = testAgg, aes(x = date)) +
  geom_smooth(aes(y = testAgg$meanDayTemp), color = "red") +
  geom_smooth(aes(y = testAgg$minDayTemp ), color = "blue") +
  geom_smooth(aes(y = testAgg$maxDayTemp ), color = "green") # +
  # facet_wrap(~verticalPosition)

ggplot(data = testAgg, aes(x = date)) +
  geom_smooth(aes(y = testAgg$meanDayWind), color = "red") +
  geom_smooth(aes(y = testAgg$minDayWind ), color = "blue") +
  geom_smooth(aes(y = testAgg$maxDayWind ), color = "green") +
  facet_grid(~verticalPosition)

ggplot(data = testAgg %>% filter(meanDayWind > 1), aes(x = meanDayTemp, y = meanDayWind)) +
  geom_point() + 
  geom_smooth() + 
  scale_x_reverse()
