## Purpose of this script is to merge the training and the test sets to create one data set and then create a second, independent tidy data set with the average of each variable for each activity and each subject.
# read the data from the Test and Training data source files
testLabels <- read.table("test/y_test.txt", col.names="label")
testSubjects <- read.table("test/subject_test.txt", col.names="subject")
testData <- read.table("test/X_test.txt")
trainLabels <- read.table("train/y_train.txt", col.names="label")
trainSubjects <- read.table("train/subject_train.txt", col.names="subject")
trainData <- read.table("train/X_train.txt")

# merge it together 
mergeData <- rbind(cbind(testSubjects, testLabels, testData),
                   cbind(trainSubjects, trainLabels, trainData))

# read the features and extract only the measurements on the mean and standard deviation for each measurement
features <- read.table("features.txt", strip.white=TRUE, stringsAsFactors=FALSE)
featuresMeanStd <- features[grep("mean\\(\\)|std\\(\\)", features$V2), ]
dataMeanStd <- mergeData[, c(1, 2, featuresMeanStd$V1+2)]

# read the labels 
labels <- read.table("activity_labels.txt", stringsAsFactors=FALSE)
# replace labels in data with label names
dataMeanStd$label <- labels[dataMeanStd$label, 2]

columnNames <- c("subject", "label", featuresMeanStd$V2)
columnNames <- tolower(gsub("[^[:alpha:]]", "", columnNames))
colnames(dataMeanStd) <- columnNames

#  average of each variable for each activity and each subject
aggregateData <- aggregate(dataMeanStd[, 3:ncol(dataMeanStd)],
                           by=list(subject = dataMeanStd$subject, 
                                   label = dataMeanStd$label),
                           mean)

# write the tidy data 
write.table(format(aggregateData, scientific=T), "tidydatafile.txt",
            row.names=F, col.names=T, quote=2)