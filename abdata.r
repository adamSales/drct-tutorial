library(tidyverse)

print(load('../ethenExperiments/data/pairwiseData.RData'))

## print(load('../ethenExperiments/results/contrasts.RData'))

## print(load('../ethenExperiments/results/resTotalFast.RData'))

## Contrasts <- filter(Contrasts,model=='combined')

## loopMult <- map_dbl(resTotal,~.['simpDiff','Var']/.['loop','Var'])
## loopMult <- loopMult[endsWith(names(loopMult),'combined')]
## names(loopMult) <- gsub(".combined","",names(loopMult),fixed=TRUE)




## length(intersect(
##   Contrasts%>%filter(compSimp=='reloopPlusVsLoop')%>%
##   arrange(-ssMult)%>%slice(1:50)%>%pull(ps),
##   names(sort(loopMult,dec=TRUE)[1:50])))

## cand <- intersect(
##   Contrasts%>%filter(compSimp=='reloopPlusVsLoop')%>%
##   arrange(-ssMult)%>%slice(1:50)%>%pull(ps),
##   names(sort(loopMult,dec=TRUE)[1:50]))


## loopMult[cand]

## decide <- full_join(
##   Contrasts%>%filter(compSimp=='reloopPlusVsLoop',ps%in%cand)%>%
##   select(problem_set=ps,ssMult),
##   datPW%>%filter(problem_set%in%cand,model=='combined')%>%
##   group_by(problem_set)%>%summarize(n()))

## decide$loopMult <- loopMult[decide$problem_set]


## final <- decide$problem_set[decide$ssMult>1.2&decide$loopMult>1.2]


## dat <- datPW%>%filter(problem_set==final,model=='combined')

## dat <- dat%>%
##   select(
##     user_id,
##     starts_with("student_prior"),
##     T=Z,
##     complete=completion_target,
##     Yhat=completion_prediction)

## save(dat,file='abTestData.RData')

combined <- resTotal[map_lgl(resTotal,~.[1,'model']=='combined')]
tstats <- map_dfr(combined,~data.frame(t(.[,'Est']/sqrt(.[,'Var']))))
names(tstats) <- rownames(combined[[1]])
sig <- as.data.frame(abs(tstats)>1.96)

tstats[sig$loop & !sig$simpDiff,]
tstats[sig$reloopPlus & !sig$simpDiff,]

tstats[sig$reloopPlus & !sig$simpDiff,]%>%mutate(across(everything(), ~2*pnorm(-abs(.))))


### choose row 139, PSATNB2Treatment 4;Treatment 3 cuz simpDiff p-value is .18, i.e. not at all sig
### and loop and reloopPlus pvals are  0.01378932 0.008768622, i.e. p<0.05 and p<0.01

## sample size OK?
datPW%>%filter(model=='combined',problem_set=="PSATNB2Treatment 4;Treatment 3")%>%summarize(nt=sum(Z),nc=sum(1-Z))

### assistments url: https://app.assistments.org/find/lv/ps/487281

final <- combined[[139]]$ps[1]

dat <- datPW%>%filter(problem_set==final,model=='combined')

dat <- dat%>%
  select(
    user_id,
    starts_with("student_prior"),
    T=Z,
    complete=completion_target,
    Yhat=completion_prediction)

save(dat,file='abTestData.RData')
write_csv(dat,'abTestExample.csv')
