### explore
library(dplyr)
library(ggplot2)

dat <- read.csv("Data/fruitVegTidy.csv")
dat$month <- factor(dat$month, c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))

# standard error
se <- function(x) sd(x)/sqrt(length(x))

# exclude NA
dat <- dat[-which(is.na(dat$price)),]

bySeason <- dat %>%
  filter(Units == "£/kg") %>%
  group_by(year, category, subcategory, item) %>%
  summarise_each(funs(mean, se), price)

# what about asparagus???
asparagus <- bySeason %>% filter(subcategory == "Asparagus")

pdf("Asparagus.pdf", 8, 5)
ggplot(bySeason, aes(x = year, y = mean,
                     group = paste(subcategory, item))) + 
  geom_line(aes(alpha = 0.5)) +
  geom_line(aes(colour = "red", lwd = 1), asparagus) +
  geom_ribbon(aes(fill = "red", alpha = 0.5,
                  ymin = mean - se,
                  ymax = mean + se), asparagus) +
  ylab("£ per kg") + xlab("Year") +
  theme(legend.position = "none") +
  geom_text(aes(label = "Asparagus", x = 2007, y = 9.5, col = "red", hjust = 0)) + 
  geom_text(aes(label = "Other", x = 2007, y = 8.5, hjust = 0))
dev.off()

