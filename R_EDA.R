#loading the function to read in excel files
library(readxl)
#Note: Set the folder where you have stored the dataset as the working directory for this session.
#reading in the data:
df1<-read_xlsx("SuperStoreUS_2015.xlsx",sheet="Orders")
#Getting an idea of the data given to us:
head(df1)
#getting the structure of the data given to us:
str(df1)
#getting the summary for the data to identify if there are any NA values present
summary(df1)

#separating the numerical and categorical variables:
num_val<-subset(df1,select = c(Discount,UnitPrice,ShippingCost,ProductBaseMargin,Profit,QuantityOrderedNew,Sales))
num_val<-as.data.frame(num_val)
#loading in the package for knn imputation:
library(DMwR)
#performing knn imputation
num_val<-knnImputation(num_val,k=2)
ProductBaseMargin<-subset(num_val,select=c(ProductBaseMargin))
#removing the original column with missing values from the df1 column
df1<-subset(df1,select=-c(ProductBaseMargin))
#adding in the new imputed column
df1<-cbind(df1,ProductBaseMargin)
df1<-as.data.frame(df1)
#checking for missing values
summary(df1)

#exploring the different graphs that can be made using plotly
library(plotly)
library(dplyr)

data<-subset(df1,select=c(Region,Sales))
regionSales<- data%>% 
  group_by(Region)%>%
  summarise(Sales=sum(Sales))

#vertical bar plot:
plot_ly(regionSales,x=~Region,y=~Sales,type="bar")

#horizontal bar plot:
plot_ly(regionSales,x=~Sales,y=~Region,type="bar",orientation='h')

#stacked bar plot:
data<-subset(df1,select=c(Region,Profit))
regionalProfit<-data%>%
  group_by(Region)%>%
  summarise(Profit=sum(Profit))
data<-merge(regionalProfit,regionSales,by='Region')

plot_ly(data,x=~Region,y=~Profit,type='bar',name='Profit')%>%
  add_trace(y=~Sales,name='Sales')%>%
  layout(yaxis=list(title='Amount'),barmode='stack')

#side by side bar plot:
plot_ly(data,x=~Region,y=~Sales,type='bar',name='Sales',marker=list(color='rgb(55,83, 109)'))%>%
  add_trace(y=~Profit,name='Profit',marker=list(color='rgb(26,118,255)'))%>%
  layout(title='Regional Profit and Sales',yaxis=list(title='Amount'))

#histogram
plot_ly(df1,x=~ShipMode,type = "histogram")

#piechart
plot_ly(regionSales,labels=~Region,values=~Sales,type = "pie")%>%
  layout(title='Sales by Region',
         xaxis=list(showgrid=FALSE,zeroline=FALSE,showticklabels=FALSE),
         yaxis=list(showgrid=FALSE,zeroline=FALSE,showticklabels=FALSE))

#boxplot
plot_ly(df1,y=~Sales,type="box")

#OrderDate vs Sales
data<-subset(df1,select=c(OrderDate,Sales))
MonthlySales<-data%>%
  mutate(month=format(OrderDate,"%m"))%>%
  group_by(month)%>%
  summarise(Sales=sum(Sales))
#scatter plot
plot_ly(MonthlySales,x=~month,y=~Sales,type='scatter')

#line plot
plot_ly(MonthlySales,x=~month,y=~Sales,type='scatter',mode='lines')

#area plot
plot_ly(MonthlySales,x=~month,y=~Sales,type='scatter',mode='lines',fill='tozeroy')

#stacked area plot
data<-subset(df1,select=c(OrderDate,Sales,Profit))
MonthlySales<-data%>%
  mutate(month=format(OrderDate,"%m"))%>%
  group_by(month)%>%
  summarise(Sales=sum(Sales))

MonthlyProfit<-data%>%
  mutate(month=format(OrderDate,"%m"))%>%
  group_by(month)%>%
  summarise(Profit=sum(Profit))
data<-merge(MonthlyProfit,MonthlySales,by='month')

plot_ly(data,x=~month,y=~Sales,name='Sales',type='scatter',mode='none',fill='tozeroy',fillcolor='#F5FF8D')%>%
  add_trace(y=~Profit,name='profit',fillcolor='50CB86')%>%
  layout(title='Monthly Sales and profit')

#dual line plot:
plot_ly(data,x=~month,y=~Sales,name='Sales',type='scatter',mode='lines')%>%
  add_trace(y=~Profit,name='Profit',type='scatter',mode='lines')%>%
  layout(yaxis=list(title='Amount'))

#dual axis plot:
ay<-list(tickfont = list(color = "red"),
         overlaying = "y",
         side = "right",
         title = "Sales")
plot_ly()%>%
  add_lines(x=~data$month,y=~data$Profit,name='Profit')%>%
  add_lines(x=~data$month,y=~data$Sales,name='Sales')%>%
  layout(title="Double Y Axis",yaxis2=ay,xaxis=list(title="Month"))

#bubble map:
data<-subset(df1,select=c(OrderDate,ShipDate))
data$days<-as.Date(as.character(data$ShipDate))-as.Date(as.character(data$OrderDate))
plot_ly(data,x=~ShipDate,y=~OrderDate,type='scatter',mode='markers',marker=list(size=~days,opacity=0.5))%>%
  layout(title='Difference b/w ShippingDate and OrderDate',
         xaxis=list(showgrid=FALSE),
         yaxis=list(showgrid=FALSE))

#treemap:
#loading the required package:
library(treemap)
data<-subset(df1,select=c(Region,StateorProvince,Sales))
pipe<-data%>%
  group_by(Region,StateorProvince)%>%
  summarise(Sales=sum(Sales))
treemap(pipe,index=c("Region","StateorProvince"),
        vSize="Sales",
        type="index",border.col = c("black","yellow"),border.lwds = c(7,2),title = "Sales by State Or Province")

#heatmap:
#loading in the required packages:
library(ggplot2)
library(reshape2)
qplot(x=Var1,y=Var2,data=melt(cor(num_val)),fill=value,geom="tile")

#wordcloud:
#note befor printing the wordcloud make sure to expand your Graph viewer size so that you can fit the whole wordcloud in it
library(wordcloud)
data<-subset(df1,select=c('ProductSubCategory'))
data$Count<-rep(1,nrow(data))
freq<-data%>%
  group_by(ProductSubCategory)%>%
  summarise(Count=sum(Count))
#making the wordcloud:
wordcloud(freq$ProductSubCategory,freq$Count,min.freq =50)

#deleting all the created objects after the session is over:
rm(data,df1,freq,MonthlyProfit,MonthlySales,num_val,pipe,ProductBaseMargin,regionalProfit,regionSales,ay)