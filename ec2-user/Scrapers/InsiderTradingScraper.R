
library('rvest')
library('tidyverse')
library('parallel')
library('foreach')
library("doFuture")



#remember to change backlashes for other Operating Systems
wd <-  getwd()
formContainer <-paste(wd, "/insiderTradingTransactions/",sep="")
dir.create(formContainer)
errorContainer <- paste(wd, "/errors/",sep="")
unlink(errorContainer, recursive=TRUE)
dir.create(errorContainer)


scrapeCIK <- function(cik, pageCount){
  link <- paste("https://www.sec.gov/cgi-bin/own-disp?action=getissuer&CIK=",cik,"&type=&dateb=&owner=include&start=",as.character((pageCount-1)*80), sep="")
  webpage <- read_html(link, options = "RECOVER")
  returnedObj <- tryCatch(
    {html_node(webpage, "#transaction-report") %>% html_table(header = TRUE) %>% mutate_all(as.character)},
    error = {function(err){return(-1)}}
  )
  return(returnedObj)
}

scrapeAllPages <- function(cik){
  lastFrame <- scrapeCIK(cik,1)
  nextFrame <- scrapeCIK(cik,2)
  i <- 2
  while(is.data.frame(nextFrame) && nrow(nextFrame) > 1){
   lastFrame <- bind_rows(lastFrame,nextFrame)
   i <- 1+i
   nextFrame <- scrapeCIK(cik,i)
  }
  return(lastFrame)
}

scrapeAllCIKSTry <- function(cik){
  insiderTransactions <- scrapeAllPages(cik) 
  if(nrow(insiderTransactions)>1)
    write.csv(insiderTransactions, paste(formContainer,cik,".csv",sep=""))
  else stop("insider transactions <2")
}

scrapeAllCIKS <- function(cikList){
  for(cik in cikList){
    tryCatch(scrapeAllCIKSTry(cik),
             error= function(err){cat(c(cik,", \"",as.character(err), sep =""), file = paste(errorContainer, Sys.getpid(),".csv", sep=""), append = TRUE)})
}}



#executable
while(TRUE){
mapping <-  data.frame(read.table(file = "~/Downloads/ticker.txt", sep = '\t',header = FALSE, colClasses=c('character')))
tickers <-  data.frame(read.table(file = "~/Downloads/constituents.csv", sep = ',',header = FALSE, colClasses=c('character')))
tickers$V1 <-  tolower(tickers$V1)
cikList <- inner_join(tickers, mapping)$V2
completeCIKList <- list.files(formContainer)
completeCIKListNoFormat <- sapply(completeCIKList, FUN = function(x){x <- substr(x,1,str_length(x)-4)},USE.NAMES=FALSE )
incompleteCIKList  <- cikList[is.na(pmatch(cikList,completeCIKListNoFormat))]
  tryCatch({scrapeAllCIKS(incompleteCIKList)}, 
          error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}



