#Setting a working directory to download zip file in
setwd("E:/TAMU/Cleaning data R") 

# Downloading and unzipping the dataset:
filename <- "Data.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Clearing workspace
rm(list=ls())

# Reading features to be extracted
names <- read.table("UCI HAR Dataset/features.txt", header = F, sep=" ")
names$V2 <- as.character(names$V2)
ftrs <- grep("mean|std", names$V2)

# Reading datasets
x_train <- read.table("UCI HAR Dataset/train/X_Train.txt", header = F)[ftrs]
activity <- read.table("UCI HAR Dataset/train/y_Train.txt", header = F)
subject_tr <- read.table("UCI HAR Dataset/train/subject_train.txt", header = F)
train = cbind(subject_tr, x_train, activity)

x_test <- read.table("UCI HAR Dataset/test/X_Test.txt", header = F)[ftrs]
activityy <- read.table("UCI HAR Dataset/test/y_test.txt", header = F)
subject_te <- read.table("UCI HAR Dataset/test/subject_test.txt", header = F)
test = cbind(subject_te, x_test, activityy)

# Binding train and test
data <- rbind(train,test)
names(data) <- c("Subject",names$V2[ftrs],"Activity")

# Activity labels
ac_label <- read.table("UCI HAR Dataset/activity_labels.txt", header = F)
colnames(ac_label)  = c('Activity','Activity_Label')
Data = merge(data,ac_label,by='Activity', all.x = T)
Data <- Data[,-1]

# Providing descriptive variable names/Tidying up column names
names(Data)
names(Data) <- sub("\\()","",names(Data))
names(Data) <- sub("BodyBody","Body",names(Data)) 
names(Data) <- sub("Freq","",names(Data)) 
names(Data) <- gsub("-","_",names(Data)) 
names(Data) <- gsub("mean","Mean",names(Data)) 
names(Data) <- gsub("std","Stdev",names(Data)) 
mean1 <- grep("Mean", names(Data))
names(Data)[mean1] <- paste("Mean_", names(Data)[mean1], sep="")
names(Data) <- gsub("_Mean_","_",names(Data))
names(Data) <- gsub("_Mean","",names(Data))
std <- grep("Stdev", names(Data))
names(Data)[std] <- paste("Stdev_", names(Data)[std], sep="")
names(Data) <- gsub("_Stdev_","_",names(Data))
names(Data) <- gsub("_Stdev","",names(Data))
sum(is.na(Data$Activity_Label))

# Average of each variable for each activity and each subject
melted_data <- melt(Data, id = c("Subject", "Activity_Label"))
casted_data <- dcast(melted_data, Subject + Activity_Label ~ variable, mean)

write.table(casted_data, "Tidy_data.txt", row.names = FALSE, quote = FALSE)
