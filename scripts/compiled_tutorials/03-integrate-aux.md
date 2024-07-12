Treatment Effect Estimation Integrating Auxiliary Data with `dRCT`
Package
================
2024-07-12

``` r
library(dplyr)
library(tidyr)
library(randomForest)
library(devtools)
if(!("dRCT" %in% installed.packages())) install_github("manncz/dRCT")
library(dRCT)
```

## Overview

In this Markdown, we will walk through the steps outlined in
[Gagnon-Bartsch et
al. (2023)](https://www.degruyter.com/document/doi/10.1515/jci-2022-0011/html)
for the RE-LOOP estimator, combining experimental and observational data
for estimating the ATE with improved efficiency.

We will continue to work with the synthetic RCT and AEIS data processed
in `00-data-setup.Rmd`.

``` r
load("../data/rct_aux_dat.Rdata")
```

## Step 1: Fit Auxiliary Model

We will fit the simplest auxiliary model possible – using all available
covariates in the auxiliary data with random forests. As a reminder,
this data includes all of the Texas middle schools in the AEIS data that
are not in the synthetic RCT. We use the `randomForest` package with the
default parameters.

In practice, you can go to town developing an auxiliary model before
looking at the RCT data. The only goal of the model is to predict the
outcomes in the RCT well.

``` r
aux_mod_dat <- aux_dat %>%
  select(-GRDSPAN) %>%
  select(!starts_with("out"))

# we do not recommend re-running the auxiliary model because it takes a long time to run
#aux.rf <- randomForest(taks08 ~ . -CAMPUS, data = aux_mod_dat)
```

From our run, we get an MSE of 66.4 and R-squared of 65.84 with the
auxiliary schools.

## Step 2: Generate Auxiliary Predictions for RCT Sample

**Note:** Don’t try to run the code in Step 2 unless you un-commented
and ran the previous code chunk.

It only takes one line of code to then generate predictions for the RCT
sample:

``` r
yhatrct <- predict(aux.rf, newdata = rct_dat)
```

We saved these predictions so that you don’t have to re-run the
auxiliary model, which takes a long time.

``` r
auxpreds <- data.frame(CAMPUS = rct_dat$CAMPUS, yhat = yhatrct)
save(auxpreds, file = "../temp/auxpred.Rdata")
```

## Step 3: RE-LOOP Estimate

### Adding Auxiliary Predictions

First, load the auxiliary predictions.

``` r
load("../temp/auxpred.Rdata")
```

I will append the predictions to the RCT data to ensure that the
predictions are in the correct order.

``` r
rct_dat <- rct_dat %>%
  left_join(auxpreds, by = "CAMPUS")
```

    ## # A tibble: 10 × 3
    ##    CAMPUS    taks08  yhat
    ##    <chr>      <dbl> <dbl>
    ##  1 031903044     76  82.7
    ##  2 031903045     87  80.9
    ##  3 074909041     91  82.9
    ##  4 178908041     68  90.6
    ##  5 021901041     94  90.7
    ##  6 220901045     90  89.1
    ##  7 175902041     72  82.1
    ##  8 234906041     89  82.5
    ##  9 014905041     92  89.6
    ## 10 143905101     71  91.3

We can get a sense of how well the auxiliary model transports to the RCT
sample by looking at the R-squared of an OLS model using the predictions
as a covariate:

``` r
summary(lm(taks08 ~ yhat, data = rct_dat))$r.squared
```

    ## [1] 0.4482058

This is a somewhat low R-squared, but it is still greater than the
R-squared that you get with the pretest score alone:

``` r
summary(lm(taks08~ premA, data = rct_dat))$r.squared
```

    ## [1] 0.4055298

### Effect Estimate

The first option is to simply use the auxiliary predictions `yhat` as a
covariate:

``` r
loop(Y = rct_dat$taks08, Tr = rct_dat$TrBern, Z =rct_dat$yhat, pred = loop_ols)
```

    ##        Estimate Std. Error  t value Pr(>|t|)
    ## ATE: -0.3246524  2.1979000 -0.14771  0.88331

Using the `pred = reloop` option, it will automatically determine
whether to impute potential outcomes using `yhat`, or any RCT covariates
that you give it in `Z`.

So here, we specifiy `yhat = rct_dat$yhat` and separately
`Z = rct_dat$premA`, the pretest score:

``` r
loop(Y = rct_dat$taks08, Tr = rct_dat$TrBern, Z = rct_dat$premA, yhat = rct_dat$yhat, pred = reloop)
```

    ##        Estimate Std. Error  t value Pr(>|t|)
    ## ATE: -0.3246524  2.1979000 -0.14771  0.88331

Given what we saw above, it makes sense that these point and standard
error estimates are similar to just adjusting with the auxiliary
predictions.

And we can confirm that incorporating auxiliary information is more
efficient than using the pretest score alone:

``` r
loop(Y = rct_dat$taks08, Tr = rct_dat$TrBern, Z =rct_dat$premA, pred = loop_ols)
```

    ##       Estimate Std. Error t value Pr(>|t|)
    ## ATE: 0.4266322  2.2302744 0.19129  0.84929
