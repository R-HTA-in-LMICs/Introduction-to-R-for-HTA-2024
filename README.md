# Introduction-to-R-for-HTA 2024: getting to grips with R for health economic decision modelling

<img src="img/logo.png" width="260" align="right" />
<br/>

This repository stores the code, presentations, and material used in the R-HTA in LMICs introductory 2024tutorial. The following sections provide a breakdown of the primary documents and guidance on how to use them for your own personal training. The tutorial is based on several open-source frameworks for basic survival analysis in R.

## Navigation

The [`R`](https://github.com/R-HTA-in-LMICs/Introduction-to-R-for-HTA-2024/tree/main/R) folder includes the R scripts of for basic data cleaning and initial statistical tests for the primary survuval analysis.

The [`excel`](https://github.com/R-HTA-in-LMICs/Introduction-to-R-for-HTA-2023/tree/main/excel) folder includes the original model's solution template, developed in Excel, provided by Oxford's [Health Economics Research Centre (HERC)](https://www.herc.ox.ac.uk/downloads/decision-modelling-for-health-economic-evaluation).

The [`analysis`](https://github.com/R-HTA-in-LMICs/Introduction-to-R-for-HTA-2023/tree/main/analysis) folder includes the secondary R script that produces the economic analysis from the results of the Markov model.

## Preliminaries

-  Install `devtools` to install [`darthtools`](https://github.com/DARTH-git/darthtools), which is an R package from [DARTH's GitHub](https://github.com/DARTH-git). See below:

```{r, eval=FALSE}
# Install release version from CRAN
install.packages("devtools")

# Or install development version from GitHub
# devtools::install_github("r-lib/devtools")
```

- then install `darthtools` using `devtools`

```{r, eval=FALSE}
# Install development version from GitHub
devtools::install_github("DARTH-git/darthtools")
```

## Citations

For syntax consistency, we follow the R syntax framework developed by the DARTH group:
-   Alarid-Escudero F, Krijkamp EM, Pechlivanoglou P, Jalal HJ, Kao SYZ, Yang A, Enns EA. [A Need for Change! A Coding Framework for Improving Transparency in Decision Modeling](https://link.springer.com/article/10.1007/s40273-019-00837-x). [PharmacoEconomics](https://www.springer.com/journal/40273), 2190;37(11):1329--1339. <https://doi.org/10.1007/s40273-019-00837-x>

# Additional Information

Visit our [webpage](https://r-hta-in-lmics.github.io/) and follow the links to our social media to keep up-to-date with our latest tutorials. Alternatively, follow us on [EventBrite](https://www.eventbrite.co.uk/o/r-hta-in-lmics-46016978693) to receive notifications as new events go live!