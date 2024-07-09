Explore AEIS Data
================
2024-07-09

## Load Data

Load data cleaned in `00-data-setup.Rmd`

``` r
load("../data/rct_aux_dat.Rdata")
load("../data/rct_schools.Rdata")
```

## Data Overview

### Source

We will be using data from the Academic Excellence Indicator System
[AEIS](https://rptsvr1.tea.texas.gov/perfreport/aeis/2008/DownloadData.html)
provided by the Texas Education Agency. This is aggregated school-level
data which includes information such as student passing rates on
standardized tests, school finances, student demographics, and teacher
demographics.

### Synthetic RCT Design

While inspired by a real field trial in Texas middle and high schools,
we have created an artificial RCT for this workshop from the ~1450
middle schools in the AEIS data due to data privacy considerations. For
our RCT, we imagine that a math curricular intervention for 8th graders
was randomized to the RCT schools to implement in the 2007/2008 school
year. We pair matched 50 schools based on information from the 2006/2007
school year to make up our RCT (see `00-data-setup.Rmd` for details).
For the sake of this tutorial, we generated both a Bernoilli randomized
treatment assignment `TrBern` and a pair randomized treatment assignment
`Tr` for these RCT schools.

### Outcomes and Covariates

We are interested in assessing the effect of the curricular intervention
on the 8th grade passing rate on a math standardized test (TAKS) in 2008
`taks08`. We also have the 2008 and 2009 TAKS math passing rates for
different subgroups of students (as discussed below).

It is common in educational trials to have access to a pretest score. We
we will use the TAKS math passing rate in 2007 as a pretest score
`premA`. We also have the 2007 TAKS math passing rates for different
subgroups of students (as discussed below).

There are thousands of available covariates from the 2003/4 to the
2006/7 school years in the data. The year of the variable is indicated
with a suffix such as `_34` for the 2003/4 school year. We include some
school information from the 2007/8 school year since it could still be
considered to be pre-treatment. We gave a handful of covariates
descriptive names for matching and exploratory purposes, which are all
from the 2006/7 school year.

For the primary data that we will use, we scaled the covariates and
filled any missing values with the column mean. We also added columns
indicating the pattern of missing values in each column (these have the
names of the original columns with the suffix `_mis`).

### Cleaned Data Files

`rct_aux_dat.Rdata` contains 3 data frames:

- `rct_dat`: Full processed data for 50 RCT schools with covariates and
  outcome and RCT information.
- `aux_dat`: Full processed data for 1418 middle schools in Texas, not
  included in the RCT (auxiliary schools).
- `covs_ms_noprep`: Covariates for all middle schools with no scaling or
  handling of missing values.

`rct_schools.Rdata` contains 1 data frame:

- `rct`: Information about the RCT design.

## Explore RCT Information

`rct` includes information about the RCT design including the following
columns: - `match`: pair match identifier - `k`: arbitrary labeling of
one school as the first or second school in a pair - `Tr`: paired random
treatment assignment - `clust_size`: number of 8th graders in the
school, which we will consider to be the cluster size - `TrBern`:
Bernoilli (non-paired) treatment assignment

``` r
head(rct) %>%
  kable() %>% 
  kable_styling(bootstrap_options = c("striped", "hover","condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
CAMPUS
</th>
<th style="text-align:left;">
match
</th>
<th style="text-align:left;">
k
</th>
<th style="text-align:right;">
Tr
</th>
<th style="text-align:right;">
clust_size
</th>
<th style="text-align:right;">
TrBern
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
031903044
</td>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
263
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
031903045
</td>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
243
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
074909041
</td>
<td style="text-align:left;">
B
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
54
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
178908041
</td>
<td style="text-align:left;">
B
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
37
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
021901041
</td>
<td style="text-align:left;">
C
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
374
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
220901045
</td>
<td style="text-align:left;">
C
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
385
</td>
<td style="text-align:right;">
0
</td>
</tr>
</tbody>
</table>

All of these columns are included in `rct_dat` as well.

## Outcome and Covariates

`aux_dat` and `rct_dat` contain the same outcome and covariate
information.

### Outcome

The primary outcome we will focus on is the all 8th grade students math
TAKS passing rate in 2008 `taks08`. We also have information on the 2009
TAKS passing rates and the rates for different subsets of 8th grade
students. The columns follow this naming structure
`outm[SUBGROUP]0[8/9]`. Columns ending in `_na` indicate if the
specified outcome is missing for that school. We do not scale the
outcome variables.

``` r
rct_dat %>%
  select(CAMPUS, taks08, starts_with("outm")) %>%
  slice(1:10) %>%
  kable() %>% 
  kable_styling(bootstrap_options = c("striped", "hover","condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
CAMPUS
</th>
<th style="text-align:right;">
taks08
</th>
<th style="text-align:right;">
outmA09
</th>
<th style="text-align:right;">
outmB09
</th>
<th style="text-align:right;">
outmH09
</th>
<th style="text-align:right;">
outmW09
</th>
<th style="text-align:right;">
outmM09
</th>
<th style="text-align:right;">
outmF09
</th>
<th style="text-align:right;">
outmE09
</th>
<th style="text-align:right;">
outmB08
</th>
<th style="text-align:right;">
outmH08
</th>
<th style="text-align:right;">
outmW08
</th>
<th style="text-align:right;">
outmM08
</th>
<th style="text-align:right;">
outmF08
</th>
<th style="text-align:right;">
outmE08
</th>
<th style="text-align:right;">
outmA09_na
</th>
<th style="text-align:right;">
outmB09_na
</th>
<th style="text-align:right;">
outmH09_na
</th>
<th style="text-align:right;">
outmW09_na
</th>
<th style="text-align:right;">
outmM09_na
</th>
<th style="text-align:right;">
outmF09_na
</th>
<th style="text-align:right;">
outmE09_na
</th>
<th style="text-align:right;">
outmA08_na
</th>
<th style="text-align:right;">
outmB08_na
</th>
<th style="text-align:right;">
outmH08_na
</th>
<th style="text-align:right;">
outmW08_na
</th>
<th style="text-align:right;">
outmM08_na
</th>
<th style="text-align:right;">
outmF08_na
</th>
<th style="text-align:right;">
outmE08_na
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
031903044
</td>
<td style="text-align:right;">
76
</td>
<td style="text-align:right;">
78
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
76
</td>
<td style="text-align:right;">
93
</td>
<td style="text-align:right;">
78
</td>
<td style="text-align:right;">
77
</td>
<td style="text-align:right;">
76
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
74
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
78
</td>
<td style="text-align:right;">
74
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
031903045
</td>
<td style="text-align:right;">
87
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
90
</td>
<td style="text-align:right;">
94
</td>
<td style="text-align:right;">
90
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
88
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
86
</td>
<td style="text-align:right;">
92
</td>
<td style="text-align:right;">
85
</td>
<td style="text-align:right;">
89
</td>
<td style="text-align:right;">
80
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
074909041
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
88
</td>
<td style="text-align:right;">
83
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
94
</td>
<td style="text-align:right;">
81
</td>
<td style="text-align:right;">
81
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
86
</td>
<td style="text-align:right;">
92
</td>
<td style="text-align:right;">
88
</td>
<td style="text-align:right;">
94
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
178908041
</td>
<td style="text-align:right;">
68
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
66
</td>
<td style="text-align:right;">
64
</td>
<td style="text-align:right;">
75
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
021901041
</td>
<td style="text-align:right;">
94
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
83
</td>
<td style="text-align:right;">
94
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
74
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
79
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
220901045
</td>
<td style="text-align:right;">
90
</td>
<td style="text-align:right;">
89
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
89
</td>
<td style="text-align:right;">
93
</td>
<td style="text-align:right;">
89
</td>
<td style="text-align:right;">
89
</td>
<td style="text-align:right;">
83
</td>
<td style="text-align:right;">
77
</td>
<td style="text-align:right;">
84
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
92
</td>
<td style="text-align:right;">
88
</td>
<td style="text-align:right;">
84
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
175902041
</td>
<td style="text-align:right;">
72
</td>
<td style="text-align:right;">
74
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
83
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
68
</td>
<td style="text-align:right;">
80
</td>
<td style="text-align:right;">
64
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:right;">
73
</td>
<td style="text-align:right;">
79
</td>
<td style="text-align:right;">
65
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
234906041
</td>
<td style="text-align:right;">
89
</td>
<td style="text-align:right;">
87
</td>
<td style="text-align:right;">
80
</td>
<td style="text-align:right;">
86
</td>
<td style="text-align:right;">
88
</td>
<td style="text-align:right;">
85
</td>
<td style="text-align:right;">
89
</td>
<td style="text-align:right;">
80
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
93
</td>
<td style="text-align:right;">
89
</td>
<td style="text-align:right;">
86
</td>
<td style="text-align:right;">
93
</td>
<td style="text-align:right;">
88
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
014905041
</td>
<td style="text-align:right;">
92
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
77
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
80
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
84
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
143905101
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
73
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
78
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
67
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
</tbody>
</table>

Here is the key for the given subgroups in the outcome data:

| Code | Subgroup     |
|------|--------------|
| A    | All Students |
| B    | Black        |
| E    | Low SES      |
| F    | Female       |
| H    | Hispanic     |
| M    | Male         |
| W    | White        |

### Pretest

The pretest score is the 2007 8th grade math TAKS passing rate, which we
similarly have available for different subsets of 8th grade students.
The pretest scores are scaled and missing values are imputed in
`aux_dat` and `rct_dat`. These columns use the naming structure
`prem[SUBGROUP]` where `premA` indicates all 8th grade students.

``` r
rct_dat %>%
  select(CAMPUS, starts_with("prem")) %>%
  slice(1:10) %>%
  kable() %>% 
  kable_styling(bootstrap_options = c("striped", "hover","condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
CAMPUS
</th>
<th style="text-align:right;">
premA
</th>
<th style="text-align:right;">
premB
</th>
<th style="text-align:right;">
premH
</th>
<th style="text-align:right;">
premF
</th>
<th style="text-align:right;">
premE
</th>
<th style="text-align:right;">
premA_mis
</th>
<th style="text-align:right;">
premB_mis
</th>
<th style="text-align:right;">
premH_mis
</th>
<th style="text-align:right;">
premE_mis
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
031903044
</td>
<td style="text-align:right;">
0.3008998
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
0.4404296
</td>
<td style="text-align:right;">
0.2346974
</td>
<td style="text-align:right;">
0.4924987
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
031903045
</td>
<td style="text-align:right;">
0.3668894
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
0.3748227
</td>
<td style="text-align:right;">
0.4267602
</td>
<td style="text-align:right;">
0.2940033
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
074909041
</td>
<td style="text-align:right;">
1.0927757
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
1.3230531
</td>
<td style="text-align:right;">
1.4849758
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
178908041
</td>
<td style="text-align:right;">
0.8288170
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
1.0669694
</td>
<td style="text-align:right;">
2.2789574
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
021901041
</td>
<td style="text-align:right;">
0.9607964
</td>
<td style="text-align:right;">
0.0233235
</td>
<td style="text-align:right;">
1.2933191
</td>
<td style="text-align:right;">
0.7468648
</td>
<td style="text-align:right;">
0.4263336
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
220901045
</td>
<td style="text-align:right;">
0.5648584
</td>
<td style="text-align:right;">
-0.0887840
</td>
<td style="text-align:right;">
0.5716433
</td>
<td style="text-align:right;">
0.5548020
</td>
<td style="text-align:right;">
0.5586639
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
175902041
</td>
<td style="text-align:right;">
0.4328791
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
-0.3468531
</td>
<td style="text-align:right;">
0.5548020
</td>
<td style="text-align:right;">
-0.1691526
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
234906041
</td>
<td style="text-align:right;">
0.1689205
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
-0.8061014
</td>
<td style="text-align:right;">
0.1706765
</td>
<td style="text-align:right;">
0.0293428
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
014905041
</td>
<td style="text-align:right;">
0.3008998
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
-0.7404945
</td>
<td style="text-align:right;">
-0.3414909
</td>
<td style="text-align:right;">
0.4924987
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
143905101
</td>
<td style="text-align:right;">
0.4988687
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
</tr>
</tbody>
</table>

If you want to look at original values, you can use `covs_ms_noprep`:

``` r
covs_ms_noprep %>%
  select(CAMPUS, starts_with("prem")) %>%
  slice(1:10) %>%
  kable() %>% 
  kable_styling(bootstrap_options = c("striped", "hover","condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
CAMPUS
</th>
<th style="text-align:right;">
premA
</th>
<th style="text-align:right;">
premB
</th>
<th style="text-align:right;">
premH
</th>
<th style="text-align:right;">
premF
</th>
<th style="text-align:right;">
premE
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
101912041
</td>
<td style="text-align:right;">
61
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:right;">
65
</td>
<td style="text-align:right;">
56
</td>
<td style="text-align:right;">
61
</td>
</tr>
<tr>
<td style="text-align:left;">
101912043
</td>
<td style="text-align:right;">
80
</td>
<td style="text-align:right;">
85
</td>
<td style="text-align:right;">
79
</td>
<td style="text-align:right;">
80
</td>
<td style="text-align:right;">
78
</td>
</tr>
<tr>
<td style="text-align:left;">
101912044
</td>
<td style="text-align:right;">
61
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:right;">
76
</td>
<td style="text-align:right;">
62
</td>
<td style="text-align:right;">
64
</td>
</tr>
<tr>
<td style="text-align:left;">
101912047
</td>
<td style="text-align:right;">
61
</td>
<td style="text-align:right;">
46
</td>
<td style="text-align:right;">
62
</td>
<td style="text-align:right;">
58
</td>
<td style="text-align:right;">
62
</td>
</tr>
<tr>
<td style="text-align:left;">
101912048
</td>
<td style="text-align:right;">
80
</td>
<td style="text-align:right;">
85
</td>
<td style="text-align:right;">
77
</td>
<td style="text-align:right;">
81
</td>
<td style="text-align:right;">
77
</td>
</tr>
<tr>
<td style="text-align:left;">
101912049
</td>
<td style="text-align:right;">
76
</td>
<td style="text-align:right;">
67
</td>
<td style="text-align:right;">
76
</td>
<td style="text-align:right;">
74
</td>
<td style="text-align:right;">
76
</td>
</tr>
<tr>
<td style="text-align:left;">
101912051
</td>
<td style="text-align:right;">
61
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:right;">
65
</td>
<td style="text-align:right;">
62
</td>
<td style="text-align:right;">
60
</td>
</tr>
<tr>
<td style="text-align:left;">
101912053
</td>
<td style="text-align:right;">
53
</td>
<td style="text-align:right;">
78
</td>
<td style="text-align:right;">
51
</td>
<td style="text-align:right;">
44
</td>
<td style="text-align:right;">
52
</td>
</tr>
<tr>
<td style="text-align:left;">
101912054
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:right;">
61
</td>
<td style="text-align:right;">
57
</td>
</tr>
<tr>
<td style="text-align:left;">
101912055
</td>
<td style="text-align:right;">
81
</td>
<td style="text-align:right;">
88
</td>
<td style="text-align:right;">
73
</td>
<td style="text-align:right;">
78
</td>
<td style="text-align:right;">
77
</td>
</tr>
</tbody>
</table>

### Selected Covariates

The `covs_ms_noprep` data frame could be useful for just checking out
original values of the covariates, since it includes no processing. Here
are the covariates from the 2006/7 school year that we used in matching
and gave interpretable names:

``` r
covs_ms_noprep %>%
  select(CAMPUS, all_stud_n:perc_stud_tag) %>%
  slice(1:10) %>%
  kable() %>% 
  kable_styling(bootstrap_options = c("striped", "hover","condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
CAMPUS
</th>
<th style="text-align:right;">
all_stud_n
</th>
<th style="text-align:right;">
grade8_n
</th>
<th style="text-align:right;">
stud_teach_rat
</th>
<th style="text-align:right;">
all_exp
</th>
<th style="text-align:right;">
inst_exp
</th>
<th style="text-align:right;">
lead_exp
</th>
<th style="text-align:right;">
supp_exp
</th>
<th style="text-align:right;">
ed_aide
</th>
<th style="text-align:right;">
teach_salary
</th>
<th style="text-align:right;">
teach_expr
</th>
<th style="text-align:right;">
perc_teach_white
</th>
<th style="text-align:right;">
perc_teach_black
</th>
<th style="text-align:right;">
perc_teach_hisp
</th>
<th style="text-align:right;">
perc_teach_female
</th>
<th style="text-align:right;">
perc_stud_white
</th>
<th style="text-align:right;">
perc_stud_black
</th>
<th style="text-align:right;">
perc_stud_hisp
</th>
<th style="text-align:right;">
perc_stud_api
</th>
<th style="text-align:right;">
perc_stud_alp
</th>
<th style="text-align:right;">
perc_stud_bil
</th>
<th style="text-align:right;">
perc_stud_tag
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
101912041
</td>
<td style="text-align:right;">
865
</td>
<td style="text-align:right;">
275
</td>
<td style="text-align:right;">
16.01879
</td>
<td style="text-align:right;">
4707778
</td>
<td style="text-align:right;">
63.2
</td>
<td style="text-align:right;">
10.6
</td>
<td style="text-align:right;">
5.0
</td>
<td style="text-align:right;">
4.9465
</td>
<td style="text-align:right;">
48213
</td>
<td style="text-align:right;">
11.944444
</td>
<td style="text-align:right;">
5.555463
</td>
<td style="text-align:right;">
90.74059
</td>
<td style="text-align:right;">
1.852068
</td>
<td style="text-align:right;">
68.51781
</td>
<td style="text-align:right;">
0.1
</td>
<td style="text-align:right;">
77.5
</td>
<td style="text-align:right;">
21.3
</td>
<td style="text-align:right;">
1.2
</td>
<td style="text-align:right;">
21.5
</td>
<td style="text-align:right;">
5.1
</td>
<td style="text-align:right;">
3.5
</td>
</tr>
<tr>
<td style="text-align:left;">
101912043
</td>
<td style="text-align:right;">
1239
</td>
<td style="text-align:right;">
349
</td>
<td style="text-align:right;">
16.19752
</td>
<td style="text-align:right;">
7140014
</td>
<td style="text-align:right;">
67.1
</td>
<td style="text-align:right;">
10.1
</td>
<td style="text-align:right;">
5.2
</td>
<td style="text-align:right;">
12.8609
</td>
<td style="text-align:right;">
47292
</td>
<td style="text-align:right;">
11.705859
</td>
<td style="text-align:right;">
15.689369
</td>
<td style="text-align:right;">
58.20099
</td>
<td style="text-align:right;">
20.918984
</td>
<td style="text-align:right;">
69.29400
</td>
<td style="text-align:right;">
1.4
</td>
<td style="text-align:right;">
6.6
</td>
<td style="text-align:right;">
91.8
</td>
<td style="text-align:right;">
0.1
</td>
<td style="text-align:right;">
12.6
</td>
<td style="text-align:right;">
19.3
</td>
<td style="text-align:right;">
15.5
</td>
</tr>
<tr>
<td style="text-align:left;">
101912044
</td>
<td style="text-align:right;">
758
</td>
<td style="text-align:right;">
251
</td>
<td style="text-align:right;">
16.29848
</td>
<td style="text-align:right;">
4027459
</td>
<td style="text-align:right;">
60.3
</td>
<td style="text-align:right;">
11.9
</td>
<td style="text-align:right;">
4.2
</td>
<td style="text-align:right;">
7.9144
</td>
<td style="text-align:right;">
47953
</td>
<td style="text-align:right;">
11.170213
</td>
<td style="text-align:right;">
8.601427
</td>
<td style="text-align:right;">
86.01061
</td>
<td style="text-align:right;">
3.237979
</td>
<td style="text-align:right;">
74.19722
</td>
<td style="text-align:right;">
0.8
</td>
<td style="text-align:right;">
82.2
</td>
<td style="text-align:right;">
16.1
</td>
<td style="text-align:right;">
0.9
</td>
<td style="text-align:right;">
23.5
</td>
<td style="text-align:right;">
5.4
</td>
<td style="text-align:right;">
2.8
</td>
</tr>
<tr>
<td style="text-align:left;">
101912047
</td>
<td style="text-align:right;">
1177
</td>
<td style="text-align:right;">
382
</td>
<td style="text-align:right;">
17.30913
</td>
<td style="text-align:right;">
5747528
</td>
<td style="text-align:right;">
70.0
</td>
<td style="text-align:right;">
9.6
</td>
<td style="text-align:right;">
3.7
</td>
<td style="text-align:right;">
3.9572
</td>
<td style="text-align:right;">
47300
</td>
<td style="text-align:right;">
11.058824
</td>
<td style="text-align:right;">
52.941522
</td>
<td style="text-align:right;">
20.58757
</td>
<td style="text-align:right;">
13.235675
</td>
<td style="text-align:right;">
58.82310
</td>
<td style="text-align:right;">
3.1
</td>
<td style="text-align:right;">
5.8
</td>
<td style="text-align:right;">
91.1
</td>
<td style="text-align:right;">
0.1
</td>
<td style="text-align:right;">
15.1
</td>
<td style="text-align:right;">
22.3
</td>
<td style="text-align:right;">
2.6
</td>
</tr>
<tr>
<td style="text-align:left;">
101912048
</td>
<td style="text-align:right;">
1119
</td>
<td style="text-align:right;">
343
</td>
<td style="text-align:right;">
17.42342
</td>
<td style="text-align:right;">
5665863
</td>
<td style="text-align:right;">
70.4
</td>
<td style="text-align:right;">
9.0
</td>
<td style="text-align:right;">
5.1
</td>
<td style="text-align:right;">
7.1751
</td>
<td style="text-align:right;">
49208
</td>
<td style="text-align:right;">
13.557252
</td>
<td style="text-align:right;">
39.689586
</td>
<td style="text-align:right;">
47.85384
</td>
<td style="text-align:right;">
7.786042
</td>
<td style="text-align:right;">
69.28900
</td>
<td style="text-align:right;">
13.6
</td>
<td style="text-align:right;">
21.4
</td>
<td style="text-align:right;">
63.8
</td>
<td style="text-align:right;">
1.0
</td>
<td style="text-align:right;">
11.0
</td>
<td style="text-align:right;">
10.7
</td>
<td style="text-align:right;">
14.0
</td>
</tr>
<tr>
<td style="text-align:left;">
101912049
</td>
<td style="text-align:right;">
1287
</td>
<td style="text-align:right;">
423
</td>
<td style="text-align:right;">
18.50169
</td>
<td style="text-align:right;">
6141881
</td>
<td style="text-align:right;">
67.5
</td>
<td style="text-align:right;">
14.2
</td>
<td style="text-align:right;">
2.2
</td>
<td style="text-align:right;">
6.9251
</td>
<td style="text-align:right;">
48187
</td>
<td style="text-align:right;">
11.845070
</td>
<td style="text-align:right;">
50.319431
</td>
<td style="text-align:right;">
33.81569
</td>
<td style="text-align:right;">
15.864879
</td>
<td style="text-align:right;">
64.74816
</td>
<td style="text-align:right;">
10.5
</td>
<td style="text-align:right;">
15.2
</td>
<td style="text-align:right;">
73.7
</td>
<td style="text-align:right;">
0.6
</td>
<td style="text-align:right;">
11.3
</td>
<td style="text-align:right;">
7.4
</td>
<td style="text-align:right;">
22.6
</td>
</tr>
<tr>
<td style="text-align:left;">
101912051
</td>
<td style="text-align:right;">
1527
</td>
<td style="text-align:right;">
489
</td>
<td style="text-align:right;">
17.96800
</td>
<td style="text-align:right;">
7528592
</td>
<td style="text-align:right;">
68.6
</td>
<td style="text-align:right;">
10.1
</td>
<td style="text-align:right;">
4.7
</td>
<td style="text-align:right;">
6.9251
</td>
<td style="text-align:right;">
48467
</td>
<td style="text-align:right;">
13.287043
</td>
<td style="text-align:right;">
18.829338
</td>
<td style="text-align:right;">
70.57742
</td>
<td style="text-align:right;">
4.708276
</td>
<td style="text-align:right;">
67.04783
</td>
<td style="text-align:right;">
0.6
</td>
<td style="text-align:right;">
30.8
</td>
<td style="text-align:right;">
68.2
</td>
<td style="text-align:right;">
0.3
</td>
<td style="text-align:right;">
12.3
</td>
<td style="text-align:right;">
20.2
</td>
<td style="text-align:right;">
6.2
</td>
</tr>
<tr>
<td style="text-align:left;">
101912053
</td>
<td style="text-align:right;">
849
</td>
<td style="text-align:right;">
262
</td>
<td style="text-align:right;">
16.32689
</td>
<td style="text-align:right;">
4850304
</td>
<td style="text-align:right;">
68.7
</td>
<td style="text-align:right;">
11.1
</td>
<td style="text-align:right;">
2.7
</td>
<td style="text-align:right;">
6.9251
</td>
<td style="text-align:right;">
45770
</td>
<td style="text-align:right;">
7.980769
</td>
<td style="text-align:right;">
59.616808
</td>
<td style="text-align:right;">
36.53705
</td>
<td style="text-align:right;">
3.846146
</td>
<td style="text-align:right;">
67.30679
</td>
<td style="text-align:right;">
4.4
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:right;">
87.6
</td>
<td style="text-align:right;">
0.2
</td>
<td style="text-align:right;">
19.7
</td>
<td style="text-align:right;">
15.4
</td>
<td style="text-align:right;">
5.2
</td>
</tr>
<tr>
<td style="text-align:left;">
101912054
</td>
<td style="text-align:right;">
1068
</td>
<td style="text-align:right;">
392
</td>
<td style="text-align:right;">
15.47306
</td>
<td style="text-align:right;">
5586845
</td>
<td style="text-align:right;">
67.8
</td>
<td style="text-align:right;">
8.7
</td>
<td style="text-align:right;">
4.4
</td>
<td style="text-align:right;">
5.9358
</td>
<td style="text-align:right;">
46335
</td>
<td style="text-align:right;">
9.814286
</td>
<td style="text-align:right;">
39.859062
</td>
<td style="text-align:right;">
15.93464
</td>
<td style="text-align:right;">
26.821561
</td>
<td style="text-align:right;">
63.78276
</td>
<td style="text-align:right;">
1.0
</td>
<td style="text-align:right;">
3.5
</td>
<td style="text-align:right;">
94.7
</td>
<td style="text-align:right;">
0.6
</td>
<td style="text-align:right;">
8.9
</td>
<td style="text-align:right;">
20.1
</td>
<td style="text-align:right;">
16.4
</td>
</tr>
<tr>
<td style="text-align:left;">
101912055
</td>
<td style="text-align:right;">
1351
</td>
<td style="text-align:right;">
426
</td>
<td style="text-align:right;">
16.94703
</td>
<td style="text-align:right;">
6531806
</td>
<td style="text-align:right;">
69.6
</td>
<td style="text-align:right;">
7.5
</td>
<td style="text-align:right;">
4.6
</td>
<td style="text-align:right;">
3.9572
</td>
<td style="text-align:right;">
48635
</td>
<td style="text-align:right;">
12.108902
</td>
<td style="text-align:right;">
61.458874
</td>
<td style="text-align:right;">
22.86005
</td>
<td style="text-align:right;">
9.408547
</td>
<td style="text-align:right;">
75.88530
</td>
<td style="text-align:right;">
16.6
</td>
<td style="text-align:right;">
36.4
</td>
<td style="text-align:right;">
42.9
</td>
<td style="text-align:right;">
3.9
</td>
<td style="text-align:right;">
8.5
</td>
<td style="text-align:right;">
7.1
</td>
<td style="text-align:right;">
18.3
</td>
</tr>
</tbody>
</table>

And here is what the scaled versions look like:

``` r
aux_dat %>%
  select(CAMPUS, all_stud_n:perc_stud_tag) %>%
  slice(1:10) %>%
  kable() %>% 
  kable_styling(bootstrap_options = c("striped", "hover","condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
CAMPUS
</th>
<th style="text-align:right;">
all_stud_n
</th>
<th style="text-align:right;">
grade8_n
</th>
<th style="text-align:right;">
stud_teach_rat
</th>
<th style="text-align:right;">
all_exp
</th>
<th style="text-align:right;">
inst_exp
</th>
<th style="text-align:right;">
lead_exp
</th>
<th style="text-align:right;">
supp_exp
</th>
<th style="text-align:right;">
ed_aide
</th>
<th style="text-align:right;">
teach_salary
</th>
<th style="text-align:right;">
teach_expr
</th>
<th style="text-align:right;">
perc_teach_white
</th>
<th style="text-align:right;">
perc_teach_black
</th>
<th style="text-align:right;">
perc_teach_hisp
</th>
<th style="text-align:right;">
perc_teach_female
</th>
<th style="text-align:right;">
perc_stud_white
</th>
<th style="text-align:right;">
perc_stud_black
</th>
<th style="text-align:right;">
perc_stud_hisp
</th>
<th style="text-align:right;">
perc_stud_api
</th>
<th style="text-align:right;">
perc_stud_alp
</th>
<th style="text-align:right;">
perc_stud_bil
</th>
<th style="text-align:right;">
perc_stud_tag
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
101912041
</td>
<td style="text-align:right;">
0.6289525
</td>
<td style="text-align:right;">
0.3263949
</td>
<td style="text-align:right;">
0.8429297
</td>
<td style="text-align:right;">
0.9078013
</td>
<td style="text-align:right;">
-0.8101936
</td>
<td style="text-align:right;">
0.4454323
</td>
<td style="text-align:right;">
-0.0100475
</td>
<td style="text-align:right;">
-0.3928124
</td>
<td style="text-align:right;">
1.1623743
</td>
<td style="text-align:right;">
0.3100129
</td>
<td style="text-align:right;">
-2.3542084
</td>
<td style="text-align:right;">
4.5543855
</td>
<td style="text-align:right;">
-0.5717127
</td>
<td style="text-align:right;">
-0.2710618
</td>
<td style="text-align:right;">
-1.3634590
</td>
<td style="text-align:right;">
3.4733129
</td>
<td style="text-align:right;">
-0.6686362
</td>
<td style="text-align:right;">
-0.2405750
</td>
<td style="text-align:right;">
1.8266733
</td>
<td style="text-align:right;">
-0.2257731
</td>
<td style="text-align:right;">
-0.8639004
</td>
</tr>
<tr>
<td style="text-align:left;">
101912043
</td>
<td style="text-align:right;">
1.5985361
</td>
<td style="text-align:right;">
0.8130697
</td>
<td style="text-align:right;">
0.9094313
</td>
<td style="text-align:right;">
2.2440640
</td>
<td style="text-align:right;">
-0.3413843
</td>
<td style="text-align:right;">
0.3452344
</td>
<td style="text-align:right;">
0.0856401
</td>
<td style="text-align:right;">
1.4517943
</td>
<td style="text-align:right;">
0.9418652
</td>
<td style="text-align:right;">
0.2282763
</td>
<td style="text-align:right;">
-1.9993003
</td>
<td style="text-align:right;">
2.7205531
</td>
<td style="text-align:right;">
0.1977009
</td>
<td style="text-align:right;">
-0.1895924
</td>
<td style="text-align:right;">
-1.3207478
</td>
<td style="text-align:right;">
-0.3960796
</td>
<td style="text-align:right;">
1.6282003
</td>
<td style="text-align:right;">
-0.4789781
</td>
<td style="text-align:right;">
-0.1022586
</td>
<td style="text-align:right;">
1.2278111
</td>
<td style="text-align:right;">
0.8160277
</td>
</tr>
<tr>
<td style="text-align:left;">
101912044
</td>
<td style="text-align:right;">
0.3515583
</td>
<td style="text-align:right;">
0.1685545
</td>
<td style="text-align:right;">
0.9469971
</td>
<td style="text-align:right;">
0.5340363
</td>
<td style="text-align:right;">
-1.1587954
</td>
<td style="text-align:right;">
0.7059469
</td>
<td style="text-align:right;">
-0.3927983
</td>
<td style="text-align:right;">
0.2989151
</td>
<td style="text-align:right;">
1.1001242
</td>
<td style="text-align:right;">
0.0447697
</td>
<td style="text-align:right;">
-2.2475331
</td>
<td style="text-align:right;">
4.2878186
</td>
<td style="text-align:right;">
-0.5157865
</td>
<td style="text-align:right;">
0.3250507
</td>
<td style="text-align:right;">
-1.3404606
</td>
<td style="text-align:right;">
3.7298170
</td>
<td style="text-align:right;">
-0.8380483
</td>
<td style="text-align:right;">
-0.3055940
</td>
<td style="text-align:right;">
2.2601411
</td>
<td style="text-align:right;">
-0.1950635
</td>
<td style="text-align:right;">
-0.9618962
</td>
</tr>
<tr>
<td style="text-align:left;">
101912047
</td>
<td style="text-align:right;">
1.4378030
</td>
<td style="text-align:right;">
1.0301003
</td>
<td style="text-align:right;">
1.3230320
</td>
<td style="text-align:right;">
1.4790366
</td>
<td style="text-align:right;">
0.0072175
</td>
<td style="text-align:right;">
0.2450365
</td>
<td style="text-align:right;">
-0.6320175
</td>
<td style="text-align:right;">
-0.6233882
</td>
<td style="text-align:right;">
0.9437806
</td>
<td style="text-align:right;">
0.0066089
</td>
<td style="text-align:right;">
-0.6946612
</td>
<td style="text-align:right;">
0.6007755
</td>
<td style="text-align:right;">
-0.1123462
</td>
<td style="text-align:right;">
-1.2886206
</td>
<td style="text-align:right;">
-1.2648946
</td>
<td style="text-align:right;">
-0.4397399
</td>
<td style="text-align:right;">
1.6053948
</td>
<td style="text-align:right;">
-0.4789781
</td>
<td style="text-align:right;">
0.4395762
</td>
<td style="text-align:right;">
1.5349064
</td>
<td style="text-align:right;">
-0.9898950
</td>
</tr>
<tr>
<td style="text-align:left;">
101912048
</td>
<td style="text-align:right;">
1.2874398
</td>
<td style="text-align:right;">
0.7736096
</td>
<td style="text-align:right;">
1.3655567
</td>
<td style="text-align:right;">
1.4341702
</td>
<td style="text-align:right;">
0.0553005
</td>
<td style="text-align:right;">
0.1247990
</td>
<td style="text-align:right;">
0.0377963
</td>
<td style="text-align:right;">
0.1266067
</td>
<td style="text-align:right;">
1.4006007
</td>
<td style="text-align:right;">
0.8625430
</td>
<td style="text-align:right;">
-1.1587684
</td>
<td style="text-align:right;">
2.1374191
</td>
<td style="text-align:right;">
-0.3322570
</td>
<td style="text-align:right;">
-0.1901171
</td>
<td style="text-align:right;">
-0.9199190
</td>
<td style="text-align:right;">
0.4116356
</td>
<td style="text-align:right;">
0.7159815
</td>
<td style="text-align:right;">
-0.2839210
</td>
<td style="text-align:right;">
-0.4490329
</td>
<td style="text-align:right;">
0.3474714
</td>
<td style="text-align:right;">
0.6060367
</td>
</tr>
<tr>
<td style="text-align:left;">
101912049
</td>
<td style="text-align:right;">
1.7229746
</td>
<td style="text-align:right;">
1.2997444
</td>
<td style="text-align:right;">
1.7667533
</td>
<td style="text-align:right;">
1.6956929
</td>
<td style="text-align:right;">
-0.2933013
</td>
<td style="text-align:right;">
1.1668573
</td>
<td style="text-align:right;">
-1.3496752
</td>
<td style="text-align:right;">
0.0683393
</td>
<td style="text-align:right;">
1.1561493
</td>
<td style="text-align:right;">
0.2759685
</td>
<td style="text-align:right;">
-0.7864917
</td>
<td style="text-align:right;">
1.3462721
</td>
<td style="text-align:right;">
-0.0062491
</td>
<td style="text-align:right;">
-0.6667244
</td>
<td style="text-align:right;">
-1.0217689
</td>
<td style="text-align:right;">
0.0732685
</td>
<td style="text-align:right;">
1.0385160
</td>
<td style="text-align:right;">
-0.3706131
</td>
<td style="text-align:right;">
-0.3840127
</td>
<td style="text-align:right;">
0.0096666
</td>
<td style="text-align:right;">
1.8099851
</td>
</tr>
<tr>
<td style="text-align:left;">
101912051
</td>
<td style="text-align:right;">
2.3451673
</td>
<td style="text-align:right;">
1.7338057
</td>
<td style="text-align:right;">
1.5681816
</td>
<td style="text-align:right;">
2.4575475
</td>
<td style="text-align:right;">
-0.1610730
</td>
<td style="text-align:right;">
0.3452344
</td>
<td style="text-align:right;">
-0.1535791
</td>
<td style="text-align:right;">
0.0683393
</td>
<td style="text-align:right;">
1.2231879
</td>
<td style="text-align:right;">
0.7699722
</td>
<td style="text-align:right;">
-1.8893328
</td>
<td style="text-align:right;">
3.4180511
</td>
<td style="text-align:right;">
-0.4564552
</td>
<td style="text-align:right;">
-0.4253506
</td>
<td style="text-align:right;">
-1.3470316
</td>
<td style="text-align:right;">
0.9246439
</td>
<td style="text-align:right;">
0.8593302
</td>
<td style="text-align:right;">
-0.4356321
</td>
<td style="text-align:right;">
-0.1672788
</td>
<td style="text-align:right;">
1.3199397
</td>
<td style="text-align:right;">
-0.4859166
</td>
</tr>
<tr>
<td style="text-align:left;">
101912053
</td>
<td style="text-align:right;">
0.5874730
</td>
<td style="text-align:right;">
0.2408980
</td>
<td style="text-align:right;">
0.9575677
</td>
<td style="text-align:right;">
0.9861047
</td>
<td style="text-align:right;">
-0.1490522
</td>
<td style="text-align:right;">
0.5456302
</td>
<td style="text-align:right;">
-1.1104560
</td>
<td style="text-align:right;">
0.0683393
</td>
<td style="text-align:right;">
0.5774625
</td>
<td style="text-align:right;">
-1.0478986
</td>
<td style="text-align:right;">
-0.4608804
</td>
<td style="text-align:right;">
1.4996393
</td>
<td style="text-align:right;">
-0.4912450
</td>
<td style="text-align:right;">
-0.3981702
</td>
<td style="text-align:right;">
-1.2221833
</td>
<td style="text-align:right;">
-0.3305891
</td>
<td style="text-align:right;">
1.4913675
</td>
<td style="text-align:right;">
-0.4573051
</td>
<td style="text-align:right;">
1.4365522
</td>
<td style="text-align:right;">
0.8285873
</td>
<td style="text-align:right;">
-0.6259106
</td>
</tr>
<tr>
<td style="text-align:left;">
101912054
</td>
<td style="text-align:right;">
1.1552238
</td>
<td style="text-align:right;">
1.0958672
</td>
<td style="text-align:right;">
0.6398792
</td>
<td style="text-align:right;">
1.3907579
</td>
<td style="text-align:right;">
-0.2572390
</td>
<td style="text-align:right;">
0.0646803
</td>
<td style="text-align:right;">
-0.2971106
</td>
<td style="text-align:right;">
-0.1622365
</td>
<td style="text-align:right;">
0.7127368
</td>
<td style="text-align:right;">
-0.4197560
</td>
<td style="text-align:right;">
-1.1528331
</td>
<td style="text-align:right;">
0.3385508
</td>
<td style="text-align:right;">
0.4358896
</td>
<td style="text-align:right;">
-0.7680537
</td>
<td style="text-align:right;">
-1.3338897
</td>
<td style="text-align:right;">
-0.5652632
</td>
<td style="text-align:right;">
1.7226801
</td>
<td style="text-align:right;">
-0.3706131
</td>
<td style="text-align:right;">
-0.9041741
</td>
<td style="text-align:right;">
1.3097032
</td>
<td style="text-align:right;">
0.9420223
</td>
</tr>
<tr>
<td style="text-align:left;">
101912055
</td>
<td style="text-align:right;">
1.8888927
</td>
<td style="text-align:right;">
1.3194745
</td>
<td style="text-align:right;">
1.1883033
</td>
<td style="text-align:right;">
1.9099165
</td>
<td style="text-align:right;">
-0.0408655
</td>
<td style="text-align:right;">
-0.1757947
</td>
<td style="text-align:right;">
-0.2014229
</td>
<td style="text-align:right;">
-0.6233882
</td>
<td style="text-align:right;">
1.2634110
</td>
<td style="text-align:right;">
0.3663544
</td>
<td style="text-align:right;">
-0.3963678
</td>
<td style="text-align:right;">
0.7288454
</td>
<td style="text-align:right;">
-0.2667835
</td>
<td style="text-align:right;">
0.5022311
</td>
<td style="text-align:right;">
-0.8213545
</td>
<td style="text-align:right;">
1.2302659
</td>
<td style="text-align:right;">
0.0350754
</td>
<td style="text-align:right;">
0.3445964
</td>
<td style="text-align:right;">
-0.9908677
</td>
<td style="text-align:right;">
-0.0210429
</td>
<td style="text-align:right;">
1.2080109
</td>
</tr>
</tbody>
</table>

### Additional Covariates

There are thousands of additional covariates available, for which we
keep the original names in the raw AEIS data. You can review the AEIS
[data
documentation](https://rptsvr1.tea.texas.gov/perfreport/aeis/2008/xplore/aeisref.html)
for the meanings of column names.

As mentioned previously, in the processed data, we handle missing values
with mean imputation and add columns indicating whether a value was
missing in the original data. For example:

``` r
rct_dat %>%
  select(CAMPUS, starts_with("CH311TS06R_67")) %>%
  slice(1:10) %>%
  kable() %>% 
  kable_styling(bootstrap_options = c("striped", "hover","condensed"))
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
CAMPUS
</th>
<th style="text-align:right;">
CH311TS06R_67
</th>
<th style="text-align:right;">
CH311TS06R_67_mis
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
031903044
</td>
<td style="text-align:right;">
-0.0708111
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
031903045
</td>
<td style="text-align:right;">
-0.8382957
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
074909041
</td>
<td style="text-align:right;">
1.5409066
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
178908041
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
021901041
</td>
<td style="text-align:right;">
0.2361828
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
220901045
</td>
<td style="text-align:right;">
0.3896797
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
175902041
</td>
<td style="text-align:right;">
-0.6847988
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
234906041
</td>
<td style="text-align:right;">
-0.3778049
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
014905041
</td>
<td style="text-align:right;">
1.5409066
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
143905101
</td>
<td style="text-align:right;">
0.0000000
</td>
<td style="text-align:right;">
1
</td>
</tr>
</tbody>
</table>

You can see that for originally missing values, the original column
`CH311TS06R_67` takes the value of `0.00` and the missing value
indicator column `CH311TS06R_67_mis` takes the value of `1`.

## Comparison of RCT and Auxiliary Schools

You may be interested in doing some poking around to see how similar or
different the RCT schools and auxiliary Texas schools are to each other.

Here are some summaries of baseline variables split by the RCT and
Auxiliary schools:

``` r
covs_ms_noprep %>%
  mutate(school_type = case_when(CAMPUS %in% rct$CAMPUS ~ "RCT",
                                  TRUE ~ "Auxiliary")) %>%
  select(CAMPUS, school_type, premA, all_stud_n:perc_stud_tag) %>%
  pivot_longer(premA:perc_stud_tag, names_to = "var", values_to = "val") %>%
  group_by(school_type, var) %>%
  summarize(mean = mean(val, na.rm = T), sd = sd(val, na.rm = T) ,min = min(val, na.rm = T), 
            max = max(val, na.rm = T)) %>%
  arrange(var) %>%
  kable(digits = 2) %>% 
  kable_styling(bootstrap_options = c("striped", "hover","condensed"))
```

    ## `summarise()` has grouped output by 'school_type'. You can override using the
    ## `.groups` argument.

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
school_type
</th>
<th style="text-align:left;">
var
</th>
<th style="text-align:right;">
mean
</th>
<th style="text-align:right;">
sd
</th>
<th style="text-align:right;">
min
</th>
<th style="text-align:right;">
max
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
all_exp
</td>
<td style="text-align:right;">
3089846.21
</td>
<td style="text-align:right;">
1831557.75
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
9380526.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
all_exp
</td>
<td style="text-align:right;">
2112771.30
</td>
<td style="text-align:right;">
1131664.73
</td>
<td style="text-align:right;">
465126.00
</td>
<td style="text-align:right;">
4376482.00
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
all_stud_n
</td>
<td style="text-align:right;">
629.62
</td>
<td style="text-align:right;">
387.81
</td>
<td style="text-align:right;">
16.00
</td>
<td style="text-align:right;">
2086.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
all_stud_n
</td>
<td style="text-align:right;">
421.78
</td>
<td style="text-align:right;">
252.42
</td>
<td style="text-align:right;">
82.00
</td>
<td style="text-align:right;">
1080.00
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
ed_aide
</td>
<td style="text-align:right;">
6.66
</td>
<td style="text-align:right;">
4.33
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
66.34
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
ed_aide
</td>
<td style="text-align:right;">
5.84
</td>
<td style="text-align:right;">
2.97
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
11.96
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
grade8_n
</td>
<td style="text-align:right;">
227.98
</td>
<td style="text-align:right;">
152.68
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
927.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
grade8_n
</td>
<td style="text-align:right;">
153.08
</td>
<td style="text-align:right;">
112.48
</td>
<td style="text-align:right;">
6.00
</td>
<td style="text-align:right;">
543.00
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
inst_exp
</td>
<td style="text-align:right;">
69.87
</td>
<td style="text-align:right;">
8.39
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
inst_exp
</td>
<td style="text-align:right;">
71.88
</td>
<td style="text-align:right;">
5.96
</td>
<td style="text-align:right;">
57.90
</td>
<td style="text-align:right;">
82.90
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
lead_exp
</td>
<td style="text-align:right;">
8.38
</td>
<td style="text-align:right;">
5.06
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
97.40
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
lead_exp
</td>
<td style="text-align:right;">
8.42
</td>
<td style="text-align:right;">
2.23
</td>
<td style="text-align:right;">
1.70
</td>
<td style="text-align:right;">
14.50
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_stud_alp
</td>
<td style="text-align:right;">
13.07
</td>
<td style="text-align:right;">
4.65
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
33.30
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_stud_alp
</td>
<td style="text-align:right;">
13.20
</td>
<td style="text-align:right;">
3.32
</td>
<td style="text-align:right;">
7.60
</td>
<td style="text-align:right;">
20.60
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_stud_api
</td>
<td style="text-align:right;">
2.32
</td>
<td style="text-align:right;">
4.64
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
48.60
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_stud_api
</td>
<td style="text-align:right;">
2.08
</td>
<td style="text-align:right;">
3.68
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
17.90
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_stud_bil
</td>
<td style="text-align:right;">
7.47
</td>
<td style="text-align:right;">
9.89
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
99.10
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_stud_bil
</td>
<td style="text-align:right;">
2.63
</td>
<td style="text-align:right;">
2.55
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
10.70
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_stud_black
</td>
<td style="text-align:right;">
14.01
</td>
<td style="text-align:right;">
18.51
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
99.40
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_stud_black
</td>
<td style="text-align:right;">
9.58
</td>
<td style="text-align:right;">
11.25
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
52.50
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_stud_hisp
</td>
<td style="text-align:right;">
42.57
</td>
<td style="text-align:right;">
30.74
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_stud_hisp
</td>
<td style="text-align:right;">
21.06
</td>
<td style="text-align:right;">
20.83
</td>
<td style="text-align:right;">
1.60
</td>
<td style="text-align:right;">
91.00
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_stud_tag
</td>
<td style="text-align:right;">
9.64
</td>
<td style="text-align:right;">
7.18
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_stud_tag
</td>
<td style="text-align:right;">
10.50
</td>
<td style="text-align:right;">
6.18
</td>
<td style="text-align:right;">
3.20
</td>
<td style="text-align:right;">
34.50
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_stud_white
</td>
<td style="text-align:right;">
40.70
</td>
<td style="text-align:right;">
30.35
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
99.30
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_stud_white
</td>
<td style="text-align:right;">
66.63
</td>
<td style="text-align:right;">
20.89
</td>
<td style="text-align:right;">
8.00
</td>
<td style="text-align:right;">
90.10
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_teach_black
</td>
<td style="text-align:right;">
10.18
</td>
<td style="text-align:right;">
17.99
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_teach_black
</td>
<td style="text-align:right;">
2.83
</td>
<td style="text-align:right;">
4.91
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
26.93
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_teach_female
</td>
<td style="text-align:right;">
71.05
</td>
<td style="text-align:right;">
9.51
</td>
<td style="text-align:right;">
32.75
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_teach_female
</td>
<td style="text-align:right;">
72.43
</td>
<td style="text-align:right;">
10.04
</td>
<td style="text-align:right;">
35.89
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_teach_hisp
</td>
<td style="text-align:right;">
16.42
</td>
<td style="text-align:right;">
25.02
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
98.73
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_teach_hisp
</td>
<td style="text-align:right;">
4.94
</td>
<td style="text-align:right;">
12.59
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
66.92
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
perc_teach_white
</td>
<td style="text-align:right;">
72.10
</td>
<td style="text-align:right;">
28.73
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
perc_teach_white
</td>
<td style="text-align:right;">
91.57
</td>
<td style="text-align:right;">
12.92
</td>
<td style="text-align:right;">
33.08
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
premA
</td>
<td style="text-align:right;">
72.12
</td>
<td style="text-align:right;">
15.23
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
premA
</td>
<td style="text-align:right;">
81.18
</td>
<td style="text-align:right;">
9.29
</td>
<td style="text-align:right;">
51.00
</td>
<td style="text-align:right;">
100.00
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
stud_teach_rat
</td>
<td style="text-align:right;">
13.78
</td>
<td style="text-align:right;">
2.70
</td>
<td style="text-align:right;">
3.80
</td>
<td style="text-align:right;">
42.75
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
stud_teach_rat
</td>
<td style="text-align:right;">
13.02
</td>
<td style="text-align:right;">
2.05
</td>
<td style="text-align:right;">
8.93
</td>
<td style="text-align:right;">
18.77
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
supp_exp
</td>
<td style="text-align:right;">
5.02
</td>
<td style="text-align:right;">
2.10
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
17.50
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
supp_exp
</td>
<td style="text-align:right;">
4.96
</td>
<td style="text-align:right;">
1.94
</td>
<td style="text-align:right;">
1.20
</td>
<td style="text-align:right;">
9.00
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
teach_expr
</td>
<td style="text-align:right;">
10.99
</td>
<td style="text-align:right;">
2.92
</td>
<td style="text-align:right;">
0.00
</td>
<td style="text-align:right;">
20.25
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
teach_expr
</td>
<td style="text-align:right;">
12.42
</td>
<td style="text-align:right;">
2.43
</td>
<td style="text-align:right;">
7.22
</td>
<td style="text-align:right;">
17.13
</td>
</tr>
<tr>
<td style="text-align:left;">
Auxiliary
</td>
<td style="text-align:left;">
teach_salary
</td>
<td style="text-align:right;">
43414.79
</td>
<td style="text-align:right;">
4189.71
</td>
<td style="text-align:right;">
25201.00
</td>
<td style="text-align:right;">
59528.00
</td>
</tr>
<tr>
<td style="text-align:left;">
RCT
</td>
<td style="text-align:left;">
teach_salary
</td>
<td style="text-align:right;">
41792.72
</td>
<td style="text-align:right;">
3484.81
</td>
<td style="text-align:right;">
35778.00
</td>
<td style="text-align:right;">
50422.00
</td>
</tr>
</tbody>
</table>
