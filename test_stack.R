# Random Foret Analysis using Raster stack
# Asami Minei


# setting environment --------------------
## install packages 
install.packages("rgdal")
install.packages("yaImpute")
install.packages("randomForest")
install.packages("raster")
install.packages("dplyr")
install.packages("sf")
install.packages("ggplot2")
install.packages("VSURF")
install.packeges("rpart")

library(rpart)
library(VSURF)
library(rgdal)
library(yaImpute)
library(randomForest)
library(raster)
library(dplyr)
library(sf)
library(ggplot2)
library(rgdal)



##  Set working path:
setwd("S:/Minei_Thesis/RANDOMFOREST/test")

# Load full stack of rasters
# if this fails, try updating your R system
st <- stack("Mas_QL2_bi_w.tif")

names(st) <- c("Mason_NWI",       "Mason_ql2_asp",    "Mason_ql2_curv",    "Mason_ql2_dem",
               "Mason_ql2_demh", "Mason_ql2_dems",   "Mason_ql2_dsm",     "Mason_ql2_FlA",
               "Mason_ql2_FloD", "Mason_ql2_plC",    "Mason_ql2_proC",    "Mason_ql2_slop",
               "Mason_NDRE", "Mason_NDVI", "Mason_NDWI")

names(st) <- c("Mason_NWI",       "Mason_quan_asp",    "Mason_quan_curv",    "Mason_quan_dem",
               "Mason_quan_demh", "Mason_quan_dems",   "Mason_quan_dsm",     "Mason_quan_FlA",
               "Mason_quan_FloD", "Mason_quan_plC",    "Mason_quan_proC",    "Mason_quan_slop",
               "Mason_NDRE", "Mason_NDVI", "Mason_NDWI")

# plot each raster lyers
plot(st)

# convert the raster into dataset
# na.rm = T -> removes all the null data
df <- as.data.frame(st, xy = TRUE, na.rm = T)
#  attach(df); str(df); summary(df); dim(df); contrasts(factor(Mason_NWI))
dim(df)
saveRDS(df, file = "Mason_QL2_bi.rds") 


