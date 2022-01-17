# Minei Thesis H2O Random Forest Analysis
# Masonboro
# Only Quanergy
# Binary

#install.packages('readr');install.packages('h2o');install.packages('caret');
library(readr)
library('h2o')
library(e1071)
library(caret)

# load RDS data
fn<-"C:/Users/am3303/Documents/Minei_Thesis/RF_LiDAR/a_RR/class/"
setwd(fn)
df.rds<-readRDS("RR_quan_cl.rds"); names(df.rds); attach(df.rds)

# Random Forest Model  --------------------
# only LiDAR not MS
df.rds$RR_NWI<-factor(df.rds$RR_NWI)
vari <- df.rds[ ,3:14]

## using H2o;
## need to install Java first, if there is any JAVA related error
h2o.shutdown(prompt = FALSE)
localH2O <- h2o.init(nthreads = -1,max_mem_size = '4g')
h2o.init()


## empty vari
y.dep <- 1;
x.indep <- c(2:12)

## record processing time
start.time <- Sys.time()

## RF for accuracy with CV (k=5)
train.h2o <- as.h2o(vari);

rforest.model<- h2o.randomForest(y=y.dep, 
                                 x=x.indep, 
                                 training_frame = train.h2o,
                                 nfold=5, 
                                 mtries=4, 
                                 max_depth=15, 
                                 ntrees = 450,  
                                 seed = 1122,
                                 keep_cross_validation_predictions=TRUE,
                                 keep_cross_validation_fold_assignment = TRUE)

## Stop recording time and calculate processing time
end.time <- Sys.time()
time.taken_rf <- end.time - start.time
time.taken_rf
rforest.model

# save the model
path <- h2o.saveModel(rforest.model, path=fn, force=TRUE )
# reload the model
rf.load <- h2o.loadModel(path)
DRF_model_R_1634910299743_1

# Export output raster
# Taking out all CV[prediction, p1, p2] (p1 is probability of being 1)
cv <- h2o.getFrame(rf.load@model[["cross_validation_holdout_predictions_frame_id"]][["name"]])
cv.vec <- as.vector(cv[,1])

# cv fold ID in case 
# foldid<-h2o.cross_validation_fold_assignment(rforest.model)

# visualize a prediction raster   --------------------
pre <- data.frame(X =as.numeric(x),
                  Y =as.numeric(y),
                  PREDICT = as.numeric(cv.vec))
attach(pre)
# contrasts(factor(PREDICT))
# summary(factor(PREDICT))

# Save an object to a file
saveRDS(pre, file = "PREDICTION_RR_Quan_cl.rds")
# Restore the object
prediction <- readRDS(file = "PREDICTION_Mays_QL2_bi.rds")


#install.packages('ggplot2'); install.packages('raster'); install.packages('sp'); 
library(ggplot2)
library(sp)
library(raster)


# reference
ggplot() +
  geom_tile(data = pre, aes(x = x, y=y, fill =RR_NWI)) +
  coord_quickmap()

# prediction
ggplot() +
  geom_tile(data = pre, aes(x = X, y=Y, fill =PREDICT)) +
  coord_quickmap() 


#Create prediction raster --------------------
# https://www.youtube.com/watch?v=LwCEe9o0vac
st <- stack("RR_Qu_st_cl_wa.tif")
names(st) <- c("NWI",       "sc_ql2_asp",    "sc_ql2_curv",    "sc_ql2_dem",
               "sc_ql2_demh", "sc_ql2_dems",   "sc_ql2_dsm",     "sc_ql2_FlA",
               "sc_ql2_FloD", "sc_ql2_plC",    "sc_ql2_proC",    "sc_ql2_slop",
               "SurfCity_NDRE", "SurfCity_NDVI", "SurfCity_NDWI")
# plot(st)
# finding out the extent and coordinate system
ex <- extent(st)
# find out the num of row and columns
n.row<-dim(st$NWI)[1];n.col <-dim(st$NWI)[2];
ncell(st$NWI)
my.crc <- crs(st$NWI)

#create a empty raster
r <- raster(ex, ncol=n.col, nrow=n.row, crs= my.crc)
r_new <- rasterize(pre[,1:2], r, pre[,3], fun=mean)
plot(r_new)

#save prediction raster in tif
writeRaster(r_new, filename = 'pre_RR_Quan_NoMS_cl.tif',options=c('TFW=YES'))

# show the variable plot
h2o.varimp_plot(rf.load)



