if(!file.exists("data")){dir.create("data")}
unzip("getdata-projectfiles-UCI HAR Dataset.zip", exdir="./data/uci")

#install.packages("stringr")
library(stringr)
library(plyr)
library(dplyr)

#The list of feature names from features.txt would be used label the column names for the dataset.

#But some processing has to be done on the strings read in from the features.txt. 
#Firstly, the number is removed from the beginning of each string.  
#Then all special characters such as comma, parenthesis, hyphens are removed.

dat<-readLines("./data/uci/UCI HAR Dataset/features.txt")
dat2<-word(dat, -1) 
dat3<-gsub("[^A-Za-z0-9]", "", dat2)




#X_train.txt is first read in, and the column names are set to that of the processed names from features.txt.
#The dimensions of x_train is 7352 rows by 561 columns.
#y_train consists of only a single column, and the name of that column is set to "activity".
#The integer values of the "activity" column are converted to factors specified in the "activity_labels.txt"

#The subject_train.txt file is read in. It also consists of one column.  It holds the ids of the participants
#in the study.  The column is given the name "subject.id"

# the subject_train, y_train and x_train are all combined into one data.frame called ctrain

xtrain<-read.table("./data/uci/UCI HAR Dataset/train/X_train.txt", col.names=dat3)
ytrain<-read.table("./data/uci/UCI HAR Dataset/train/Y_train.txt", col.names="activity")
activity<-mapvalues(ytrain$activity, from = 1:6, to = c("WALKING","WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))
utrain<-read.table("./data/uci/UCI HAR Dataset/train/subject_train.txt", col.names="subject.id")
ctrain<-cbind(utrain, activity, xtrain)



#X_test.txt is then read in, and the column names are set to that of the processed names from features.txt.
#The dimensions of x_test is 2947 rows by 561 columns.
#y_test consists of only a single column, and the name of that column is set to "activity".
#The integer values of the "activity" column are converted to factors specified in the "activity_labels.txt"

#The subject_test.txt file is read in. It also consists of one column.  It holds the ids of the participants.  
#The column is given the name "subject.id"

#The subject_test, y_test and x_test are all combined into one data.frame called ctest.

xtest<-read.table("./data/uci/UCI HAR Dataset/test/X_test.txt", col.names=dat3)
ytest<-read.table("./data/uci/UCI HAR Dataset/test/y_test.txt", col.names="activity")
activity<-mapvalues(ytest$activity, from = 1:6, to = c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))
utest<-read.table("./data/uci/UCI HAR Dataset/test/subject_test.txt",col.names="subject.id")
ctest<-cbind(utest, activity, xtest)


#ctrain and ctest have the same number of type of columns (i.e., same variables) so their rows are combined to form a data.frame called data_all which has dimensions 10299 by 563 columns.

data_all<-rbind(ctrain, ctest)
#dim(data_all)


# Extracted from data_all are the columns: subject.id and activity, together with
# all the variables containing the string "mean" (for mean of the given measurement) or  
# "std" (for standard deviation of the measurement in question)

data_some<-select(data_all, subject.id, activity, contains("mean"), contains("std"))
#str(data_some)

# A tidy data set is produced that groups the data by subject.id and activity 
#and for each group finds the average for each of the variables

data_tidy<-data_some%>%group_by(subject.id, activity)%>%summarise_each(funs(mean))

# This tidy data set is written out to a text filed called "tidydata.txt". This can be found in the working directory
write.table(data_tidy, "tidydata.txt", row.names=FALSE)

