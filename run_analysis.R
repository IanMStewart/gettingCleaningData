# run_analysis.R
# Usage: This script should be run in the "UCI HAR Dataset" directory that contains "train" and "test" subdirectories
# Author: Ian Stewart
# Description: run_analysis.R reads the training and test data and all associated activity types, activity labels and 
#              record subject IDs to first create a tidy data set of all data, then subsets the data to only include
#              mean and std measurements.  Finally, means of all records of the mean and std measurements are calculated
#              by activity type and subject.  The user is prompted to select either a long or wide data set for output.
#              A WIDE data set is uploaded to the Coursera website for this assignment.

run_analysis <- function() {

    # Prompt user for long or wide data set output type
    answer <- character()
    getOutputType <- function() {
        answer <<- readline(prompt="Would you like to output the data set in long (l) or wide (w) format? ")
        answer <<- tolower(substr(answer, 1, 1))
        if ( ! answer %in% c("l", "w")) {
            getOutputType()
        }
    }
    if ( interactive() ) getOutputType()
    
    # data.frame for tidy data set
    tidyData <- data.frame()
    
    # --------------------------------------------------------

    # 4. Appropriately labels the data set with descriptive variable names.
    
    # Read the features.txt file - this will provide the colnames for measurement variables
    message("reading features.txt")
    measCols <- read.table("features.txt", header=F, sep=" ")
    colnames(measCols) <- c("colIndex", "colName")
    
    # Remove parentheses and comma characters prior to assigning to tidyData data.frame colnames
    measCols$colName <- gsub("[\\(\\)]", "", measCols$colName)
    measCols$colName <- gsub(",", "-", measCols$colName)
    
    # --------------------------------------------------------
    
    # Load the training data set
    
    # Read the y_train.txt file - contains the activity type for each training record
    message("reading y_train.txt")
    trainRecActType <- read.table("train/y_train.txt", header=F)
    colnames(trainRecActType) <- "actID"
    
    # Read the subject_train.txt file - contains the subject ID for each training record
    message("reading subject_train.txt")
    trainRecSubjectID <- read.table("train/subject_train.txt", header=F)
    colnames(trainRecSubjectID) <- "subjectID"
    
    # Read the X_train.txt file - contains the training data set
    message("reading X_train.txt")
    trainingSet <- read.table("train/X_train.txt", header=F)
    colnames(trainingSet) <- measCols$colName
    
    # Combine the training data
    tidyData <- cbind(trainRecActType, trainRecSubjectID, trainingSet)
        
    # --------------------------------------------------------
    
    # Load the test data set
    
    # Read the y_test.txt file - contains the activity type for each test record
    message("reading y_test.txt")
    testRecActType <- read.table("test/y_test.txt", header=F)
    colnames(testRecActType) <- "actID"
    
    # Read the subject_test.txt file - contains the subject ID for each test record
    message("reading subject_test.txt")
    testRecSubjectID <- read.table("test/subject_test.txt", header=F)
    colnames(testRecSubjectID) <- "subjectID"

    # Read the X_test.txt file - contains the test data set
    message("reading X_test.txt")
    testSet <- read.table("test/X_test.txt", header=F)
    colnames(testSet) <- measCols$colName
    
    # Combine the test data
    testData <- data.frame()
    testData <- cbind(testRecActType, testRecSubjectID, testSet)
        
    # --------------------------------------------------------
    
    # 1. Combine training and test data to create one data set.
    tidyData <- rbind(tidyData, testData)
        
    # --------------------------------------------------------
    
    # 2. Extract only the measurements on the mean and standard deviation for each measurement
    
    # Select columns with "[Mm]ean" or "std" in their colnames (and retain actID and subjectID)
    # This should return 86 measurement variables as columns
    tidyData <- tidyData[, grepl("actID|subjectID|mean|std",colnames(tidyData), ignore.case=T)]
    
    # --------------------------------------------------------
    
    # 3. Use descriptive activity names to name the activities in the data set
    
    # Read the activity_labels.txt file - contains the descriptive labels for each activity type
    actLabels <- read.table("activity_labels.txt", header=F, sep=" ")
    colnames(actLabels) <- c("actID", "actName")
    
    # Merge the actLabels data.frame to provide descriptive activities for all records
    # NB This should be done after concatenating all other data, as merge() reorders the data.
    mergeDf <- merge(actLabels, tidyData, all=T)
    # Remove unnecessary actID column
    tidyMerge <- mergeDf[,2:ncol(mergeDf)]
    
    # --------------------------------------------------------
    
    # 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.
    
    # To avoid looping through all of the measurement columns, let's melt all of the columns into a variable/value pair
    library(reshape2)
    melted <- melt(tidyMerge, id.vars=c("actName", "subjectID"))
    
    # Now use plyr to calculate means for each of the measurement variables by activity and subject
    library(plyr)
    meltedMeans <- ddply(melted, .(actName, subjectID, variable), summarise, mean=mean(value))
    
    if (answer == "l") {
        # This is a long data set - which is an acceptable tidy form, but is NOT the one uploaded to the Coursera website
        message("writing longTidyData.txt")
        write.table(meltedMeans, "longTidyData.txt", sep="\t")
    }
    else if (answer == "w") {
        # Cast the long data set to a wide data set using dcast()
        wideMeans <- dcast(meltedMeans, actName + subjectID ~ variable, value.var="mean")
        # Write out a tab separated WIDE data format file for upload to the Coursera website
        # This is the one submitted for the course assignment
        message("writing wideTidyData.txt")
        write.table(wideMeans, "wideTidyData.txt", sep="\t")
    }
    
    # Hope that's enough comments for you!
}
