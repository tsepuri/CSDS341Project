DELIMITER // 
Create Procedure favorite(param_username VARCHAR(20), param_ticker VARCHAR(6))
BEGIN

/*This procedure toggles a particular stock as either favorited or unfavorited
If the value is -1, it is interpreted as unfavorited
If the value is 1, it is interpreted as favorited
To avoid cluttering the database with blank information, 
the procedure concludes by scrubbing the table for tuples lacking customization*/
INSERT INTO Watchlist(username, ticker, is_favorited, notes)
VALUES (param_username, param_ticker, 1, "")
ON DUPLICATE KEY UPDATE
	is_favorited     = is_favorited*-1;
DELETE FROM Watchlist WHERE ticker=param_ticker AND username=param_username AND notes="" AND is_favorited=-1;

END 
// DELIMITER ;