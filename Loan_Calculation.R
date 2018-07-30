# Import Libraries
library(dplyr)
# Import Data
df.DataTree <- read.csv("~/Models/DataTree/Raw/06065.csv", sep="|", na.strings=c(""," ","NA", "\\N"), stringsAsFactors = FALSE, fill=TRUE, quote="", colClasses = "character")
df.InterestRates <- read.csv("~/Models/Annual 30 yr interest rate.csv")

# Extract residential properties
## Generate Property Type(SFR/Condo) (SFR=1004), (1004=Condo), (1009=PUD) 
df.DataTree$PropertType <- NA
lut <- c("1001" = "SFR", "1004" = "Condo", "1009" = "Condo", "1010" = "Condo")
df.DataTree$PropertyType <- lut[df.DataTree$StdLandUseCode]
df.DataTree <- filter(df.DataTree, PropertyType == "SFR" | PropertyType == "Condo")
rm(lut)

#Merge Interest Rate Data
##Obtain merge id - "year"
df.DataTree$Year <- as.numeric(substr(df.DataTree$CurrSaleRecordingDate, 1, 4))
df.DataTree <- left_join(df.DataTree,df.InterestRates, by = "Year")

#Est current loan balance
##Add first and second mortgage
df.DataTree$loanTotal<- as.numeric(df.DataTree$ConCurrMtg1LoanAmt) + as.numeric(df.DataTree$ConCurrMtg2LoanAmt)
#Obtain number of years owned
df.DataTree$yearsOwned <- 2019 - as.numeric(df.DataTree$Year)
#Replace missing ConCurrMtg1Term with year(ConCurrMth1DueDate) - year(CurrSaleRecordingDate)
df.DataTree$ConCurrMtg1Term[is.na(df.DataTree$ConCurrMtg1Term)] <- (2019 - as.numeric(substr(df.DataTree$CurrSaleRecordingDate, 1,4)))  
#Obtain number of months remaining on mortgage
df.DataTree$monthsremaining <- as.numeric(df.DataTree$ConCurrMtg1Term) - (df.DataTree$yearsOwned * 12)
df.DataTree$monthsremaining[df.DataTree$monthsremaining < 0] <- 0
#Obtain monthly mortgage rate & payment
df.DataTree$monthlyrate <- df.DataTree$Average.Rate / 12
df.DataTree$monthlyPayment <- df.DataTree$loanTotal * df.DataTree$monthlyrate / (1 - 1 / (1 + df.DataTree$monthlyrate) ^ as.numeric(df.DataTree$ConCurrMtg1Term))
#Caluclate Outstanding Balance
df.DataTree$loanBalanceCurrent <- df.DataTree$monthlyPayment * (1 - 1 / (1 + df.DataTree$monthlyrate) ^ df.DataTree$monthsremaining) / df.DataTree$monthlyrate

#df$loanBalance <- df$loanTotal * (1 - 1 / ((1 + df$monthlyrate) ^ df$monthsremaing)) / df$monthlyrate