---
title: "Code Book"
author: "Federica"
date: "24 maggio 2020"
output:
  html_document: default
  pdf_document: default
---

## run_analysis.R

The run_analysis.R script is a five step process that allows to prepare tidy data that can be used for further analysis 

**Original raw data set: Human Activity Recognition Using Smartphones Dataset Version 1.0**
Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto. Smartlab. Non Linear Complex Systems Laboratory DITEN 
-Universita degli Studi di Genova.

for a full description:
www.smartlab.ws

# Download and unzip the file

```
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./myfile.zip")   
unzip("myfile.zip")}
```

The datasets were downloaded and extracted 

# Read files 
```
#read features file
features <- read.table("./UCI HAR Dataset/features.txt", header = FALSE)
features <- as.character(features[ ,2]) 

#read the train set
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)
train_df <- data.frame(subject_train, y_train, X_train)
colnames(train_df) <- c(c("subject", "activity"), features)

#read the test set
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)
test_df <- data.frame(subject_test, y_test, X_test)
colnames(test_df) <- c(c("subject", "activity"), features)

#read activity labeles
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE)
colnames(activity_labels) <- c("activityCode", "activityName")
```
**features**
The features object contains the variable names

**activity_labels**
the activity_labels object contains the activity names and the coresponding class labels

**train_df**
the train_df is a dataframe consisting of 7352 observations and 563 variables. It was obtained by binding together the subject_train, the y_train and the X_train

**test_df**
the test_df is a dataframe consisting of 2947 observations and 563 variables. It was obtained by binding together the subject_test, the y_test and the X_test

**other information**
the y_test and y_train were renamed activity in the test_df and train_df.
the subject_test and the subject_train were renamed subject in the test_df and train_df.
the X_test and X_train were renamed according to the features file

# 1.Merges the training and the test sets to create one data set. 
```
#merge the train and test dataset
data_all <- rbind(train_df, test_df)
```
**data_all**
data_all is a dataframe consisting of 10299 observations and 563 variables it was obtained by rbinding the train_df and the test_df 

#2.Extracts only the measurements on the mean and standard deviation for each measurement
```
#extract the columns that corespond to mean and standard devietion measures  
meansd <- grep("mean\\(\\)|std\\(\\)", colnames(data_all))
meansd_df <- data_all[ ,meansd]
```
the above scripts let select all the variables corresponding to the mean and standard deviation measurements.

**meansd**
the meansd is an object that contains the position of the columns that contain mean and standard deviation values

**meansd_df** 
the meansd_df is a dataframe that contains 10299 observations and 66 variables. the 66 variables corespond to the mean and standard deviation measurements 

**meansd_df1**
meansd_df1 is  a dataframe containing 10299 observations and 68 variables. it was abtainined by binding the subject and activity columns to the meansd_df

# 3.Uses descriptive activity names to name the activities in the data set
```
renameactivity <- merge(meansd_df1, activity_labels, by.x = "activity", by.y = "activityCode", all = TRUE)
renameactivity$activity <- renameactivity$activityName
renameactivity1 <- renameactivity[1:(length(colnames(renameactivity))-1)]
```
the above scripts allow to name the activities in the meansd_df1 dataframe. the activity names were linked to the corresponding activity code by using the merge function

**renameactivity**
the renameactivity is a data frame containing 10299 observations and 69 variable. The content of the activity column was substituted with the activity name. This dataframe contains an activity column and an activityName column both containing the same contentent (that is the activity names).

**renameactivity1**
the renameactivity1 data frame contains 10299 observations and 68 variables. the activityName column was remuve and only the activity column was retained. 

# 4.Appropriately labels the data set with descriptive variable names
```
colnames(renameactivity1)<-gsub("Acc", "Accelerometer", colnames(renameactivity1))
colnames(renameactivity1)<-gsub("Gyro", "Gyroscope", colnames(renameactivity1))
colnames(renameactivity1)<-gsub("BodyBody", "Body", colnames(renameactivity1))
colnames(renameactivity1)<-gsub("Mag", "Magnitude", colnames(renameactivity1))
colnames(renameactivity1)<-gsub("^t", "Time", colnames(renameactivity1))
colnames(renameactivity1)<-gsub("^f", "Frequency", colnames(renameactivity1))
colnames(renameactivity1)<-gsub("tBody", "TimeBody", colnames(renameactivity1))
colnames(renameactivity1)<-gsub("-mean()", "Mean", colnames(renameactivity1), ignore.case = TRUE)
colnames(renameactivity1)<-gsub("-std()", "STD", colnames(renameactivity1), ignore.case = TRUE)
colnames(renameactivity1)<-gsub("-freq()", "Frequency", colnames(renameactivity1), ignore.case = TRUE)
colnames(renameactivity1)<-gsub("angle", "Angle", colnames(renameactivity1))
colnames(renameactivity1)<-gsub("gravity", "Gravity", colnames(renameactivity1))
```
the scripts allowed to replace the variable names with more descriptive names

#5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
```
tidydata <- renameactivity1 %>% group_by(activity, subject) %>% summarise_each(mean)
View(tidydata)
write.table(tidydata, "TidyData.txt", row.names = FALSE)
```
**tidydata**
the tidydata is a dataframe consisting of 180 observations and 68 variables. It was obtained by summarizing the renameactivity1 dataframe. It takes the mean of each variable after grouping by activity and subject


