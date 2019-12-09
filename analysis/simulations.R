# #########################################################################################################
# Script to do simulations of different experimental conditions
# #########################################################################################################

# working current directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# ****************
# packages
library(CellNOptR)
library(MEIGOR)
library(CNORode2017)
print(paste("CNORode version:", as.character(packageVersion("CNORode2017"))))

# ****************
# load data structure for predictions
MIDAS_fileName<-"../data//MIDAS_predictions.csv"
Mydata<-readMIDAS(MIDASfile=MIDAS_fileName)
cnolist_pred<-makeCNOlist(Mydata, subfield=F)
transferFun=4

load("../data/model.RData")

ode_parameters=createLBodeContPars(model, LB_n = 1, LB_k = 0,
                                   LB_tau = 0, UB_n = 3, UB_k = 1, UB_tau = 2, default_n = 3,
                                   default_k = 0.5, default_tau = 0.7, opt_n = FALSE, opt_k = TRUE,
                                   opt_tau = TRUE, random = TRUE)


# ****************
# load optimised models parameters
collected_opt_results = readRDS("../output/cellLines/parameters.RDS")
# retrieve the names of the optimized parameters
parNames <- ode_parameters$parNames[ode_parameters$index_opt_pars]

# extract parameters from the file where the optimization results were stored
# for AsPC1
opt_res_AsPC1 <- subset(collected_opt_results, cellline == "AsPC1")
opt_res_AsPC1 <- opt_res_AsPC1[order(opt_res_AsPC1$rep),]
opt_res_AsPC1 <- as.matrix(opt_res_AsPC1[,4:ncol(opt_res_AsPC1)])
colnames(opt_res_AsPC1) <- parNames
# and for BxPC3
opt_res_BxPC3 <- subset(collected_opt_results, cellline == "BxPC3")
opt_res_BxPC3 <- opt_res_BxPC3[order(opt_res_BxPC3$rep),]
opt_res_BxPC3 = as.matrix(opt_res_BxPC3[,4:ncol(opt_res_BxPC3)])
colnames(opt_res_BxPC3) <- parNames

res_parameters_bootstrap <- list(AsPC1 = opt_res_AsPC1,
                                 BxPC3 = opt_res_BxPC3)



# ****************
# simulate predictions
# example simulation for AsPC1 
pars_cellline <- res_parameters_bootstrap$AsPC1
# use the optimized parameters (e.g. the one from the first bootstra iteration in this case)
opt_pars_tmp <- ode_parameters
opt_pars_tmp$parValues[ode_parameters$index_opt_pars] <- pars_cellline[1,]
# plot is saved in pdf file because too big to visualize
pdf("temp.pdf",width=30,height=20);
simulatedData=plotLBodeFitness(cnolist_pred, model, transfer_function=transferFun, ode_parameters=opt_pars_tmp, reltol = 1e-6, atol = 1e-6, maxStepSize = 1)
dev.off()

