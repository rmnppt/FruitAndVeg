# clustering seasonal variation
### BIG PROBLEM HERE AS NA'S NOT ALLOWED IN KMEANS
library(tidyr)
library(dplyr)
library(ggplot2)

theme_blog <- theme(
  panel.grid = element_blank(),
  panel.background = element_blank()
)

dat <- read.csv("Data/fruitVegTidy.csv")
dat$month <- factor(dat$month, c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))
# exclude NA
dat <- dat[-which(is.na(dat$price)),]
# month integer
dat$monthInt <- as.numeric(dat$month)

# group and normalise
items <- dat %>% 
  group_by(category, subcategory) %>%
  mutate(newCat = paste(category, subcategory),
         priceNorm = scale(price)) %>%
  ungroup %>%
  group_by(newCat, month) %>%
  summarise(priceNorm = mean(priceNorm))
forClust <- items %>%
  spread(newCat, priceNorm) %>%
  select(-month) %>%
  as.matrix %>%
  t %>%
  as.numeric

### BIG PROBLEM - NEED TO TURN NA'S INTO 0'S
forClust[which(is.na(forClust))] <- 0

# logLik for kmeans
logLik.kmeans <- function(object) structure(
  object$tot.withinss,
  df = nrow(object$centers)*ncol(object$centers),
  nobs = length(object$cluster)
)

# perform clustering
kMax <- 10
bic <- rep(NA, kMax)
for(i in 1:kMax){
  clust <- kmeans(forClust, i, iter.max = 1e4, nstart = 20)
  bic[i] <- BIC(clust)
}
plot(bic)

