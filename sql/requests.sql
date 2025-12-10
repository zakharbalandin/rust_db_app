-- 1 Not disbanded bands
SELECT name FROM Artists WHERE disbanded_year IS NULL;

-- 2 Albums dropped after 2000-01-01
SELECT title, release_date FROM Albums WHERE release_date > '2000-01-01';

-- 3 Max durable title in album
SELECT album_id, MAX(duration) FROM Tracks GROUP BY album_id;

-- 4 Titles ammount by genre
SELECT g.name, COUNT(*) 
FROM Track_Genres tg
JOIN Genres g ON tg.genre_id = g.genre_id
GROUP BY g.name;

-- 5 album_artist_view
CREATE VIEW album_artist_view AS
SELECT a.title AS album, ar.name AS artist, a.release_date
FROM Albums a
JOIN Artists ar ON a.artist_id = ar.artist_id;

-- 6 Albums where country of artist and label are the same
SELECT a.title 
FROM Albums a
JOIN Artists ar ON a.artist_id = ar.artist_id
JOIN Labels l ON a.label_id = l.label_id
WHERE ar.country = l.country;

-- 7 Replace UK with United Kingdom
UPDATE Artists SET country = 'United Kingdom' WHERE country = 'UK';
-- Undo :D
UPDATE Artists SET country = 'UK' WHERE country = 'United Kingdom';

-- 8 Delete Abbey Road from albums
DELETE FROM Albums WHERE title = 'Abbey Road';

-- 9 Tracks that have word like in the title
SELECT title FROM Tracks WHERE title ILIKE '%like%';

-- 10 Ammount of tracks for every label
SELECT l.name, COUNT(a.album_id) AS album_count
FROM Labels l
LEFT JOIN Albums a ON l.label_id = a.label_id
GROUP BY l.name;

-- 11 Artists with 3+ albums in one genre
SELECT ar.name
FROM Artists ar
JOIN Artist_Genres ag ON ar.artist_id = ag.artist_id
GROUP BY ar.artist_id, ar.name
HAVING COUNT(DISTINCT ag.genre_id) >= 3;

-- 12 Tracks with duration between 3 and 5 min
SELECT title FROM Tracks 
WHERE duration BETWEEN '00:03:00' AND '00:05:00';

-- 13 labels with albums of artists from USA
SELECT DISTINCT l.name 
FROM Labels l
JOIN Albums a ON l.label_id = a.label_id
JOIN Artists ar ON a.artist_id = ar.artist_id
WHERE ar.country = 'USA';

-- 14 Albums with out tracks
SELECT title FROM Albums 
WHERE album_id NOT IN (SELECT DISTINCT album_id FROM Tracks);

-- 15 Trigger usage
SELECT title, total_duration FROM Albums;

-- 16 3 most productive years
SELECT EXTRACT(YEAR FROM release_date) AS year, COUNT(*) 
FROM Albums
GROUP BY year
ORDER BY COUNT(*) DESC
LIMIT 3;

-- 17 Albums without labels
SELECT title, release_date
FROM Albums
WHERE label_id IS NULL
ORDER BY release_date DESC;

-- 18 Avg durability of tracks ordered by years
SELECT 
    EXTRACT(YEAR FROM a.release_date) AS release_year,
    AVG(t.duration) AS avg_track_duration
FROM Albums a
JOIN Tracks t ON a.album_id = t.album_id
GROUP BY release_year
ORDER BY release_year DESC;

-- 19 Artists with albums from different decades
SELECT 
    ar.name,
    COUNT(DISTINCT (EXTRACT(DECADE FROM a.release_date))) AS decades
FROM Artists ar
JOIN Albums a ON ar.artist_id = a.artist_id
GROUP BY ar.artist_id
HAVING COUNT(DISTINCT (EXTRACT(DECADE FROM a.release_date))) > 1;

-- 20 3 albums with bigger ammount of rock tracks
WITH rock_albums AS (
    SELECT 
        a.album_id,
        a.title,
        COUNT(t.track_id) AS track_count
    FROM Albums a
    JOIN Tracks t ON a.album_id = t.album_id
    JOIN Track_Genres tg ON t.track_id = tg.track_id
    JOIN Genres g ON tg.genre_id = g.genre_id
    WHERE g.name = 'Rock'
    GROUP BY a.album_id
)
SELECT title, track_count
FROM rock_albums
ORDER BY track_count DESC
LIMIT 3;