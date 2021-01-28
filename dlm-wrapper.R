# DLM wrapper function ===============================================================================
#
# Description: wrapper for Maximum likelihood estimation, Kalman filtering and smoothing of normal linear
#             State Space models, also known as Dynamic Linear Models, using the dlm package by
#             Giovanni Petris (U of Arkansas). Adapted from code generously provided by Cody Szuwalski (NOAA)
#
# data: a dataframe with three columns for brood years ("byr"), corresponding spawner abundance ("spwn")
#       and resulting recruitment ("rec")
# alpha_vary: should alpha (intercept) be estimated as time varying?
# beta_vary: should beta (slope) be estimated as time varying?

library(dlm)

fitDLM <- function(data = bt,
                   alpha_vary = FALSE,
                   beta_vary = FALSE){

  # 0. housekeeping
  lnRS <- log(data$rec/data$spwn)
  alpha <- NULL
  beta <- NULL

  # 1. create a dlm representation of a linear regression model
  mod <- dlmModReg(data$spwn) # this specifies a linear model

  # 2. number of parameters used in the AICc calculation
  dlmPars=3
  if(alpha_vary==TRUE & beta_vary==FALSE){dlmPars=4}
  if(alpha_vary==FALSE & beta_vary==TRUE){dlmPars=4}
  if(alpha_vary==TRUE & beta_vary==TRUE){dlmPars=5}

  # 3. specify the model based on variance structure
  build_mod <- function(parm)
  {
    mod$V <- exp(parm[1])
    if(alpha_vary==TRUE & beta_vary==FALSE){mod$W[1,1]=exp(parm[2]); mod$W[2,2]=0}
    if(alpha_vary==FALSE & beta_vary==TRUE){mod$W[1,1]=0; mod$W[2,2]=exp(parm[2])}
    if(alpha_vary==TRUE & beta_vary==TRUE){mod$W[1,1]=exp(parm[2]); mod$W[2,2]=exp(parm[3])}
    return(mod)
  }

  # 4.  maximum likelihood optimization of the variance
  dlm_out<-dlmMLE(y=lnRS, build=build_mod, parm=c(-.1,-.1,-.1), method="Nelder-Mead")

  # 5. log-likelihood
  lls <- dlm_out$value

  # 6. specify the model based on variance structure
  dlmMod <- build_mod(dlm_out$par)

  # 7. apply Kalman filter
  outsFilter <- dlmFilter(y=lnRS,mod=dlmMod)

  # 8. backward recursive smoothing
  outsSmooth	<-dlmSmooth(outsFilter)

  # 9. grab parameters, their SEs and calculate AICc
  lnalpha<- cbind(alpha,outsSmooth$s[-1,1,drop=FALSE])
  beta<- cbind(beta,outsSmooth$s[-1,2,drop=FALSE])
  lnalpha_se <- sqrt(array(as.numeric(unlist(dlmSvd2var(outsSmooth$U.S, outsSmooth$D.S))), dim=c( 2, 2,length(lnRS)+1)))[1,1,-1]
  beta_se <- sqrt(array(as.numeric(unlist(dlmSvd2var(outsSmooth$U.S, outsSmooth$D.S))), dim=c( 2, 2,length(lnRS)+1)))[2,2,-1]
  AICc	<- 2*lls + 2*dlmPars +(2*dlmPars*(dlmPars+1)/(length(data$rec)-dlmPars-1))

  # 10. output results
  results <- cbind(data,lnalpha, beta,lnalpha_se,beta_se)
  output <- list(results=results,AICc=AICc)

}
