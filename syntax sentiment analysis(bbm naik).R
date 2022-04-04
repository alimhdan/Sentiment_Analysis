# Import Library
library(rtweet)
library(dplyr)
library(tidyr)
library(NLP)
library(tm)
library(stringr)
library(ROAuth)
library(twitteR)
library(caret)
library(devtools)
install_github("nurandi/katadasaR")
library(katadasaR)
library(tau)
library(parallel)
library(twitteR)
library(RCurl)
library(ggplot2)
library(SnowballC)
library(RColorBrewer)
library(wordcloud)
library(tokenizers)

setwd("E:/UNDIP/smt 6/data mining/praktikum")
token <- create_token(
  consumer_key  = "vPoDCU9994ZZUsEHFf5p8QrBV",
  consumer_secret = "36r659jBumNUURjefZIBLc2Kz1kV3ozd22hOabFgWna8zNkvY8",
  access_token = "313826433-eEv2aWHNeF0krqHkDc2BwWYhvgdLKPd80zI31vTX",
  access_secret = "jv45289JTKP0lTkKjyZNShP7SCmtCvkeVVktt0C0Yk5gb")

crawling <- search_tweets("harga bbm naik",n=1000,lang = "id", include_rts = TRUE)

View(crawling)

#save sebagai CSV
write_as_csv(crawling,"E:/My Works/bbm.csv", prepend_ids = TRUE, na="", fileEncoding= "UTF-8")

#Memasukkan file ke dalam Corpus
corpusdata <- Corpus(VectorSource(crawling$text))
View(corpusdata)

#Mengubah seluruh huruf kapital menjadi huruf kecil
data_casefolding <- tm_map(corpusdata, content_transformer(tolower))
inspect(data_casefolding[1:10])

#Data Cleansing
## Remove URL
removeURL <- function(x)gsub("http[^[:space:]]*","",x)
data_URL <- tm_map(data_casefolding, content_transformer(removeURL))
inspect(data_URL[1:10])

##Remove Mention
remove.mention <- function(x)gsub("@\\S+","",x)
data_mention <- tm_map(data_URL, remove.mention)
inspect(data_mention[1:10])

##Remove hastag
remove.hastag <- function(x)gsub("#\\S+","",x)
data_hastag <- tm_map(data_mention, remove.hastag)
inspect(data_hastag[1:10])

##Remove NL
remove.NL <- function(x)gsub("\n","",x)
data_NL <- tm_map(data_hastag, remove.NL)
inspect(data_NL[1:10])

##Replace Comma
replace.comma <- function(x)gsub(",","",x)
data_comma <- tm_map(data_NL, replace.comma)
inspect(data_comma[1:10])

##remove colon
remove.colon <- function(x)gsub(":","",x)
data_colon <- tm_map(data_comma, remove.colon)
inspect(data_colon[1:10])

##remove semicolon
remove.semicolon <- function(x)gsub(";","",x)
data_semicolon <- tm_map(data_colon, remove.semicolon)
inspect(data_semicolon[1:10])

#remove Punctuation
data_punctuation <- tm_map(data_semicolon, content_transformer(removePunctuation))
inspect(data_punctuation[1:10])

#cleaning number
data_number <- tm_map(data_punctuation, content_transformer(removeNumbers))
inspect(data_number[1:10])

#remove emoticon (\u12414)
removeEmoticon <- function(x){gsub("[^\x01-\x7F]", "", x)}
data_emoticon <- tm_map(data_number, content_transformer(removeEmoticon))
inspect(data_emoticon[1:10])

#stopword
stopwordID <- "E:/UNDIP/smt 6/data mining/praktikum/stopwords.txt"
cStopwordID<-readLines(stopwordID)
data_stopword <- tm_map(data_emoticon, removeWords, cStopwordID)
inspect(data_stopword[1:10])

#remove strip whitespace
data_strip<-tm_map(data_stopword,stripWhitespace)
inspect(data_strip[1:10])

#menyimpan data bersih
databersih=data.frame(text=unlist(sapply(data_strip, `[`)), stringsAsFactors=F)
write_as_csv(databersih,"E:/My Works/bbm_clear.csv", prepend_ids = TRUE, na="", fileEncoding= "UTF-8")



#Sentiment analysis
#memnaggil data
datasentimen=read.delim("E:/My Works/bbm_clear.csv",header = T, sep = ",")
View(datasentimen)

#kamus sentimen
positif <- scan("E:/My Works/positive.txt",what="character",comment.char=";")
negatif <- scan("E:/My Works/negative.txt",what="character",comment.char=";")

#fungsi untuk menjalankan penilaian atau pembobotan tehadap kata-kata 
score.sentiment = function(kalimat2, kata.positif, kata.negatif, .progress='none')
{
  require(plyr)
  require(stringr)
  scores = laply(kalimat2, function(kalimat, kata.positif, kata.negatif) {
    kalimat = gsub('[[:punct:]]', '', kalimat)
    kalimat = gsub('[[:cntrl:]]', '', kalimat)
    kalimat = gsub('\\d+', '', kalimat)
    kalimat = tolower(kalimat)
    
    list.kata = str_split(kalimat, '\\s+')
    kata2 = unlist(list.kata)
    positif.matches = match(kata2, kata.positif)
    negatif.matches = match(kata2, kata.negatif)
    positif.matches = !is.na(positif.matches)
    negatif.matches = !is.na(negatif.matches)
    score = sum(positif.matches) - (sum(negatif.matches))
    return(score)
  }, kata.positif, kata.negatif, .progress=.progress )
  scores.df = data.frame(score=scores, text=kalimat2)
  return(scores.df)
}

library(dplyr)
library(plyr)
hasil=score.sentiment(datasentimen$text,positif,negatif)
View(hasil)

#konversi skor ke dlm sentimen
hasil$sentimen<- ifelse(hasil$score<0, "Negatif","Positif")
hasil$sentimen
View(hasil)

#mengubah urutan posisi kolom
data <- hasil[c(3,1,2)]
View(data)
write_as_csv(data, file = "E:/My Works/bbmfiks1.csv",prepend_ids = TRUE, na="", fileEncoding= "UTF-8")

data1=read.csv("E:/My Works/bbmfiks1.csv",header=T,sep=",")
View(data1)

#visualisasi sentimen
prop.table(table(data1$sentimen))
win.graph()
barplot(prop.table(table(data1$sentimen)),
        col = c("blue","green"),
        ylim = c(0, 1),
        main = "Class Distribution")

#Memasukkan file ke dalam Corpus
corpus1<- Corpus(VectorSource(data1$text))

#Data stemming
stem_text <- function(text,mc.cores=1)
{
  stem_string <- function(str)
  {str <- tokenize (x=str)
  str <- sapply(str, katadasaR)
  str <- paste(str, collapse = '')
  return(str)}
  x<- mclapply(X=text, FUN = stem_string,mc.cores=mc.cores)
}

data_stemming <- tm_map(corpus1, stem_text)
inspect(data_stemming[1:10])

#DocumentTermMatrix
tdm<-DocumentTermMatrix(data_stemming)
TDMmat<-as.matrix(tdm)
View(TDMmat)

#Pembobotan TF IDF
tfidf<-weightTfIdf(m=tdm,normalize=TRUE)
tfidfmat<-as.matrix(tfidf)
tfidfmat=as.data.frame(tfidfmat)
View(tfidfmat)


write_as_csv(tfidfmat,"E:/My Works/tfidf_bbm.csv", prepend_ids = TRUE, na="", fileEncoding= "UTF-8")

data_tfidf=read.csv("E:/My Works/tfidf_bbm.csv",header=T,sep=",")
View(data_tfidf)
dim(data_tfidf)

#Wordcloud
m<-sort(colSums(TDMmat),decreasing = TRUE)
Warna<-brewer.pal(6,"Dark2")
graylevels<-gray((m+10)/(max(m)+10))
d<-data.frame(word=names(m),freq=m)
head(d,10)
win.graph()
wc<-wordcloud(words=d$word,freq=d$freq,min.freq=1,max.word=500,random.order=F,colors=Warna,scale=c(4,0.3),rot.per=0.5)

#membagi data
#membentuk data training dan testing
set.seed(1000)
trainingX=data.frame(data_tfidf)[1:(0.70*nrow(data_tfidf)),]
testingX=data.frame(data_tfidf)[-(1:(0.70*nrow(data_tfidf))),]
sentimen=as.factor(data1$sentimen)
trainingY=data.frame(sentimen)[1:(0.70*nrow(data_tfidf)),]
testingY=data.frame(sentimen)[-(1:(0.70*nrow(data_tfidf))),]

#Random Forest
library(randomForest)
training=cbind(trainingY,trainingX)
random_forest <- randomForest(trainingY ~ .,data=training,type="class")
random_forest
win.graph()
plot(random_forest)
#Prediksi
pred = predict(random_forest, testingX,type = "class")
library(caret)
hasil=confusionMatrix(table(pred,testingY))
hasil
