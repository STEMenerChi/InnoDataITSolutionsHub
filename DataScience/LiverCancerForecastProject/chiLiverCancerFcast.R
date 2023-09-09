
################################### Live Cancer Forecast ############################################## 
# Project: Liver Cancer Time Series Forecast
# Author: C.T. Dinh
# Date: 03/05/2023 
#
# Code and Data Accesss via Github :https://github.com/STEMenerChi/DataScience/tree/main/HarvardXCYOProject
#
# Software & HardwareCapacity: R 4.2.2 running on i7 Intel Core @1.90/2.11 GHz CPU and 16GB RAM laptop.
# Total time to run this project: ~5 minutes 
#
# Steps to be taken: 
# 1. Loading the data (EDA, format, sort, plot, clean, plot again) 
# 2. decompose the data 
# 3. Checking whether the observed data is stationary  
# 4. Partitioning the data into  (test1 & validation) according to time. Plot showing test1 and validation.  
# 5. Create auto and custom best fitted ARIMA models (perform error measurement, comparison models, plot)
# 6. Forecast the best fitted model against the validation data series (the hold-out-set).  
#######################################################################################################
# Install pacman first so that the function p_load() from {pacman} will check to see if a package is installed, 
# if not it will attempt to install the package and then load it. 
install.packages("pacman")
pacman::p_load( broom, caret, data.table, dplyr, forecast, formattable, 
                ggplot2,  gghighlight, ggfortify, grid, gridExtra, knitr, kableExtra,
                lubridate, pagedown, readr, stringr, scales,styler,
                smooth, tidyr, tidyverse, tseries, tinytex)

######################################################################
# Step 1 - Load the data 
# Perform exploratory data analysis (EDA) - 
# format, sort, partition, clean 
# exam the data structurally and visually.     
#########################################################################
# set working dir
setwd(dir = "C:/")

# How to get raw data URL, see this link https://rpubs.com/kylewbrown/github-csv-r
# download the data (liver cases) file from github:
urlfile <-'https://raw.githubusercontent.com/STEMenerChi/DataScience/main/HarvardXCYOProject/regByLiver.csv'
# set stringsAsFactors = FALSE so that the string won't get converted into factor
dataL<-read.csv(urlfile, stringsAsFactors = FALSE )

# download data (liver cases by fy) 
urlfile2 <- 'https://raw.githubusercontent.com/STEMenerChi/DataScience/main/HarvardXCYOProject/regByFY.csv'
dataByFY <-read.csv(urlfile2, stringsAsFactors = FALSE )
#View(dataByFY)

#Convert FY into ISO date format
dataL$as.date =  as.Date(as.character(dataL$fy), format = "%Y")

#It's important to sort the data in a chronological order before convert it into a time series (TS) object
#the date doesn't go into the TS object, only 3 parameters: begin date, end date and frequency. 
dataL = dataL[order(dataL$as.date), ]

glimpse(dataL)
dataL

str(dataL)
# Rows: 790
# Columns: 5
# $ fy         <int> 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009…
# $ id         <int> 1, 2, 3, 4, 6, 7, 8, 9, 11, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 34, 36, …
# $ cancersite <chr> "Liver", "Liver", "Liver", "Liver", "Liver", "Liver", "Liver", "Liver", "Liver", "Liver", "Liver", "Liver", "Liv…
# $ regpatient <int> 200, 29, 110, 137, 39, 70, 81, 130, 125, 69, 105, 85, 289, 138, 207, 28, 68, 45, 80, 90, 69, 104, 282, 2, 54, 56…
# $ as.date    <date> 2009-02-12, 2009-02-12, 2009-02-12, 2009-02-12, 2009-02-12, 2009-02-12, 2009-02-12, 2009-02-12, 2009-02-12, 200…

# 13 Fiscal Years (FY):
unique(dataL$fy)

# Visually look of the actual liver cases time series
par(col="#008000")
plot.ts(dataL$regpatient, main="Actual Observed Liver Cancer Cases Series")

######################################
# Calculate Percentage of liver cancer changes per fiscal year (yr)
pctChangePerFY <- dataByFY %>%
  arrange(fy) %>%
  mutate(percent_change = (regpatient-lag(regpatient))/lag(regpatient) * 100, 
         case_count = regpatient)

# Exclude 2nd col "regpatient", use case_count which is more intuitive 
pctChangePerFY <- pctChangePerFY[, -c(2)]

# display cols in this order
pctChangePerFY <- pctChangePerFY [c(1,3,2)]
#pctChangePerFY
######################################
# Calculate the Avg cases per year 
# Exclude cancersite and as.date fields from the data set, show avg count of liver cases per FY
data <- dataL[,-c(3,5)] 

data_avg <- data %>%
  group_by(fy) %>%
  summarize(avg_count = mean(regpatient))
#data_avg

####################################
# combine percent change & avg count and display the cols in this order: 
# fy, case)count, avg_case_count, percent_change
pctChangeAvgCase <- cbind(pctChangePerFY [c(1,2)], data_avg[c(2)], pctChangePerFY [c(3)] )

# convert every double values to 1 decimal point
table = pctChangeAvgCase %>% mutate_if(is.double, ~sprintf("%.1f", .))
#table

################################## KEEP #############################
#  Liver cancer cases count per FY  
#  The number of cases  progressively increased over the years, 
#  except there are dips  in 2016, 2019, and 2021.   
#####################################################################
# cases count by year 
dataByFY %>%
  ggplot(aes(x = fy, y=regpatient)) +
  geom_line(color="darkgreen", lwd = .5) +
  geom_point(color = "orange", lwd = 3)+
  theme_bw() +
  ggtitle("Cancer Liver Cases from 2009-2021") +
  xlab("FY") + 
  ylab("Case Count") +
  scale_x_continuous(breaks = 2009:2021) +
  # add a table inside ggplot,rows=NULL to prevent displaying of the indices, xmin/xmax/ymin/ymax for table placement in the graph.  
  annotation_custom(tableGrob(table, rows=NULL), xmin= 2017, xmax=2020, ymin=5500, ymax=8500) 

###############
# STEP 2 - Decompose Data
#############
# convert data into time series object 
dataL.ts = (ts(dataL$regpatient, start=c(2009, 1), end=c(2021, 12), freq=12))
#decompose on the cleaned data w/o any outliets
par(col="darkgreen")
decomp_add = decompose(dataL.ts, type='additive')
plot(decomp_add) 

#######################################################################
# Step 3 Check whether the clean observed TS is stationary 
# The p-value is less than 0.05 is typically considered to be statistically significant, 
# in which case the null hypothesis should be rejected, concluded that this time series is stationary, 
# This time series data is ready to be analyzed. 
####################################################################
adf.test(dataL.ts)

# tsdisplay() plots observed, ACF And PACF graphs
forecast::tsdisplay(dataL.ts)
# Based on the ACF graph, there are def. some lags at time step 12 and 22 which will be addressed later 
# in ARIMA models fitting process  

#############################################################################################
# 
# STEP 4: PARTITION the dataset into train & validation (hold-out-set) according to time. 
# Plot both data series
#
##############################################################################################
# check for min and max date
min_date = min(dataL$as.date)
max_date= max(dataL$as.date)

# Build a time series data 
dataL.ts = ts(dataL$regpatient, start=c(2009,1) , end=c(2021,12), freq=12)
dataL.ts

# Evenly Split the data series into train and test sets according to time
# Both train and valid contain 2015 data
trainL.ts <- window(dataL.ts, start=c(2009, 1), end=c(2015,12), freq=12)
validL.ts <- window(dataL.ts, start=c(2016, 1), end=c(2021,12), freq=12)

trainL.ts
validL.ts

# Plot the train data series: 
plot(trainL.ts, col="#00B7C7", 
     ylab="Observed Liver Cancer Cases", 
     main="Train data series from 2009 to 2015")

# Plot both the train and validation data series
autoplot(cbind(trainL.ts, validL.ts)) + 
  ggtitle("Train and Validation Data Series")+
  guides(colour=guide_legend(title="Data series")) +
  scale_colour_manual(values=c("#00B7C7", "#FF7F50"))

########################################################################################
# Step 5 - Fit & Evaluate Models
#
# using train ts: 
#  Let's fit our first model using auto.arima() so it will select the best ARMIMA model for us 
#  Plot the model
#  Check for coefficients and error measures in the  model using summary() 
#  Check for p-value of the model using  checkresiduals()
#  Forecast the model
#  Plot the forecast model on the observed ts
#  Check for lags, exam ACF and PACF using tsdisplay()
#  reiterate and select/fit another model...
########################################################################################
# Initialize the forecast term to 5 years (60 months)
term <- 60

##########
# Model 1 - auto.arima ARIMA(0,0,0)
# auto.arima will present us with the best model with the lowest AIC.
########
autoarima.Model1 <- auto.arima(trainL.ts, ic="aic", trace=TRUE, seasonal = FALSE)

plot(trainL.ts, main='An ARIMA (0,0,0) model')
lines(fitted(autoarima.Model1), col='#dc0ab4', lwd=2)
legend("topright",c("Observed","auto ARIMA(0,0,0)"), lty=8, col=c("darkgreen","#dc0ab4"), cex=0.8)

summary(autoarima.Model1)  
forecast::checkresiduals(autoarima.Model1)

# h is the forecast horizon value, set it to the defined term; otherwise it defaults to 2 years forecast 
autoarima.Model1.Fcast = forecast(autoarima.Model1, h=term)
# Plot base R,  shows observed and forecast, the prediction is just a flat line

#using plot or ggplot::(autoplot) produces similar plot
plot(autoarima.Model1.Fcast)
#autoplot(autoarima.Model1.Fcast)
# It's worthy note that fcast$fitted, fcast$mean have diff length for a given h. 
# fcast$fitted is the result of the fit (the model fitted to observation).
# fcast$mean is the result of the forecast (the application of the model to the future). 
autoarima.Model1.Fcast$fitted
autoarima.Model1.Fcast$mean[1:1]

# format the AIC into two decimal float
# 2 ways to get AIC value:
# autoarima.Model1.AIC <- formattable(stats::AIC(autoarima.Model1), digits=2, format="f")
# AIC.val <- round(autoarima.Model1.AIC[["aic"]],2)

#Check how accurate the forecast is
autoarima.Model1.Fcast.em <- forecast(autoarima.Model1, h=term) %>%
  accuracy(validL.ts)

#Check TS forecast accuracy with regression evaluation metrics:
round(autoarima.Model1.Fcast.em[,c("RMSE","MAPE")],1)
#                  RMSE     MAPE
# Training set 61.31457 161.4497
# Test set     61.50664 156.4807

# divide RMSE and MAPE by 100 since we're using the y-axis scale of hundreds.  
# Create an error measure (em) table and record the model and forecast performance for comparison 

#rm(em_results) 
model1.AIC  <- formattable(stats::AIC(autoarima.Model1), digits = 1, format = "f")
model1.RMSE <- formattable(autoarima.Model1.Fcast.em[1,c("RMSE")], digits = 1, format = "f")

em_results <- tibble( Method = "Model 1 - auto.arima ARIMA(0,0,0)", 
                      AIC    = model1.AIC, 
                      RMSE   = model1.RMSE)
em_results
# AIC.val = 934.

########################################### Model 2 ARIMA Model MA12  LOOKING BETTER  #######################
# Model 2 ARIMA(0,0,22)
# A spike at lag 22 in the ACF plot but no other significant spikes;
# this suggests that the model may better with a different specification, such as p=22 or q=22.
# we can repeat the fitting process allowing for the MA(22) component and examine diagnostic plots again. 
# AR-I-MA
# AR = 0, I=0, MA=22, 
# An ARIMA model for a 22nd order of MA process
#############################################################################################################
MA1.model2 = forecast::Arima(trainL.ts, c(0, 0, 1))
#plot(dataL.ts, main='Liver - An ARIMA model for a 22nd order of MA process')

plot(trainL.ts, col="#00B7C7", main="Fitted Models")
lines(fitted(autoarima.Model1), col='green', lwd=2)
lines(fitted(MA1.model2), col='#ffa300', lwd=2)
legend("topright",c("Observed (Train)","ARIMA(0,0,0)", "ARIMA(0,0,1)"), lty=8, col=c("#00B7C7","green", "#FFA300" ), cex=0.9)

# explore how the  model is fitting
summary(MA1.model2)
forecast::checkresiduals(MA1.model2, col="#00B7C7") 
#p-value = 0.3513


MA1.model2.Fcast = forecast(MA1.model2, h=term)
plot(MA1.model2.Fcast)
MA1.model2.Fcast$mean
# The forecast shows some movements in the first two years then flat liner. Let's continue on to improve out model. 

#Check how accurate the forecast is
MA1.model2.Fcast.em <- forecast(MA1.model2, h=term) %>%
  accuracy(validL.ts)

#MA1.model2.Fcast.em
#Check TS forecast accuracy with regression evaluation metrics:
round(MA1.model2.Fcast.em[,c("RMSE","MAPE")], 1)
#              RMSE  MAPE
# Training set 61.3 153.5
# Test set     60.5 301.2
#
# a HUGE diff between the data sets - overfitting issue??
# divide RMSE and MAPE by 100 since we're using the y-axis scale of hundreds. 
# record the model and forecast performance in the em table. 

# Let's modify our model slightly
MA12.model2 = forecast::Arima(trainL.ts, c(0, 0, 12))
MA12.model2.Fcast.em <- forecast(MA12.model2, h=term) %>%
  accuracy(validL.ts)
MA12.model2.Fcast.em[,c("RMSE","MAPE")]

# can we improve it? 
MA22.model2 = forecast::Arima(trainL.ts, c(0, 0, 22))
MA22.model2.Fcast.em <- forecast(MA1.model2, h=term) %>%
  accuracy(validL.ts)
MA22.model2.Fcast.em[,c("RMSE","MAPE")]
AIC(MA22.model2)

# Use and record the better model of (0, 0, 1) as model 2
model2.AIC  <- formattable(stats::AIC(MA1.model2), digits = 1, format = "f")
model2.RMSE <- formattable(MA1.model2.Fcast.em[1,c("RMSE")], digits =1, format="f")

em_results <- bind_rows(em_results,
                        tibble(Method = "Model 2 - ARIMA(0,0,1)", 
                               AIC    = model2.AIC, 
                               RMSE   = model2.RMSE))
em_results
###############################################
# Model 3
# Approaches to TS data with weak seasonality. 
# Using an ARIMA model alone does not sufficiently capture the long-term patterns, the Fourier term is introduced into the model. 
###########################################
# Comparing with plots
plots <- list()
for (i in seq(4)) {
  fit <- trainL.ts %>%
    auto.arima(xreg = fourier(trainL.ts, K = i), seasonal = FALSE, lambda = "auto")  
  plots[[i]] <- autoplot(forecast(fit, xreg=fourier(trainL.ts, K=i, h=term))) +
    xlab(paste("K=",i,"   AIC=",round(fit[["aic"]],2))) +
    ylab("") +
    theme_light()
}

gridExtra::grid.arrange(
  plots[[1]],plots[[2]],
  plots[[3]],plots[[4]], nrow=2)
# K should be equals to 1 for the minimum AIC value of 206!! BAM  

#Modeling with Fourier Regression
fit.fourier.model3 <- trainL.ts %>%
  auto.arima(xreg = fourier(trainL.ts,K=1), seasonal = FALSE, lambda = "auto")

#Plot fitted models
plot(trainL.ts, col="#00B7C7", main="Fitted Models")
lines(fitted(autoarima.Model1), col='green', lwd=2)
lines(fitted(MA1.model2), col='#ffa300', lwd=2)
lines(fitted(fit.fourier.model3), col='purple', lwd=2)
legend("topright",c("Observed(train)","ARIMA(0,0,0)", "ARIMA(0,0,1)", "ARIMA(0,0,0) Fourier w/ K=1" ), lty=8, col=c("#00B7C7","green", "#FFA300", "purple" ), cex=0.9)

summary(fit.fourier.model3)
forecast::checkresiduals(fit.fourier.model3, col="#00B7C7") 
# Model 3 seems to be able to capture much more information from the data and produces a much better result. 
# The residual histogram seems to follow a normal distribution. 

# compare Forecast Accuracy
fit.fourier.model3.fcast.em <- fit.fourier.model3 %>%
  forecast(xreg=fourier(trainL.ts,K=1,h=term)) %>%
  accuracy(validL.ts)
#fit.fourier.model3.fcast.em
round(fit.fourier.model3.fcast.em[,c("RMSE","MAPE")],1)
#              RMSE MAPE
#Training set   63  131
#Test set       63  244

#Plot of the Fourier Regression Model 3 forecast, train.ts fit and valid.ts
fit.fourier.model3.fcast <- forecast(fit.fourier.model3, xreg=fourier(trainL.ts, K=1, h=term))

autoplot(fit.fourier.model3.fcast) +
  #autolayer(validL.ts) +
  theme_light() +
  ylab("")

#--------------  This code produces the same graph 
# fit.fourier.model3 %>% forecast( xreg=fourier(trainL.ts, K=1, h=term)) %>%
# autoplot()+
#   autolayer(validL.ts) +
#   theme_light() +
#   ylab("")
#-------------

fit.fourier.model3.fcast$mean

model3.AIC  <- formattable(stats::AIC(fit.fourier.model3), digits = 1, format = "f")
model3.RMSE <- formattable(fit.fourier.model3.fcast.em[1,c("RMSE")], digits = 1, format = "f")

em_results <- bind_rows(em_results,
                        tibble(Method = "Model 3 - ARIMA(0,0,0) w/ Fourier K=1", 
                               AIC = model3.AIC, 
                               RMSE = model3.RMSE ))
em_results

################################################
# Model 4 
# Modeling the Arima model with transformed data
###################################################
fit.arima.trans.model4 <- trainL.ts %>%
  auto.arima(stepwise = FALSE, approximation = FALSE, lambda = "auto")
fit.arima.trans.model4

# As seen above code chunk, stepwise=FALSE, approximation=FALSE parameters are used to amplify the searching for all possible model options.
# From the results above ARIMAR(0,0,0) which can be denoted as ARIMA(p,d,q) we can see that there is no autoregressive (AR or p) part of the model, no order moving average (MA or q) with no differencing (I or d).

#Plot fitted models
plot(trainL.ts, col="#00B7C7", main="Fitted Models")
lines(fitted(autoarima.Model1), col='green', lwd=2)
lines(fitted(MA22.model2), col='#ffa300', lwd=2)
lines(fitted(fit.fourier.model3), col="purple", lwd=2)
lines(fitted(fit.arima.trans.model4), col="blue", lwd=2)
legend("topright",c("Observed (Train)","ARIMA(0,0,0)", "ARIMA(0,0,22)", "ARIMA(0,0,0) w/ Fourier K=1", "ARIMA(0,0,0) Transformed" ), lty=8, col=c("darkgreen","green", "#FFA300", "purple", "blue" ), cex=0.9)

summary(fit.arima.trans.model4)
forecast::checkresiduals(fit.arima.trans.model4, col="#00B7C7") 

stats::AIC(fit.arima.trans.model4)
#[1] 202.8408   DOUBLE BAM BAM! :-)


# Model 5 forecast
par(mfrow=c(1,1))
fit.arima.trans.model4.fcast <- forecast(fit.arima.trans.model4, h=term)
autoplot(fit.arima.trans.model4.fcast) 

fit.arima.trans.model4.fcast$mean
# Model5 forecast is a flat liner at 77


#check forecast accuracy 
fit.arima.trans.model4.fcast.em <- fit.arima.trans.model4 %>% forecast(h = term) %>%
  accuracy(validL.ts)
#fit.arima.trans.model4.fcast.em
round(fit.arima.trans.model4.fcast.em[,c("RMSE","MAPE")],1)
#                  RMSE     MAPE
# Training set 64.7 125.9
# Test set     61.8 234.1


model4.AIC  <- formattable(stats::AIC(fit.arima.trans.model4), digits = 1, format = "f")
model4.RMSE <- formattable( fit.arima.trans.model4.fcast.em[1,c("RMSE")], digits = 1, format ="f")

em_results <- bind_rows(em_results,
                        tibble(Method = "Model 4 - ARIMA(0,0,0) w/ Transformation", 
                               AIC    = model4.AIC, 
                               RMSE   = model4.RMSE))
em_results

############################### SES ####################################
# Model 5 - Single Exponential Smoothing (SES) Nonseasonal Method
# Forecast future values using a weighted average of all previous values in the series.
############################
ses.fit.model5a <- ses(trainL.ts,
                       alpha = .01,
                       h = term)

summary(ses.fit.model5a)
#AIC 1068, RMSE = 62/61

autoplot(ses.fit.model5a)
round(ses.fit.model5a$mean[1:1],1)

ses.fit.model5a.em <- round(accuracy(ses.fit.model5a, validL.ts ), 1)
ses.fit.model5a.em[,c("RMSE","MAPE")]

###
# Compare our models based on the lowest alpha 
alpha <- seq(.01, .99, by = .01)
RMSE <- NA
for(i in seq_along(alpha)) {
  fit <- ses(trainL.ts, 
             alpha = alpha[i],
             h = term)
  
  RMSE[i] <- accuracy(fit, validL.ts)[2,2]
}

# convert to a data frame and identify min alpha value
alpha.fit <- tibble(alpha, RMSE)
#alpha.fit
alpha.min <- filter(alpha.fit,
                    RMSE == min(RMSE))

ggplot(alpha.fit, aes(alpha, RMSE)) +
  geom_line() +
  geom_point(data = alpha.min,
             aes(alpha, RMSE),
             lwd = 2, color = "red")
alpha.min
# A tibble: 1 × 2
#      alpha  RMSE
#     <dbl> <dbl>
#   1  0.33  60.2

# refit model with alpha = .33
# Now, we will try to re-fit our forecast model for SES with alpha =0.01. 
# We will notice the significant difference between alpha 0.2 and alpha=0.01.
ses.fit.model5b <- ses(trainL.ts,
                       alpha = .33,
                       h = term)

summary(ses.fit.model5b)
# AIC is 1085, train RMSE = 68 

#check forecast accuracy 
ses.fit.model5a.em <- ses.fit.model5a %>%
  accuracy(validL.ts)

round(ses.fit.model5a.em[,c("RMSE","MAPE")], 1)
#              RMSE  MAPE
# Training set 61.6 164.2
# Test set     60.6 302.6

# model ses.fit.model5a is the better, keep a vs. b
# Plot fitted models
plot(trainL.ts, col="#00B7C7", main="Fitted Models")
lines(fitted(autoarima.Model1), col='green', lwd=2)
lines(fitted(MA1.model2), col='#ffa300', lwd=2)
lines(fitted(fit.fourier.model3), col="purple", lwd=2)
lines(fitted(fit.arima.trans.model4), col="blue", lwd=2)
lines(fitted(ses.fit.model5a), col="red", lwd=2)
legend("topright",c("Observed (Train)","1. ARIMA(0,0,0)", "2. ARIMA(0,0,1)", "3. ARIMA(0,0,0) w/ Fourier K=1", "4. ARIMA(0,0,0) Transformed", "5. SES" ), lty=8, col=c("darkgreen","green", "#FFA300", "purple", "blue", "red" ), cex=0.8)

# Visually Model 1, 2, and 5 look closely similar.  
# Model 4 seems to be the average line running through Model 3. 

# Forecast plot, 
plot(ses.fit.model5a, col="#00B7C7")
# Flatted line at 
ses.fit.model5a$mean[1:1]
#102

ses.fit.model5a.coef <- summary(ses.fit.model5a)
ses.fit.model5a.coef$model

model5.AIC  <- formattable(1068, digits = 1, format = "f")
model5.RMSE <- formattable(ses.fit.model5a.em[1,c("RMSE")], digits = 1, format="f")

em_results <- bind_rows(em_results,
                        tibble(Method = "Model 5 - SES", 
                               AIC    = model5.AIC,
                               RMSE   = model5.RMSE))
em_results

########################################################
# Model 6 -  nnetar: Neural Network Auto-Regressive Time Series Forecast
############################################################

nnetar.fit.Model6 <- nnetar(trainL.ts)
summary(nnetar.fit.Model6)

# nnetar.fit.Model6.opt <- nnetar(trainL.ts, n_nodes = NULL, n_networks = 20, scale_inputs = TRUE)
# summary(nnetar.fit.Model6)
# there's no difference between these two models; therefore, nnetar.fit.Model6.opt will be omitted. 

# Plot fitted model 
plot(trainL.ts, col="#00B7C7", main="Fitted Models")
lines(fitted(autoarima.Model1), col='green', lwd=2)
lines(fitted(MA1.model2), col='#ffa300', lwd=2)
lines(fitted(fit.fourier.model3), col="purple", lwd=2)
lines(fitted(fit.arima.trans.model4), col="blue", lwd=2)
lines(fitted(ses.fit.model5a), col="red", lwd=2)
lines(fitted(nnetar.fit.Model6), col="black", lwd=2)
legend("topright",c("Observed (Train)","1.ARIMA(0,0,0)", "2.ARIMA(0,0,1)", "3.ARIMA(0,0,0) w/ Fourier K=1", "4.ARIMA(0,0,0) Transformed", "5.SES", "6.NNet" ), lty=8, col=c("darkgreen","green", "#FFA300", "purple", "blue", "red", "black" ), cex=0.9)

# Forecast plot
plot(forecast(nnetar.fit.Model6,h=term), col="#00B7c7")
points(fitted(nnetar.fit.Model6),type="l",col="#FF00CC")

nnetar.fit.Model6.fcast <- forecast(nnetar.fit.Model6,h=term)
nnetar.fit.Model6.fcast$mean
# This forecast (fcast$mean) looks better than model 5
# It fluxes from 2016-2020, 90 seems to be a popular monthly average cases. 
# Model 5 flats at 77, too low. 
# Model 2

#check forecast accuracy 
nnetar.fit.Model6.fcast.em <- nnetar.fit.Model6 %>% forecast(h = term) %>%
  accuracy(validL.ts)

round(nnetar.fit.Model6.fcast.em[,c("RMSE","MAPE")],1)
#               RMSE MAPE
# Training set   51  145
# Test set       70  337
# Huge diff between training and test set, we may have overfitting issue. 
#
# In a nutshell, on an average year, the predictions are off by 5.1 cases or around 14.5% 
# Our scale is in thousands. 

model6.RMSE <- formattable(nnetar.fit.Model6.fcast.em[1,c("RMSE")], digits=1, format="f")

em_results <- bind_rows(em_results,
                        tibble(Method = "Model 6 - nnetar", 
                               AIC    = NA,
                               RMSE   = model6.RMSE))
em_results

###########################################################################
# Step 6 - Forecast the best fitted model against the validation data series (hold-out-set).
# Based on the RMSE, model 6 will be the chosen one. 
########################################################################################
nnetar.fit.model.final <- nnetar(validL.ts)
summary(nnetar.fit.model.final)

# Plot fitted model 
plot(validL.ts, col="#FF7f50", main="Fitted Models")
lines(fitted(nnetar.fit.model.final), col="black", lwd=2)
legend("topright",c("Observed (valid)" , "6.NNet" ), lty=8, col=c("#FF7F50", "black" ), cex=0.9)

# Forecast plot
plot(forecast(nnetar.fit.model.final,h=term), col="#FF7F50")
points(fitted(nnetar.fit.model.final),type="l",col="#006633", lwd=2)
legend("topright",c("Observed (valid)" , "Fitted NNetar", "Forecast" ), lty=8, col=c("#FF7F50", "#006633", "#3399FF"), cex=0.9)

nnetar.fit.model.final.fcast <- forecast(nnetar.fit.model.final,h=term)
nnetar.fit.model.final.fcast$mean

# Max and min overall avg cases  
round(max(nnetar.fit.model.final.fcast$mean),1)
round(min(nnetar.fit.model.final.fcast$mean),1)
############################
# max min cases per year 
# convert the ts with max and min values into a data.frame. 
y = c(2022, 
      round(max(nnetar.fit.model.final.fcast$mean[1:12]),1),
      round(min(nnetar.fit.model.final.fcast$mean[1:12]),1),
      2023,
      round(max(nnetar.fit.model.final.fcast$mean[13:24]),1),
      round(min(nnetar.fit.model.final.fcast$mean[13:24]),1),
      2024,
      round(max(nnetar.fit.model.final.fcast$mean[25:36]),1),
      round(min(nnetar.fit.model.final.fcast$mean[25:36]),1),
      2025,
      round(max(nnetar.fit.model.final.fcast$mean[37:48]),1),
      round(min(nnetar.fit.model.final.fcast$mean[37:48]),1),
      2026,
      round(max(nnetar.fit.model.final.fcast$mean[49:60]),1),
      round(min(nnetar.fit.model.final.fcast$mean[49:60]),1) )

# Convert ts->matrix->df
fcast.df = data.frame(matrix(data = y, ncol=3, byrow=TRUE))

# assign new names to the cols
colnames(fcast.df) <- c('fy', 'avg.max', 'avg.min')
fcast.df

# cal % change for max and min
pc <- fcast.df %>%
  arrange(fy) %>%
  mutate(pct.max.change = round((avg.max-lag(avg.max))/lag(avg.max) * 100, 1) , 
         pct.min.change = round((avg.min-lag(avg.min))/lag(avg.min) * 100, 1))

# change the order of col diplay
pc <- pc[c(1, 2, 4, 3,5)]

##################################
# display  table, pc side by side
# kbl(caption="Actual 2009-2021 ---vs-- Forecast 2022-2026", list(table, pc)) %>%
#   kable_classic_2(full_width = F, c("striped", "hover", "hold_position") )

kbl(table,  caption = "Actual Cases 2009-2021") %>%
  kable_classic_2(full_width = F, c("striped", "hover", "hold_position") )%>%
  kable_styling(position="float_left")

kbl(pc, caption = "Forecast Cases 2022-2026") %>%
  kable_classic_2(full_width = F, c("striped", "hover", "hold_position") )%>%
  kable_styling(position="float_right")



#####################
#check forecast accuracy 
nnetar.fit.model.final.fcast.em <- accuracy(nnetar.fit.model.final.fcast)
round(nnetar.fit.model.final.fcast.em[,c("RMSE","MAPE")],1)

model.final.RMSE <- formattable(nnetar.fit.model.final.fcast.em[1,c("RMSE")], digits=1, format="f")

em_results <- bind_rows(em_results,
                        tibble(Method = "Model Final - nnetar", 
                               AIC    = NA,
                               RMSE   = model.final.RMSE))
em_results %>%
  kbl() %>%
  kable_classic_2(full_width = F, c("striped", "hover") )