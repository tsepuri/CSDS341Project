use CSDS341_Project;
DROP PROCEDURE IF EXISTS onLoad;
DELIMITER // 
Create Procedure onLoad (IN param_company VARCHAR(20), IN param_date varchar(20), IN param_year INT, IN param_quarter INT, IN param_username VARCHAR(20))
BEGIN

DECLARE TRADING_DAYS_PER_WEEK INT DEFAULT 5;
DECLARE TRADING_DAYS_PER_MONTH INT DEFAULT 21;
DECLARE TRADING_DAYS_PER_6MONTHS INT DEFAULT 126;
DECLARE TRADING_DAYS_PER_YEAR INT DEFAULT 252;

/*retrieves the description associated with a particular company*/
SELECT description
FROM Company
WHERE ticker = param_company;

/*retrieves the price of a particular stock, adjusted for stock splits and dividends*/
SELECT price/priceAdjustment as adjustedPrice
FROM Securities
WHERE date = DATE(param_date) AND ticker = param_company;
    
/*calculates a stock's beta.
Beta is a measure of a volatility and it's calculated with four steps.
First, calculate the daily price changes over 1 year. 
This is done in the first subquery.
Second, calculate the mean price changes for the entire market over 1 year.
This is done in the second subquery.
Third, calculate the covariance of the single-stock and market price changes
Fourth, divide the covariance by the variance of the market price changes
Steps three and four are done in the third subquery*/
WITH
StockReturns AS
	(Select  S1.date, (S1.price/S1.priceAdjustment - S2.price/S2.priceAdjustment) / (S2.price/S2.priceAdjustment) AS stockReturns
	FROM Securities as S1 INNER JOIN Securities as S2 ON S1.date = (S2.date+1) 
	WHERE S1.date BETWEEN DATE_ADD(param_date, INTERVAL -52 WEEK) AND param_date
	AND S2.date BETWEEN DATE_ADD(param_date, INTERVAL -52 WEEK) AND param_date
	AND S1.ticker=param_company AND S2.ticker=param_company) ,
MarketReturns AS
	(SELECT S1.date , AVG((S1.price/S1.priceAdjustment - S2.price/S2.priceAdjustment) / (S2.price/S2.priceAdjustment)) AS marketReturns
	FROM Securities as S1 INNER JOIN Securities as S2 ON S1.date = (S2.date+1)  AND  S1.ticker=S2.ticker
	WHERE S1.date BETWEEN DATE_ADD(param_date, INTERVAL -52 WEEK) AND param_date
	AND S2.date BETWEEN DATE_ADD(param_date, INTERVAL -52 WEEK) AND param_date
	GROUP BY S1.date)
SELECT( SUM( stockReturns *marketReturns ) - SUM( stockReturns ) * SUM( marketReturns ) / COUNT( stockReturns ) ) /( COUNT( stockReturns ) - 1 )
	/(STDDEV_SAMP(marketReturns) * STDDEV_SAMP(marketReturns)) as beta FROM  StockReturns NATURAL JOIN MarketReturns;
    
/*Calculates a firm's market capitalization
Market Capitalization = Current Price * Shares Outstanding
Note that shares outstanding is disclosed quarterly while price history is available daily*/
SELECT (price * shares_outstanding) as marketcap
FROM Financials, Securities
WHERE Financials.ticker = param_company AND date = param_date AND Securities.ticker = param_company AND year = param_year AND quarter = param_quarter;


/*Calculates a firm's EV/EBITDA ratio, which is often used for valuation
EV/EBITDA = (price * shares outstanding + total liabilities) / the total EBITDA of the most recent four quarters
Note that shares outstanding, EBITDA, and liabilities are disclosed quarterly while price history is available daily*/
SELECT (price * shares_outstanding + total_liabilities) / Trailing12.ebitda as ebitda
FROM
    Financials, Securities,
    (SELECT SUM(ebitda) AS ebitda FROM Financials 
    WHERE ticker = param_company AND ((year = param_year AND quarter <= param_quarter) OR (year = param_year - 1 AND quarter > param_quarter))) AS Trailing12
WHERE Financials.ticker = param_company AND date = param_date AND Securities.ticker = param_company AND year = param_year AND quarter = param_quarter;

 
/*Calculates a firm's Price/Earnings ratio, which is often used for valuation
Price/Earnings = (price * shares outstanding) / the total net income of the most recent four quarters
Note that shares outstanding and net income are disclosed quarterly while price history is available daily*/
SELECT price*shares_outstanding/Trailing12.net_income as price_to_earnings
FROM
    Financials, Securities,
    (SELECT SUM(net_income) AS net_income FROM Financials 
    WHERE ticker = param_company AND ((year = param_year AND quarter <= param_quarter) OR (year = param_year - 1 AND quarter > param_quarter))) AS Trailing12
WHERE Financials.ticker = param_company AND date = param_date AND Securities.ticker = param_company AND year = param_year AND quarter = param_quarter;


/*Calculates a firm's Price/Book ratio, which is often used for valuation
Price/Book = (price * shares outstanding) / total equity
Note that shares outstanding and total equity are disclosed quarterly while price history is available daily*/
SELECT price*shares_outstanding/total_equity as price_to_book
FROM Financials, 
	(SELECT price FROM Securities
	WHERE ticker=param_company AND date=DATE(param_date)) AS PriceData
WHERE ticker=param_company AND (year=param_year AND quarter=param_quarter);



/*Calculates a firm's Price/Sales ratio, which is often used for valuation
Price/Sales = (price * shares outstanding) / total revenue of the most recent four quarters
Note that shares outstanding and total revenue are disclosed quarterly while price history is available daily*/
SELECT price*shares_outstanding/Trailing12.total_revenue as price_to_sales
FROM
    Financials, Securities,
    (SELECT SUM(total_revenue) AS total_revenue FROM Financials 
    WHERE ticker = param_company AND ((year = param_year AND quarter <= param_quarter) OR (year = param_year - 1 AND quarter > param_quarter))) AS Trailing12
WHERE Financials.ticker = param_company AND date = param_date AND Securities.ticker = param_company AND year = param_year AND quarter = param_quarter;



/*Calculates a stock's SMA20
SMA20=The average price over the past 20 trading days, adjusted for dividends and stock splits*/  
SELECT avg(T.split_adjusted_price) as moving_avg_20 FROM 
	(SELECT date, price / PriceAdjustment as split_adjusted_price FROM Securities 
    WHERE ticker = param_company AND date <= Date(param_date) ORDER BY date DESC LIMIT 20) as T;


/*Calculates a stock's SMA100
SMA100=The average price over the past 100 trading days, adjusted for dividends and stock splits*/  
SELECT avg(T.split_adjusted_price) as moving_avg_100 FROM
	(SELECT date, price / PriceAdjustment as split_adjusted_price FROM Securities 
    WHERE ticker = param_company AND date <= Date(param_date) ORDER BY date DESC LIMIT 100) as T;


/*Calculates a stock's SMA200
SMA100=The average price over the past 200 trading days, adjusted for dividends and stock splits*/  
SELECT avg(T.split_adjusted_price) as moving_avg_200 FROM 
	(SELECT date, price / PriceAdjustment as split_adjusted_price FROM Securities 
    WHERE ticker = param_company AND date <= Date(param_date) ORDER BY date DESC LIMIT 200) as T;


/*Finds a stock's minimum price over the past 52 weeks, adjusted for dividends and stock splits*/
SELECT min(T.split_adjusted_price) as min_52_week FROM
	(SELECT date, price / PriceAdjustment as split_adjusted_price FROM Securities 
    WHERE ticker = param_company AND date BETWEEN DATE_ADD(param_date, INTERVAL -52 WEEK) AND param_date) as T;
 
 
/*Finds a stock's maximum price over the past 52 weeks, adjusted for dividends and stock splits*/
SELECT max(T.split_adjusted_price) as max_52_week FROM
	(SELECT date, price / PriceAdjustment as split_adjusted_price FROM Securities 
    WHERE ticker = param_company AND date BETWEEN DATE_ADD(param_date, INTERVAL -52 WEEK) AND param_date) as T;

/*retrieves all of the available data on price history and volume for a particular company*/
SELECT  price/priceAdjustment as price_and_volume, date, volume FROM Securities
WHERE ticker=param_company;



/*calculates a stock's 1 week return, adjusted for dividends and stock splits
Note that this value currently isn't outputted onto the website, but we intend to incorporate it in the future*/
SELECT ((Securities.price/Securities.priceAdjustment)-PastPrice.adjustedPrice)/PastPrice.adjustedPrice as return_1_week FROM Securities, 
	(SELECT price / priceAdjustment as adjustedPrice, ticker, date FROM Securities 
    WHERE ticker = param_company AND date <= Date(param_date) ORDER BY date DESC LIMIT TRADING_DAYS_PER_WEEK, 1) as PastPrice
WHERE Securities.ticker = PastPrice.ticker AND Securities.date = param_date;


/*calculates a stock's 1 month return, adjusted for dividends and stock splits
Note that this value currently isn't outputted onto the website, but we intend to incorporate it in the future*/
SELECT ((Securities.price/Securities.priceAdjustment)-PastPrice.adjustedPrice)/PastPrice.adjustedPrice as return_1_moth FROM Securities, 
	(SELECT price / priceAdjustment as adjustedPrice, ticker, date FROM Securities 
    WHERE ticker = param_company AND date <= Date(param_date) ORDER BY date DESC LIMIT TRADING_DAYS_PER_MONTH, 1) as PastPrice
WHERE Securities.ticker = PastPrice.ticker AND Securities.date = param_date;

/*calculates a stock's 6 month return, adjusted for dividends and stock splits
Note that this value currently isn't outputted onto the website, but we intend to incorporate it in the future*/
SELECT ((Securities.price/Securities.priceAdjustment)-PastPrice.adjustedPrice)/PastPrice.adjustedPrice as return_6_month FROM Securities, 
	(SELECT price / priceAdjustment as adjustedPrice, ticker, date FROM Securities 
    WHERE ticker = param_company AND date <= Date(param_date) ORDER BY date DESC LIMIT TRADING_DAYS_PER_6MONTHS, 1) as PastPrice
WHERE Securities.ticker = PastPrice.ticker AND Securities.date = param_date;

/*calculates a stock's 1 year return, adjusted for dividends and stock splits
Note that this value currently isn't outputted onto the website, but we intend to incorporate it in the future*/
SELECT ((Securities.price/Securities.priceAdjustment)-PastPrice.adjustedPrice)/PastPrice.adjustedPrice as return_1_year FROM Securities, 
	(SELECT price / priceAdjustment as adjustedPrice, ticker, date FROM Securities 
    WHERE ticker = param_company AND date <= Date(param_date) ORDER BY date DESC LIMIT TRADING_DAYS_PER_YEAR, 1) as PastPrice
WHERE Securities.ticker = PastPrice.ticker AND Securities.date = param_date;

/*retrieve's the notes of a particular user for a particular stock*/
SELECT notes AS user_info, is_favorited FROM Watchlist WHERE username = param_username AND ticker = param_company;

/*lists a user's favorited stocks*/
SELECT ticker as favorited FROM Watchlist WHERE username = param_username AND is_favorited = 1;

/*gets info on all of particular company's executives*/
SELECT * FROM Executives WHERE ticker =param_company;

/*gets info on all of particular company's institutional shareholders*/
SELECT * FROM Institution WHERE ticker =param_company ORDER BY position_value DESC LIMIT 10;

/*gets info on all of particular company's insider trading activity*/
SELECT * FROM Insider_trading WHERE ticker =param_company ORDER BY transaction_date DESC LIMIT 100;

/*gets info on all of particular company's quarterly financial results*/
SELECT *, net_income/shares_outstanding AS eps FROM Financials WHERE ticker =param_company;

/*gets a list of tickers and company names, which is used to create the dynamic search bar*/
SELECT ticker as searchBarInfo, name FROM Company;

END 
// DELIMITER ;