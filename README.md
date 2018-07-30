# est-loan-balance
Estimate the current loan balance on a given property.

## Data
### Deed and Mortgage Data
Loan balance data on each property.
* Source: First American Title (Private)

### Historical Interest Rates
Historical Interest rates for 30 year fixed mortgage. 
* Source: Federal Reserve (Public)

## Formula: 
* B=Balance 
* L=Original Loan Amt 
* c=monthly interest rate(rate/12) 
* n=number months

B = L[(1 + c)n - (1 + c)p]/[(1 + c)n - 1]

loanBalance <- loanTotal * (1 - 1 / ((1 + monthlyrate) ^ monthsremaing)) / monthlyrate
