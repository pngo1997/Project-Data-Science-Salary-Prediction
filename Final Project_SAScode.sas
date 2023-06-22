*Load the dataset and print first few observation;
PROC IMPORT datafile="C:\Users\MNGO\OneDrive - DePaul University\salaries.csv" out=salary replace;
DELIMITER = ',';
GETNAMES = YES;
DATAROW = 2;
RUN;

TITLE "Salary Data 10 observation";
PROC PRINT DATA=salary (OBS=10);
RUN;

*Get data types of each attribute;
TITLE "Data Types";
PROC CONTENTS data=salary;
RUN;

*Checking distribution of each attribute;
*Starting with predicted value - salary in USD;
TITLE "Distribution of Salary (USD)";
PROC UNIVARIATE data=salary normal;
VAR salary_in_usd;
HISTOGRAM / normal(mu=est sigma=est);
RUN;

*Working Year;
TITLE "Distribution of Working Year - Bar Chart";
PROC FREQ;
TABLES work_year;
RUN;
PROC SGPLOT DATA = salary;
VBAR work_year;
RUN;

TITLE "Boxplot: Working Year vs. Salary (USD)";
PROC SORT;
BY work_year;
RUN;
PROC BOXPLOT;
PLOT salary_in_usd*work_year;
RUN;

*Experience Level;
TITLE "Distribution of Experience Level - Bar Chart";
PROC FREQ;
TABLES experience_level;
RUN;
PROC SGPLOT DATA = salary;
VBAR experience_level;
RUN;

TITLE "Boxplot: Experience vs. Salary (USD)";
PROC SORT;
BY experience_level;
RUN;
PROC BOXPLOT;
PLOT salary_in_usd*experience_level;
RUN;

*Employment Type;
TITLE "Distribution of Employment Type - Bar Chart";
PROC FREQ;
TABLES employment_type;
RUN;
PROC SGPLOT DATA = salary;
VBAR employment_type;
RUN;

*Salary - Original Currency;
TITLE "Distribution of Salary (Original currency)";
PROC UNIVARIATE data=salary normal;
VAR salary;
HISTOGRAM / normal(mu=est sigma=est);
RUN;

*Salary Currency;
TITLE "Distribution of Salary Currency - Bar Chart";
PROC FREQ;
TABLES salary_currency;
RUN;
PROC SGPLOT DATA = salary;
VBAR salary_currency;
RUN;

*Employee Residence;
TITLE "Distribution of Employee Residence - Bar Chart";
PROC FREQ;
TABLES employee_residence;
RUN;
PROC SGPLOT DATA = salary;
VBAR employee_residence;
RUN;

*Company Location;
TITLE "Distribution of Company Location - Bar Chart";
PROC FREQ data=salary;
TABLES company_location;
RUN;
PROC SGPLOT DATA = salary;
VBAR company_location;
RUN;

*Company Size;
TITLE "Distribution of Company Size - Bar Chart";
PROC FREQ data=salary;
TABLES company_size;
RUN;
PROC SGPLOT DATA = salary;
VBAR company_size;
RUN;


*Remote Ratio;
TITLE "Convert Remote Ratio to categorical variable";
DATA salary;
SET salary;
remote_ratio = put(remote_ratio, $CHAR.);
RUN;

TITLE "Distribution of Remote Ratio - Bar Chart";
PROC FREQ data=salary;
TABLES remote_ratio;
RUN;
PROC SGPLOT DATA = salary;
VBAR remote_ratio;
RUN;

TITLE "Boxplot: Remote Ratio vs. Salary (USD)";
PROC SORT;
BY remote_ratio;
RUN;
PROC BOXPLOT;
PLOT salary_in_usd*remote_ratio;
RUN;

*Transform predicted attribute for final dataset;
TITLE "Transform DV";
DATA salary;
SET salary;
sqrtSalary_in_usd = sqrt(salary_in_usd);
RUN;
PROC PRINT DATA=salary (OBS=10);
RUN;

TITLE "Distribution of Sqrt Salary (USD)";
PROC UNIVARIATE data=salary normal;
VAR sqrtSalary_in_usd;
HISTOGRAM / normal(mu=est sigma=est);
RUN;

*Correlation between Salary(USD) and Salary(org currency);
TITLE "Salary (USD) vs. Salary (org currency): Before transformation";
PROC SGPLOT data=salary;
SCATTER x=sqrtSalary_in_usd y=salary;
RUN;

*Convert attribute for final dataset;
DATA finalSalary;
SET salary;
*Dummy variable set US value = 1 | Employee Residence and Company Location;
IF employee_residence = "US" THEN numEmployee_residence = 1;
ELSE numEmployee_residence = 0;
IF company_location = "US" THEN numCompany_location = 1;
ELSE numCompany_location = 0;

*Dummy variable | Experience Level;
IF experience_level in ("EN", "MI") THEN experience_New = 1; 
ELSE experience_New = 0;

*Dummy variable | Employment Type;
IF employment_type = "FT" THEN employment_FT = 1; 
ELSE employment_FT = 0;

*Dummy variable | Company Size;
IF company_size = "M" THEN size_M = 1; 
ELSE size_M = 0;

*Dummy variable | Remote Ratio;
IF remote_ratio = "0" THEN remote_ratioNone = 1;
ELSE remote_ratioNone = 0;

*Dummmy variable | Salary Currency;
IF salary_currency = "USD" THEN salary_currencyUSD = 1;
ELSE salary_currencyUSD = 0;

DROP experience_level employment_type employee_residence company_location job_title salary_currency company_size remote_ratio salary_in_usd;
RUN;

TITLE "Final Salary Data 10 observation";
PROC PRINT DATA=finalSalary (OBS=10);
RUN;

TITLE "Descriptive Statistics - Final Dataset";
PROC MEANS min max median p25 p75;
VAR sqrtSalary_in_usd work_year salary numEmployee_residence numCompany_location experience_New employment_FT size_M remote_ratioNone salary_currencyUSD;
RUN; 

TITLE "Correlation Values between Variables";
PROC CORR;
VAR sqrtSalary_in_usd work_year salary numEmployee_residence numCompany_location experience_New employment_FT size_M remote_ratioNone salary_currencyUSD;
RUN;

TITLE "Regression Result: Full model";
PROC REG data=finalSalary;
MODEL sqrtSalary_in_usd = work_year salary numEmployee_residence numCompany_location experience_New employment_FT size_M remote_ratioNone salary_currencyUSD / STB VIF TOL;
RUN;

*Residual plot: Studentized residual vs.Predictors;
TITLE "Residual Plot: Studentized Residual vs. numEmployee_residence (US)";
PLOT student.* (work_year salary numEmployee_residence numCompany_location experience_New employment_FT size_M remote_ratioNone salary_currencyUSD);
RUN; 

*Residual plot: Studentized residual vs. predicted value;
TITLE "Residual Plot: Studentized Residual vs. Predicted Value";
PLOT student.* predicted.;
RUN; 

*Normal probability plot or QQ plot;
TITLE "Normal Probability plot";
PLOT npp.* student.;
RUN;

*Remove numCompany_location due to multicollinearity;
TITLE "Regression Result: 2nd model";
PROC REG data=finalSalary;
MODEL sqrtSalary_in_usd = work_year salary numEmployee_residence experience_New employment_FT size_M remote_ratioNone salary_currencyUSD / STB VIF TOL;
RUN;

*Residual plot: Studentized residual vs.Predictors;
TITLE "Residual Plot: Studentized Residual vs. numEmployee_residence (US)";
PLOT student.* (work_year salary numEmployee_residence experience_New employment_FT size_M remote_ratioNone salary_currencyUSD);
RUN; 

*Residual plot: Studentized residual vs. predicted value;
TITLE "Residual Plot: Studentized Residual vs. Predicted Value";
PLOT student.* predicted.;
RUN; 

*Normal probability plot or QQ plot;
TITLE "Normal Probability plot";
PLOT npp.* student.;
RUN;

*Run model with stepwise selection method;
TITLE "Regression Result: Model Selection Stepwise";
PROC REG data=finalSalary;
MODEL sqrtSalary_in_usd = work_year salary numEmployee_residence experience_New employment_FT size_M remote_ratioNone salary_currencyUSD / selection = stepwise;
RUN;

*Run third model with slected attributes;
TITLE "Regression Result: 3rd model with outliers/influential points";
PROC REG data=finalSalary;
MODEL sqrtSalary_in_usd = work_year salary numEmployee_residence experience_New employment_FT salary_currencyUSD / STB VIF TOL INFLUENCE R;
RUN;

*Residual plot: Studentized residual vs.Predictors;
TITLE "Residual Plot: Studentized Residual vs. numEmployee_residence (US)";
PLOT student.* (work_year salary numEmployee_residence experience_New employment_FT salary_currencyUSD);
RUN; 

*Residual plot: Studentized residual vs. predicted value;
TITLE "Residual Plot: Studentized Residual vs. Predicted Value";
PLOT student.* predicted.;
RUN; 

*Normal probability plot or QQ plot;
TITLE "Normal Probability plot";
PLOT npp.* student.;
RUN;

TITLE "Remove Influential Points and Outliers";
DATA finalSalary2;
SET finalSalary;
IF _n_ in (5, 40, 44, 72, 93, 112, 169, 170, 185, 187, 211, 288, 370, 565, 577, 1088, 1096, 1186, 1310, 1344, 1373, 1556, 1670, 1672, 1682, 1698, 1924, 1933, 1937, 1952, 1955, 1957, 1963, 1965, 1975, 1991, 1999, 2000, 2013, 2016, 2029, 2033, 2045, 2055, 2096, 2097, 2107, 2108, 2118, 2125, 2126, 2129, 2133, 2136, 2148, 2152, 2155, 2164, 2165, 2168, 2169, 2170, 2192, 2208, 2240, 2257, 2262, 2324, 2339, 2345, 2353, 2359, 2498, 2541, 2550, 2551, 2552, 2600, 2652, 2657, 2700, 2711, 2760, 2798, 2904, 3278, 3310, 3311, 3319, 3475, 3505, 3545, 3560) then delete;
RUN;

TITLE "Regression Result: 4th model";
PROC REG data=finalSalary2;
MODEL sqrtSalary_in_usd = work_year salary numEmployee_residence experience_New employment_FT salary_currencyUSD / STB TOL VIF;
RUN;

*Residual plot: Studentized residual vs.Predictors;
TITLE "Residual Plot: Studentized Residual vs. numEmployee_residence (US)";
PLOT student.* (work_year salary numEmployee_residence experience_New employment_FT salary_currencyUSD);
RUN; 

*Residual plot: Studentized residual vs. predicted value;
TITLE "Residual Plot: Studentized Residual vs. Predicted Value";
PLOT student.* predicted.;
RUN; 

*Normal probability plot or QQ plot;
TITLE "Normal Probability plot";
PLOT npp.* student.;
RUN;

*Run final model;
TITLE "Regression Result: Final model";
PROC REG data=finalSalary2;
MODEL sqrtSalary_in_usd = work_year salary numEmployee_residence experience_New employment_FT salary_currencyUSD / STB TOL VIF;
RUN;

*Create prediction dataset;
TITLE "Prediction data";
DATA pred;
INPUT work_year salary numEmployee_residence experience_New employment_FT salary_currencyUSD;
DATALINES;
2024 100000 1 1 1 1
2024 100000 0 1 1 0
;
PROC PRINT;
RUN;

*Join prediction dataset with current dataset;
DATA predSalary;
SET pred finalSalary2;
RUN;
PROC PRINT DATA=predSalary (OBS=5);
RUN;

TITLE "Regression Analysis and Confidence Interval for Average Estimate.";
PROC REG data = predSalary;
MODEL sqrtSalary_in_usd = work_year salary numEmployee_residence experience_New employment_FT salary_currencyUSD / p clm cli;
RUN;

*Split the data into training and test sets - 80/20;
TITLE "Test and Train Set for Salary Data";
PROC SURVEYSELECT data = finalSalary2 out = xvalSalary seed = 1997 samprate = 0.8 outall;
PROC PRINT data = xvalSalary (OBS=10);
RUN;

*Generate new predicted value used for cross validation;
TITLE "Create predicted value for cross validation";
DATA xvalSalary;
SET xvalSalary;
IF (selected = 1) then new_y = sqrtSalary_in_usd;
RUN;
PROC PRINT data = xvalSalary (OBS=10);
RUN;

*Run full model Stepwise selection using train set;
TITLE "Full model regression with stepwise selection method: Train set";
PROC REG data=xvalSalary;
MODEL new_y = work_year salary numEmployee_residence numCompany_location experience_New employment_FT size_M remote_ratioNone salary_currencyUSD  / selection = stepwise;
RUN;

*Run model with selected attribute using test data;
TITLE "Validation - Test Set";
PROC REG DATA=xvalSalary;
MODEL new_y = work_year salary numEmployee_residence experience_New employment_FT salary_currencyUSD / STB VIF;
OUTPUT out=out(where=(new_y=.)) p=yhat;
RUN;
PROC PRINT data = out (OBS=10);
RUN;

*Compute the difference between observed and predicted values.;
TITLE "Difference between Observed and Predicted - Test Set";
DATA out_sum;
SET out;
diff = sqrtSalary_in_usd - yhat;
abs_diff = abs(diff);
RUN;

*Compute descriptive statistics: RMSE, MAE;
TITLE "Descriptive Statistics: RMSE and MAE - Test Set";
PROC SUMMARY data=out_sum;
VAR diff abs_diff;
OUTPUT out=out_stats std(diff)=rmse mean(abs_diff)=mae;
RUN;
PROC PRINT data=out_stats;
TITLE "Validation statistics for Model";
RUN;

*Computes correlation of observed and predicted values in test set;
TITLE "Correlation between Observed and Predicted values";
PROC CORR data=out;
var sqrtSalary_in_usd yhat;
RUN;
