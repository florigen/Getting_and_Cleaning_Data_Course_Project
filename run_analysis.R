library(tidyverse)

x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")


# read training data
x_train       <- read_table('data/train/X_train.txt', col_names = F, col_types = cols( .default = col_double()))
y_train       <- read_table('data/train/y_train.txt', col_names = F, col_types = cols( .default = col_double()))
subject_train <- read_table('data/train/subject_train.txt', col_names = F, col_types = cols( .default = col_double()))

# read test data
x_test       <- read_table('data/test/X_test.txt', col_names = F, col_types = cols( .default = col_double()))
y_test       <- read_table('data/test/y_test.txt', col_names = F, col_types = cols( .default = col_double()))
subject_test <- read_table('data/test/subject_test.txt', col_names = F, col_types = cols( .default = col_double()))

# read labels
feature       <- read_delim('data/features.txt', delim = ' ', col_names = F, col_types =cols( X1 = col_double(),X2 = col_character()))
activityLabels <- read_delim('data/activity_labels.txt', delim = ' ', col_names = F, col_types =cols( X1 = col_double(),X2 = col_character()))
colnames(activityLabels) <- c('activityId','activityType')


# training data
colnames(x_train) <- feature %>% select(X2) %>% pull
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"

y_train <- y_train %>% cbind(subject_train) %>% inner_join(activityLabels, by = "activityId")

train <- cbind(y_train, x_train)
train['Type'] = "Train"

rm(x_train, subject_train, y_train)

# test data
colnames(x_test) <- feature %>% select(X2) %>% pull
colnames(y_test) <-"activityId"
colnames(subject_test) <- "subjectId"

y_test <- y_test %>% cbind(subject_test) %>% inner_join(activityLabels, by = "activityId")

test <- cbind(y_test, x_test)
test['Type'] = 'Test'

rm(x_test, subject_test, y_test)

# rowbind test / train
all <- rbind(train, test)
rm(activityLabels, feature, train, test)

# select mean(), and std() fileds
mean_std <- all %>% select(activityId, activityType,subjectId,  contains('mean()'), contains('std()'))

# summarise all vriable means for each subject and activity
final <- mean_std %>% group_by(subjectId,activityId,activityType) %>% summarise_all(mean)

# write result to file
write.table(final, "secTidySet.txt", row.name=FALSE)
