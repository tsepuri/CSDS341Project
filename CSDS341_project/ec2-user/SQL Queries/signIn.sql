use CSDS341_Project;
DROP PROCEDURE IF EXISTS signIn;
DELIMITER // 
Create Procedure signIn (IN param_username VARCHAR(20), IN param_password VARCHAR(20))
BEGIN
/*retrieves a particular user's password hash and salt*/
SELECT password FROM User_info WHERE username = param_username;
END 
// DELIMITER ;