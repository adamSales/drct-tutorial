RCT Treatment Effect Estimation with `dRCT` Package
================
2024-07-09

``` r
library(dplyr)
library(tidyr)
library(devtools)
```

## Load Data

Load data cleaned in `00-data-setup.Rmd`

``` r
load("../data/rct_aux_dat.Rdata")
load("../data/rct_schools.Rdata")
```

## Install `dRCT` package

The `dRCT` package is currently hosted on Github at
[manncz/dRCT](https://github.com/manncz/dRCT). To install it, use the
`install_github()` function from the `devtools` package.

``` r
if(!("dRCT" %in% installed.packages())) install_github("manncz/dRCT")
library(dRCT)
```

## Estimate the ATE with Bernoulli Randomized Trails (LOOP)

We are interested in estimating the effect of a new 8th grade math
curriculum on the 2008 8th grade math TAKS passing rates. We identify
the outcome variable in the data as `taks08`.

First, we will treat the our synthetic RCT as a Bernoilli randomized
trial and analyze it using LOOP ([Wu & Gagnon-Bartsch,
2018](https://doi.org/10.1177/0193841X18808003)). The treatment
assignment vector is `TrBern`.

### LOOP with OLS imputation

Let’s start only adjusting by the 2007 overall math TAKS passing rate
`premA` using OLS for LOO potential outcome imputation. Therefore, we
will set the parameter `Z = rct_dat$premA`. To use OLS imputation we
choose `pred = loop_ols`.

``` r
loop(Y = rct_dat$taks08, Tr = rct_dat$TrBern, Z = rct_dat$premA, pred = loop_ols)
```

    ##       Estimate Std. Error t value Pr(>|t|)
    ## ATE: 0.4266322  2.2302744 0.19129  0.84929

### LOOP with Random Forest imputation

Now, we can adjust with all covariates using random forest.

First, we need to carefully only chose pre-treatment covariates to
adjust with.

``` r
covMat = rct_dat %>%
  select(-CAMPUS, -GRDSPAN, -match, -k, -Tr, -TrBern, -taks08, -clust_size) %>%
  select(!starts_with("out"))
```

Then, we can input our matrix of pre-treatment covariates into the
`loop()` function for the `Z` parameter. To impute using random forests,
we choose `pred = loop_rf`.

Use `set.seed()` to have a reproducible results if using random forests
to impute potential outcomes. This can take a couple of seconds to run.

``` r
set.seed(483)
loop(Y = rct_dat$taks08, Tr = rct_dat$TrBern, Z = covMat, pred = loop_rf)
```

    ##        Estimate Std. Error  t value Pr(>|t|)
    ## ATE: -0.8674415  2.5358446 -0.34207  0.73381

### Difference in Means Estimator (LOOP with mean imputation)

We can compare these estimates to the difference-in-means estimator (in
other words, to a t-test). To calculate the difference in means
estimator, you can either leave the covariate parameter `Z` empty in the
`loop()` function:

``` r
loop(Y = rct_dat$taks08, Tr = rct_dat$TrBern)
```

    ##       Estimate Std. Error t value Pr(>|t|)
    ## ATE: 0.1050903  2.8013678 0.03751  0.97023

choose `pred = loop_mean`:

``` r
loop(Y = rct_dat$taks08, Tr = rct_dat$TrBern, pred=loop_mean)
```

    ##       Estimate Std. Error t value Pr(>|t|)
    ## ATE: 0.1050903  2.8013678 0.03751  0.97023

or calculate directly with other functions in `R`. Below, we show how to
do so with the `lm` function.

The difference in means estimator is equivalent to the estimated
coefficient an OLS model of the outcome on the treatment assignment:

``` r
dmout <- lm(taks08 ~ TrBern,data = rct_dat)
summary(dmout)
```

    ## 
    ## Call:
    ## lm(formula = taks08 ~ TrBern, data = rct_dat)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -27.276  -4.131   1.724   5.724  14.724 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  85.2759     1.8419  46.297   <2e-16 ***
    ## TrBern        0.1051     2.8422   0.037    0.971    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 9.919 on 48 degrees of freedom
    ## Multiple R-squared:  2.848e-05,  Adjusted R-squared:  -0.0208 
    ## F-statistic: 0.001367 on 1 and 48 DF,  p-value: 0.9707

``` r
# extract estimates 
est <- dmout$coefficients["TrBern"]
sderr <- sqrt(vcov(dmout)["TrBern","TrBern"])
```

    ## [1] "Estimate: 0.1051"

    ## [1] "Standard Error: 2.8422"

**Note:** The standard error estimate from the `loop()` function is
$\frac{N}{N-1}$ times the standard standard error used in a t-test as
seen above where $N$ is the number of units in the trial.

## Estimate the ATE with a Paired Trial (P-LOOP)

Next, we will treat the synthetic RCT as a paired trial. The `p_loop()`
function implements the P-LOOP estimator ([Wu & Gagnon-Bartsch,
2021](https://doi.org/10.3102/1076998620941469)).

We identify the pair indicator as `match` and the treatment assignment
vector as `Tr`.

### P-LOOP with OLS imputation

We can estimate the ATE using OLS to impute potential outcomes,
adjusting with only the pretest score `premA`. There are three options
to chose from for OLS imputation: `p_ols_po`, `p_ols_v12`, and
`p_ols_interp`. We will use `p_ols_interp` here because it interpolates
between the other two options, automatically determining the optimal
method for the data.

``` r
p_loop(Y = rct_dat$taks08, Tr = rct_dat$Tr, Z = rct_dat$premA, P = rct_dat$match, pred = p_ols_interp)
```

    ##      Estimate Std. Error t value Pr(>|t|)
    ## ATE: 2.112970   2.538833 0.83226  0.40526

### P-LOOP with Random Forest imputation

The same options are available for imputing potential outcomes with
random forests (`p_rf_po`, `p_rf_v12`, `p_rf_interp`) with `p_loop()`.

### Difference in Means Estimator

As with the Bernoilli randomized experiment, there are number of
different ways to calculate the difference in means estimator and
corresponding standard error in `R`.

First, using the `p_loop()` function, either don’t include any
covariates (`Z = NULL`):

``` r
p_loop(Y = rct_dat$taks08, Tr = rct_dat$Tr, P = rct_dat$match)
```

    ## Note: pred = p_loomi is used because no covariates were provided

    ##      Estimate Std. Error t value Pr(>|t|)
    ## ATE:  1.76000    2.62948 0.66933  0.50328

or explicitly specify `pred = p_loomi`:

``` r
p_loop(Y = rct_dat$taks08, Tr = rct_dat$Tr, P = rct_dat$match, pred = p_loomi)
```

    ## Note: pred = p_loomi is used because no covariates were provided

    ##      Estimate Std. Error t value Pr(>|t|)
    ## ATE:  1.76000    2.62948 0.66933  0.50328

You can use the OLS to calculate the difference-in-means *point*
estimator as we did for the Bernoilli trial above, however the standard
error will not take the paried randomization into account.

Below we will calculate the point estimator and a common design-based
standard error estimate ([Imai,
2008](https://onlinelibrary.wiley.com/doi/10.1002/sim.3337)) directly.
You can also use the `ATEnocov` function in the `experiment` package in
`R`, which we won’t show here for the sake of not installing an
additional package.

First, we will rearrange the data to calculate the difference between
the treatment (`Y1`) and control outcomes (`Y0`) within each pair:

``` r
paired.dat <- rct_dat %>%
  select(P = match, Tr, taks08) %>%
  pivot_wider(values_from = taks08, names_from = Tr,
              names_prefix = "Y") %>%
  mutate(dif = Y1 - Y0)

paired.dat
```

    ## # A tibble: 25 × 4
    ##    P        Y0    Y1   dif
    ##    <fct> <dbl> <dbl> <dbl>
    ##  1 A        76    87    11
    ##  2 B        91    68   -23
    ##  3 C        90    94     4
    ##  4 D        72    89    17
    ##  5 E        92    71   -21
    ##  6 F        79    84     5
    ##  7 G        88    84    -4
    ##  8 H        82    73    -9
    ##  9 I        91    86    -5
    ## 10 J        93    87    -6
    ## # ℹ 15 more rows

The difference in means estimator is the mean of these differences and
the standard error is proportional to the standard deviation of the
paired differences:

``` r
M <- nrow(paired.dat)
est = mean(paired.dat$dif)
sderr = sqrt(1/(M*(M-1))*sum((paired.dat$dif - mean(paired.dat$dif))^2))
```

    ## [1] "Estimate: 1.76"

    ## [1] "Standard Error: 2.5764"

**Note:** The standard error estimate from the `p_loop()` function is
$\frac{M}{M-1}$ times the typical design-based standard error used for
the difference-in-means estimator ([Imai,
2008](https://onlinelibrary.wiley.com/doi/10.1002/sim.3337)) as seen
above where $M$ is the number of pairs in the trial.

## Estimate the individual ATE with a Paired Cluster-Randomized Trial (IDPD)

Above, we estimated the average treatment effect on the *schools* in our
RCT. If we want to estimate the average treatment effect for *students*
in the RCT, we want to treat it as a paired *cluster*-randomized trial
(pCRT). The `p_loop()` function allows you to add cluster sizes for each
unit in the trial with the `n` parameter.

We identify the variable `clust_size` as our cluster sizes.

### Design-Based Covariate Adjustment with OLS or Random Forest imputation for pCRTs

The `p_loop` syntax is exactly the same, just specifying
`n = rct_dat$clust_size`:

``` r
p_loop(Y = rct_dat$taks08, Tr = rct_dat$Tr, Z = rct_dat$premA, P = rct_dat$match, pred = p_ols_interp,
       n = rct_dat$clust_size)
```

    ##      Estimate Std. Error t value Pr(>|t|)
    ## ATE: 2.232116   2.528115 0.88292  0.37728

As an additional feature for pCRTs, you can also specify if you would
like the imputation models to be weighted themselves by `n` by setting
`weighted_imp = TRUE`:

``` r
p_loop(Y = rct_dat$taks08, Tr = rct_dat$Tr, Z = rct_dat$premA, P = rct_dat$match, pred = p_ols_interp,
       n = rct_dat$clust_size, weighted_imp = TRUE)
```

    ##      Estimate Std. Error t value Pr(>|t|)
    ## ATE: 2.175192   2.504661 0.86846  0.38514

We see this improves the standard error somewhat, because the imputation
model is prioritizing predicting the outcomes well for the larger
schools.

### Design-Based Estimation with No Covariates for pCRTs

You can use the `p_loop()` function to estimate the individual ATE
without covariate adjustment as well. When cluster sizes differ within
pairs, using leave-one-out mean imputation results in a different
estimator than the difference in means estimator ([Mann, Sales, &
Gagnon-Bartsch, 2024](https://arxiv.org/abs/2407.01765)).

You can use leave-one-out (un-weighted) mean imputation by not including
any covariates `Z` and/or by specifying `pred = p_loomi`:

``` r
p_loop(Y = rct_dat$taks08, Tr = rct_dat$Tr, P = rct_dat$match, n = rct_dat$clust_size, pred = p_loomi)
```

    ## Note: pred = p_loomi is used because no covariates were provided

    ##      Estimate Std. Error t value Pr(>|t|)
    ## ATE: 2.017884   2.881349 0.70033  0.48372

Adding `weighted_imp = TRUE` specifies that the mean imputation should
be weighted by `n`.

``` r
p_loop(Y = rct_dat$taks08, Tr = rct_dat$Tr, P = rct_dat$match, n = rct_dat$clust_size, pred = p_loomi,
       weighted_imp = TRUE)
```

    ## Note: pred = p_loomi is used because no covariates were provided

    ##      Estimate Std. Error t value Pr(>|t|)
    ## ATE: 1.917569   3.090340  0.6205  0.53493

For mean imputation, you can also specify that you want to use data from
all pairs for imputation (rather than leave-one-out imputation) with
`loo = FALSE`. Specifying `weighted_imp = TRUE` as well returns the
difference-in-means *point* estimator:

``` r
p_loop(Y = rct_dat$taks08, Tr = rct_dat$Tr, P = rct_dat$match, n = rct_dat$clust_size, pred = p_loomi,
       weighted_imp = TRUE, loo = FALSE)
```

    ## Note: pred = p_loomi is used because no covariates were provided

    ##      Estimate Std. Error t value Pr(>|t|)
    ## ATE: 1.962894   2.803567 0.70014  0.48384

**Note:** However, in this case, the estimate standard error tends to be
anti-conservative. See ([Mann, Sales, & Gagnon-Bartsch,
2024](https://arxiv.org/abs/2407.01765)) for detailed discussion of
design based estimators without covariate adjustment for pCRTs.
