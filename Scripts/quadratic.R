rm(list = ls())

### fitting quadratic models
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
  mutate(newCat = paste(category, subcategory)) %>%
  ungroup %>%
  group_by(newCat)

# fit models
models <- items %>%
  do(mod = lm(price ~ year + poly(monthInt, 2), .))
### pulling out the results is a bit messy as we need 
### the last coefficient from different sized models
results <- models %>% do(data.frame(
    poly = .$mod$coefficients[length(.$mod$coefficients)],
    pval = summary(.$mod)$coefficients[nrow(summary(.$mod)$coefficients), 4],
    rsq = summary(.$mod)$adj.r.squared
  ))
results$pval <- p.adjust(results$pval)
sig <- which(results$pval < 0.05)

# annotate the original data with sig/non-sig polynomial
items$sig <- F
for(i in 1:length(sig)){
  items$sig[items$newCat == models$newCat[sig[i]]] <- T
}
length(sig) / nrow(models)
length(which(items$sig == T)) / nrow(items)
models[sig,]

# # plot price against month
itemMeans <- items %>% 
  group_by(newCat, category, month, sig) %>%
  summarise(meanP = mean(price))
# ggplot(itemMeans, aes(x = month, y = meanP)) +
#   geom_line(aes(group = newCat)) +
#   facet_grid(sig ~ category, scales = "free")

# plot the significant ones
sigs <- itemMeans %>% 
  filter(sig == T)
ggplot(sigs, aes(x = month, y = meanP)) +
  geom_point(aes(y = price), filter(items, sig == T), alpha = 0.25) + 
  geom_line(aes(group = newCat), col = "red", size = 1.5) +
  facet_wrap(~ newCat, scales = "free_y") +
  theme_blog


