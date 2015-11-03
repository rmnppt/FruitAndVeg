# aggregate data to be used in time series decomposition
# continuous models in batch
rm(list = ls())

# continuous
library(dplyr)

dat <- read.csv("Data/fruitVegTidy.csv")
dat$month <- factor(dat$month, c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))

# group 
series <- dat %>% 
  mutate(newCat = paste(category, subcategory)) %>%
  group_by(newCat, category, subcategory, year, month) %>%
  summarise(price = mean(price)) %>%
  ungroup %>%
  group_by(newCat)

# save
saveRDS(series, "Data/continuous.rds")
