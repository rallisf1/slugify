DROP FUNCTION IF EXISTS `SLUGIFY`;

DELIMITER //

CREATE FUNCTION `SLUGIFY`(dirty_string VARCHAR(255))
	RETURNS VARCHAR(255)
	DETERMINISTIC
BEGIN
	
	DECLARE allowed_chars, new_string VARCHAR(255);
	DECLARE found_equiv, current_char VARCHAR(5);
	DECLARE counter, string_length, temp_table_rows INT(10);
	DECLARE is_allowed TINYINT(1);
	
	SET new_string = '';
    -- Replace all spaces and dots with a dash
	SET dirty_string = LOWER(REPLACE(TRIM(REPLACE(dirty_string, '.', '-')), ' ', '-'));
    -- Set the allowed characters to be any letter from the english alphabet, numbers or hyphens
	SET allowed_chars = 'abcdefghijklmnopqrstuvwxyz0123456789-';
	SET string_length = CHAR_LENGTH(dirty_string);
	SET counter = 1;
    
    -- Crete a temporary table that will hold the characters replacement map
	CREATE TEMPORARY TABLE IF NOT EXISTS slug_temp_table (bul_letter VARCHAR(5) NOT NULL, eng_equiv VARCHAR(5) NOT NULL);
	
    -- Comment out the following block if you don't want to use the character table
    SELECT COUNT(*) INTO temp_table_rows FROM slug_temp_table;
	IF temp_table_rows = 0 THEN
		INSERT INTO slug_temp_table (bul_letter, eng_equiv) VALUES 
            -- Replace the following line with the your preferred character map
            ('α', 'a'), ('β', 'b'), ('γ', 'g'), ('δ', 'd'), ('ε', 'e'), ('ζ', 'z'), ('η', 'h'), ('θ', '8'), ('ι', 'i'), ('κ', 'k'), ('λ', 'l'), ('μ', 'm'), ('ν', 'n'),  ('ξ', '3'), ('ο', 'o'), ('π', 'p'), ('ρ', 'r'), ('σ', 's'), ('τ', 't'), ('υ', 'y'), ('φ', 'f'), ('χ', 'x'), ('ψ', 'ps'), ('ω', 'w')
        ;
	END IF;
    
	
	-- Make the actual replacements character by character
	WHILE counter <= string_length DO
		SET current_char = SUBSTRING(dirty_string, counter, 1);
		SET is_allowed = LOCATE(current_char, allowed_chars);
		IF is_allowed > 0 THEN
			SET new_string = CONCAT(new_string, current_char);
		ELSE
			SELECT slug_temp_table.eng_equiv INTO found_equiv FROM slug_temp_table WHERE slug_temp_table.bul_letter = current_char;
			IF CHAR_LENGTH(found_equiv) > 0 THEN
				SET new_string = CONCAT(new_string, found_equiv);
			END IF;
		END IF;
		
		SET found_equiv = '';
		SET counter = counter + 1;
	END WHILE;
    
        -- Replace the double hyphens with a single hyphen
	WHILE LOCATE('--', new_string) > 0 DO
		SET new_string = REPLACE(new_string, '--', '-');
	END WHILE;
	
    
	RETURN new_string;

END
//

DELIMITER ;
