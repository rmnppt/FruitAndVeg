### explore
library(dplyr)

dat <- read.csv("Data/fruitVegTidy.csv")
dat$month <- factor(dat$month, c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))

# exclude NA
dat <- dat[-which(is.na(dat$price)),]

# remove combined etc
these <- grep("item", dat$subcategory)
dat <- dat[-these,]

dat$desc <- paste(dat$subcategory, dat$item)

# collapse seasonal variation -> yearly summaries
bySeason <- dat %>%
  group_by(year, category, desc) %>%
  summarise(price = mean(price))

# vector and count of items 
items <- unique(dat$desc)
nItems <- length(items)

# calculate models
grad <- numeric(nItems)
pval <- numeric(nItems)
for(i in 1:nItems) {
  s <- subset(dat, desc == items[i])
  if(length(unique(s$year)) <= 1) {
    grad[i] <- NA
    pval[i] <- NA
  }else {
  mod <- lm(price ~ year, s)
  grad[i] <- mod$coefficients["year"]
  pval[i] <- summary(mod)$coefficients[2, 4]
  }
}
pval <- p.adjust(pval)
models <- data.frame(items, grad, pval) 

# insufficient data across years
insuff <- which(is.na(grad))
models <- models[-insuff,]
items <- models$items
nItems <- length(items)
yl <- function(x) extendrange(r = range(x), f = 0.2)

collumns <- 3

png("Plots/Sparklines.png", 6, 3, "in", res = 200)
laymat <- matrix(c(1:(nItems*2), rep(0, nItems%%collumns)), 
                 ceiling(nItems/collumns), 2*collumns, byrow = T)
lay <- layout(laymat, rep(c(1, 9), collumns))
par(mar = c(0.1, 0, 0.1, 0), oma = c(1, 1, 1, 1))
for(i in 1:nItems) {
  s <- subset(bySeason, desc == items[i])
  colr <- "grey"
  if(models$grad[i] > 0 & models$pval[i] < 0.05){ colr <- "red" }
  if(models$grad[i] < 0 & models$pval[i] < 0.05){ colr <- "blue" }
  plot(NA, ann = F, axes = F, xlim = c(2004, 2015.5), ylim = yl(s$price))
  abline(h = s$price[s$year == min(s$year)], col = grey(0.6), lwd = 0.3)
  lines(price ~ year, s,  col = colr, lwd = 0.75)
  points(price ~ year, subset(s, year == max(s$year)), col = colr, pch = 19, cex = 0.3)
  plot(NA, ann = F, axes = F, xlim = c(0, 1), ylim = c(0, 1))
  text(0, 0.5, items[i], pos = 4, cex = 0.5, family = "mono")
}
dev.off()


