DELIMITER $$
DROP TRIGGER IF EXISTS Atleast_5_char$$

CREATE TRIGGER Atleast_5_char
BEFORE INSERT ON User_info FOR EACH ROW
BEGIN
DECLARE errorMessage VARCHAR(255);
SET errorMessage = "Credentials must be at least 5 characters";
IF CHAR_LENGTH(new.username)<5 OR CHAR_LENGTH(new.password)<5 THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
END IF;

END$$    


DROP TRIGGER IF EXISTS Max_favorites$$
CREATE TRIGGER Max_favorites
BEFORE INSERT ON Watchlist FOR EACH ROW
BEGIN
DECLARE currentFavoriteCount INT;
DECLARE errorMessage VARCHAR(255);
SET errorMessage = "No more than ten companies allowed on Watchlist";
SELECT COUNT(*) INTO currentFavoriteCount FROM Watchlist WHERE new.username=Watchlist.username AND Watchlist.is_favorited=1;
IF currentFavoriteCount >=10 THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
END IF;

END$$    


DROP TRIGGER IF EXISTS No_negatives$$
CREATE TRIGGER No_negatives
BEFORE INSERT ON Securities FOR EACH ROW
BEGIN
IF new.price < 0 OR new.volume < 0 THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
END IF;

END$$    

DROP TRIGGER IF EXISTS No_negatives2$$
CREATE TRIGGER No_negatives2
BEFORE INSERT ON Financials FOR EACH ROW
BEGIN
IF total_assets< 0 OR total_equity< 0 OR total_liabilities< 0 OR total_revenue< 0 OR shares_outstanding< 0 THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
END IF;

END$$    



DELIMITER ;