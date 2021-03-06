#' Build output dataframes for CU data
#'
#' This is one of two sister functions that are extensions of
#' \code{genOutputList} and used to builds dataframes around key variables that
#' change across scenarios. One is for CU-specific data and the other for
#' aggregate data. Each combination of directory, subdirectory, and key
#' variable levels should represent a unique scenario (i.e. they can vary across
#' up to three dimensions). For example, different key variables (proportion
#' allocated to mixed fisheries) nested within OM (productivity regime) nested
#' within higher level MP or additional OM (e.g. fixed exploitation or TAM
#' rule).
#'
#' @importFrom here here
#'
#' @param dirNames A character vector representing directories, each of which
#' contains multiple scenarios nested within subdirectories.
#' @param cuVars A character vector representing CU-specific performance metrics
#' to include in the dataframe.
#' @param keyVarName A character vector specifying which variable differs among
#' scenarios within a subdirectory within a directory (e.g. fixed exploitation
#' rate).
#' @param selectedCUs An optional character vector of CU names used to subset
#' output data if CU-specific data are being pulled (i.e. \code{agg = FALSE}).
#' @return Returns a dataframe with columns for the keyVariable, management
#' procedure, operating model, plotOrder, cuName, muName, variable, its median
#' value, its lower quantile, and its upper quantile.
#'
#' @examples
#'
#' @export

buildDataCU <- function(dirNames, cuVars, keyVarName, selectedCUs = NULL) {
  cuData = NULL #construct CU dataframe
  for (i in seq_along(dirNames)) {
    #alternatively ID OMs based on prespecified directory
    subDirs <- list.dirs(path = paste(here::here("outputs/simData"),
                                      dirNames[i], sep = "/"),
                         full.names = FALSE, recursive = FALSE)

    if (length(subDirs) == 0) {
      subDirs <- "blank"
    }
    for (j in seq_along(subDirs)) {
      if (is.null(selectedCUs == TRUE)) {
        cuList <- if (subDirs[j] == "blank") {
          genOutputList(dirNames[i], agg = FALSE)
        } else {
          genOutputList(dirNames[i], subDirs[j], agg = FALSE)
        }
      } else {
        cuList <- if (subDirs[j] == "blank") {
          genOutputList(dirNames[i], selectedCUs = selectedCUs, agg = FALSE)
        } else {
          genOutputList(dirNames[i], subDirs[j], selectedCUs = selectedCUs,
                        agg = FALSE)
        }
      }
      nCU <- length(cuList[[1]]$stkName)
      keyVarValue <- rep(sapply(cuList, function(x) unique(x$keyVar)),
                         each  = nCU)
      plotOrder <- rep(sapply(cuList, function(x) unique(x$plotOrder)),
                       each = nCU)
      cuName <- as.vector(sapply(cuList, function(x) x$stkName))
      muName <- as.vector(sapply(cuList, function(x) x$manUnit))
      singleScenDat = NULL
      for (k in seq_along(cuVars)) {
        dum <- data.frame(keyVar = keyVarValue,
                          mp = rep(sapply(cuList, function(x) x$manProc),
                                   each = nCU),
                          om = rep(sapply(cuList, function(x) x$opMod),
                                   each = nCU),
                          hcr = rep(sapply(cuList, function(x) x$hcr),
                                    each = nCU),
                          plotOrder = as.factor(plotOrder),
                          cuName = as.factor(cuName),
                          muName = as.factor(muName),
                          var = rep(cuVars[k], length.out = length(cuList)),
                          avg = as.vector(sapply(cuList, function(x)
                            apply(x[[cuVars[k]]], 2, median))),
                          lowQ = as.vector(sapply(cuList, function(x)
                            apply(x[[cuVars[k]]], 2, qLow))),
                          highQ = as.vector(sapply(cuList, function(x)
                            apply(x[[cuVars[k]]], 2, qHigh))),
                          row.names = NULL
        )
        singleScenDat <- rbind(singleScenDat, dum, row.names = NULL)
      }
      names(singleScenDat)[1] <- keyVarName
      cuData <- rbind(cuData, singleScenDat)
    }
  }
  return(cuData)
}

# _____________________________________________________________________________

#' Build output dataframes for aggregate data
#'
#' This is one of two sister functions that are extensions of
#' \code{genOutputList} and used to builds dataframes around key variables that
#' change across scenarios. One is for CU-specific data and the other for
#' aggregate data. Each combination of directory, subdirectory, and key
#' variable levels should represent a unique scenario (i.e. they can vary across
#' up to three dimensions). For example, different key variables (proportion
#' allocated to mixed fisheries) nested within OM (productivity regime) nested
#' within higher level MP or additional OM (e.g. fixed exploitation or TAM
#' rule).
#'
#' @importFrom here here
#'
#' @param dirNames A character vector representing directories, each of which
#' contains multiple scenarios nested within subdirectories.
#' @param agVars A character vector representing aggregate performance metrics
#' to include in the dataframe.
#' @param keyVarName A character vector specifying which variable differs among
#' scenarios within a subdirectory within a directory (e.g. fixed exploitation
#' rate).
#' @return Returns a dataframe with columns for the keyVariable, management
#' procedure, operating model, plotOrder, variable, its median value, its lower
#' quantile, and its upper quantile.
#'
#' @examples
#'
#' @export

buildDataAgg <- function(dirNames, agVars, keyVarName) {
  agData = NULL #construct aggregate dataframe
  for (i in seq_along(dirNames)) {
    #alternatively ID OMs based on prespecified directory
    subDirs <- list.dirs(path = paste(here::here("outputs/simData"),
                                      dirNames[i], sep = "/"),
                         full.names = FALSE, recursive = FALSE)

    ## NEED TO REPLACE WITH TRUE CONDITIONAL BASED ON INPUT ARGUMENT
    if (length(subDirs) == 0) {
      subDirs <- "blank"
    }
    for (j in seq_along(subDirs)) {
      #set subdirectory to blank if there aren't any present
      agList <- if (subDirs[j] == "blank") {
        genOutputList(dirNames[i], agg = TRUE)
      } else {
        genOutputList(dirNames[i], subDirs[j], agg = TRUE)
      }
      singleScenDat = NULL
      for (k in seq_along(agVars)) {
        dum <- data.frame(keyVar = sapply(agList, function(x)
          unique(as.character(x$keyVar))),
          om = sapply(agList, function(x) unique(x$opMod)),
          mp = sapply(agList, function(x) unique(x$manProc)),
          hcr = sapply(agList, function(x) unique(x$hcr)),
          plotOrder = sapply(agList, function(x)
            unique(x$plotOrder)),
          var = rep(agVars[k], length.out = length(agList)),
          avg = as.vector(sapply(agList, function(x)
            median(x[[agVars[k]]]))),
          lowQ = as.vector(sapply(agList, function(x)
            qLow(x[[agVars[k]]]))),
          highQ = as.vector(sapply(agList, function(x)
            qHigh(x[[agVars[k]]]))),
          row.names = NULL
        )
        singleScenDat <- rbind(singleScenDat, dum, row.names = NULL)
      }
      names(singleScenDat)[1] <- keyVarName
      agData <- rbind(agData, singleScenDat)
    }
  }
  return(agData)
}
