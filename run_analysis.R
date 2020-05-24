#R code for Cleaning and Working with Data
##Source Data
#The data used in this course project represent data collected from the accelerometers from the Samsung Galaxy S smartphone.
#More information can be found at the data source website: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#The data for this project can be downloaded here:
#https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#The R run_analysis.R code in this repository primarily performs these 5 functions:
#1.Merges the training and the test sets to create one data set.
#2.Extracts only the measurements on the mean and standard deviation for each measurement
#3.Uses descriptive activity names to name the activities in the data set
#4.Appropriately labels the data set with descriptive variable names
#5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject


# 1 Download and unzip the file

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./myfile.zip")   
unzip("myfile.zip")

#read the features file
features <- read.table("./UCI HAR Dataset/features.txt", header = FALSE)
#extract the column we are interested in and convert o character
features <- as.character(features[ ,2]) 

#read activity labeles
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE)
colnames(activity_labels) <- c("activityCode", "activityName")

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

#merge the train and test dataset
data_all <- rbind(train_df, test_df)

#extract the columns that corespond to mean and standard devietion measures  
meansd <- grep("mean\\(\\)|std\\(\\)", colnames(data_all))
meansd_df <- data_all[ ,meansd]
meansd_df1 <- cbind(data_all[ ,1:2], meansd_df)

#Uses descriptive activity names to name the activities in the data set
renameactivity <- merge(meansd_df1, activity_labels, by.x = "activity", by.y = "activityCode", all = TRUE)
renameactivity$activity <- renameactivity$activityName
renameactivity1 <- renameactivity[1:(length(colnames(renameactivity))-1)]

#Appropriately labels the data set with descriptive variable names
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


#From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject
tidydata <- renameactivity1 %>% group_by(activity, subject) %>% summarise_each(mean)
View(tidydata)
write.table(tidydata, "TidyData.txt", row.names = FALSE)
