-- 1
CREATE OR REPLACE FUNCTION genre_track_percentage(genre_name TEXT)
RETURNS NUMERIC(5,2) AS $$
DECLARE
    total_tracks BIGINT;
    genre_tracks BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_tracks FROM Tracks;
    SELECT COUNT(*) INTO genre_tracks
    FROM Track_Genres tg
    JOIN Genres g ON tg.genre_id = g.genre_id
    WHERE g.name ILIKE genre_name;
    
    RETURN (genre_tracks::NUMERIC / total_tracks * 100);
END;
$$ LANGUAGE plpgsql;
SELECT genre_track_percentage('Rock') AS rock_percentage;

-- 2
CREATE FUNCTION avg_artist_track_duration(artist_name TEXT)
RETURNS INTERVAL AS $$
DECLARE
    result INTERVAL;
BEGIN
    SELECT AVG(t.duration) INTO result
    FROM Tracks t
    JOIN Artists a ON t.artist_id = a.artist_id
    WHERE a.name = artist_name;
    RETURN result;
END;
$$ LANGUAGE plpgsql;
SELECT avg_artist_track_duration('Queen') AS avg_duration;

-- 3
CREATE PROCEDURE add_genre_to_track(track_title TEXT, genre_name TEXT)
LANGUAGE plpgsql AS $$
DECLARE
    tid INT;
    gid INT;
BEGIN
    SELECT track_id INTO tid FROM Tracks WHERE title = track_title;
    SELECT genre_id INTO gid FROM Genres WHERE name = genre_name;
    INSERT INTO Track_Genres (track_id, genre_id) VALUES (tid, gid);
END;
$$;
CALL add_genre_to_track('Bohemian Rhapsody', 'Pop');

-- 4
CREATE PROCEDURE delete_artist(artist_name TEXT)
LANGUAGE plpgsql AS $$
DECLARE
    aid INT;
BEGIN
    SELECT artist_id INTO aid FROM Artists WHERE name = artist_name;
    DELETE FROM Artists WHERE artist_id = aid;
END;
$$;
CALL delete_artist('Nirvana');

-- 5
CREATE VIEW album_summary AS
SELECT 
    a.title AS album_title,
    ar.name AS artist_name,
    a.release_date,
    a.total_duration,
    COUNT(t.track_id) AS track_count
FROM Albums a
JOIN Artists ar ON a.artist_id = ar.artist_id
LEFT JOIN Tracks t ON a.album_id = t.album_id
GROUP BY a.album_id, a.title, ar.name, a.release_date, a.total_duration
ORDER BY a.release_date DESC;