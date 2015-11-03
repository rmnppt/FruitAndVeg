# generate the 'stl' objects and store as .rds
library(dplyr)
library(zoo)

series <- readRDS("Data/continuous.rds")

# check all start in January
starts <- slice(series, 1)
all(starts$month == "Jan")

# some might be too sparse
sampleSize <- summarise(series, count = n())
minN <- 0.25*(12*12)
tooSmall <- sampleSize$newCat[sampleSize$count < minN]

# trim out the sparse ones
trimmed <- series %>% filter(n() >= minN)
things <- unique(trimmed$newCat)
nThings <- length(things)

# going to need a loop here
mods <- list()
for(i in 1:nThings){
  s <- subset(trimmed, newCat == things[i])
  tser <- ts(s$price, frequency = 12)
  if(all(is.na(tser))){ next }
  if(any(is.na(tser))){ tser <- na.approx(tser, rule = 2) }
  mods[[i]] <- stl(tser, 5)
}
names(mods) <- unique(trimmed$subcategory)

saveRDS(mods, "Data/continuousSTL.rds")
