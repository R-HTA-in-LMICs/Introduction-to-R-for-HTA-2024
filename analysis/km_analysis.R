# Intro to Survival Analysis for HTA --------------------------------------
# This script is an an introduction to survival analysis, presented in the
# R-HTA in LMICS Introduction to R Tutorial: 2024.

# Load Packages -----------------------------------------------------------
## names of required packages for analysis:
pkgs <- c("tidyverse", "survival", "survminer", "flexsurv", "gtsummary", 
          "eeptools", "muhaz", "broom", "openxlsx")
## install packages not yet installed:
installed_packages <- pkgs %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(pkgs[!installed_packages])
}
## loop through packages list by applying lapply function and load packages 
invisible(lapply(pkgs, library, character.only = TRUE))

# alternatively, if you struggle understanding the above code, you can also
# install and load each package one-by-one as shown below for the survival 
# package(remove the # sign in the two lines below to see how!):
#install.packages("survival")
#library(survival)

# Load Data ---------------------------------------------------------------
# for this analysis we are using a freely available oncology data set, which
# comes as a part of the survival package
data(cancer, package = "survival")
# assign data to object for easy access
df_aml <- aml
# display head of data
head(df_aml)

# Non-stratified Kaplan-Meier Analysis -------------------------------------
model_km_nstr <- survfit(
 Surv(time, status) ~ 1, data = df_aml) # ~ 1 indicates KM survival estimates for whole sample
# show model results...
model_km_nstr # same as line below
print(model_km_nstr) # same as line above
# inspect the predictions:
summary(model_km_nstr)
## plot KM predicted overall survival for all patients...
ggsurvplot(model_km_nstr, conf.int = TRUE, censor = TRUE, 
           tables.height = 0.3, palette = "#BD1622",
           title ="Non-stratified Kaplan-Meier: Overall survival",
           xlab = "Months", risk.table = TRUE, 
           ylim = c(0, 1)
           )
# but this is for all patients, regardless of treatment arm. What would we see
# if we stratified patients (assuming treatment/strategy affects overall 
# survival)?

# Stratified Kaplan-Meier Analysis ----------------------------------------
# To do this, we will need an indicator variable so that our code can identify
# which treatment/strategy a patient was one. So, let's first make sure our 
# data are correctly defined.
str(df_aml$x)
# okay, good. The arm variable is a factor!

# let's go ahead and fit a stratified KM:
model_km_strat <- survfit(
 Surv(time, status) ~ x, data = df_aml) # ~ x is the indicator variable 
# show model results...
model_km_strat # same as line below
print(model_km_strat) # same as line above
# inspect the predictions:
summary(model_km_strat)
## plot KM predicted overall survival for all patients...
ggsurvplot(model_km_strat, conf.int = TRUE, censor = TRUE, 
           tables.height = 0.3, palette = c("#BD1622", "#237085"),
           title ="Stratified Kaplan-Meier: Overall survival",
           xlab = "Months", risk.table = TRUE, 
           ylim = c(0, 1)
           )

### OS cumulative hazards -------------------------------------------------
# cumulative hazards statistic for overall survival for all types
surv_cumhaz_os <- ggsurvplot(
  model_km_strat, fun = "cumhaz", conf.int = FALSE, censor = TRUE,
  risk.table = TRUE, risk.table.y.text = FALSE, risk.table.fontsize = 3,
  tables.height = 0.3, xlab = "Years", title ="Cumulative hazard: overall survival",
  palette = c("#BD1622", "#237085"),
)
surv_cumhaz_os # (O-E)^2/V is the bases for the log-rank test
# cumulative hazards for overall survival by strategy

# Conclusion: proportional hazards assumption appears reasonable from visual
# inspection of the cumulative hazards.

# Statistical Tests for Kaplan-Meier --------------------------------------
## Log-Rank Test
# log-rank statistic for overall survival for all patients
surv_lr_os <- survdiff(
 Surv(time, status) ~ x, data = df_aml, rho = 0) # rho = 0 is Mantel-Haenszel test
surv_lr_os

## Peto-Peto Test
surv_pp_os <-  survdiff(
 Surv(time, status) ~ x, data = df_aml, rho = 1) # same as above, but rho = 1 
                                                 # is Peto-Peto test
surv_pp_os
# test-statistic indicates a slightly differing result than the log-rank
# test. However, from visual inspection of the KM survivor functions,
# it is sensible to conclude that proportional hazards holds.

## Which Test Should We Lean On for Reasoning About Our Assumptions?
# The log-rank test is more suitable when the alternative to the null 
# hypothesis, of no difference between two groups of survival times, is that
# the hazard of death at any given time for an individual in one group is
# proportional to the hazard at that time for a similar individual in the
# other group. However, the Peto-Peto test performs better when the 
# censoring pattern differs between groups. Hence, if the proportional 
# hazards assumption is in doubt, the Peto-Peto test is preferable.

# Using this in relation to the data we are analysing here, the log-rank
# test seems to be the preferable test-statistic. However, we know that
# patients in these data are generally similar despite observing that the 
# censoring between groups potentially varies. Visually, we can also see that 
# it is reasonable to assume proportional hazards between groups.

## ----Stratified Kaplan-Meier estimates-----------------------------------------------
# stratify by x variable
survfit(Surv(time, status) ~ x, data=aml)

# median survival by strata
KM.x


## ----tidy KM strat-------------------------------------------------------------------
# KM estimated survival functions by strata
tidy(KM.x)


## ----Graphing stratified KM estimates of survival------------------------------------
# stratified KM curves with 95% CI, 2 colors
plot(KM.x, ylab="survival probability", xlab="months",
     conf.int=T, col=c("red", "blue")) 


## ----Customizable, informative survival plots with survminer-------------------------
ggsurvplot(KM.x, conf.int=T)


## ----adding risk table---------------------------------------------------------------
ggsurvplot(KM.x, conf.int=T,
           risk.table=T)


## ----passing ggplot arguments--------------------------------------------------------
ggsurvplot(KM.x, conf.int=T, 
           risk.table=T,
           palette="Accent", # argument to scale_color_brewer()
           size=2, # argument to geom_line()
           ggtheme = theme_minimal()) # changing ggtheme


## ----traditional ggplot syntax-------------------------------------------------------
g <- ggsurvplot(KM.x, conf.int=T,
                risk.table=T)$plot  # this is the ggplot object
g + scale_fill_grey() + scale_color_grey()


## ----Comparing survival functions with `survdiff()`----------------------------------
# log rank test, default is rho=0
survdiff(Surv(time, status) ~ x, data=aml)


## ----Fitting a Cox model-------------------------------------------------------------
##Database: 
# fit cox model and save results
lung.cox <- coxph(Surv(time, status) ~ age + sex + wt.loss, data=lung)
# summary of results
summary(lung.cox)


## ----Tidy coxph() results------------------------------------------------------------
# save summarized results as data.frame
#  exponentiate=T returns hazard ratios
lung.cox.tab <- tidy(lung.cox, exponentiate=T, conf.int=T) 

# display table   
lung.cox.tab


## ----plot of coefficients------------------------------------------------------------
# plot of hazard ratios and 95% CIs
ggplot(lung.cox.tab, 
       aes(y=term, x=estimate, xmin=conf.low, xmax=conf.high)) + 
  geom_pointrange() +  # plots center point (x) and range (xmin, xmax)
  geom_vline(xintercept=1, color="red") + # vertical line at HR=1
  labs(x="hazard ratio", title="Hazard ratios and 95% CIs") +
  theme_classic()


## ----Predicting survival after coxph() with survfit()--------------------------------
# predict survival function for subject with means on all covariates
surv.at.means <- survfit(lung.cox) 

#table of survival function
tidy(surv.at.means)


## ----Plotting survival curves--------------------------------------------------------
# plot of predicted survival for subject at means of covariates
plot(surv.at.means, xlab="days", ylab="survival probability")


## ----Predicting survival at specific covariate values--------------------------------
# create new data for plotting: 1 row for each sex
#  and mean age and wt.loss for both rows
plotdata <- data.frame(age=mean(lung$age),
                       sex=1:2,
                       wt.loss=mean(lung$wt.loss, na.rm=T))

# look at new data
plotdata


## ----tidy predicted by sex-----------------------------------------------------------
# get survival function estimates for each sex
surv.by.sex <- survfit(lung.cox, newdata=plotdata) # one function for each sex

# tidy results
tidy(surv.by.sex)


## ----Plotting multiple predicted survival functions----------------------------------
# plot survival estimates
plot(surv.by.sex, xlab="days", ylab="survival probability",
     conf.int=T, col=c("blue", "red"))


## ----ggsurvplot multiple survival functions------------------------------------------
# data= is the same data used in survfit()
#  censor=F removes censoring symbols
ggsurvplot(surv.by.sex, data=plotdata, censor=F,
           legend.labs=c("male", "female")) 


## ----Assessing the proportional hazards assumption-----------------------------------
cox.zph(lung.cox)


## ----PH assessment plot--------------------------------------------------------------
plot(cox.zph(lung.cox))


## ----original model------------------------------------------------------------------
# reprinting original model results
summary(lung.cox)


## ----Stratified Cox model------------------------------------------------------------
lung.strat.sex <- coxph(Surv(time, status) ~ age + wt.loss + strata(sex), data=lung)
summary(lung.strat.sex)


## ----Modeling time-varying coefficients----------------------------------------------
# notice sex and tt(sex) in model formula
lung.sex.by.time <- coxph(Surv(time, status) ~ age + wt.loss + sex + tt(sex), # sex and tt(sex) in formula
                          data=lung,
                          tt=function(x,t,...) x*t) # linear change in effect of sex
summary(lung.sex.by.time)



## ----graph of smoothed residuals again-----------------------------------------------
plot(cox.zph(lung.cox), var="sex")


## ----Time-varying covariates---------------------------------------------------------
head(jasa1)


## ----coxph with time-varying covariates----------------------------------------------
jasa1.cox <- coxph(Surv(start, stop, event) ~ transplant + age + surgery, data=jasa1)
summary(jasa1.cox)


## ----after coxph with time-varying covariates----------------------------------------
# check PH assumptions
cox.zph(jasa1.cox)



#### EXERCISE 2 ####

#### Solutions to Exercises ###

## ----Exercise 1, echo=F, eval=F----------------------------------------------------------
## # estimate survival for whole data set
KM.all <- survfit(Surv(time,status)~1, data=veteran)
## # median survival time
KM.all
## # plot survival function
plot(KM.all)
## # table of survival function
tidy(KM.all)
## 
## # survival stratified by treatment
KM.treat <- survfit(Surv(time,status)~trt, data=veteran)
## # stratified plot
ggsurvplot(KM.treat, conf.int=T)
## # log-rank test
survdiff(Surv(time,status)~trt, data=veteran)


## ----Exercise 2, echo=F, eval=F------------------------------------------------------
# fit model
veteran.cox <- coxph(Surv(time, status) ~ trt + age, data=veteran)
summary(veteran.cox)
# asses PH
cox.zph(veteran.cox)
plot(cox.zph(veteran.cox))
# fit model allowing effect of trt to vary with time
veteran.cox.nonph <- coxph(Surv(time, status) ~ trt + tt(trt) + age, data=veteran, tt=function(x,t,...) x*t)
summary(veteran.cox.nonph)

