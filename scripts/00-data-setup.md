AEIS Data Example – Generating a Synthetic RCT
================
2024-07-09

## Load Data

``` r
load("../input/MS_data_public.Rdata")
var.names.clean <- read.csv("../input/var_names.csv")
```

## Clean some variable names for interpretability

``` r
covs_ms <- covs_ms %>%
  rename(all_stud_n = CPETALLC_67, grade8_n = CPETG08C_67, stud_teach_rat = CPSTKIDR_67,
         all_exp = CPFPAALLT_67, inst_exp = CPFEAINSP_67, lead_exp = CPFEAADSP_67, supp_exp = CPFEASUPP_67,
         ed_aide = CPSETOFC_67, teach_salary = CPSTTOSA_67, 
         teach_expr = CPSTEXPA_67, perc_teach_female = CPSTFEFP_67,
         perc_teach_white = CPSTWHFP_67, perc_teach_black = CPSTBLFP_67, perc_teach_hisp = CPSTHIFP_67,
         perc_stud_black = CPETBLAP_67, perc_stud_hisp = CPETHISP_67, 
         perc_stud_api = CPETPACP_67, perc_stud_white = CPETWHIP_67,
         perc_stud_alp = CPETSPEP_67, perc_stud_bil = CPETBILP_67, perc_stud_tag = CPETGIFP_67) %>%
  select(CAMPUS, GRDSPAN, starts_with("pre"),all_of(var.names.clean$var_clean), everything())

covs_ms_noprep <- covs_ms_noprep %>%
  rename(all_stud_n = CPETALLC_67, grade8_n = CPETG08C_67, stud_teach_rat = CPSTKIDR_67,
         all_exp = CPFPAALLT_67, inst_exp = CPFEAINSP_67, lead_exp = CPFEAADSP_67, supp_exp = CPFEASUPP_67,
         ed_aide = CPSETOFC_67, teach_salary = CPSTTOSA_67, 
         teach_expr = CPSTEXPA_67, perc_teach_female = CPSTFEFP_67,
         perc_teach_white = CPSTWHFP_67, perc_teach_black = CPSTBLFP_67, perc_teach_hisp = CPSTHIFP_67,
         perc_stud_black = CPETBLAP_67, perc_stud_hisp = CPETHISP_67, 
         perc_stud_api = CPETPACP_67, perc_stud_white = CPETWHIP_67,
         perc_stud_alp = CPETSPEP_67, perc_stud_bil = CPETBILP_67, perc_stud_tag = CPETGIFP_67) %>%
  select(CAMPUS, GRDSPAN, starts_with("pre"),all_of(var.names.clean$var_clean), everything())
```

Here are descriptions of the variables that we will use in matching:

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;font-weight: bold;text-align: center;">
Original Variable
</th>
<th style="text-align:left;font-weight: bold;text-align: center;">
Variable Description
</th>
<th style="text-align:left;font-weight: bold;text-align: center;">
Clean Name
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
CPETALLC_67
</td>
<td style="text-align:left;">
Total Students (n)
</td>
<td style="text-align:left;">
all_stud_n
</td>
</tr>
<tr>
<td style="text-align:left;">
CPETG08C_67
</td>
<td style="text-align:left;">
Total 8th Grade Students
</td>
<td style="text-align:left;">
grade8_n
</td>
</tr>
<tr>
<td style="text-align:left;">
CPSTKIDR_67
</td>
<td style="text-align:left;">
Student:Teacher Ratio
</td>
<td style="text-align:left;">
stud_teach_rat
</td>
</tr>
<tr>
<td style="text-align:left;">
CPFPAALLT_67
</td>
<td style="text-align:left;">
All Expenditures (\$)
</td>
<td style="text-align:left;">
all_exp
</td>
</tr>
<tr>
<td style="text-align:left;">
CPFEAINSP_67
</td>
<td style="text-align:left;">
Expenditures % Instruction
</td>
<td style="text-align:left;">
inst_exp
</td>
</tr>
<tr>
<td style="text-align:left;">
CPFEAADSP_67
</td>
<td style="text-align:left;">
Expenditures % School Leadership
</td>
<td style="text-align:left;">
lead_exp
</td>
</tr>
<tr>
<td style="text-align:left;">
CPFEASUPP_67
</td>
<td style="text-align:left;">
Expenditures % Support Services
</td>
<td style="text-align:left;">
supp_exp
</td>
</tr>
<tr>
<td style="text-align:left;">
CPSETOFC_67
</td>
<td style="text-align:left;">
Educational Aides (n)
</td>
<td style="text-align:left;">
ed_aide
</td>
</tr>
<tr>
<td style="text-align:left;">
CPSTTOSA_67
</td>
<td style="text-align:left;">
Average Teacher Base Salary (\$)
</td>
<td style="text-align:left;">
teach_salary
</td>
</tr>
<tr>
<td style="text-align:left;">
CPSTEXPA_67
</td>
<td style="text-align:left;">
Average Teacher Experience (years)
</td>
<td style="text-align:left;">
teach_expr
</td>
</tr>
<tr>
<td style="text-align:left;">
CPSTWHFP_67
</td>
<td style="text-align:left;">
Teachers % White
</td>
<td style="text-align:left;">
perc_teach_white
</td>
</tr>
<tr>
<td style="text-align:left;">
CPSTBLFP_67
</td>
<td style="text-align:left;">
Teachers % Black
</td>
<td style="text-align:left;">
perc_teach_black
</td>
</tr>
<tr>
<td style="text-align:left;">
CPSTHIFP_67
</td>
<td style="text-align:left;">
Teachers % Hispanic
</td>
<td style="text-align:left;">
perc_teach_hisp
</td>
</tr>
<tr>
<td style="text-align:left;">
CPSTFEFP_67
</td>
<td style="text-align:left;">
Teachers % Female
</td>
<td style="text-align:left;">
perc_teach_female
</td>
</tr>
<tr>
<td style="text-align:left;">
CPETWHIP_67
</td>
<td style="text-align:left;">
Students % White
</td>
<td style="text-align:left;">
perc_stud_white
</td>
</tr>
<tr>
<td style="text-align:left;">
CPETBLAP_67
</td>
<td style="text-align:left;">
Students % Black
</td>
<td style="text-align:left;">
perc_stud_black
</td>
</tr>
<tr>
<td style="text-align:left;">
CPETHISP_67
</td>
<td style="text-align:left;">
Students % Hispanic
</td>
<td style="text-align:left;">
perc_stud_hisp
</td>
</tr>
<tr>
<td style="text-align:left;">
CPETPACP_67
</td>
<td style="text-align:left;">
Students % Asian and Pacific Islander
</td>
<td style="text-align:left;">
perc_stud_api
</td>
</tr>
<tr>
<td style="text-align:left;">
CPETSPEP_67
</td>
<td style="text-align:left;">
Students % Assisted Learning Program
</td>
<td style="text-align:left;">
perc_stud_alp
</td>
</tr>
<tr>
<td style="text-align:left;">
CPETBILP_67
</td>
<td style="text-align:left;">
Students % Bilingual Program
</td>
<td style="text-align:left;">
perc_stud_bil
</td>
</tr>
<tr>
<td style="text-align:left;">
CPETGIFP_67
</td>
<td style="text-align:left;">
Students % Gifted and Talented Program
</td>
<td style="text-align:left;">
perc_stud_tag
</td>
</tr>
</tbody>
</table>

## Form Fake/Example Paired RCT

First, match pairs of schools on baseline characteristics. Note, that
this is not how one would design a paired trial because I used a
bipartite pair matching algorithm from `optmatch` (which is just the
package that I know how to use).

This results in 146 pairs of schools based on their previous 8th grade
Math TAKS performance, size of the school, student and teacher
demographics, and total school funding.

``` r
set.seed(25)

poss_rct <- covs_ms_noprep %>%
  filter(!is.na(grade8_n)) %>%
  select(CAMPUS) %>%
  left_join(covs_ms)
```

    ## Joining with `by = join_by(CAMPUS)`

``` r
# create a random grouping to be able to do bipartite matching
poss_rct$Z <- sample(0:1, nrow(poss_rct), replace = T)

# calculate distances between schools
dist_mat <- match_on(Z ~ premA + premB + premF + all_stud_n + stud_teach_rat + all_exp + 
                       perc_teach_white + perc_stud_hisp + 
                       perc_stud_alp + perc_stud_bil, data = poss_rct, caliper = 1)
summary(dist_mat)
```

    ## Membership: 730 treatment, 707 control
    ## Total eligible potential matches: 240 
    ## Total ineligible potential matches: 515870 
    ## 
    ## 593 unmatchable treatment members:
    ##  3, 4, 7, 9, 11, ...
    ## See summary(dist_mat)$unmatchable$treatment for a complete list.
    ## 
    ## 571 unmatchable control members:
    ##  1, 2, 5, 6, 8, ...
    ## See summary(dist_mat)$unmatchable$control for a complete list.
    ## 
    ## Summary of minimum matchable distance per treatment member:
    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##  0.4171  0.7191  0.8604  0.8244  0.9341  0.9976

``` r
# exclude distances outside of the caliper
initialmatch <- fullmatch(dist_mat, data = poss_rct)
excl <- which(is.na(initialmatch))

# and recalculate distances
dist.update <- match_on(Z ~ premA + premB + premF + all_stud_n + stud_teach_rat + all_exp + 
                       perc_teach_white + perc_stud_hisp + 
                       perc_stud_alp + perc_stud_bil, dat = poss_rct[-excl,]) 

# final optimal pair matching
fakematch <- pairmatch(dist.update,  data = poss_rct)
summary(fakematch)
```

    ## Structure of matched sets:
    ##  1:0  1:1  0:0 
    ##    1  136 1164 
    ## Effective Sample Size:  136 
    ## (equivalent number of matched pairs).

Select 25 random pairs from those matched to make up our paired trial.

``` r
set.seed(125)

match.ids <- unique(fakematch[which(!is.na(fakematch))])
rct.ids <- sample(match.ids, 25)
```

Randomly assign one school within each pair to receive treatment `Tr`
and save RCT information. We also include a Bernoulli randomized
treatment assignment `TrBern` (ignoring pairs).

``` r
set.seed(73)

rct <- poss_rct %>%
  select(CAMPUS) %>%
  mutate(match = fakematch) %>%
  filter(match %in% rct.ids) %>%
  mutate(match = factor(match,levels = rct.ids, labels = LETTERS[1:25])) %>%
  group_by(match) %>% 
  mutate(k = row_number()) %>%
  pivot_wider(values_from = CAMPUS, names_from = k, names_prefix = "CAMPUS") %>%
  mutate(Tr1 = sample(0:1,1),
         Tr2 = 1-Tr1) %>%
  pivot_longer(!match,
               names_to = c(".value","k"),
               names_pattern = "(.*)(1|2)") %>%
  select(CAMPUS, match, k, Tr) %>%
  ungroup() %>%
  arrange(match, k) %>%
  left_join(select(covs_ms_noprep, CAMPUS, clust_size = CPETG08C_78))
```

    ## Joining with `by = join_by(CAMPUS)`

``` r
rct$TrBern = sample(0:1, 50, replace = T)
```

``` r
save(rct, file = "../data/rct_schools.Rdata")
```

Example Paired RCT schools:

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
CAMPUS
</th>
<th style="text-align:left;">
match
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
<tr>
<td style="text-align:left;">
175902041
</td>
<td style="text-align:left;">
D
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
234906041
</td>
<td style="text-align:left;">
D
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
174
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
014905041
</td>
<td style="text-align:left;">
E
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
44
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
143905101
</td>
<td style="text-align:left;">
E
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
107901041
</td>
<td style="text-align:left;">
F
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
213
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
213901041
</td>
<td style="text-align:left;">
F
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
134
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
094904041
</td>
<td style="text-align:left;">
G
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
103
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
241902041
</td>
<td style="text-align:left;">
G
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
66
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
123908041
</td>
<td style="text-align:left;">
H
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
187
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
252901041
</td>
<td style="text-align:left;">
H
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
168
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
183902042
</td>
<td style="text-align:left;">
I
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
187
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
230906041
</td>
<td style="text-align:left;">
I
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
74
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
139912041
</td>
<td style="text-align:left;">
J
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
87
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
194903102
</td>
<td style="text-align:left;">
J
</td>
<td style="text-align:right;">
1
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
014906046
</td>
<td style="text-align:left;">
K
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
265
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
150901041
</td>
<td style="text-align:left;">
K
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
135
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
025909041
</td>
<td style="text-align:left;">
L
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
114
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
127905101
</td>
<td style="text-align:left;">
L
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
13
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
100903041
</td>
<td style="text-align:left;">
M
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
116
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
236901042
</td>
<td style="text-align:left;">
M
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
63
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
152909041
</td>
<td style="text-align:left;">
N
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
113
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
188903041
</td>
<td style="text-align:left;">
N
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
62
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
015906041
</td>
<td style="text-align:left;">
O
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
82
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
092906041
</td>
<td style="text-align:left;">
O
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
057922042
</td>
<td style="text-align:left;">
P
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
244
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
057922044
</td>
<td style="text-align:left;">
P
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
278
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
046901041
</td>
<td style="text-align:left;">
Q
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
554
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
220918043
</td>
<td style="text-align:left;">
Q
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
206
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
161925101
</td>
<td style="text-align:left;">
R
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
15
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
227912041
</td>
<td style="text-align:left;">
R
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
85
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
019905041
</td>
<td style="text-align:left;">
S
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
117
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
091909041
</td>
<td style="text-align:left;">
S
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
124
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
026901041
</td>
<td style="text-align:left;">
T
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
122
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
084908042
</td>
<td style="text-align:left;">
T
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
86
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
113901041
</td>
<td style="text-align:left;">
U
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
88
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
176902041
</td>
<td style="text-align:left;">
U
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
77
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
061902045
</td>
<td style="text-align:left;">
V
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
248
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
123905041
</td>
<td style="text-align:left;">
V
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
197
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
034907041
</td>
<td style="text-align:left;">
W
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
72
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
212903041
</td>
<td style="text-align:left;">
W
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
270
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
035901041
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
82
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
185903041
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
84
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
043911041
</td>
<td style="text-align:left;">
Y
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
181
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
170906042
</td>
<td style="text-align:left;">
Y
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
385
</td>
<td style="text-align:right;">
1
</td>
</tr>
</tbody>
</table>

## Rename Outcomes for Clarity

The outcome data consists of variables representing the **8th grade math
TAKS passing rates** for different subgroups of students and two
different school years. The variables follow the naming structure
`outm[A][08]` where `[A]` takes the values of A, B, H, W, M, F, and E
which indicate subgroups as in the table below and `[08]` takes the
value of 08 or 09, indicating the 2007/8 or 2008/9 school years.

| Code | Subgroup     |
|------|--------------|
| A    | All Students |
| B    | Black        |
| E    | Low SES      |
| F    | Female       |
| H    | Hispanic     |
| M    | Male         |
| W    | White        |

For this tutorial, we will focus on the overall `A`, 2008 `08` math TAKS
passing rate, so we rename that column `taks08`, but leave the remaining
variable names as-is, if you would like to explore.

``` r
out_ms <- out_ms %>%
  rename(taks08 = outmA08) %>%
  select(CAMPUS, taks08, everything())
```

## Save Cleaned Data

``` r
rct_dat = rct %>%
  left_join(out_ms, by = "CAMPUS") %>%
  left_join(covs_ms, by = "CAMPUS") %>%
  select(CAMPUS, GRDSPAN, match, k , Tr, TrBern, taks08, starts_with("pre"), 
         all_of(var.names.clean$var_clean), everything())

aux_dat = out_ms %>%
  filter(!(CAMPUS %in% rct$CAMPUS)) %>%
  left_join(covs_ms, by = "CAMPUS") %>%
  select(CAMPUS, GRDSPAN, taks08, starts_with("pre"), 
         all_of(var.names.clean$var_clean), everything())

save(rct_dat, aux_dat, covs_ms_noprep, file = "../data/rct_aux_dat.Rdata")
```
