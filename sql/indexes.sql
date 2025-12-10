-- Boost finding albums by artists
CREATE INDEX idx_albums_artist ON Albums(artist_id);

-- Boost treck filtration by album
CREATE INDEX idx_tracks_album ON Tracks(album_id);

-- Boost search by countries
CREATE INDEX idx_artists_country ON Artists(country);

-- Boost search by genre
CREATE INDEX idx_track_genres_genre ON Track_Genres(genre_id);