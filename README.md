===============================================================

R Script: run_analysis.R
Author: Ian Stewart

===============================================================

Usage: This script should be run in the "UCI HAR Dataset" directory that contains "train" and "test" subdirectories
Description: run_analysis.R reads the training and test data and all associated activity types, activity labels and 
             record subject IDs to first create a tidy data set of all data, then subsets the data to only include
             mean and std measurements.  Finally, means of all records of the mean and std measurements are calculated
             by activity type and subject.  The user is prompted to select either a long or wide data set for output.
             A wide data set is uploaded to the Coursera website for this assignment.

===============================================================

The run_analysis.R script contains plenty of comments within the code to describe what the script is doing at relevant
points.  I recommend reading the comments next to the code within the script to understand what it is doing, rather than
reading this readme, however a plain english description follows, as per the assignment instructions.

===============================================================

The script executes the following:

    1. Prompts the user for long or wide data set output type
    2. Read the features.txt file - this will provide the descriptive colnames for measurement variables
    3. Remove parentheses and comma characters prior to assigning to the tidy data.frame colnames
    4. Loads the training data set:
    	i. Reads the y_train.txt file - contains the activity type for each training record
    	ii. Reads the subject_train.txt file - contains the subject ID for each training record
    	iii. Reads the X_train.txt file - contains the training data set
    5. Combines the training data loaded in step 4 into one tidy data set.
    6. Loads the test data set:
    	i. Reads the y_test.txt file - contains the activity type for each test record
    	ii. Reads the subject_test.txt file - contains the subject ID for each test record
    	iii. Reads the X_test.txt file - contains the test data set
    7. Combines the test data loaded in step 6 into one tidy data set.
    8. Combines training and test data to create one data set.
    9. Extracts only the measurements on the mean and standard deviation for each measurement:
    	i. Select columns with "[Mm]ean" or "std" in their colnames (and retain actID and subjectID) 
    	ii. This should return 86 measurement variables as columns
    10. Use descriptive activity names to name the activities in the data set:
    	i. Reads the activity_labels.txt file - contains the descriptive labels for each activity type
    	ii. Merges the actLabels data.frame to provide descriptive activities for all records
    	iii. NB This should be done after concatenating all other data, as merge() reorders the data.
    	iv. Removes unnecessary actID column
    11. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    	i. To avoid looping through all of the measurement columns, let's melt all of the columns into a variable/value pair
    	ii. Uses plyr to calculate means for each of the measurement variables by activity and subject
    12. Writes out either a long or wide data format tidy data set.

