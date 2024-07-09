devtools::install_github("manncz/dRCT")

library(dRCT)

load('abTestData.RData')
## or
dat <- read.csv('abTestExample.csv')

### t-test
print(TTest <- t.test(completion~video,data=dat))
TTest$estimate[2]-TTest$estimate[1]
TTest$stderr

loop(Y=dat$completion,Tr=dat$video)

### use covariates
### covariates start with string "student_prior"
covariates <- dat[,startsWith(names(dat),'student_prior')]


LOOP <- with(dat,
     loop(Y= completion,Tr=video,Z=covariates))

print(LOOP)
confint(LOOP)


RELOOP <- loop(dat$complete,dat$T,dat[,startsWith(names(dat),'student_prior')],
               pred=reloop,yhat=dat$Yhat)

print(RELOOP)
confint(RELOOP)
