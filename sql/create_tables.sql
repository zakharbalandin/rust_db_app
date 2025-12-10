-- Таблица исполнителей
CREATE TABLE Artists (
    artist_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE CHECK (LENGTH(name) > 2),
    country VARCHAR(50),
    formed_year INTEGER CHECK (formed_year > 1900 AND formed_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    disbanded_year INTEGER CHECK (disbanded_year IS NULL OR disbanded_year > formed_year)
);

-- Таблица жанров
CREATE TABLE Genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE CHECK (name ~ '^[A-Za-z ]+$')
);

-- Таблица лейблов
CREATE TABLE Labels (
    label_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(50),
    founded_year INTEGER CHECK (founded_year > 1900)
);

-- Таблица альбомов
CREATE TABLE Albums (
    album_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL CHECK (LENGTH(title) > 0),
    release_date DATE NOT NULL CHECK (release_date <= CURRENT_DATE),
    artist_id INTEGER NOT NULL REFERENCES Artists(artist_id) ON DELETE CASCADE,
    label_id INTEGER REFERENCES Labels(label_id) ON DELETE SET NULL,
    total_duration INTERVAL DEFAULT '0' -- Вычисляется триггером
);

-- Таблица треков
CREATE TABLE Tracks (
    track_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL CHECK (LENGTH(title) > 0),
    duration INTERVAL NOT NULL CHECK (duration > '00:00:00' AND duration <= '01:00:00'),
    album_id INTEGER NOT NULL REFERENCES Albums(album_id) ON DELETE CASCADE,
    artist_id INTEGER REFERENCES Artists(artist_id) ON DELETE SET NULL
);

-- Связь многие-ко-многим: исполнители и жанры
CREATE TABLE Artist_Genres (
    artist_id INTEGER NOT NULL REFERENCES Artists(artist_id) ON DELETE CASCADE,
    genre_id INTEGER NOT NULL REFERENCES Genres(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (artist_id, genre_id)
);

-- Связь многие-ко-многим: треки и жанры
CREATE TABLE Track_Genres (
    track_id INTEGER NOT NULL REFERENCES Tracks(track_id) ON DELETE CASCADE,
    genre_id INTEGER NOT NULL REFERENCES Genres(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (track_id, genre_id)
);