
### explore
library(dplyr)
library(ggplot2)

dat <- read.csv("Data/fruitVegTidy.csv")
dat$month <- factor(dat$month, c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))

# exclude NA
dat <- dat[-which(is.na(dat$price)),]

# plot price against month
ggplot(dat, aes(x = month, y = price)) +
  geom_line(aes(group = paste(year, subcategory, item, Quality, Units))) +
  facet_wrap(~ category, scales = "free")

# look at relationship between mean and var
bySeason <- dat %>%
  filter(Units == "£/kg") %>%
  group_by(year, category, subcategory, item) %>%
  summarise_each(funs(mean, sd), price) %>%
  filter(sd > 0) %>%
  mutate(varCoef = sd / mean)

ggplot(bySeason, aes(x = mean, y = varCoef, alpha = 0.5)) +
  geom_point() + geom_rug(sides = "bl") +
  facet_wrap( ~ category)

filter(bySeason, varCoef > 0.6)
filter(bySeason, mean > 7)

# look at the trends over years
ggplot(bySeason, aes(x = year, y = mean,
                     group = paste(subcategory, item))) + 
  geom_line()


  


