# Load libraries ----------------------------------------------------------
## names of required packages for analysis:
pkgs <- c("tidyverse", "survival", "survminer", "flexsurv", "gtsummary", 
          "eeptools", "muhaz")
## install packages not yet installed:
installed_packages <- pkgs %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(pkgs[!installed_packages])
}
## loop through packages list by applying lapply function and load packages 
invisible(lapply(pkgs, library, character.only = TRUE))

# Source ------------------------------------------------------------------
## call cleaned data objects from data transformation script
source("analysis/SurvivalRHTA.R")
# Parametric Analyses ----------------------------------------------------
### Exponential ----------------------------------------------------------
surv_os_exponential <- flexsurvreg(
  Surv(time, status) ~ x,
  data = aml, 
  dist = "exponential"
  )
# inspect model...
surv_os_exponential

### Weibull PH -----------------------------------------------------------
surv_os_weibullPH <- flexsurvreg(
  Surv(time, status) ~ x,
  data = aml, 
  dist = "weibullPH"
  )
# inspect model...
surv_os_weibullPH

## Parametric Model Fit Inspection ---------------------------------------
### Exponential Model ----------------------------------------------------
## AIC
n_os_aic_exponential <- surv_os_exponential$AIC
## BIC
n_os_bic_exponential <- -2 * surv_os_exponential$loglik +
  (length(surv_os_exponential$coefficients) * log(
    sum(surv_os_exponential$data$m["(weights)"]))
   )
## Cox-Snell Residuals
v_os_csr_exponential <- coxsnell_flexsurvreg(surv_os_exponential)

### Weibull PH ------------------------------------------------------------
## AIC
n_os_aic_weibullPH <- surv_os_weibullPH$AIC
## BIC
n_os_bic_weibullPH <- -2 * surv_os_weibullPH$loglik +
  (length(surv_os_weibullPH$coefficients) * log(
    sum(surv_os_weibullPH$data$m["(weights)"]))
  )
## Cox-Snell Residuals
v_os_csr_weibullPH <- coxsnell_flexsurvreg(surv_os_weibullPH)

### AIC Table ------------------------------------------------------------
# AIC Table: Type-I
tbl_aic <- cbind(
 "AIC: Extrapolation Models" = sort(
  c("Exponential Model" = n_os_aic_exponential,
    "Weibull PH Model" = n_os_aic_weibullPH),
  decreasing = FALSE)
 )

### BIC Table ------------------------------------------------------------
# BIC Table: Treatment
tbl_bic <- cbind(
  "BIC: Extrapolation Models" = sort(
   c("Exponential Model" = n_os_bic_exponential,
     "Weibull PH Model" = n_os_bic_weibullPH),
   decreasing = FALSE)
  )

## Summary of Model fit -----------------------------------------------
tbl_aic
# AIC: exponential is best fit
tbl_bic
# BIC: exponential is best fit

# Based on visual inspection of these models...
surv_os_exponential
ggsurvplot(surv_os_exponential, conf.int = TRUE)
# generate HR
exp(surv_os_exponential$res.t[2, 1]) # or...
exp(coef(surv_os_exponential)[2])

# compared to cox model...
coxph(Surv(time = time, event = status) ~ x, data = aml)

surv_os_weibullPH
ggsurvplot(surv_os_weibullPH, data = aml, conf.int = TRUE)
# generate HR
exp(surv_os_weibullPH$res.t[3, 1]) # or...
exp(coef(surv_os_weibullPH)[3])

# exponential cs residuals
plot(survfit(Surv(v_os_csr_exponential$est, status) ~ x, 
             data = aml), 
     fun = "cumhaz")
abline(0, 1, col = "red")
# weibull PH cs residuals
plot(survfit(Surv(v_os_csr_weibullPH$est, status) ~ x, 
             data = aml), 
     fun = "cumhaz")
abline(0, 1, col = "red")

# End file ----------------------------------------------------------------