# Code to make some new plots for TESAsamSim
# Authors: Robyn Forrest and Luke Warkentin

# Feb 4, 2021

# Functions:
#
#   plot_bias_boxplots - this reads in the dlm model output and saves boxplots showing
#                         bias of estimates of alpha and beta for different scenarios
#
#
#

# load libraries - these will move to Rmd file
library(tidyverse)
library(purrr)
library(reshape2)
library(here)


# -------------------
# plot_bias_boxplots
# -------------------

# Read in outputs of fitDLM and save boxplots of bias of estimates of alpha and beta
# will need to change "example" to folder of automated outputs and scen to names of
#     scenarios from table of scenarios to loop over/map over

# pass in the pbias dataframe
plot_bias_boxplots <- function(pbias) {

 # x_discrete <-  # is the x variable of interest discrete? yes

alpha_bias <- pbias %>%
   as.data.frame() %>%
   dplyr::filter(parameter == "alpha_mpb") %>%
  ggplot(aes(x=factor(scenario), y=mpb, fill=estModel))+
    geom_boxplot(outlier.shape = NA)+
    #facet_wrap(vars(parameter))+
    xlab("Scenario") +
    ylab("Mean % bias") +
    ggtitle("alpha")+
    theme(legend.position = "none")+
    theme_bw()
 beta_bias <- pbias %>%
   as.data.frame() %>%
   dplyr::filter(parameter == "beta_mpb") %>%
  ggplot(aes(x=factor(scenario), y=mpb, fill=estModel))+
   geom_boxplot(outlier.shape = NA)+
   #facet_wrap(vars(parameter))+
   xlab("Scenario") +
   ylab("Mean % bias")+
   ggtitle("beta")+
   theme_bw()

 cowplot::plot_grid(alpha_bias, beta_bias, nrow=2)



# if(x_discrete == FALSE) {

# ggplot(data=pbias,aes(x= , y=mpb, fill=parameter))+ # x variable should be continuous variable from dlm_out
#   geom_boxplot(outlier.shape = NA)+
#   # xlab("Stock depletion") +
#   ylab("Mean % bias") +
#   coord_cartesian(ylim=c(-100,400))+
#   scale_fill_viridis_d(labels=c("alpha", "beta"))+
#   facet_wrap(~paste0("CU ", CU)) +
#   theme_bw()

#}


} # end of function



