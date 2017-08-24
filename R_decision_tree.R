#importing the dataset:
library(readxl)
#change the working directory accordingly
df<-read_xls("titanic3.xls")
#taking a look into our data:
head(df)
str(df)

#doing a little bit of exploratory data analysis:
#percentage of passengers who survived:
mean(df$survived)
#to get the averages of different variables by class
aggregate(df[,c("survived","age","sibsp","parch","fare","body")],list(df$pclass),mean,na.rm=TRUE)
#now breaking down the different averages by sex and class
sex_group<-aggregate(df[,c("survived","age","sibsp","parch","fare","body")],list(df$sex,df$pclass),mean,na.rm=TRUE)
sex_group

#preprocessing the dataset so that ml algorithms can be applied on it:
#identifying and treating missing values:
summary(df)
#from this output we can conclude there are a few variables in this dataset with upto 67% of missing values,so in order to deal with them, we will just drop them
df=subset(df,select=-c(body,cabin,boat))
#a lot of the age observations are also missing and as we know that age can have a significant impact on our model but home.dest can't do the same, hence we will replace the NAs in home.dest with a string and drop rest of the missing values
df$home.dest[is.na(df$home.dest)]<-'NA'
df<-na.omit(df)
#dropping variables containing non-categorical string values as it is difficult for a classifier to interpret them
df_processed<-subset(df,select = -c(name,ticket,home.dest))
#creating dummy variables
library(dummies)
df_processed<-cbind(df_processed,dummy(df$pclass,sep="."),dummy(df$sex,sep="."),dummy(df$embarked,sep="."))
#removing the original variables which were one hot encoded
df_processed<-subset(df_processed,select = -c(pclass,sex,embarked))
#understanding the proportion of the outcome variable
prop.table(table(df_processed$survived))
#transforming the outcome variable's type to a desirable one(i.e from a num into a factor):
df_processed$survived = factor(df_processed$survived, levels = c(0, 1))

#splitting the preprocessed dataset into testing and training sets
library(caret)
splitIndex<-createDataPartition(df_processed$survived,p=.80,list=FALSE,times=1)
train<-df_processed[splitIndex,]
test<-df_processed[-splitIndex,]

#fitting the decision tree model onto the training set data:
library(rpart)
classifier<-rpart(survived~.,data=train)

#making predictions on the test-set data
y_pred<-predict(classifier,newdata=test[-1],type='class')

#confusion matrix:
cm<-table(test$survived,y_pred)
#calculating the accuracy of the classifier
accuracy<-(cm[1,1]+cm[2,2])/(cm[1,1]+cm[2,2]+cm[1,2]+cm[2,1])

#applying k-fold validation to improve the classifier's accuracy:
#creating the folds
fold<-createFolds(train$survived,k=10)
#implementing the k-fold function
cv<-lapply(fold, function(x){
    training_fold<-train[-x,]
    test_fold<-train[x,]
    classifier<-rpart(survived~.,data=training_fold)
    #making predictions the test fold
    y_pred<-predict(classifier,newdata=test_fold[-1],type='class')
    #creating confusion matrix:
    cm<-table(test_fold$survived,y_pred)
    accuracy<-(cm[1,1]+cm[2,2])/(cm[1,1]+cm[2,2]+cm[1,2]+cm[2,1])
    return(accuracy)
  })
#getting the mean of all the accuracies:
accuracy<-mean(as.numeric(cv))
accuracy

#plotting the decision tree:
library(rpart.plot)
library(rattle)
fancyRpartPlot(model)

#removing the created objects after the session is over:
rm(df,df_processed,sex_group,splitIndex,test,train,accuracy,classifier,cm,cv,fold,y_pred)

