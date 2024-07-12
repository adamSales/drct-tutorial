---
title: "Estimating Heterogeneous Effects from a Bernoulli Experiment: Solutions"
output: html_notebook
---
  

### Step 0: Preliminaries

Install all the necessary packages:

```r
needed.packages <- c("devtools","sandwich","lmtest",
                     "rpart","rpart.plot")
new.packages <- needed.packages[!(needed.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

if(!require(dRCT)) devtools::install_github("manncz/dRCT",upgrade = FALSE)
```

Load in the required packages:

```r
library(dRCT)
library(sandwich)
library(lmtest)
```

```
## Warning: package 'lmtest' was built under R version 4.4.1
```

```
## Loading required package: zoo
```

```
## 
## Attaching package: 'zoo'
```

```
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
```

```r
library(rpart)
library(rpart.plot)
```

```
## Warning: package 'rpart.plot' was built under R version 4.4.1
```

This process builds off of the average effect estimation from earlier. 
If you are just opening `R`, you may need to either load in the earlier results, or calculate them from scratch:

```r
if(!exists("est_reloop")){
  if(file.exists("abResults.RData")){
    load("abResults.RData")
  } else{
    abdat <- read.csv('../data/abTestExample.csv')
    Tr= abdat$video
    Y = abdat$completion
    covariates= abdat[,2:10]
    yhat_nn <- read.csv('../data/yhatNN.csv')[,1]
    est_reloop <- loop(Y = Y, Tr = Tr, Z=covariates,p=0.5, pred = reloop, yhat=yhat_nn)
    save(abdat,covariates,est_reloop,file='abResults.RData')
  }
}
```
    

## Estimating heterogeneous treatment effects (HTE)

### Step 1: Extract ITE estimates 
You can retrieve the estimated individual treatment effects (ITE) using the following command:


```r
tauhat <- getITE(est_reloop)
```

### Subgroup effects
We can estimate effects in a subgroup by just taking the mean of `tauhat` for 
all members of that subgroup. 

Say we are interested in the effect for students whose prior median time on task is below the median:

```r
lowPriorTime <- covariates$student_prior_median_time_on_task<
  median(covariates$student_prior_median_time_on_task)
```

Then the estimated effect for those students is

```r
mean(tauhat[lowPriorTime])
```

```
## [1] 0.08699327
```
(`R` note: since `lowPriorTime` is a boolean (logical) variable, `tauhat[lowPriorTime]` is the sub-vector of `tauhat` for which `lowPriorTime` is TRUE.)

For inference, use the `t.test()` function:

```r
t.test(tauhat[lowPriorTime])
```

```
## 
## 	One Sample t-test
## 
## data:  tauhat[lowPriorTime]
## t = 2.0793, df = 340, p-value = 0.03834
## alternative hypothesis: true mean is not equal to 0
## 95 percent confidence interval:
##  0.004699255 0.169287290
## sample estimates:
##  mean of x 
## 0.08699327
```
`t.test()` can also be used to test the difference between two subgroup effects:

```r
t.test(tauhat~lowPriorTime)
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  tauhat by lowPriorTime
## t = -0.17615, df = 677.8, p-value = 0.8602
## alternative hypothesis: true difference in means between group FALSE and group TRUE is not equal to 0
## 95 percent confidence interval:
##  -0.1312865  0.1096700
## sample estimates:
## mean in group FALSE  mean in group TRUE 
##          0.07618502          0.08699327
```

### More complex moderation models


We will run a linear regression model, regressing the estimated ITE on the covariates to estimate the conditional average treatment effects (CATE). 


Simply run the model below:

```r
hteMod=lm(tauhat ~ ., data = covariates) 
```
### Display and interpret the results:

To get the standard errors right, we'll use heteroscedasticity-consistent standard errors from the `sandwich` package, and a helper function from the `lmtest` package:


```r
coeftest(hteMod,vcov. = vcovHC)
```

```
## 
## t test of coefficients:
## 
##                                                Estimate  Std. Error t value Pr(>|t|)
## (Intercept)                                  0.40956803  0.37722051  1.0858   0.2780
## student_prior_started_skill_builder_count   -0.00789977  0.01152621 -0.6854   0.4933
## student_prior_completed_skill_builder_count  0.00802857  0.01338377  0.5999   0.5488
## student_prior_started_problem_set_count      0.00526813  0.00763193  0.6903   0.4903
## student_prior_completed_problem_set_count   -0.00707898  0.00929525 -0.7616   0.4466
## student_prior_completed_problem_count        0.00021257  0.00054826  0.3877   0.6983
## student_prior_median_first_response_time     0.00598480  0.00444343  1.3469   0.1785
## student_prior_median_time_on_task           -0.00627831  0.00410164 -1.5307   0.1263
## student_prior_average_correctness           -0.24262863  0.25588743 -0.9482   0.3434
## student_prior_average_attempt_count         -0.07757773  0.17974266 -0.4316   0.6662
```


Note that you can use any regression model to estimate the CATE this way. 

For instance, you can also use regression trees:

```r
cart <- rpart(tauhat~.,data=covariates)
```

Plot the fitted model:
(with some extra code to shorten the variable names)

```r
prp(cart, 
    split.fun=function(x,labs,digits,varlen,faclen)  
          gsub("student_prior_","",labs))
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12-1.png)


Now, choose your own model, using `lm()`, `rpart()` or any other function you know of, to estimate heterogeneous effects:
  

```r
## put code here
```
