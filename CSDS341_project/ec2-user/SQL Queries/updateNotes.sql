use CSDS341_Project;
DROP PROCEDURE IF EXISTS updateNotes;
DELIMITER // 
Create Procedure updateNotes(param_username VARCHAR(20), param_ticker VARCHAR(6), param_notes VARCHAR(1000))
BEGIN

/*Updates a user's notes on a particular stock*/
INSERT INTO Watchlist(username, ticker, is_favorited, notes)
VALUES (param_username, param_ticker, -1, param_notes)
ON DUPLICATE KEY UPDATE
	notes  =  param_notes;
DELETE FROM Watchlist WHERE ticker=param_ticker AND username=param_username AND notes="" AND is_favorited=-1;

END 
// DELIMITER ;
