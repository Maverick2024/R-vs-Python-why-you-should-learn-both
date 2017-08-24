# -*- coding: utf-8 -*-
"""
Created on Tue Jul 11 15:05:09 2017

@author: Suryansh
"""
import pandas as pd
from sklearn import preprocessing
#importing  the dataset
df1=pd.read_excel("C:/Users/Suryansh/Desktop/Data Science Project/Visualization/SuperStoreUS/SuperStoreUS_2015.xlsx",sheetname="Orders")

#getting an idea of the data:
df1.head()
#getting an idea of the structure of the data:
stru_info=df1.dtypes
#getting an idea of summary of the data:
summary_info=df1.describe()
#checking for missing values:
df1.columns[df1.isnull().any()]

#separating the numerical values from the categorical values
num_val=df1[['Discount','UnitPrice','ShippingCost','ProductBaseMargin','Profit','QuantityOrderedNew','Sales']]
#imputing the missing values

#checking for Na values again:
num_val.isnull().sum()

#exploring the different graphs that can be made using plotly
import plotly
plotly.tools.set_credentials_file(username='Maverick2024', api_key='KtXgSJVmQotHXCUl889W')
import plotly.plotly as py
import plotly.graph_objs as go

#bar-plots for regional sales:
data=df1[["Region","Sales"]]
regionSales=data.groupby('Region').agg('sum')
regionSales['Region']=regionSales.index.values

#bar-plot
Data=[go.Bar(x=regionSales['Region'],y=regionSales['Sales'])]
py.plot(Data,filename='Regional-Sales')
#horizontal bar-plot:
Data=[go.Bar(x=regionSales['Sales'],y=regionSales['Region'],orientation='h')]
py.plot(Data,filename='Regional-Sales')

#regional-profits
data=df1[["Region","Profit"]]
regionProfit=data.groupby('Region').agg('sum')
regionProfit['Region']=regionProfit.index.values
#stacked bar-plot:
trace1=go.Bar(x=regionProfit['Region'],y=regionProfit['Profit'],name='Profit')
trace2=go.Bar(x=regionSales['Region'],y=regionSales['Sales'],name='Sales')
Data=[trace1,trace2]
layout=go.Layout(barmode='stack')
fig=go.Figure(data=Data,layout=layout)
py.plot(fig,filename='Stacked-Bar-Plot')
#side-by-side bar-plot:
Data=[trace2,trace1]
layout=go.Layout(barmode='group')
fig=go.Figure(data=Data,layout=layout)
py.plot(fig,filename='grouped-bar')

#histogram:
Data=[go.Histogram(x=df1['ShipMode'])]
py.plot(Data,filename='Histogram')

#piechart:
trace=go.Pie(labels=regionSales['Region'],values=regionSales['Sales'])
py.plot([trace],filename='Sales-by-Region-Piechart')

#boxplot:
Data=[go.Box(y=df1['Sales'])]
py.plot(Data,filename='Sales-box-plot')

#monthly-Sales
data=df1[["OrderDate","Sales"]]
data['Month']=data['OrderDate'].apply(lambda x:x.strftime('%B'))
monthlySales=data.groupby('Month').agg('sum')
monthlySales['Month']=monthlySales.index.values

#scatterplot:
Data=[go.Scatter(x=monthlySales['Month'],y=monthlySales['Sales'],mode='markers')]
py.plot(Data,filename='MonthlySales-Scatter')
#lineplot:
Data=[go.Scatter(x=monthlySales['Month'],y=monthlySales['Sales'],mode='lines')]
py.plot(Data,filename='MonthlySales-LinePlot')
#areaplot:
Data=[go.Scatter(x=monthlySales['Month'],y=monthlySales['Sales'],fill='tozeroy')]
py.plot(Data,filename='MonthlySales-AreaPlot')

#monthly-profits:
data=df1[["OrderDate","Profit"]]
data['Month']=data['OrderDate'].apply(lambda x:x.strftime('%B'))
monthlyProfit=data.groupby('Month').agg('sum')
monthlyProfit['Month']=monthlyProfit.index.values
#stacked area plot:
trace1=go.Scatter(x=monthlySales['Month'],y=monthlySales['Sales'],fill='tozeroy',name='Sales')
trace2=go.Scatter(x=monthlyProfit['Month'],y=monthlyProfit['Profit'],fill='tonexty',name='Profit')
Data=[trace1,trace2]
py.plot(Data,filename='Stacked-Area-Plot')
#dual-line-plot
trace1=go.Scatter(x=monthlySales['Month'],y=monthlySales['Sales'],mode='lines',name='Sales')
trace2=go.Scatter(x=monthlyProfit['Month'],y=monthlyProfit['Profit'],mode='lines',name='Profit')
Data=[trace1,trace2]
py.plot(Data,filename='Dual-line-plot')

#dual-axis plot:
trace1=go.Scatter(x=monthlySales['Month'],y=monthlySales['Sales'],name='Sales')
trace2=go.Scatter(x=monthlyProfit['Month'],y=monthlyProfit['Profit'],name='Profit')
Data=[trace1,trace2]
layout=go.Layout(
    title='Double Y Axis Example',
    yaxis=dict(
        title='Sales'
    ),
    yaxis2=dict(title='Profit',
        titlefont=dict(
            color='rgb(148, 103, 189)'
    ),
     tickfont=dict(color='rgb(148,103,189)'),
     overlaying='y',
     side='right'
     )
    )
fig=go.Figure(data=Data,layout=layout)
plot_url=py.plot(fig,filename='multiple-axes')

#bubble plot:
import numpy as np
data=df1[["OrderDate","ShipDate"]]
days=data["ShipDate"]-data["OrderDate"]
data["days"]=(data["days"]/np.timedelta64(1,'D')).astype(int)
Data=[go.Scatter(x=data["ShipDate"],y=data["OrderDate"],mode='markers',marker=dict(size=data["days"],))]
py.plot(Data,filename='BubbleChart')

#heatmap using matplotlib and seaborn:
import matplotlib.pyplot as plt
import seaborn as sns
corrmat=num_val.corr()
#setting up the matplotlib figure
f, ax=plt.subplots(figsize=(12,9))
#draw the heatmap using seaborn
sns.heatmap(corrmat,vmax=.8,square=True)

#word cloud:
data=df1[["ProductSubCategory"]]
data["Count"]=1
freq=data.groupby('ProductSubCategory').agg('sum')
freq['ProductSubCategory']=freq.index.values
from wordcloud import WordCloud
wordcloud=WordCloud()
wordcloud.generate_from_frequencies(frequencies=freq["Count"])
plt.figure()
plt.imshow(wordcloud,interpolation="bilinear")
plt.axis("off")
plt.show()

#deleting all the created objects after the session is over:
del([fig,layout,stru_info,trace,trace1,trace2,df1,data,Data,regionSales,regionProfit,summary_info,num_val,corrmat,freq,wordcloud,days])

