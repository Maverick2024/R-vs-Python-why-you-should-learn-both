# -*- coding: utf-8 -*-
"""
Created on Fri Aug  4 17:18:50 2017

@author: Suryansh
"""
#importing the necessary packages:
import numpy as np
import pandas as pd
from sklearn import cross_validation,preprocessing
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import cross_val_score

#getting in the dataset:
df=pd.read_excel('C:/Users/Suryansh/Desktop/Data Science Project/Machine Learning/titanic3.xls','titanic3',index_Col=None,na_values=['NA'])

#initial data analysis:
#taking a look at our data
df.head()
#overall chance of survival for a titanic passenger:
df['survived'].mean()
#from the output of the above code we can conclude that only 38% of the passengers survived
#to get the averages for different variables by class
df.groupby('pclass').mean()
#from this output we can conclude that the first class passengers had a 62% chance of survival while third class passengers only had a 25% chance
#now breaking down the different averages by sex and class
sex_grouping=df.groupby(['pclass','sex']).mean()
sex_grouping
#visual representation of survivability of passengers by sex and class
sex_grouping['survived'].plot.bar()
#breaking down survivability by age
groupby_age=pd.cut(df["age"],np.arange(0,90,10))
age_grouping=df.groupby(groupby_age).mean()
age_grouping
#visualising the survivability by age
age_grouping['survived'].plot.bar()
#so far we can conclude that our analysis result is in sync with the maritime tradition of "women and children first" policy 

#preprocessing the dataset:
#identifying missing values:
df.count()
#from this output we can conclude there are a few variables in this dataset with upto 67% of missing values,so in order to deal with them, we will just drop them
df=df.drop(['body','cabin','boat'],axis=1)
#a lot of the age observations are also missing and as we know that age can have a significant impact on our model but home.dest can't do the same, hence we will replace the NAs in home.dest with a string and drop rest of the missing values 
df["home.dest"]=df["home.dest"].fillna("NA")
df=df.dropna()
#checking our dataset again to see if the recent changes have taken place:
df.count()
#formatting our data in a way that the machine learning algorithm will accept it:
def preprocessing_function(df):
    processed_df=df.copy()
    label_encoder=preprocessing.LabelEncoder()
    processed_df.sex=label_encoder.fit_transform(processed_df.sex)
    processed_df.embarked=label_encoder.fit_transform(processed_df.embarked)
    processed_df=processed_df.drop(['name','ticket','home.dest'],axis=1)
    return processed_df
#getting the processed dataset by passing out original dataset through the preprocessing fucntion
processed_df=preprocessing_function(df)
processed_df.dtypes


#spliting the dataset into testing and training sets:
X=processed_df.drop(['survived'],axis=1).values
y=processed_df['survived'].values
#20% of the data will be used for testing and 80% of the data will be used for training
X_train, X_test, y_train, y_test=cross_validation.train_test_split(X,y,test_size=0.2)   

#fitting the knn classifier on the training set data:
classifier=KNeighborsClassifier(n_neighbors=5,metric='minkowski',p=2)
classifier.fit(X_train, y_train)
classifier.score(X_train,y_train)
#making predictions on the test set data:
y_pred=classifier.predict(X_test)

#confusion matrix:
cm=confusion_matrix(y_test, y_pred)
cm

#applying k-fold validation:
accuracies=cross_val_score(estimator=classifier,X=X_train,y=y_train,cv=10)
accuracies.mean()

#removing the objects created after the session is over:
del([X, X_test, X_train, accuracies, age_grouping, cm, df, groupby_age, processed_df, sex_grouping, y, y_pred, y_test, y_train])
