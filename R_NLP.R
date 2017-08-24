#importing the dataset:
df<-read.delim('Restaurant_Reviews.tsv', quote = '', stringsAsFactors = FALSE)

#cleaning the text and creating a corpus:
library(tm)
library(SnowballC)
corpus<-VCorpus(VectorSource(df$Review))
corpus<-tm_map(corpus, content_transformer(tolower))
corpus<-tm_map(corpus, removeNumbers)
corpus<-tm_map(corpus, removePunctuation)
corpus<-tm_map(corpus, removeWords, stopwords())
corpus<-tm_map(corpus, stemDocument)
corpus<-tm_map(corpus, stripWhitespace)

#Creating the Bag of words model:
bow<-DocumentTermMatrix(corpus)
bow<-removeSparseTerms(bow, 0.999)
dataset<-as.data.frame(as.matrix(bow))
dataset$Liked<-df$Liked

# Encoding the target feature as factor
dataset$Liked = factor(dataset$Liked, levels = c(0, 1))

# Splitting the dataset into the Training set and Test set
library(caTools)
set.seed(123)
split<-sample.split(dataset$Liked, SplitRatio = 0.8)
train<-subset(dataset, split == TRUE)
test<-subset(dataset, split == FALSE)

# Fitting Random Forest Classification to the Training set
library(randomForest)
classifier = randomForest(x = train[-692],
                          y = train$Liked,
                          ntree = 10)

# Predicting the Test set results i.e whether a review is negative or positive
y_pred = predict(classifier, newdata=test[-692])

# Making the Confusion Matrix
cm = table(test[, 692], y_pred)
cm

#removing the created objects after the session is over
rm(dataset,df,test,train,bow,classifier,cm,corpus,split,y_pred)