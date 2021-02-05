# Run TESAsamSim over scenarios


listOfPackages <- c("here", "parallel", "doParallel", "foreach",
                    "tidyverse", "tictoc", "TESAsamSim")
newPackages <- listOfPackages[!(listOfPackages %in%
                                  installed.packages()[ , "Package"])]
if (length(newPackages)) {
  install.packages(newPackages)
}
lapply(listOfPackages, require, character.only = TRUE)


## Load relevant input data

# CU-specific parameters
cuPar <- read.csv(here("data", "IFCohoPars", "CUpars.csv"),
                  stringsAsFactors=F)

# Stock-recruit and catch data that are used to populate the simulation priming
# period
srDat <- read.csv(here("data", "IFCohoPars", "cohoRecDatTrim.csv"),
                  stringsAsFactors=F)

# Simulation run parameters describing different scenarios
simPar <- read.csv(here("data", "IFCohoPars",
                        "SimPar.csv"),
                   stringsAsFactors = F)

# Directory where simulated data will be saved
scenNames <- unique(simPar$scenario)
dirNames <- sapply(scenNames, function(x) paste(x, unique(simPar$species),
                                                sep = "_Sig"))

# # loop through each scenario and simulate data
# for (i in 1:dim(simPar)[1] ) {
#   genericRecoverySim(simPar=simPar[i,], cuPar=cuPar,  srDat=srDat,
#                      variableCU=FALSE, ricPars=NULL,  dirName="runTESA",
#                      nTrials=2, makeSubDirs=FALSE, random=FALSE)
# }
#


## Divide each scenario into a list element to pass to parLapply()
nTrials <- 100
simsToRun <- split(simPar, seq(nrow(simPar)))
dirName <- "runTESA"
Ncores <- detectCores()
cl <- makeCluster(Ncores - 1) #save one core
registerDoParallel(cl)
clusterEvalQ(cl, c(library(TESAsamSim)))
clusterExport(cl, c("simsToRun", "cuPar", "nTrials", "dirName",
                    "srDat"), envir=environment())
tic("run in parallel")
parLapply(cl, simsToRun, function(x) {
  genericRecoverySim(x, cuPar=cuPar, srDat=srDat, catchDat=NULL,  variableCU=FALSE,
                     ricPars=NULL, larkPars=NULL, cuCustomCorrMat = NULL,
                     uniqueSurv=FALSE, dirName=dirName,
                     nTrials=nTrials, makeSubDirs=FALSE, random=FALSE)
})
stopCluster(cl) #end cluster
toc()

# okay <- readRDS(here("outputs", "simData", "runTESA",
#              "decLinearProdCap_ar.RData"))$srDatout


