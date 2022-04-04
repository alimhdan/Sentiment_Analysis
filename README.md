# Random Forest for Sentiment Analysis from Twitter Crawling Data
Random Forest for sentiment analysis from Twitter Crawling with sentence specification "Kenaikan Harga BBM"

# Introduction
This project started from the issue of increased fuel prices in early April in Indonesia. Many people complain about this. So, I decided to make this project to research how the public sentiment regarding this issue.

# Result 
I used the data from crawling data on Twitter with the sentence specification is "kenaikan harga bbm". From crawling data on Twitter, collected 1000 rows of data (tweets). After collecting data, I must to preprocessing this data to get clear data before used in Sentiment Analysis. In this project, I divided the data into proportions of 70% of train data and 30% of test data.

# Data Preparation
![BBM NAIK WORDCLOUD](https://user-images.githubusercontent.com/102334577/161466576-2f1c6a62-e505-43d8-8165-7d2993c30061.png)

From wordcloud we can see that the words often appear are words with a big size. We can see that one of the words are often appearing is "Gaji", so we can make a hypothesis that the public may be worried or asked about their "Gaji"(salary)?. Here are the top 10 words that often appear on tweets with the specification sentence "kenaikan harga bbm":

![image](https://user-images.githubusercontent.com/102334577/161640205-b218eacd-2ca3-4814-a284-0b374a8d7f04.png)


![sentiment proportion](https://user-images.githubusercontent.com/102334577/161467256-406ce677-5349-48c9-bc80-6fe640c2995b.png)

The picture above is a picture of sentiment score from crawling twitter data with sentence specification "kenaikan harga bbm". We can see that the dominant public response is positive with a proportion 60.1%. While a negative proportion is 39.9%.

    Negatif Positif 
     0.399   0.601

# Random Forest 
In this project, I divided the dataset with the proportion of 70% for train data and 30% for test data. Here are the results of the performance Random Forest Classification:

    Confusion Matrix and Statistics

         testingY
    pred      Negatif Positif
     Negatif      91      12
     Positif      11     186
                                          
               Accuracy : 0.9233          
                 95% CI : (0.8872, 0.9508)
    No Information Rate : 0.66            
    P-Value [Acc > NIR] : <2e-16          
                                          
                  Kappa : 0.8296          
                                          
    Mcnemar's Test P-Value : 1               
                                          
            Sensitivity : 0.8922          
            Specificity : 0.9394          
         Pos Pred Value : 0.8835          
         Neg Pred Value : 0.9442          
             Prevalence : 0.3400          
         Detection Rate : 0.3033          
     Detection Prevalence : 0.3433          
      Balanced Accuracy : 0.9158          
                                          
       'Positive' Class : Negatif         
   
 We can see that classification accuracy is 0.9233 or 92.33% so the accuracy is well. Sensitivity and Specificity are more than 0.8 is a high value so we can conclude that the performance is very well.
   
Based on the result, we can conclude that the dominant sentiment in public is a positive sentiment with a proportion of 60.1%. The Random Forest Classification could work so well in classifying the sentiment on Twitter in this classification with an accuracy of 92.33%.
