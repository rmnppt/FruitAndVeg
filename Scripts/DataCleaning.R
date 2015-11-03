
### clean up the data
library(reshape2)

# download
daturl <- "http://data.defra.gov.uk/statistics_2015/food/fruitveg.csv"
dat <- read.csv(daturl, sep = "\t")

# the table is lots of tables stacked on top of eachother split by year
# find those splits, split and rejoin
firstCollumn <- read.csv(daturl, sep = "\t", header = F, as.is = T)[,1]

# combined and new items indeces
combinedAndNew <- grep("item", firstCollumn)

# year break indeces
yearBreaks <- grep("20", firstCollumn)
yearBreaks <- yearBreaks[-which(!is.na(match(yearBreaks, combinedAndNew)))]
firstCollumn[yearBreaks]

# add an endpoint
yearBreaks <- c(yearBreaks, length(firstCollumn))

# generate a year vector
year <- numeric(nrow(dat))
for(i in 1:(length(yearBreaks)-1)){
  year[yearBreaks[i]:(yearBreaks[i+1])] <- as.numeric(firstCollumn[yearBreaks][i])
}

# find ALLCAPS category delineators
noLower <- grep("[[:lower:]]", firstCollumn, invert = TRUE)
empty <- which(firstCollumn == "")
categories <- noLower[-which(!is.na(match(noLower, empty)))]
categories <- categories[-which(!is.na(match(categories, yearBreaks)))]
firstCollumn[categories]

# add an endpoint
categories <- c(categories, length(firstCollumn))

# generate a categories vector
category <- character(nrow(dat))
for(i in 1:(length(categories)-1)){
  category[categories[i]:(categories[i+1])] <- firstCollumn[categories][i]
}

length(category) == length(year)

# now lets sort out the variable stored in the first collumn,
# the fruit subcategory
subcategory <- firstCollumn
for(i in 1:length(subcategory)){
  if(subcategory[i] == ""){
    subcategory[i] <- subcategory[i-1]
  }
}

### ok now we have three vectors that split all of the info in the first collumn
### lets bind that in and then clean up
vars <- cbind(year, category, subcategory)[-1,]
dat2 <- cbind(vars, dat[,-1])

# remove the rows that were reserved for category and year
remove <- c(categories[-49], yearBreaks[-13])
dat2 <- dat2[-(remove-1),]

# tidy up classes
dat2$year <- as.integer(as.character(dat2$year))
for(i in 7:18){
  dat2[,i] <- as.numeric(as.character(dat2[,i]))
}

# melt
dat2M <- melt(dat2, 1:6, variable.name = "month", value.name = "price")
colnames(dat2M)[4] <- "item"

# finally save it
write.csv(dat2M, "Data/fruitVegTidy.csv", row.names = F)

