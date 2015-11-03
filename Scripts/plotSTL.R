addBox <- function(x, ...) {
  plot(x, type = "n", ann = F, 
       xaxt = "n", yaxt = "n", ...)
}
addRect <- function(x) {
  xVals <- 1:length(x)
  yRange <- extendrange(r = range(x), f = 100)
  yMin <- yRange[1]; yMax <- yRange[2]
  n <- floor((length(x)/12)/2)
  x <- c(1, 12, 12, 1)
  y <- c(yMin, yMin, yMax, yMax)
  for(i in 1:n){
    polygon(x, y, col = "#ff000020", border = NA)
    x <- x + 24
  }
}
plotSTL <- function(x, title, n = 4) {
  par(mfrow = c(n, 1), 
      mar = c(0.5, 2, 0.5, 5),
      oma = c(2, 2, 3, 1))
  tser <- x$time.series
  totals <- rowSums(tser)
  all <- matrix(c(totals, tser[,"seasonal"], 
                  tser[,"trend"], tser[,"remainder"]),
                nrow(tser), 4)
  labs <- c("data", colnames(tser))
  for(i in 1:n) {
    if(i == 1 | i == 3){yl <- range(totals)}else
      if(i == 2 | i == 4){yl <- range(totals) - mean(range(totals))}
    addBox(all[,i], ylim = yl); addRect(all[,i]); lines(all[,i], lwd = 2)
    rug(1:length(totals))
    mtext(labs[i], 3, -2, adj = 0.01)
  }
  mtext(title, 3, 1, T, adj = 0, cex = 1.5, col = "grey")
}