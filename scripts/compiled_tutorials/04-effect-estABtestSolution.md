---
title: 'Estimating Effects from a Bernoulli Experiment: Solutions'
output:
  html_document:
    df_print: paged
---

This notebook will guide you through the process of estimating a treatment effect from a randomized A/B test, using the new `dRCT` package in `R`.

## Estimating an Average Effect with Just RCT data

### Step 0: Install the required packages (only do this once)

Install all the necessary packages:

```r
needed.packages <- c("devtools","SuperLearner","ranger")
new.packages <- needed.packages[!(needed.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

if(!require(dRCT)) devtools::install_github("manncz/dRCT",upgrade = FALSE)
```

```
## Loading required package: dRCT
```


### Step 1: Load in the required packages:


```r
library(dRCT)
library(SuperLearner)
```

```
## Warning: package 'SuperLearner' was built under R version 4.4.1
```

```
## Loading required package: nnls
```

```
## Loading required package: gam
```

```
## Loading required package: splines
```

```
## Loading required package: foreach
```

```
## Loaded gam 1.22-3
```

```
## Super Learner
```

```
## Version: 2.0-29
```

```
## Package created on 2024-02-06
```

```r
library(ranger)
```

```
## Warning: package 'ranger' was built under R version 4.4.1
```


### Step 2: Load and Explore the Dataset


```r
abdat <- read.csv('../data/abTestExample.csv')
```

You may want to use one or more of these functions to explore the dataset's structure:


```r
View(abdat) ## opens a new tab in Rstudio
dim(abdat) ## the dimension of the datset (rows, columns)
```

```
## [1] 683  12
```

```r
names(abdat) ## variable names
```

```
##  [1] "user_id"                                     "student_prior_started_skill_builder_count"  
##  [3] "student_prior_completed_skill_builder_count" "student_prior_started_problem_set_count"    
##  [5] "student_prior_completed_problem_set_count"   "student_prior_completed_problem_count"      
##  [7] "student_prior_median_first_response_time"    "student_prior_median_time_on_task"          
##  [9] "student_prior_average_correctness"           "student_prior_average_attempt_count"        
## [11] "video"                                       "completion"
```

```r
head(abdat) ## first 6 rows
```

```
##   user_id student_prior_started_skill_builder_count student_prior_completed_skill_builder_count
## 1   34420                                         8                                           4
## 2   35241                                        16                                          11
## 3  109255                                        14                                          10
## 4  109310                                         8                                           8
## 5  109320                                         8                                           8
## 6  109541                                        15                                           8
##   student_prior_started_problem_set_count student_prior_completed_problem_set_count
## 1                                      23                                        19
## 2                                      25                                        24
## 3                                      25                                        23
## 4                                      19                                        19
## 5                                      19                                        18
## 6                                      23                                        18
##   student_prior_completed_problem_count student_prior_median_first_response_time student_prior_median_time_on_task
## 1                                   219                                  31.2060                           36.8080
## 2                                   299                                  24.8730                           37.5170
## 3                                   216                                  48.3005                           56.3740
## 4                                   138                                  37.5555                           48.0435
## 5                                   146                                  39.1480                           48.6580
## 6                                   184                                  28.4565                           34.1600
##   student_prior_average_correctness student_prior_average_attempt_count video completion
## 1                         0.5707071                            1.881279  TRUE          1
## 2                         0.4982079                            1.725753  TRUE          0
## 3                         0.6010101                            1.500000 FALSE          1
## 4                         0.7692308                            1.355072  TRUE          1
## 5                         0.7608696                            1.239726 FALSE          1
## 6                         0.4855491                            1.358696  TRUE          1
```

More information on the dataset is available [here](https://github.com/manncz/edm-rct-tutorial/blob/main/data/ABexampleDataDictionary.md).

### Step 3: Extract the necessary variables from the dataset

To estimate effects from a Bernoulli RCT, you really only need two variables:

1.  Treatment (the exposure, intervention, etc.)
2.  Outcome (What the the treatment is supposed to affect)

Extract the treatment variable from the dataset:


```r
Tr= abdat$video
```

Extract the outcome variable:


```r
Y = abdat$completion
```

### Interlude

With these two variables, you can estimate the average effect using a t-test:


```r
print(TTest <- t.test(Y~Tr))
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  Y by Tr
## t = -1.3383, df = 680.94, p-value = 0.1812
## alternative hypothesis: true difference in means between group FALSE and group TRUE is not equal to 0
## 95 percent confidence interval:
##  -0.12460016  0.02358989
## sample estimates:
## mean in group FALSE  mean in group TRUE 
##           0.5578035           0.6083086
```

the estimate is:


```r
TTest$estimate[2]-TTest$estimate[1]
```

```
## mean in group TRUE 
##         0.05050514
```

with a standard error:


```r
TTest$stderr
```

```
## [1] 0.03773709
```

The `loop()` function without covariates gives you the same answer:


```r
loop(Y=Y,Tr=Tr)
```

```
##        Estimate Std. Error t value Pr(>|t|)
## ATE: 0.05050514 0.03779207  1.3364  0.18187
```

### Covariates

To get a precise answer, you'll want to use baseline covariates

Extract the covariates: identify which columns of the data matrix are baseline covariates, and create a new matrix or dataframe with only those columns. You can identify the columns numerically, like:

```         
covariates=abdat[,c(2,3,7,8)] ## for columns 2, 3, 7, 8
```

or

```         
covariates=abdat[,5:9] ## for columns 5,6,7,8,9
```

by name:

```         
covariates = abdat[,c("var1","var2","var3")]
```

or using regular expressions:

```         
covariates = abdat[,grep("pattern",names(abdat))]
```


```r
# put your code here
covariates= abdat[,2:10]
# or
covariates= abdat[,grep('student_prior',names(abdat))]
```

### Step 4: Estimate the average effect

One more ingredient is necessary to estimate effects from a Bernoulli RCT: the probability of a unit being assigned to the treatment condition. In this case, $Pr(Tr_i=1)=0.5$.

Then, to estimate effects, use the `loop()` function:


```r
est_loop=loop(Y=Y, Tr=Tr,Z=covariates,p=0.5)
```

To see the estimate, standard error, and a p-value testing the null hypothesis of no average effect, use `print()`:


```r
print(est_loop)
```

```
##        Estimate Std. Error t value Pr(>|t|)  
## ATE: 0.08213545 0.03352044 2.45031 0.014524 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The `confint()` function gives confidence intervals:


```r
confint(est_loop)
```

```
##          2.5 %    97.5 %
## ATE 0.01631962 0.1479513
```

## Incorporating Auxiliary Data

### Step 1: Gather auxiliary data and analogous experimental data

The file "auxiliaryLogData.csv" has data for a separate group of students who worked on a problem set similar to the one featured in the RCT. The dataset includes assignment-level student performance measurements for the previous five assignments each student worked on, along with student-level averages.

```r
aux_logdata <- read.csv('../data/auxiliaryLogData.csv')
```
The dataset "rctLogData.csv" includes the same predictors for the students in the RCT:

```r
rct_logdata <- read.csv('../data/rctLogData.csv')
```

### Step 2: Train a prediction algorithm 
Use the auxiliary dataset to train a prediction algorithm, predicting `completion` as a function of the predictors.

Here, you may use any algorithm you want--you may even use the auxiliary data to compare the results of several algorithms and then choose between them or ensemble them. 

In fact, the `SuperLearner` package does that all for you, so we'll use that. 

The way `SuperLearner` works is that you provide a matrix or dataframe of predictors, `X`, and outcome `Y`, and a list of candidate prediction algorithms. To see the built-in options, run:

```r
listWrappers()
```

```
## All prediction algorithm wrappers in SuperLearner:
```

```
##  [1] "SL.bartMachine"      "SL.bayesglm"         "SL.biglasso"         "SL.caret"            "SL.caret.rpart"     
##  [6] "SL.cforest"          "SL.earth"            "SL.gam"              "SL.gbm"              "SL.glm"             
## [11] "SL.glm.interaction"  "SL.glmnet"           "SL.ipredbagg"        "SL.kernelKnn"        "SL.knn"             
## [16] "SL.ksvm"             "SL.lda"              "SL.leekasso"         "SL.lm"               "SL.loess"           
## [21] "SL.logreg"           "SL.mean"             "SL.nnet"             "SL.nnls"             "SL.polymars"        
## [26] "SL.qda"              "SL.randomForest"     "SL.ranger"           "SL.ridge"            "SL.rpart"           
## [31] "SL.rpartPrune"       "SL.speedglm"         "SL.speedlm"          "SL.step"             "SL.step.forward"    
## [36] "SL.step.interaction" "SL.stepAIC"          "SL.svm"              "SL.template"         "SL.xgboost"
```

```
## 
## All screening algorithm wrappers in SuperLearner:
```

```
## [1] "All"
## [1] "screen.corP"           "screen.corRank"        "screen.glmnet"         "screen.randomForest"  
## [5] "screen.SIS"            "screen.template"       "screen.ttest"          "write.screen.template"
```

Choose your favorite algorithms from this list (bear in mind, some may require you to install yet more packages, and/or take a long time to run -- ahem, `SL.nnet`)

For instance, say we want to try regression, ridge regression, and 
a fast version of random forest called `ranger`. Then run:

```r
algs <- c('SL.lm','SL.ridge','SL.ranger')
```
Go ahead and edit that code, and re-run, if you want to try something different!

Then train the model using the auxiliary data:

```r
X <- aux_logdata
X$completion <- NULL

auxmod <- SuperLearner(Y=aux_logdata$completion,X=X,SL.library=algs)
```

```
## Loading required namespace: MASS
```

The SuperLearner uses cross-validation to weight the candidate algorithms:

```r
auxmod
```

```
## 
## Call:  SuperLearner(Y = aux_logdata$completion, X = X, SL.library = algs) 
## 
## 
##                    Risk       Coef
## SL.lm_All     0.1072648 0.03833501
## SL.ridge_All  0.1053585 0.27313608
## SL.ranger_All 0.1003523 0.68852891
```


### Step 3: Get predictions for RCT students

Now, use the model from step 2 to generate predicted outcomes for the students in the RCT.
Here we'll use the `rct_logdata` dataset.
Note that we've conveniently arranged things so that the rows are in the right order:

```r
all.equal(rct_logdata$user_id, abdat$user_id)
```

```
## [1] TRUE
```
To keep things simple, we'll remove that column:

```r
rct_logdata$user_id <- NULL
```
With a SuperLearner model, getting predictions is straightforward:


```r
yhat <- predict(auxmod,rct_logdata)
yhat <- yhat$pred[,1]
```

### Step 4: Use `loop`, along with the Auxiliary predictions, to estimate effects

The call is the same as before, except we use the `reloop` prediction algorithm, and 
include `yhat` as an additional argument:

```r
est_reloop <- loop(Y = Y, Tr = Tr, Z=covariates,p=0.5, pred = reloop, yhat=yhat)

print(est_reloop)
```

```
##        Estimate Std. Error t value Pr(>|t|)  
## ATE: 0.06761072 0.03222088 2.09835 0.036244 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```r
confint(est_reloop)
```

```
##           2.5 %    97.5 %
## ATE 0.004345892 0.1308755
```


To replicate the result in [this JEDM article](https://jedm.educationaldatamining.org/index.php/JEDM/article/view/646),
first load in the predictions from that fancy-schmancy deep neural net:


```r
yhat_nn <- read.csv('../data/yhatNN.csv')[,1]
```
Then re-run the estimation routine:

```r
est_reloop <- loop(Y = Y, Tr = Tr, Z=covariates,p=0.5, pred = reloop, yhat=yhat_nn)

print(est_reloop)
```

```
##        Estimate Std. Error t value Pr(>|t|)   
## ATE: 0.08158123 0.03090779  2.6395 0.008493 **
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```r
confint(est_reloop)
```

```
##          2.5 %    97.5 %
## ATE 0.02089509 0.1422674
```

```r
## save for later use
save(abdat, covariates,est_reloop,file='abResults.RData')
```

