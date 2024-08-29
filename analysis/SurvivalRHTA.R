
## Main packages.
#install.packages("survival")
#install.packages("survminer")
#install.packages("broom")
#install.packages("ggplot2")
library(survival)
library(broom) 
library(survminer) 
library(ggplot2) 

## Database: Acute Myelogenous Leukemia survival data ("aml")
head(aml)
aml
aml <-aml

## Kaplan-Meier estimation with survfit()
KM <- survfit(Surv(time = time, event = status) ~ 1, data=aml)
KM
plot(KM)

## Table of KM survival function
tidy(KM)

## Stratified Kaplan-Meier estimates by treatment category
KM.x <- survfit(Surv(time = time, event = status) ~ x, data=aml)
KM.x
plot(KM.x)
tidy(KM.x)

## Graphing the survival function
plot(KM, ylab="survival probability", xlab="months")

## Graphing stratified KM estimates of survival
# stratified KM curves with 95% CI, 2 colors
plot(KM.x, ylab="survival probability", xlab="months",
     conf.int=FALSE, col=c("red", "blue")) 


## Customizable, informative survival plots with survminer
ggsurvplot(KM.x, conf.int=T)


## Adding a risk table
ggsurvplot(KM.x, conf.int=T,
           risk.table=T)


## Comparing survival functions with `survdiff()`
# log rank test
survdiff(Surv(time, status) ~ x, data=aml)


## Fitting a Cox model
##Database: "Lung"
lung
KM.lung <- survfit(Surv(time = time, event = status) ~ 1, data=lung)
tidy(KM.lung)
# Fit cox model 
coxph(Surv(time=time, event=status) ~ age + sex + wt.loss, data=lung)
lung.cox <- coxph(Surv(time, status) ~ age + sex + wt.loss, data=lung)
# summary of results
summary(lung.cox)

KM.lung <- survfit(lung.cox) 
plot(KM.lung, ylab="survival probability", xlab="days")


#### Exercises using the "veteran" dataset ------

# Exercise #1 Generate a table of the survival function for the "veteran" dataset.
# Exercise #2 Create a Kaplan-Meier plot for the "veteran" dataset.
# Exercise #3 Assess statistical differences stratified by treatment (variable "trt").
# Exercise #4 Create a Kaplan-Meier plot for the "veteran" dataset stratified by treatment (variable "trt").

veteran

#### Solutions to Exercises --------
### Exercise #1 
KM.veteran <- survfit(Surv(time=time,event=status)~1, data=veteran)
KM.veteran
tidy(KM.veteran)

### Exercise #2
plot(KM.veteran, ylab="survival probability", xlab="days")

### Exercise #3
KM.treat <- survfit(Surv(time,status)~trt, data=veteran)
survdiff(Surv(time,status)~trt, data=veteran)

### Exercise #4
ggsurvplot(KM.treat, conf.int=T)


