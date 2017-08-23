# -*- coding: utf-8 -*-
"""
@author: Suryansh
"""
#importing the necessary variables:
import pandas as pd
from sklearn import preprocessing
import numpy as np
#importing the dataset (for reuse change the file location accordingly)
dataset=pd.read_csv("C:/Users/Suryansh/Desktop/Data Science Project/loan.csv/loan.csv")

#exploring the dataset:
dataset.shape
#to find summary statistics
summary_stats=dataset.describe()
#structure of the dataset:
structure_info=dataset.dtypes

#to get the frequency of different levels contained within various categorical variables:
dataset.groupby('term').term.count()
dataset.groupby('grade').grade.count()
dataset.groupby('sub_grade').sub_grade.count()
dataset.groupby('emp_title').emp_title.count()
dataset.groupby('emp_length').emp_length.count()
dataset.groupby('home_ownership').home_ownership.count()
dataset.groupby('verification_status').verification_status.count()
dataset.groupby('issue_d').issue_d.count()
dataset.groupby('loan_status').loan_status.count()
dataset.groupby('pymnt_plan').pymnt_plan.count()
dataset.groupby('url').url.count()
dataset.groupby('desc').desc.count()
dataset.groupby('purpose').purpose.count()
dataset.groupby('title').title.count()
dataset.groupby('zip_code').zip_code.count()
dataset.groupby('addr_state').addr_state.count()
dataset.groupby('earliest_cr_line').earliest_cr_line.count()
dataset.groupby('initial_list_status').initial_list_status.count()
dataset.groupby('last_pymnt_d').last_pymnt_d.count()
dataset.groupby('next_pymnt_d').next_pymnt_d.count()
dataset.groupby('last_credit_pull_d').last_credit_pull_d.count()
dataset.groupby('application_type').application_type.count()
dataset.groupby('verification_status_joint').verification_status_joint.count()

#printing the names of the columns containing missing values:
dataset.columns[dataset.isnull().any()]

#removing the less relevant variables from the dataset:
dataset=dataset.drop(['id', 'member_id', 'emp_title', 'url', 'zip_code', 'desc', 'next_pymnt_d', 'last_pymnt_d', 'last_credit_pull_d', 'recoveries', 'policy_code', 'earliest_cr_line', 'total_rec_late_fee', 'last_pymnt_amnt', 'collections_12_mths_ex_med'],axis=1)

#removing variables containing more than 75% N/A values
dataset=dataset.drop(['annual_inc_joint','dti_joint','open_acc_6m','open_il_6m','open_il_12m','open_il_24m','mths_since_rcnt_il','total_bal_il','il_util','open_rv_12m','open_rv_24m','max_bal_bc','all_util','inq_fi','total_cu_tl','inq_last_12m','mths_since_last_record','mths_since_last_major_derog','verification_status_joint'],axis=1)

#removing categorical variables with more than 30 levels:
dataset=dataset.drop(['issue_d','title','sub_grade'],axis=1)

#zero imputing the mths_since_last_delinq variable (cause an N/A may just mean that there is no outstanding amount, whihc can also be represented by zero) 
dataset['mths_since_last_delinq']=dataset['mths_since_last_delinq'].fillna(0)

#one-hot encoding the remaining categorical vaariables:
dataset_dummies=pd.get_dummies(dataset,columns=['term','grade','emp_length','home_ownership','verification_status','loan_status','pymnt_plan','purpose','addr_state','initial_list_status','application_type'],drop_first=True)
#saving the list of names into a different variable for the future:
name=list(dataset_dummies)

#central imputing the missing variables:
fill_NaN=preprocessing.Imputer(missing_values=np.nan,strategy='mean',axis=1)
df_imputed=pd.DataFrame(fill_NaN.fit_transform(dataset_dummies))
df_imputed.columns=dataset_dummies.columns
df_imputed.index=dataset_dummies.index

#scaling the dataset to help the computer deal with imbalanced values:
df_imputed.z=preprocessing.scale(df_imputed)
#converting the scaled matrix into a dataframe:
df_sc=pd.DataFrame(df_imputed.z,columns=name)

#separating numerical data from categorical data for outlier treatment and calculating their descriptive statistics:
num=df_sc[['funded_amnt','funded_amnt_inv','int_rate','installment','annual_inc','dti','delinq_2yrs','inq_last_6mths','mths_since_last_delinq','open_acc','pub_rec','revol_bal','revol_util','total_acc','out_prncp','out_prncp_inv','total_pymnt','total_pymnt_inv','total_rec_prncp','total_rec_int','collection_recovery_fee','acc_now_delinq','tot_coll_amt','tot_cur_bal','total_rev_hi_lim']]
#outier treatment:
low=.05
high=.95
quant_df=num.quantile([low,high])
print(quant_df)
num=num.apply(lambda x: x[(x>=quant_df.loc[low,x.name]) & (x<=quant_df.loc[high,x.name])],axis=0)
#central imputing the missing values for the numerical data after performing outlier treatment on it:
fill_NaN=preprocessing.Imputer(missing_values=np.nan,strategy='mean',axis=1)
num_imputed=pd.DataFrame(fill_NaN.fit_transform(num))
num_imputed.columns=num.columns
num_imputed.index=num.index
#finding the variance for the scaled dataframe:
num_imputed.var()
#finding the covariance for the scaled dataframe:
num_imputed.cov()
#finding the correlation for the scaled dataframe:
num_imputed.corr()
#kurtosis
num_imputed.kurtosis(axis=None,skipna=None,level=None,numeric_only=None)
#skewness
num_imputed.skew(axis=None,skipna=None,level=None,numeric_only=None)

#deleting the objects after the session is over:
del([dataset,dataset_dummies,df_imputed,df_sc,high,low,name,num,num_imputed,quant_df,structure_info,summary_stats])



