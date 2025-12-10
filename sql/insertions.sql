INSERT INTO Artists (name, country, formed_year, disbanded_year) VALUES
('The Beatles', 'UK', 1960, 1970),
('Queen', 'UK', 1970, 1991),
('Nirvana', 'USA', 1987, 1994),
('Pink Floyd', 'UK', 1965, 2014),
('Led Zeppelin', 'UK', 1968, 1980),
('Radiohead', 'UK', 1985, 2018),
('Metallica', 'USA', 1981, NULL),
('Daft Punk', 'France', 1993, 2021),
('The Rolling Stones', 'UK', 1962, NULL),
('AC/DC', 'Australia', 1973, NULL);

INSERT INTO Genres (name) VALUES
('Rock'),
('Pop'),
('Jazz'),
('Electronic'),
('Metal'),
('Alternative'),
('Blues'),
('Classical');

INSERT INTO Labels (name, country, founded_year) VALUES
('EMI', 'UK', 1931),
('Capitol', 'USA', 1942),
('DGC', 'USA', 1990),
('Harvest', 'UK', 1969),
('Atlantic', 'USA', 1947),
('Parlophone', 'UK', 1923),
('Elektra', 'USA', 1950),
('Columbia', 'USA', 1988);

INSERT INTO Albums (title, release_date, artist_id, label_id) VALUES
('Abbey Road', '1969-09-26', 1, 1),
('A Night at the Opera', '1975-11-21', 2, 1),
('Nevermind', '1991-09-24', 3, 3),
('The Wall', '1979-11-30', 4, 4),
('Led Zeppelin IV', '1971-11-08', 5, 5),
('OK Computer', '1997-06-16', 6, 6),
('Master of Puppets', '1986-03-03', 7, 7),
('Random Access Memories', '2013-05-17', 8, 8),
('Exile on Main St.', '1972-05-12', 9, 1),
('Back in Black', '1980-07-25', 10, 5);

INSERT INTO Tracks (title, duration, album_id, artist_id) VALUES
('Come Together', '00:04:20', 1, 1),
('Bohemian Rhapsody', '00:05:55', 2, 2),
('Smells Like Teen Spirit', '00:05:01', 3, 3),
('Another Brick in the Wall', '00:03:59', 4, 4),
('Stairway to Heaven', '00:08:02', 5, 5),
('Paranoid Android', '00:06:23', 6, 6),
('Master of Puppets', '00:08:35', 7, 7),
('Get Lucky', '00:06:09', 8, 8),
('Tumbling Dice', '00:03:44', 9, 9),
('You Shook Me All Night Long', '00:03:30', 10, 10);

INSERT INTO Artist_Genres (artist_id, genre_id) VALUES
(1, 1), (1, 2),  -- The Beatles: Rock, Pop
(2, 1), (2, 2),  -- Queen: Rock, Pop
(3, 1), (3, 6),  -- Nirvana: Rock, Alternative
(4, 1), (4, 6),  -- Pink Floyd: Rock, Alternative
(5, 1), (5, 5),  -- Led Zeppelin: Rock, Metal
(6, 1), (6, 6),  -- Radiohead: Rock, Alternative
(7, 1), (7, 5),  -- Metallica: Rock, Metal
(8, 4), (8, 1),  -- Daft Punk: Electronic, Rock
(9, 1), (9, 7),  -- The Rolling Stones: Rock, Blues
(10, 1), (10, 5); -- AC/DC: Rock, Metal

INSERT INTO Track_Genres (track_id, genre_id) VALUES
(1, 1),  -- Come Together: Rock
(2, 1),  -- Bohemian Rhapsody: Rock
(3, 1),  -- Smells Like Teen Spirit: Rock
(4, 1),  -- Another Brick in the Wall: Rock
(5, 1),  -- Stairway to Heaven: Rock
(6, 6),  -- Paranoid Android: Alternative
(7, 5),  -- Master of Puppets: Metal
(8, 4),  -- Get Lucky: Electronic
(9, 1),  -- Tumbling Dice: Rock
(10, 1); -- You Shook Me All Night Long: Rock