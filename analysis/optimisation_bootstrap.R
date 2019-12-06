# #########################################################################################################
# Script to run the optimisation on the cluster
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
# input arguments
argsJob= commandArgs(trailingOnly=TRUE)
MIDAS_fileName=toString(argsJob[1])
print(MIDAS_fileName)
repIndex=as.numeric(argsJob[2])

# ****************
# load MIDAS files
setwd("../data/MIDAS_files")
Mydata<-readMIDAS(MIDASfile=MIDAS_fileName)
cnolist<-makeCNOlist(Mydata, subfield=F)

# ****************
# load PKN
setwd("../data/")
pknmodel<-readSIF("PKN_curated.sif")

# ****************
# compress and expand the network
model<-preprocessing(data=cnolist, model=pknmodel, compression=TRUE, expansion=FALSE)

# ****************
# set initial parameters 
ode_parameters=createLBodeContPars(model, LB_n = 1, LB_k = 0,
                                   LB_tau = 0, UB_n = 3, UB_k = 1, UB_tau = 2, default_n = 3,
                                   default_k = 0.5, default_tau = 0.7, opt_n = FALSE, opt_k = TRUE,
                                   opt_tau = TRUE, random = TRUE)

# ****************
# set optimisation parameters 
paramsSSm=defaultParametersSSm()
paramsSSm$local_solver = "DHC"
paramsSSm$maxtime = 5400
paramsSSm$maxeval = Inf
paramsSSm$atol=1e-6
paramsSSm$reltol=1e-6
paramsSSm$nan_fac=1000
paramsSSm$dim_refset=30
paramsSSm$n_diverse=1000
paramsSSm$maxStepSize=Inf
paramsSSm$maxNumSteps=10000
transferFun=4
paramsSSm$transfer_function = transferFun

paramsSSm$bootstrap=T
paramsSSm$SSpenalty_fac=5
paramsSSm$SScontrolPenalty_fac=10
paramsSSm$verbose=T
paramsSSm$lambda_k=0
paramsSSm$lambda_tau=0
paramsSSm$boot_seed=repIndex

# ****************
# run parameters optimisation
opt_pars=parEstimationLBode(cnolist,model, method="essm", ode_parameters=ode_parameters, paramsSSm=paramsSSm)


# ****************
# create one directory per cell line if it does't already exist
dataFileName<-strsplit(MIDAS_fileName, split="\\.")[[1]][1]
mainDir<-"../output/r_bootstrap/"
subDir <- dataFileName

setwd(mainDir)

if (file.exists(subDir)){
  setwd(file.path(mainDir, subDir))
} else {
  dir.create(file.path(subDir))
  setwd(file.path(subDir)) 
}


# ****************
# save the results

# pdf(paste('bootstrap_fit_', repIndex, ".pdf", sep=""),width=30,height=20);
simulatedData=plotLBodeFitness(cnolist, model, transfer_function=transferFun, ode_parameters=opt_pars, reltol = 1e-6, atol = 1e-6, maxStepSize = 1)
# dev.off()

# ****************
# save the data
fileName<-paste(dataFileName, "_rep", repIndex, ".RData", sep="")
save(list=c("simulatedData", "opt_pars", "model", "cnolist"), file=fileName)

if (repIndex%%10 == 0){
   pdf(paste('bootstrap_fit_', repIndex, ".pdf", sep=""),width=30,height=20);
   simulatedData=plotLBodeFitness(cnolist, model, transfer_function=transferFun, ode_parameters=opt_pars, reltol = 1e-6, atol = 1e-6, maxStepSize = 1)
   dev.off()
}


