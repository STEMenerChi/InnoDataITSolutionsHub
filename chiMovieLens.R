#######################################################
# Project: Movielens Project - HarvardX Data Science - Capstone Course
# Author : Chi T. Dinh
# Date   : 01/08/2023
########################################################

##########################################################
# Required packages
##########################################################

if(!require(broom)) install.packages("broom", repos = "http://cran.us.r-project.org")
if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(data.table)) install.packages("data.table")
if(!require(dplyr)) install.packages("dplyr")
if(!require(dslabs)) install.packages("dslabs")
if(!require(gghighlight)) install.packages("gghighlight")
if(!require(ggplot2)) install.packages("ggplot2")
if(!require(ggrepel)) install.packages("ggrepel", repos = "http://cran.us.r-project.org")
if(!require(ggthemes)) install.packages("ggthemes")
if(!require(kableExtra)) install.packages("kableExtra", repos = "http://cran.us.r-project.org")
if(!require(pagedown)) install.packages("pagedown", repos = "http://cran.us.r-project.org")
if(!require(readr)) install.packages("readr")
if(!require(readxl)) install.packages("readxl")
if(!require(scales)) install.packages("scales")
if(!require(stringr)) install.packages("stringr")
if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(tidyr)) install.packages("tidyr", repos = "http://cran.us.r-project.org")

tidyverse_conflicts()  #lists all the conflicts between packages in the tidyverse and other loaded packages. 

library(broom)   #broom and kableExtra packages produce beautiful tables
library(caret)
library(data.table)
library(dplyr)
library(dslabs) # To extract 
library(gghighlight)
library(ggplot2)
library(ggrepel)  # to use geom_text_repel to prevent text overlapping on graph
library(ggthemes)
library(kableExtra)
library(pagedown) # to convert from html to pdf
library(readr)
library(readxl)   # to import excel data
library(scales) # to scale y-axis, for example from 8e+05 to 800,000
library(stringr) 
library(tidyr)   # tidyr is the Tidyverse package to help create tidy data
library(tidyverse)


#################################################################
# Data Loading
# Create edx dataset and final_holdout_test as a validate dataset 
################################################################

# this process could take a couple of minutes
#
# MovieLens 10M dataset:
# https://grouplens.org/datasets/movielens/10m/
# http://files.grouplens.org/datasets/movielens/ml-10m.zip

options(timeout = 120)

dl <- "ml-10M100K.zip"
if(!file.exists(dl))
  download.file("https://files.grouplens.org/datasets/movielens/ml-10m.zip", dl)

ratings_file <- "ml-10M100K/ratings.dat"
if(!file.exists(ratings_file))
  unzip(dl, ratings_file)

movies_file <- "ml-10M100K/movies.dat"
if(!file.exists(movies_file))
  unzip(dl, movies_file)

ratings <- as.data.frame(str_split(read_lines(ratings_file), fixed("::"), simplify = TRUE),
                         stringsAsFactors = FALSE)
colnames(ratings) <- c("userId", "movieId", "rating", "timestamp")
ratings <- ratings %>%
  mutate(userId = as.integer(userId),
         movieId = as.integer(movieId),
         rating = as.numeric(rating),
         timestamp = as.integer(timestamp))

movies <- as.data.frame(str_split(read_lines(movies_file), fixed("::"), simplify = TRUE),
                        stringsAsFactors = FALSE)
colnames(movies) <- c("movieId", "title", "genres")
movies <- movies %>%
  mutate(movieId = as.integer(movieId))

movielens <- left_join(ratings, movies, by = "movieId")

# final_holdout_test set contains 10% (p.01) of MovieLens data and serves as validation dataset. 
set.seed(1) # if using R 3.6 or later
test_index <- createDataPartition(y = movielens$rating, times = 1, p = 0.1, list = FALSE)
edx <- movielens[-test_index,]
temp <- movielens[test_index,]

# Make sure userId and movieId in final_holdout_test set are also in edx set
# Semi_join() function to return in one data frame that have matching values in another data frame. 
final_holdout_test <- temp %>% 
  semi_join(edx, by = "movieId") %>%
  semi_join(edx, by = "userId")
validation <- final_holdout_test

# Add rows removed from final_holdout_test set back into edx set
# anti_join() function from the dplyr package to return all rows in one data frame that do not have matching values in another data frame.
removed <- anti_join(temp, final_holdout_test)
edx <- rbind(edx, removed)

# rm() function to delete objects no longer required from the memory to reduce memory footprint
rm(dl, ratings, movies, test_index, temp, movielens, removed)

###########################################################
# Exploratory Data Analysis - MovieLens Dataset Overview
###########################################################

# exam edx's first 7 rows
#head(edx)
edx[1:7, ] 

# exam the edx data structure
str(edx)


# check for any missing values
anyNA(edx)

# summary of the edx dataset
summary(edx)

# edx contains 69,878 unique users giving ratings to 10,677 different movies
edx %>% summarize(n_users = n_distinct(userId), n_movies = n_distinct(movieId))


# There're 10 different ratings lowest is 0.5 and highest 5.0.   
unique(edx$rating)
# Ratings Mean
mean(edx$rating)
# 3.512

# Some movies are rated more than others given that there are blockbuster movies watched by millions
# and artsy, independent movies watch by just a few (33.7.1 Movielens data.)
edx %>% 
  count(movieId) %>% 
  ggplot(aes(n)) + 
  geom_histogram(bins = 30, binwidth=0.2,  show.legend = FALSE, aes(fill = cut(n, 100)), fill="lightblue", color="black",) + 
  scale_x_log10() + 
  ggtitle("Movies Rated") +
  xlab("Times Rated") +
  ylab("Movie Count")

# Top 10 most rated movies 
edx %>%
  group_by(title) %>%
  summarize(count = n()) %>%
  arrange(-count) %>%
  top_n(10, count) %>%
  ggplot(aes(count, reorder(title, count))) +
  geom_bar(color = "darkblue", fill="lightblue", stat = "identity") +
  ggtitle("Top 10 Rated Movies") +
  xlab("Times Rated") +
  ylab("")
# Pulp Fiction (1994) is #1 rated movie. 
  
# Exam training distribution of the 10 unique ratings 
  edx %>%
    ggplot(aes(rating, y = ..prop..)) +
    geom_bar(color = "darkblue", fill="lightblue") +
    labs(x = "Ratings", y = "Proportion") +
    ggtitle("Rating Distribution (Training)") +
    theme(plot.title = element_text(size=12)) +
    scale_x_continuous(breaks = c(0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5))
# 4.0 seems to be the most given rating
  
# Histrogram - Exam the number of times each user reviewed movies
# From observation, some users are more active than otehr at rating movies:
  edx %>% 
    count(movieId) %>% 
    ggplot(aes(n)) + 
    geom_histogram(bins = 30, binwidth=0.2,  show.legend = FALSE, aes(fill = cut(n, 100)), fill="lightblue", color="darkblue") + 
    scale_x_log10() + 
    ggtitle("Movies Rated") +
    xlab("Times Rated") +
    ylab("Movie Count")

  
# Exam the genres
# It would be difficult to factor genre into the overall prediction because certain genres being more popular in certain periods
  # There are 797 unique classified genres,
  edx %>% summarize(n_genres = n_distinct(genres))
  #unique(edx$genres)  # this will list all of 797 genres
  
  # shows the top 20 genres ordered by number of ratings.
  edx %>% group_by(genres) %>% 
    summarise(count=n()) %>% 
    arrange(-count) %>%
    top_n(20, count)
  
# Exam the movie release years
# There's an exponential growth of the movie count in especially 1995 and a sudden drop in 2010.
# The reason for the drop was that the data was not collected until Oct 2009; 
# therefore, we don't' have the full data on this year. 
# There's barely any rating prior to 1985 due to lack of internet and public access.
# The growth of the internet didn't start until 1985. 
  
# Extract release year from string title into a separate numeric field
  edx <- edx %>% mutate(releaseyear = as.numeric(str_extract(str_extract(title, "[/(]\\d{4}[/)]$"), regex("\\d{4}"))),title = str_remove(title, "[/(]\\d{4}[/)]$")) 
  
  # or extract release year from title:  edx$releaseyear <- as.numeric(substr(as.character(edx$title),nchar(as.character(edx$title))-4,nchar(as.character(edx$title))-1))
  
  #sort(unique(edx$releaseyear))
  # There are 94 unique numeric years from 1915 to 2008
  
  # Number of movies per year/decade
  movies_per_year <- edx %>%
    select(movieId, releaseyear) %>% # select columns we need
    group_by(releaseyear) %>%        # group by year
    summarise(count = n())  %>%      # count movies per year
    arrange(releaseyear)
  
  
  # Exam the rating trend based on releaseyear 
  movies_per_year %>%
    ggplot(aes(x = releaseyear, y = count)) +
    scale_y_continuous(labels = comma) +
    geom_line(color="blue")
    
  # Exam release year vs ratings mean
  edx %>% group_by(releaseyear) %>%
    summarize(rating = mean(rating)) %>%
    ggplot(aes(releaseyear, rating)) +
    geom_point() +
    theme_hc() + 
    geom_smooth() +
    theme_bw() +
    ggtitle("Release Year vs. Rating")
  #older movies seem to get higher rating. 
  #A movie could be penalized based on release year by a calculated weight 
  
  ########################################################################################
  # Data Wrangling 
  # Tried 300,000, 450,000, 700,00, and all ~9M random without replacement rows from edx data set
  
  # Split that random dataset further into 90/10 ratio for train and test sets receptively.
  #
  # *******Chi ***** look at 33.7.2 So let’s create a test set to assess the accuracy of the models we implement. 
  #We only consider movies rated five times or more, and users that have rated more than 100 of these movies.
  ########################################################################################
  
  # Use random without replacement ~1/2 of ~9 million rows of the edx dataset 
  # due to time and memory considerations
  set.seed(1)
  #edx_random <- sample_n(edx, 700000, replace = FALSE)
 
  # Partition edx into train and test sets with ratio 90:10 
  test_index <- createDataPartition(y = edx$rating, times = 1, p = 0.1, list = FALSE)
  train <- edx[-test_index,]
  temp <- edx[test_index,]
  
  # Make sure userId and movieId in test set are also in train set. 
  test <- temp %>% 
    semi_join(train, by = "movieId") %>%  
    semi_join(train, by = "userId")
  
  # Add rows removed from test set back into train set
  removed <- anti_join(temp, test)
  train <- rbind(train, removed)
  
  # Clear unused objects from memory
  rm(test_index, temp, removed)
  
  ###########################################################
  ## Predictive Model Approach & Evaluation  
  ###########################################################
  #
  # One approach to access how well a regression model fits a dataset is to calculate 
  # the root or residual mean square error (RMSE). 
  # To compute RMSE, calculate the residual (difference between prediction and truth) for each data point (rating), 
  # compute the norm of residual for each data point, 
  # compute the mean of residuals and take the square root of that mean. 
  #
  #  #RMSE formula is as follows:
  #              $$RMSE=\sqrt{\frac{1}{N}\sum_{u,i}(\hat{y}_{u,i}-y_{u,i})^2}$$
  #
  # In each case, models will be built and tested using only the edx
  # partitions (train and test). This includes any parameter optimization or
  # regularization that may be required.
  #
  # The model with the best accuracy, as measured by RMSE, will be tested
  # using the (final_holdout_test) validation set.
  #
  # The final model's performance will be evaluated based on the RMSE. 
  # The objective target RMSE is < 0.86490.
  #
  #
  #
  #
  # Loss-function RMSE computes the RMSE as the measure of accuracy for the error in rating: 
  RMSE <- function(true_ratings, predicted_ratings){
    sqrt(mean((true_ratings - predicted_ratings)^2))
  }
  
  # A first model - A Naive Model Approach
  # Start with the simplest recommendation system by predicting the same rating for all movies
  # regardless of user. 
  # The estimate that minimize the RMSE is the least squares estimate of u and, in this case
  # the average of all rating: 
  mu <- mean(train$rating)
  mu # 3.511522, 3.510878
  # the mean moving rating is > 3.5
  

  # If we predict all unknown ratings with u we obtain the following RMSE:
  # This is the first RMSE 
  naive_rmse <- RMSE(test$rating, mu)
  naive_rmse # 1.060152
  
  # From looking at the distribution of ratings, we can visualize that this is the standard deviation of that distribution. 
  # We get a RMSE of about 1. To win the grand prize of $1,000,000, a participating team had to get an RMSE of about 0.857.
  # We got to do better!
  # We will be comparing different approaches. Let's create a results table with this first RMSE:
  rmse_results <- tibble(Method = "Model 1 - Naive (Observed Average)", 
                         RMSE = naive_rmse)
  rmse_results
  # #####################################################################
  # Model 2 - Movie Effects Model
  #
  # We know from experience that some movies are just generally rated higher than others. 
  # This intuition, that different movies are rated differently (33.7.5 Modeling movie effects) 
  #
  # Taking into account the biases effects associated with the movies, b_i. 
  # We can augment our previous model by adding the term b_i
  # to represent average ranking for movie i: 
  #                      $$ Y_{u,i} = \mu_hat + b_i + \varepsilon_{u,i} $$
  # ######################################################################
  #  
  # In this particular situation,we know that the least squares estimate $$^b_i$ is just the average of 
  # $$Y_u,i - U_hat$$ for each movie i So we can compute them this way:
  
  #(we will drop the hat notation in the code to represent estimates going forward):
  mu <- mean(train$rating)
  
  # bi is the movies averages
  bi <- train %>% 
    group_by(movieId) %>%
    summarize(bi = mean(rating - mu))
  
  bi %>% ggplot(aes(bi)) +
    geom_histogram(color = "black", fill = "deepskyblue2", bins = 10) +
    xlab("Movie Bias") +
    ylab("Count") +
    theme_bw()
 
  
  #When we account for the movie effect in the model, the RMSE is reduced.
  predicted_ratings <- mu + test %>%
    left_join(bi, by='movieId') %>%
    pull(bi)
  
  bi_rmse <- RMSE(predicted_ratings, test$rating)
  bi_rmse
  
  
  # Record a 2nd rmse into the results table
  rmse_results <- bind_rows(rmse_results,
                            tibble(Method = "Model 2 - Movie Effects",  
                                   RMSE = bi_rmse))
  rmse_results 
  # ############################################################################
  # Model 3 - User Effects
  # Taking into account additional bias effects associated with the users, b_u. 
  # There is substantial variability across users as well: some users are very cranky and others love every movie.
  # (33.7.6 user effects)
  # This implies that a further improvement to our model may be:
  #                     $$ Y_{u,i} = \mu_hat + b_i + b_u + \varepsilon_{u,i} $$
  # ############################################################################
  
  bu <- train %>% 
    left_join(bi, by="movieId") %>%
    group_by(userId) %>%
    summarize(bu = mean(rating - mu - bi))
  
  
  predicted_ratings <- test %>%  
    left_join(bi, by='movieId') %>% 
    left_join(bu, by='userId') %>% 
    mutate(pred = mu + bi + bu) %>% 
    pull(pred)
  
  bu_rmse <-  RMSE(predicted_ratings, test$rating)
  bu_rmse
  
  #Record a 3nd rmse into the results table
  rmse_results <- bind_rows(rmse_results,
                            tibble(Method = "Model 3 - User Effects",  
                                   RMSE = bu_rmse))
  rmse_results
  
  # There's some improvement. Can we make it better?
  
  # ############################################################################
  #
  # Model 4 - Regularization permits us to penalize large estimates that are formed using small sample sizes. 
  #
  # Regularize the movie and user effect prediction model to avoid over fitting by factoring in 
  # $\lambda$ that penalizes small sample sizes.
  # ############################################################################
  lambdas <- seq(0, 10, 0.25)
  rmses <- sapply(lambdas, function(l){
    mu <- mean(train$rating)
    bi <- train %>% 
      group_by(movieId) %>% 
      summarize(bi = sum(rating - mu)/(n()+l))
    bu <- train %>% 
      left_join(bi, by="movieId") %>% 
      group_by(userId) |>
      summarize(bu = sum(rating - bi - mu)/(n()+l))
    predicted_ratings <- 
      test %>% 
      left_join(bi, by = "movieId") %>% 
      left_join(bu, by = "userId") %>% 
      mutate(pred = mu + bi + bu) %>% 
      pull(pred)
    return(RMSE(predicted_ratings, test$rating))
  })
  
  #This Graph shows a range of lambdas VS RMSE. The optimal setting provides the lowest error.
  qplot(lambdas, rmses, color=I("blue"))+
    theme_bw()

  #The value of lambda which results in lowest RMSE is:
  lambda <- lambdas[which.min(rmses)]
  lambda
  
  #The RMSE has improved however it is a very small gain in accuracy.
  #Record a 4th rmse into the results table
  rmse_results <- bind_rows(rmse_results,
                            tibble(Method = "Mdoel 4 - Regularized Movie + User Effects",  
                                   RMSE = min(rmses)))
  rmse_results
  # free the unused object from memory
  rm(predicted_ratings)
  
  
  ########################################################################
  # Model 5 - Recommender Systems
  #
  # **Be advised this process may take from 4 to more than 30 minutes to run.**
  ######################################################################
  
  if(!require(recosystem)) install.packages("recosystem", repos = "http://cran.us.r-project.org")
  
  library(recosystem)
  # data_memory(): Specifies a data set from R objects
  set.seed(1, sample.kind="Rounding")
  train_reco <- with(train, data_memory(user_index = userId, item_index = movieId, rating = rating))
  test_reco <- with(test, data_memory(user_index = userId, item_index = movieId, rating = rating))
  
  # Create a model object (a Reference Class object in R) by calling Reco().
  r <- Reco()
  
  # select best tuning parameters along a set of candidate values
  para_reco <- r$tune(train_reco, opts = list(dim = c(20, 30),
                                              costp_l2 = c(0.01, 0.1),
                                              costq_l2 = c(0.01, 0.1),
                                              lrate = c(0.01, 0.1),
                                              nthread = 4,
                                              niter = 10))
  
  # Train the model 
  r$train(train_reco, opts = c(para_reco$min, nthread = 4, niter = 30))
  # Compute predicted values 
  results_reco <- r$predict(test_reco, out_memory())
  
  #With the algorithm trained now we can test to see the resulting RMSE. 
  factorization_rmse <- RMSE(results_reco, test$rating)

  # Record our 5th Model
  rmse_results <- bind_rows(rmse_results, tibble(Method = "Model 5: Matrix Factorization Using Recosystem", RMSE = factorization_rmse))
  rmse_results
  
  
  #This is a great improvement. The RMSE is significantly less than the target RMSE. **We have our model.**  
  # clear objects from memory 
  rm (train_reco, para_reco, results_reco)
  
  
##############################################
# Final Validation 
# Now that we've found the lowest RMSE, the final step is to use matrix factorization to train it using the edx dataset and
# then test its accuracy on the validation set. 
############################################################################


###########################################################################
# Be advised tunning process below may take from 20 to more than an hour to run.**
##########################################################################
set.seed(1, sample.kind="Rounding")
edx_reco <- with(edx, data_memory(user_index = userId, item_index = movieId, rating = rating))
validation_reco <- with(validation, data_memory(user_index = userId, item_index = movieId, rating = rating))
  
r <- Reco()

#########
#### Be advised, this may take more than 45 min to run: 
########
para_reco <- r$tune(edx_reco, opts = list(dim = c(20, 30),
                                            costp_l2 = c(0.01, 0.1),
                                            costq_l2 = c(0.01, 0.1),
                                            lrate = c(0.01, 0.1),
                                            nthread = 4,
                                            niter = 10))

r$train(edx_reco, opts = c(para_reco$min, nthread = 4, niter = 30))

final_reco <- r$predict(validation_reco, out_memory())

final_rmse <- RMSE(final_reco, validation$rating)

 # Record our final model
 rmse_results <- bind_rows(rmse_results, tibble(Method = "Final Validation: Matrix factorization using recosystem", RMSE = final_rmse))
 rmse_results

 # clear no longer needed objects from Memory 
 rm (para_reco, final_reco)

# # A tibble: 6 × 2
#  Method                                                     RMSE
# <chr>                                                     <dbl>
# 1 "Model 1 - Naive (Observed Average) "                     1.06 
# 2 "Model 2 - Movie Effects"                                 0.943
# 3 "Model 3 - User Effects"                                  0.865
# 4 "Mdoel 4 - Regularized Movie + User Effects"              0.864
# 5 "Model 5: Matrix Factorization Using Recosystem"          0.784
# 6 "Final Validation: Matrix factorization using recosystem" 0.781
 
# The final RMSE is 0.7805. Significantly below the target of 0.8649.