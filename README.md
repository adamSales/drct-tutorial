# Tools for Planning &amp; Analyzing Randomized Controlled Trials &amp; A/B Tests



This repository contains the materials for the SREE 2024 half day tutorial "Tools for Planning &amp; Analyzing Randomized Controlled Trials &amp; A/B Tests" on 9/18/24. This tutorial is organized by Adam Sales, Johann Gagnon-Bartsch, Duy Pham, Charlotte Mann, and Jaylin Lowe.

The tutorial focuses on how to use the current version of the `dRCT` package in `R`.

## Repo Contents
 1. [Preliminaries--what you will need to fully participate](#preliminaries)
 1. [Workshop Slides (pdf)](https://github.com/adamSales/drct-tutorial/blob/main/slides.pdf)
 2. [Interactive `R` Scripts](https://github.com/adamSales/drct-tutorial/tree/main/scripts)
 3. [Example Datasets](https://github.com/adamSales/drct-tutorial/tree/main/data)

## Preliminaries

To work with the code, participants need to:

 1) [Download and Install R and RStudio](#downloading-and-installing-r-and-rstudio)
 2) [Clone the Github repository `adamSales/drct-tutorial/`](#cloning-tutorial-github-repo)
 3) [Install required packages]

### Downloading and Installing R and RStudio
 1. Follow the instructions [here](https://cran.rstudio.com/) to download and install R. 
 2. Follow instructions [here](https://posit.co/download/rstudio-desktop/) to download and install RStudio

### Cloning Tutorial Github Repo
"Cloning" means to make a local version of the remote Github repository on your computer. 

There are a couple of options for how to do this:

#### Option 1 : Command Line

In the Terminal, navigate to a directory where you would like the tutorial directory to live, then run command:  
```
git clone https://github.com/adamSales/drct-tutorial.git
```
You should now have a directory drct-tutorial/

#### Option 2: Download .zip File from GitHub

Just [click here](https://github.com/adamSales/drct-tutorial/archive/refs/heads/main.zip), or:

 1. Go to (https://github.com/adamSales/drct-tutorial)
 2. Click the green <>Code button at the top right corner (see below)
 3. Select Download ZIP
 4. Unzip the downloaded file drct-tutorial-main.zip by double clicking on it

### Installing Required Packages
All scripts include code to install necessary packages. However, to save time, it would be helpful to run the code in [scripts/_installPackages.R](https://github.com/adamSales/drct-tutorial/blob/main/scripts/_installPackages.R) while the workshop is starting.
If you are in RStudio, you can open the script and select "Source" on the upper-right of the panel.



## Detailed Contents
The contents are organized as follows:

- `data/`: processed data files and documentation
  - `README.md`: data dictionaries
  - A/B example data:
    - `abTestExample.csv`
    - `auxiliaryLogData.csv`
    - `rctLogData.csv`
    - `yhatNN.csv`
  - Field test example data (AEIS) outputted by `00-data-setup.Rmd`:
    - `rct_aux_dat.Rdata`
    - `rct_schools.Rdata`
    - `aux_dat_small.csv`: Smaller version of `rct_aux_dat.Rdata` with some covariates removed for the Shiny app demo. 
- `input/`: input data files
  - `MS_data_public.Rdata`: AEIS data from [manncz/aeis-aux-rct/](https://github.com/manncz/aeis-aux-rct/)
  - `var_names.csv`: Cross-walk for cleaning variable names in AEIS data
  - `subset_var_names.csv`: Names of covariates to be used in creating the smaller version of the auxiliary data for the Shiny app demo
- `scripts/`: all tutorial scripts to be run in order
  - `_installPackages.R`: contains code to install all packages used in tutorial scripts
  - `00-data-setup.Rmd`
  - `01-explore-aeis-data.Rmd`
  - `02-effect-est.Rmd`
  - `03-integrate-aux.Rmd`
  - `04-effect-estABtest.Rmd`
  - `04-effect-estABtestSolution.Rmd`
  - `05-heterogeneousEffects.Rmd`
  - `compiled_tutorials/`: compiled versions of all tutorial scripts
- `temp/`: intermediate data artifacts
  - `auxpred.Rdata`: auxiliary predictions to be used in `03-integrate-aux.Rmd`

## Use

**Option 1 -- Run Everything:**
1. Run `00-data-setup.Rmd`
3. Now the scripts can be run in any order, although we will work through the scripts in order for the workshop


**Option 2 -- Skip Data Build:**
1. Skip `00-data-setup.Rmd` and can can still run the scripts in any order because the outputs are already saved in the `data/` directory

**Option 3 -- Run Nothing:**
1. Read through the compiled scripts in the `scripts/compiled_tutorials/` directory


## Real-Data Examples

We work through two real-data examples in this workshop - a educational school-level field experiment (AEIS data) and educational A/B tests (ASSISTments).

#### AEIS Data and Synthetic RCT

In scripts `00`-`03`, we work through an example of analyzing a school-level field experiment using data provided by the Texas Education Agency called the Academic Excellence Indicator System ([AEIS](https://rptsvr1.tea.texas.gov/perfreport/aeis/index.html)). Data documentation can be found on the AEIS website [here](https://rptsvr1.tea.texas.gov/perfreport/aeis/2008/xplore/aeisref.html) and [here](https://rptsvr1.tea.texas.gov/perfreport/aeis/2008/masking.html).

We use an already processed version of the AEIS data for this tutorial (`MS_data_public.Rdata`). A detailed description of our data processing can be found on at [github.com/manncz/aeis-aux-rct](https://github.com/manncz/aeis-aux-rct).

Inspired by the Cognitive Tutor Algebra I Study (Pane et. al, 2014), we construct a synthetic RCT with the middle schools included in the Texas AEIS data for this workshop.

#### ASSISTments Data

You then have the chance to implement what you learned in `04-effect-estABtest.Rmd`, with data from real educational A/B tests.


## References

Johann A. Gagnon-Bartsch, Adam C. Sales, Edward Wu, Anthony F. Botelho, John A.
Erickson, Luke W. Miratrix, and Neil T. Heffernan. *Precise unbiased estimation in randomized experiments using auxiliary observational data.* Journal of Causal Inference,
11(1):20220011, August 2023. URL:
https://www.degruyter.com/document/doi/10.1515/jci-2022-0011/html.

Kosuke Imai. *Variance identification and efficiency analysis in randomized experiments under the matched-pair design.* Statistics in Medicine, 27(24):4857–4873, October 2008. URL: https://onlinelibrary.wiley.com/doi/10.1002/sim.3337.

Kosuke Imai and Zhichao Jiang. *`experiment:` R Package for Designing and Analyzing Randomized Experiments.* April 2022. URL https://cran.r-project.org/web/packages/experiment/index.html.

Jaylin Lowe, Charlotte Mann, Jiaying Wang, Adam Sales and Johann Gagnon-Bartsch. *Power Calculations for Randomized Controlled Trials with Auxiliary Observational Data* EDM2024. 

Charlotte Z. Mann, Adam C. Sales, and Johann A. Gagnon-Bartsch. *A General Framework for Design-Based Treatment Effect Estimation in Paired Cluster-Randomized Experiments*. Preprint. July 2024. URL: https://arxiv.org/abs/2407.01765.

John F. Pane, Beth Ann Griffin, Daniel F. McCaffrey, and Rita Karam. *Effectiveness of Cognitive Tutor Algebra I at Scale.* Educational Evaluation and Policy Analysis, 36(2):
127–144, June 2014. URL: https://doi.org/10.3102/0162373713507480.

Duy Pham, Kirk Vanacore, Adam Sales and Johann Gagnon-Bartsch. *LOOL: Towards Personalization with Flexible & Robust Estimation of Heterogeneous Treatment Effects* EDM2024.

Texas Education Agency. *Academic Excellence Indicator System*. 2020. URL: https://rptsvr1.tea.texas.gov/perfreport/aeis/index.html. Accessed on 2/12/2024.

Edward Wu and Johann A. Gagnon-Bartsch. *The LOOP Estimator: Adjusting for Covariates in Randomized Experiments*. Evaluation Review, 42(4):458–488, August 2018. URL: https://doi.org/10.1177/0193841X18808003.

Edward Wu and Johann A. Gagnon-Bartsch. *Design-Based Covariate Adjustments in Paired Experiments*. Journal of Educational and Behavioral Statistics, 46(1):109–132, February 2021. URL: https://doi.org/10.3102/1076998620941469.


Edward Wu, Adam C. Sales, Charlotte Z. Mann, and Johann A. Gagnon-Bartsch. *`dRCT`*,
December 2023. URL: https://github.com/adamSales/dRCT.
