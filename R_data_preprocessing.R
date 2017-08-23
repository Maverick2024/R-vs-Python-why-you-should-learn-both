#importing loan.csv dataset:
#in order to import the dataset set the folder where your dataset is stored as the working directory
dataset<-read.csv("loan.csv")

#understanding the structure of the dataset:
str(dataset)
#getting the basic descriptive statistics of the dataset:
summary(dataset)

#removing the less relevant variables from the dataset:
dataset<-subset(dataset, select=-c(id, member_id, emp_title, url, zip_code, desc, next_pymnt_d, last_pymnt_d, last_credit_pull_d, recoveries, policy_code, earliest_cr_line,  total_rec_late_fee, last_pymnt_amnt, collections_12_mths_ex_med))

#handling missing values:
#removing varaibles with more than 75% N/A values (note: these variables were identified from the summary statistics of the dataset)
dataset<-subset(dataset, select = -c(annual_inc_joint,dti_joint,open_acc_6m,open_il_6m,open_il_12m,open_il_24m,mths_since_rcnt_il,total_bal_il,il_util,open_rv_12m,open_rv_24m,max_bal_bc,all_util,inq_fi,total_cu_tl,inq_last_12m,mths_since_last_record,mths_since_last_major_derog,verification_status_joint))


#zero imputing the mths_since_last_delinq column (an empty deliquency column may just mean that there is no deliquent amount left)
dataset$mths_since_last_delinq[is.na(dataset$mths_since_last_delinq)]<-0

#again getting the structure and statistics for the dataset to plan further action:
str(dataset)
summary(dataset)

#handling categorical variables:
#library for creating dummy variables
library(dummies)
#removing variables with more than 30 levels:
dataset<-subset(dataset,select = -c(issue_d, title,sub_grade))
#one hot encoding the categorical variables:
dataset<-cbind(dataset,dummy(dataset$term,sep="."),dummy(dataset$grade,sep="."),dummy(dataset$emp_length,sep="."),dummy(dataset$home_ownership,sep="."),dummy(dataset$verification_status,sep="."),dummy(dataset$loan_status,sep="."),dummy(dataset$pymnt_plan,sep="."),dummy(dataset$purpose,sep="."),dummy(dataset$addr_state,sep="."),dummy(dataset$initial_list_status,sep="."),dummy(dataset$application_type,sep="."))
#removing the original categorical variables which have been one-hot encoded now:
dataset<-subset(dataset,select = -c(term, grade,emp_length, home_ownership, verification_status, loan_status, pymnt_plan,  purpose, addr_state, initial_list_status, application_type))

#scaling the dataset to help the computer deal with imbalanced values:
dataset.z<-scale(dataset)
dataset_sc<-as.data.frame(dataset.z)
rm(dataset.z)

#imputing the missing values:
dataset_sc$tot_coll_amt[is.na(dataset_sc$tot_coll_amt)]<-mean(dataset_sc$tot_coll_amt,na.rm = T)
#imputing the tot_cur_bal and total_rev_hi_lim variables:
dataset_sc$tot_cur_bal[is.na(dataset_sc$tot_cur_bal)]<-mean(dataset_sc$tot_cur_bal,na.rm = T); dataset_sc$total_rev_hi_lim[is.na(dataset_sc$total_rev_hi_lim)]<-mean(dataset_sc$total_rev_hi_lim,na.rm = T)
#imputing acc_now_delinq, open_acc, pub_rec, revol_bal, revol_util, total_acc, delinq_2yrs, inq_last_6mths, annual_inc variables
dataset_sc$acc_now_delinq[is.na(dataset_sc$acc_now_delinq)]<-mean(dataset_sc$acc_now_delinq,na.rm = T)
dataset_sc$open_acc[is.na(dataset_sc$open_acc)]<-mean(dataset_sc$open_acc,na.rm = T)
dataset_sc$pub_rec[is.na(dataset_sc$pub_rec)]<-mean(dataset_sc$pub_rec,na.rm = T)
dataset_sc$revol_bal[is.na(dataset_sc$revol_bal)]<-mean(dataset_sc$revol_bal,na.rm = T)
dataset_sc$revol_util[is.na(dataset_sc$revol_util)]<-mean(dataset_sc$revol_util,na.rm = T)
dataset_sc$total_acc[is.na(dataset_sc$total_acc)]<-mean(dataset_sc$total_acc,na.rm = T)
dataset_sc$delinq_2yrs[is.na(dataset_sc$delinq_2yrs)]<-mean(dataset_sc$delinq_2yrs,na.rm = T)
dataset_sc$inq_last_6mths[is.na(dataset_sc$inq_last_6mths)]<-mean(dataset_sc$inq_last_6mths,na.rm = T)
dataset_sc$annual_inc[is.na(dataset_sc$annual_inc)]<-mean(dataset_sc$annual_inc,na.rm = T)

#outlier identification and treatment:
library(outliers)
#identifying the outliers:
outlier(dataset_sc)
outlier(dataset_sc,opposite = TRUE)
#function to replace the outliers with the 5th and 95th percentile values:
fun<- function(x){
  quantiles<-quantile(x,c(.05,.95))
  x[x<quantiles[1]]<-quantiles[1]
  x[x>quantiles[2]]<-quantiles[2]
  x
}
m<-as.matrix(dataset_sc)
#implementing the outlier treatment function:
df<-fun(m)
#removing the original dataset_sc df and replacing it with the matrix with outlier treatment
rm(m)
rm(dataset_sc)
dataset_sc<-as.data.frame(df)
rm(df)
rm(dataset)
#checking to see if the outliers have been removed or not
outlier(dataset_sc)

#descriptive summary statistics of numerical variables:
num<-subset(dataset_sc,select = c(funded_amnt,funded_amnt_inv,int_rate,installment,annual_inc,dti,delinq_2yrs,inq_last_6mths,mths_since_last_delinq,open_acc,pub_rec,revol_bal,revol_util,total_acc,out_prncp,out_prncp_inv,total_pymnt,total_pymnt_inv,total_rec_prncp,total_rec_int,collection_recovery_fee,acc_now_delinq,tot_coll_amt,tot_cur_bal,total_rev_hi_lim))
#converting that numerical dataframe into a matrix
mat<-as.matrix(num)
#finding the standard deviation for the matrix conatining numerical values
apply(mat,2,sd)
#finding the variance for the matrix conatining numerical values
apply(mat,2,var)
#loading the moments package to use kurtosis and skewness
library(moments)
#finding the kurtosis for the matrix conatining numerical values
apply(mat,2,kurtosis)
#finding the skewness for the matrix conatining numerical values
apply(mat,2,skewness)
#covariance of the numerical matrix conatining numerical values
cov(mat)
#correlation of the numerical matrix: conatining numerical values
cor(mat)

#removal of all the objects after the session is completed
rm(dataset_sc,mat,num,fun)


