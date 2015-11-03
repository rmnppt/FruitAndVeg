# continuous
mods <- readRDS("Data/continuousSTL.rds")
source("scripts/plotSTL.R")

### play with some time series
names(mods)

search <- "Carrots"
thisGuy <- mods[grep(search, names(mods))][[1]]
plotSTL(thisGuy, search, 4)

