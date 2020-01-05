Using linear regression with base sas and r to interpolate missimg values

github
https://tinyurl.com/wkwbsmt
https://github.com/rogerjdeangelis/utl-using-linear-regression-with-base-sas-and-r-to-interpolate-missimg-values

Interpolate missing values using linear regression

    Three Solutions
          a. using single data step to calculate sums of squares
          b. using proc corr sums of squares
          c. R

StackOverflow
https://tinyurl.com/vlbds6w
https://stackoverflow.com/questions/57242496/r-linear-extrapolate-missing-values

R linear extrapolate missing values

 *_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data have;
   input grp$ x y;
cards4;
A 2001 1.5
A 2002 2.6
A 2003 2.8
A 2004 2.9
A 2005 .
B 2001 0.1
B 2002 0.6
B 2003 0.7
B 2004 1.4
B 2005 .
C 2001 4.7
C 2002 4.6
C 2003 4.8
C 2004 5.0
C 2005 .
;;;;
run;quit;

WORK.HAVE total obs=15

                      |  RULES
                      |
 GRP      X      Y    |   Y
                      |
  A     2001    1.5   |
  A     2002    2.6   |
  A     2003    2.8   |            SLOPE         INTERCEPT
  A     2004    2.9   |
  A     2005     .    |  2.890 =   0.220 * 2005 + -438.21
  B     2001    0.1   |
  B     2002    0.6   |
  B     2003    0.7   |
  B     2004    1.4   |
  B     2005     .    |
  C     2001    4.7   |
  C     2002    4.6   |
  C     2003    4.8   |
  C     2004    5.0   |
  C     2005     .    |

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;


GRP      X       Y     SLOPE    INTERCEPT

 A     2001    1.50      .           .
 A     2002    2.60      .           .
 A     2003    2.80      .           .
 A     2004    2.90      .           .

 A     2005    3.55*    0.44     -878.65

 B     2001    0.10      .           .
 B     2002    0.60      .           .
 B     2003    0.70      .           .
 B     2004    1.40      .           .

 B     2005*   1.70     0.40     -800.30

 C     2001    4.70      .           .
 C     2002    4.60      .           .
 C     2003    4.80      .           .
 C     2004    5.00      .           .

 C     2005*   5.05     0.11     -215.50

* Interpolated;

*              _       _            _
  __ _      __| | __ _| |_ __ _ ___| |_ ___ _ __
 / _` |    / _` |/ _` | __/ _` / __| __/ _ \ '_ \
| (_| |_  | (_| | (_| | || (_| \__ \ ||  __/ |_) |
 \__,_(_)  \__,_|\__,_|\__\__,_|___/\__\___| .__/
                                           |_|
;


data want;
   retain sumx sumy sumxx sumxy sumyy n;
   set have;
   by grp notsorted;
   if first.grp then do;
     sumx  = 0;
     sumy  = 0;
     sumxx = 0;
     sumxy = 0;
     sumyy = 0;
     n     = 0;
   end;
   if Y ne . then do;
      sumx  = sum(sumx, x);
      sumy  = sum(sumy, y);
      sumxx = sum(sumxx, x ** 2);
      sumxy = sum(sumxy, x * y);
      sumyy = sum(sumyy, y * y);
      n     = sum(n, 1);
   end;
   if last.grp then do;
      nmr = sumxy  - sumx * sumy /n;
      den = sqrt ( sumxx -(sumx)**2/n ) * sqrt ( sumyy -(sumy)**2/n );
      slope = (sumxy - sumx * sumy / n)/(sumxx - sumx ** 2 / n);
      intercept = sumy / n - slope * sumx / n;
      corr=nmr/den;
      put slope = ;
      put intercept = ;
      put corr=;
      y=slope*x + intercept;
   end;
   keep grp x y slope intercept;
run;

*_
| |__     _ __  _ __ ___   ___    ___ ___  _ __ _ __
| '_ \   | '_ \| '__/ _ \ / __|  / __/ _ \| '__| '__|
| |_) |  | |_) | | | (_) | (__  | (_| (_) | |  | |
|_.__(_) | .__/|_|  \___/ \___|  \___\___/|_|  |_|
         |_|
;

proc datasets lib=work mt=data mt=view;
  delete avg ssq havSsq want;
run;quit;

ods output simplestats=avg;
ods output csscp=ssq;
proc corr data=have(where=(Y ne .)) sscp csscp;
by grp;
var x y;
run;

data havSsq/view=havSsq;
merge
   avg(where=(variable="X") keep=grp variable mean      rename=mean=x_avg)
   avg(where=(variable="Y") keep=grp variable mean      rename=(mean=y_avg))
   ssq(where=(variable="X") keep=grp variable x y nobs  rename=(x=x_ssq y=xy_ssq))
   ssq(where=(variable="X") keep=grp variable y         rename=(y=y_ssq));
   Slope=xy_ssq/x_ssq;
   Intercept=(y_avg-Slope*x_avg);
   keep grp slope intercept;
run;quit;

data want;
 merge have havSsq;
 by grp;
 if y=. then y=intercept + slope*x;
run;

*         ____
  ___    |  _ \
 / __|   | |_) |
| (__ _  |  _ <
 \___(_) |_| \_\

;
options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
   input grp$ x y;
cards4;
A 2001 1.5
A 2002 2.6
A 2003 2.8
A 2004 2.9
A 2005 .
B 2001 0.1
B 2002 0.6
B 2003 0.7
B 2004 1.4
B 2005 .
C 2001 4.7
C 2002 4.6
C 2003 4.8
C 2004 5.0
C 2005 .
;;;;
run;quit;


%utlfkil(d:/xpt/want.xpt);

proc datasets lib=work;
  delete want fixR;
run;quit;

%utl_submit_r64('
library(dplyr);
library(broom);
library(data.table);
library(SASxport);
library(haven);
have<-read_sas("d:/sd1/have.sas7bdat");
fitted_models = have %>% group_by(GRP) %>%
do(model = lm(Y ~ X, data = .));
want<-as.data.frame(ungroup(fitted_models %>% tidy(model)));
str(want);
write.xport(want,file="d:/xpt/want.xpt");
');

libname xpt xport "d:/xpt/want.xpt";
data want;
  set xpt.want;
run;quit;
libname xpt clear;


WORK.WANT total obs=6

  GRP    TERM           ESTIMATE    STD_ERRO    STATISTI    P_VALUE

   A     (Intercept)     -878.65     336.277    -2.61288    0.12055
   A     X                  0.44       0.168     2.62016    0.12000
   B     (Intercept)     -800.30     155.113    -5.15946    0.03557
   B     X                  0.40       0.077     5.16398    0.03551
   C     (Intercept)     -215.50     104.053    -2.07106    0.17417
   C     X                  0.11       0.052     2.11695    0.16848

data fixR;
    merge
      want(where=(TERM="(Intercept)") rename=estimate=intercept)
      want(where=(TERM="X"          ) rename=estimate=slope)
      have;
  by grp;
  if y=. then y=intercept + slope*x;
  keep grp x y slope intercept;
run;quit;


