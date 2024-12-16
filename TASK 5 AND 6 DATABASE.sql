
-- Task 3: Create a view summarizing concert revenue
-- This view calculates the total tickets sold and revenue generated for each artist's concert.
-- It includes a JOIN across multiple tables, uses GROUP BY to aggregate data, 
-- and applies a HAVING clause to filter concerts with revenue greater than 900.


CREATE VIEW ConcertRevenueSummary AS
SELECT 
    c.concert_date, 
    a.artist_name, 
    COUNT(t.ticket_id) AS total_tickets, 
    ROUND(SUM(t.price), 2) AS total_revenue
FROM 
    artists AS ar
JOIN 
    concerts_artists AS ca ON ar.artist_id = ca.artist_id
JOIN 
    concerts AS co ON ca.concert_id = co.concert_id
JOIN 
    tickets AS ti ON co.concert_id = ti.concert_id
GROUP BY 
    c.concert_date, a.artist_name
HAVING 
    total_revenue > 900;

-- Task 4: Create BEFORE and AFTER triggers
-- The BEFORE trigger ensures ticket prices are not below the minimum value (10).
-- The AFTER trigger logs each ticket purchase into the ticket_logs table.

-- BEFORE Trigger: Enforce minimum ticket price
CREATE TRIGGER BeforeTicketInsert
BEFORE INSERT ON tickets
FOR EACH ROW
SET NEW.price = GREATEST(NEW.price, 10);

-- AFTER Trigger: Log ticket purchase
CREATE TRIGGER AfterTicketInsert
AFTER INSERT ON tickets
FOR EACH ROW
INSERT INTO ticket_logs (ticket_id, message, log_date)
VALUES (NEW.ticket_id, 'Ticket purchased.', NOW());
Task 3-4.sql
Displaying Task 3-4.sql.




TASK 5: Writing a function named get_occupied_seats that takes an integer parameter concert representing a concert ID. It counts the number of tickets sold for that specific concert from the concert_tickets table and returns the total count as an integer, indicating the number of occupied seats for the concert. 

DELIMITER $$

CREATE FUNCTION get_occupied_seats(concert INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_seats INT;
    SELECT COUNT(*) INTO total_seats
    FROM concert_tickets
    WHERE concert_id = concert;
    RETURN total_seats;
END $$

DELIMITER ;

TASK 6 : checking if song_id is associated with a given album_id. if not, it updates the association and adjusts the song's release date to match the album's release date if the song's date is later.
DELIMITER $$

CREATE PROCEDURE check_and_update_song_album(
    IN song_id INT,
    IN album_id INT
)
BEGIN
    DECLARE album_release_date DATE;
    DECLARE song_release_date DATE;

    
    IF NOT EXISTS (
        SELECT 1 
        FROM songs 
        WHERE song_id = song_id AND album_id = album_id
    ) THEN
        
        UPDATE songs
        SET album_id = album_id
        WHERE song_id = song_id;
    END IF;

    
    SELECT release_date INTO album_release_date 
    FROM albums 
    WHERE album_id = album_id;

    SELECT release_date INTO song_release_date 
    FROM songs 
    WHERE song_id = song_id;

    IF song_release_date > album_release_date THEN
        UPDATE songs
        SET release_date = album_release_date
        WHERE song_id = song_id;
    END IF;
END $$

DELIMITER ;

