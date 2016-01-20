
library(zoo)
library(ggplot2)
library(dplyr)
library(reshape2)
library(gridExtra)
library(animation)
url <- "https://raw.githubusercontent.com/rmnppt/FruitAndVeg/master/Data/fruitVegTidy.csv"
dat <- read.csv(url)
dat$month <- factor(dat$month, c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))
dat <- dat %>%
  group_by(year, month, subcategory) %>%
  summarise(price =  mean(price))
theme_tsPlot <-   theme(text = element_text(size = 25),
                        axis.title.y = element_text(margin = unit(c(1, 1, 1, 1), "lines")),
                        strip.text = element_text(hjust = 0))

carrots <- subset(dat, subcategory == "Carrots")
carrots$filled_price <- na.approx(carrots$price, rule = 2)
carrot_ts <- ts(carrots$filled_price, frequency = 12)

carrots_start <- as.POSIXct("2004-01-01")
carrots$time <- seq(carrots_start, by = "months", length.out = nrow(carrots))

carrot_stl <- stl(carrot_ts, 
                  s.window = "periodic", s.degree = 1,
                  t.window = 21, t.degree = 1)

total <- rowSums(carrot_stl$time.series)
carrot_stl_results <- data.frame(time = carrots$time, total = total, carrot_stl$time.series)

loessPlot <- function(i) {
  tm <- carrots$time[i-10]
  t0 <- carrots$time[i]
  tp <- carrots$time[i+10]
  p4 <- ggplot(carrot_stl_results, aes(x = time)) +
    geom_line(aes(y = total - seasonal)) +
    geom_point(data = filter(carrot_stl_results, time < t0),
               aes(y = trend), colour = "blue") +
    geom_smooth(data = filter(carrot_stl_results, time > tm & time < tp), 
                aes(y = total - seasonal),
                method = "lm",
                formula = y ~ x)
  print(p4 + theme_tsPlot)
}

saveGIF(
  for(i in 33:53) {
    loessPlot(i)
  },
  "loess.gif",
  ani.dev = "pdf",
  ani.width = 18,
  ani.height = 4
)

p4a <- ggplot(carrot_stl_results, aes(x = time)) +
  geom_line(aes(y = total - seasonal))
pdf(file = "EdinbR/images/loess_single.pdf", width = 18, height = 4)
print(p4a + theme_tsPlot)
dev.off()

im.convert("EdinbR/images/loess_single.pdf", "EdinbR/images/loess_single.gif")
file.copy("loess.gif", "EdinbR/images/loess.gif", overwrite = T)





