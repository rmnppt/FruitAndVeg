# continuous models in batch
library(dplyr)
library(pander)
library(ggplot2)

mods <- readRDS("Data/continuousSTL.rds")
things <- names(mods)
nThings <- length(things)

# extract the relevant stats
results <- data.frame(
  item = things,
  seasonal = NA,
  trend = NA
)
for(i in 1:nThings){
  if(is.null(mods[[i]])){ next }
  this <- mods[[i]]$time.series
  var_total <- sum(c(
    var(this[,"seasonal"]), 
    var(this[,"trend"]), 
    var(this[,"remainder"])))
  results$seasonal[i] <- var(this[,"seasonal"]) / var_total
  results$trend[i] <- var(this[,"trend"]) / var_total
}

top <- top_n(results, 5, trend)
bottom <- top_n(results, 5, seasonal)

yl <- c(0, 1)
plot(seasonal ~ trend, results, type = "n", ann = F,
     yaxt = "n", xaxt = "n", ylim = yl, xlim = yl)
abline(0, 1, lty = 3)
symbols(results$seasonal ~ results$trend, 
        circles = results$seasonal + results$trend, 
        add = T, inches = 0.1, fg = "grey", bg = "#ff000050")
mtext("high seasonal variation", 2, 1, F, adj = 1)
mtext("strong trend", 1, 1, F, adj = 1)
text(0.8, 0.8, "seasonal = trend", srt = 45)

pander(rbind(top, bottom))


