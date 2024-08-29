#install.packages("IPDfromKM")
library(IPDfromKM)

###Get points from KM curves
#getpoints("~/Desktop/R-HTA/August 2024/OS_RHTA.png",x1=0, x2=54, y1=0, y2=100)

Osimertinib_KM <- data.frame(getpoints("~/Desktop/R-HTA/August 2024/OS_RHTA.png",x1=0, x2=54, y1=0, y2=100))
Comparator <- data.frame(getpoints("~/Desktop/R-HTA/August 2024/OS_RHTA.png",x1=0, x2=54, y1=0, y2=100))


##Download as Excel file
#install.packages("openxlsx")
library(openxlsx)
write.xlsx(Osimertinib_KM, file = "~/Desktop/Osimertinib_KM.xlsx", rowNames = FALSE)
write.xlsx(list("Osimertinib_KM" = Osimertinib_KM, "Comparator" = Comparator), 
           file = "~/Desktop/Osimertinib_KM_Comparator.xlsx", rowNames = FALSE)


##Upload as Excel file
#install.packages("readxl")
library(readxl)
T1_OS <- read_excel("~/Desktop/R-HTA/August 2024/Osimertinib_KM_Comparator.xlsx", 
                    sheet = "T1_OS")
T2_OS <- read_excel("~/Desktop/R-HTA/August 2024/Osimertinib_KM_Comparator.xlsx", 
                    sheet = "T2_OS")


###Defining parameters for PREPPROCESS- T1 (intervention) and T2 (control) for Overall Survival (OS)
pre <- preprocess(dat=T1_OS[,1:2], trisk=T1_OS$Time[1:19], nrisk=T1_OS$`Pat. At. Risk`[1:19], maxy=100)
pre_control <-preprocess(dat=T2_OS[,1:2], trisk=T2_OS$Time[1:19], nrisk=T2_OS$`Pat. At. Risk`[1:19], maxy=100)

###Defining parameters for GETIPD- T1 (intervention) and T2 (control) for Overall Survival (OS)
est <- getIPD(prep=pre,armID=1)
est_control<- getIPD(prep=pre_control,armID=2)


###IPD -------
est$IPD
est_control$IPD

#### VALIDATION
summary(est)
summary(est_control)
plot(est)
plot(est_control)
report<-survreport(ipd1 = est$IPD,ipd2 = est_control$IPD, arms = 2, interval=1, s=c(0.5,0.75,0.99))

###Calculating HR from our data for Validation
data_fco <- rbind(est$IPD, est_control$IPD)
data.survdiff <- survdiff(Surv(time, status) ~ treat, data=data_fco)
HR = (data.survdiff$obs[2]/data.survdiff$exp[2])/(data.survdiff$obs[1]/data.survdiff$exp[1])
up95 = exp(log(HR) + qnorm(0.975)*sqrt(1/data.survdiff$exp[2]+1/data.survdiff$exp[1]))
low95 = exp(log(HR) - qnorm(0.975)*sqrt(1/data.survdiff$exp[2]+1/data.survdiff$exp[1]))
resultados_cox_data_1 <- cbind(1/HR,1/up95,1/low95)
colnames(resultados_cox_data_1) <- c("HR", "IC95MIN", "IC95MAX")
resultados_cox_data_1

#### Kapplan Meier
#Intervention
KM.est_fco <- survfit(Surv(time, status) ~ treat, data=est$IPD, type="kaplan-meier")
tiempos <- seq(from=0, to=max(T1_OS$Time[1:19]), by=1)
summaryKM_fco <- summary(KM.est_fco, tiempos)
#Comparator
KM.est_fco_control <- survfit(Surv(time, status) ~ treat, data=est_control$IPD, type="kaplan-meier")
tiempos_control <- seq(from=0, to=max(T2_OS$Time[1:19]), by=1)
summaryKM_fco_control <- summary(KM.est_fco, tiempos_control)

