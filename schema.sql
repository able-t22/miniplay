-- =========================================================
-- Spotify Mini Clone - Database Schema + Seed Data
-- Run this whole file in phpMyAdmin (Import) or via CLI:
--   mysql -u root -p < schema.sql
-- =========================================================

DROP DATABASE IF EXISTS spotify_clone;
CREATE DATABASE spotify_clone CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE spotify_clone;

-- ---------------------------------------------------------
-- TABLE: Users
-- ---------------------------------------------------------
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------
-- TABLE: Artists
-- ---------------------------------------------------------
CREATE TABLE Artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(100) NOT NULL,
    bio TEXT,
    image_url VARCHAR(255)
);

-- ---------------------------------------------------------
-- TABLE: Albums
-- ---------------------------------------------------------
CREATE TABLE Albums (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    album_title VARCHAR(150) NOT NULL,
    artist_id INT NOT NULL,
    release_year YEAR,
    cover_url VARCHAR(255),
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- TABLE: Songs
-- ---------------------------------------------------------
CREATE TABLE Songs (
    song_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    artist_id INT NOT NULL,
    album_id INT,
    duration_sec INT NOT NULL,
    file_url VARCHAR(255),
    release_year YEAR,
    play_count INT DEFAULT 0,
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id) ON DELETE CASCADE,
    FOREIGN KEY (album_id) REFERENCES Albums(album_id) ON DELETE SET NULL
);

-- ---------------------------------------------------------
-- TABLE: Genres
-- ---------------------------------------------------------
CREATE TABLE Genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE
);

-- ---------------------------------------------------------
-- TABLE: SongGenre (junction, many-to-many)
-- ---------------------------------------------------------
CREATE TABLE SongGenre (
    song_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (song_id, genre_id),
    FOREIGN KEY (song_id) REFERENCES Songs(song_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- TABLE: Playlists
-- ---------------------------------------------------------
CREATE TABLE Playlists (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    playlist_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- TABLE: PlaylistSongs (junction)
-- ---------------------------------------------------------
CREATE TABLE PlaylistSongs (
    playlist_id INT NOT NULL,
    song_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES Songs(song_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- TABLE: Recommendations
-- ---------------------------------------------------------
CREATE TABLE Recommendations (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    song_id INT NOT NULL,
    score DECIMAL(6,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES Songs(song_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- TABLE: RecentlyPlayed
-- ---------------------------------------------------------
CREATE TABLE RecentlyPlayed (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    song_id INT NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES Songs(song_id) ON DELETE CASCADE
);

-- =========================================================
-- SEED DATA
-- =========================================================

-- ---------------- Genres (10) ----------------
INSERT INTO Genres (genre_name) VALUES
('Pop'),('Rock'),('Hip-Hop'),('Jazz'),('Classical'),
('Electronic'),('R&B'),('Country'),('Metal'),('Indie');

-- ---------------- Artists (15) ----------------
INSERT INTO Artists (artist_name, bio, image_url) VALUES
('Luna Ray','Dreamy pop vocalist known for sunset anthems.','https://picsum.photos/seed/artist1/300'),
('The Midnight Echoes','Alt-rock four-piece with raw guitar energy.','https://picsum.photos/seed/artist2/300'),
('MC Zephyr','Fast-flow hip-hop artist from the city underground.','https://picsum.photos/seed/artist3/300'),
('Sarah Blume','Smoky-voiced jazz singer and pianist.','https://picsum.photos/seed/artist4/300'),
('The Chamber Ensemble','Contemporary classical chamber orchestra.','https://picsum.photos/seed/artist5/300'),
('Pulse Grid','Electronic duo blending synths and glitch beats.','https://picsum.photos/seed/artist6/300'),
('Velvet Skyline','Smooth R&B trio with soulful harmonies.','https://picsum.photos/seed/artist7/300'),
('Dusty Trail Band','Country-rock band singing about open roads.','https://picsum.photos/seed/artist8/300'),
('Iron Vultures','Heavy metal band known for thunderous riffs.','https://picsum.photos/seed/artist9/300'),
('Paper Moths','Lo-fi indie project with whispery vocals.','https://picsum.photos/seed/artist10/300'),
('Crimson Harbor','Coastal rock band with anthemic choruses.','https://picsum.photos/seed/artist11/300'),
('Nova Bloom','Upbeat pop artist with electro-pop influences.','https://picsum.photos/seed/artist12/300'),
('Echo Static','Ambient electronic producer.','https://picsum.photos/seed/artist13/300'),
('The Southern Draw','Traditional country storytellers.','https://picsum.photos/seed/artist14/300'),
('Night Owl Collective','Late-night jazz fusion group.','https://picsum.photos/seed/artist15/300');

-- ---------------- Albums (16) ----------------
INSERT INTO Albums (album_title, artist_id, release_year, cover_url) VALUES
('Golden Hour', 1, 2021, 'https://picsum.photos/seed/album1/300'),
('Neon Dreams', 1, 2023, 'https://picsum.photos/seed/album2/300'),
('Static Bloom', 2, 2019, 'https://picsum.photos/seed/album3/300'),
('Concrete Verses', 3, 2022, 'https://picsum.photos/seed/album4/300'),
('Blue Room Sessions', 4, 2020, 'https://picsum.photos/seed/album5/300'),
('Symphony No. 4', 5, 2018, 'https://picsum.photos/seed/album6/300'),
('Circuit Dreams', 6, 2022, 'https://picsum.photos/seed/album7/300'),
('Midnight Hours', 7, 2021, 'https://picsum.photos/seed/album8/300'),
('Open Road', 8, 2020, 'https://picsum.photos/seed/album9/300'),
('Steel Requiem', 9, 2019, 'https://picsum.photos/seed/album10/300'),
('Quiet Static', 10, 2023, 'https://picsum.photos/seed/album11/300'),
('Tidewater', 11, 2020, 'https://picsum.photos/seed/album12/300'),
('Firelight', 12, 2022, 'https://picsum.photos/seed/album13/300'),
('Waveforms', 13, 2021, 'https://picsum.photos/seed/album14/300'),
('Backroad Ballads', 14, 2019, 'https://picsum.photos/seed/album15/300'),
('After Hours', 15, 2020, 'https://picsum.photos/seed/album16/300');

-- ---------------- Songs (50) ----------------
-- (title, artist_id, album_id, duration_sec, file_url, release_year, play_count)
INSERT INTO Songs (title, artist_id, album_id, duration_sec, file_url, release_year, play_count) VALUES
('Golden Hour', 1, 1, 210, 'https://example.com/audio/1.mp3', 2021, 4200),
('Sunset Drive', 1, 1, 198, 'https://example.com/audio/2.mp3', 2021, 3100),
('Paper Hearts', 1, 1, 205, 'https://example.com/audio/3.mp3', 2021, 2650),
('Skyline Kiss', 1, 1, 220, 'https://example.com/audio/4.mp3', 2021, 1980),
('Neon Dreams', 1, 2, 215, 'https://example.com/audio/5.mp3', 2023, 5300),
('Electric Feeling', 1, 2, 190, 'https://example.com/audio/6.mp3', 2023, 4700),
('Midnight Glow', 1, 2, 230, 'https://example.com/audio/7.mp3', 2023, 2200),
('Static Bloom', 2, 3, 245, 'https://example.com/audio/8.mp3', 2019, 3800),
('Broken Radio', 2, 3, 210, 'https://example.com/audio/9.mp3', 2019, 2900),
('Ashes and Amps', 2, 3, 260, 'https://example.com/audio/10.mp3', 2019, 2100),
('Concrete Verses', 3, 4, 195, 'https://example.com/audio/11.mp3', 2022, 6100),
('City Lights Anthem', 3, 4, 200, 'https://example.com/audio/12.mp3', 2022, 5400),
('Rhythm and Rust', 3, 4, 188, 'https://example.com/audio/13.mp3', 2022, 3300),
('Blue Room', 4, 5, 250, 'https://example.com/audio/14.mp3', 2020, 1500),
('Smoke and Velvet', 4, 5, 240, 'https://example.com/audio/15.mp3', 2020, 1250),
('Late Night Sax', 4, 5, 275, 'https://example.com/audio/16.mp3', 2020, 980),
('Symphony No. 4: Allegro', 5, 6, 320, 'https://example.com/audio/17.mp3', 2018, 700),
('Symphony No. 4: Andante', 5, 6, 340, 'https://example.com/audio/18.mp3', 2018, 610),
('Symphony No. 4: Finale', 5, 6, 300, 'https://example.com/audio/19.mp3', 2018, 890),
('Circuit Dreams', 6, 7, 205, 'https://example.com/audio/20.mp3', 2022, 4400),
('Binary Sunset', 6, 7, 215, 'https://example.com/audio/21.mp3', 2022, 3600),
('Pulse Grid', 6, 7, 198, 'https://example.com/audio/22.mp3', 2022, 4100),
('Digital Rain', 6, 7, 225, 'https://example.com/audio/23.mp3', 2022, 3000),
('Midnight Hours', 7, 8, 210, 'https://example.com/audio/24.mp3', 2021, 3900),
('Slow Burn', 7, 8, 230, 'https://example.com/audio/25.mp3', 2021, 3200),
('Velvet Skyline', 7, 8, 200, 'https://example.com/audio/26.mp3', 2021, 2800),
('Open Road', 8, 9, 215, 'https://example.com/audio/27.mp3', 2020, 2600),
('Dusty Boots', 8, 9, 205, 'https://example.com/audio/28.mp3', 2020, 2100),
('Whiskey and Wildflowers', 8, 9, 240, 'https://example.com/audio/29.mp3', 2020, 1800),
('Steel Requiem', 9, 10, 265, 'https://example.com/audio/30.mp3', 2019, 3500),
('Iron Storm', 9, 10, 250, 'https://example.com/audio/31.mp3', 2019, 3100),
('Vultures Rising', 9, 10, 275, 'https://example.com/audio/32.mp3', 2019, 2400),
('Quiet Static', 10, 11, 190, 'https://example.com/audio/33.mp3', 2023, 1700),
('Paper Moths', 10, 11, 200, 'https://example.com/audio/34.mp3', 2023, 1450),
('Faded Polaroid', 10, 11, 210, 'https://example.com/audio/35.mp3', 2023, 1200),
('Tidewater', 11, 12, 220, 'https://example.com/audio/36.mp3', 2020, 2700),
('Crimson Harbor', 11, 12, 205, 'https://example.com/audio/37.mp3', 2020, 2300),
('Salt and Stone', 11, 12, 235, 'https://example.com/audio/38.mp3', 2020, 1900),
('Firelight', 12, 13, 198, 'https://example.com/audio/39.mp3', 2022, 4600),
('Bloom', 12, 13, 205, 'https://example.com/audio/40.mp3', 2022, 3900),
('Chasing Stars', 12, 13, 215, 'https://example.com/audio/41.mp3', 2022, 3400),
('Waveforms', 13, 14, 240, 'https://example.com/audio/42.mp3', 2021, 2200),
('Echo Static', 13, 14, 225, 'https://example.com/audio/43.mp3', 2021, 1900),
('Analog Heart', 13, 14, 210, 'https://example.com/audio/44.mp3', 2021, 1600),
('Backroad Ballads', 14, 15, 220, 'https://example.com/audio/45.mp3', 2019, 2000),
('Southern Draw', 14, 15, 205, 'https://example.com/audio/46.mp3', 2019, 1750),
('Porch Light', 14, 15, 230, 'https://example.com/audio/47.mp3', 2019, 1400),
('After Hours', 15, 16, 260, 'https://example.com/audio/48.mp3', 2020, 1550),
('Night Owl', 15, 16, 245, 'https://example.com/audio/49.mp3', 2020, 1300),
('Last Call', 15, 16, 270, 'https://example.com/audio/50.mp3', 2020, 1100);

-- ---------------- SongGenre (primary genre for each song) ----------------
INSERT INTO SongGenre (song_id, genre_id) VALUES
(1,1),(2,1),(3,1),(4,1),(5,1),(6,1),(7,1),
(8,2),(9,2),(10,2),
(11,3),(12,3),(13,3),
(14,4),(15,4),(16,4),
(17,5),(18,5),(19,5),
(20,6),(21,6),(22,6),(23,6),
(24,7),(25,7),(26,7),
(27,8),(28,8),(29,8),
(30,9),(31,9),(32,9),
(33,10),(34,10),(35,10),
(36,2),(37,2),(38,2),
(39,1),(40,1),(41,1),
(42,6),(43,6),(44,6),
(45,8),(46,8),(47,8),
(48,4),(49,4),(50,4);

-- ---------------- SongGenre (a few secondary/crossover genre tags) ----------------
INSERT INTO SongGenre (song_id, genre_id) VALUES
(3,10),   -- Paper Hearts -> also Indie
(6,6),    -- Electric Feeling -> also Electronic
(16,7),   -- Late Night Sax -> also R&B
(26,4),   -- Velvet Skyline -> also Jazz
(34,2),   -- Paper Moths -> also Rock
(41,6);   -- Chasing Stars -> also Electronic

-- ---------------- Sample User (for testing) ----------------
-- NOTE: this is a placeholder hash. After importing, register a real user
-- via POST /api/auth.php?action=register (this also lets you log in normally).
-- Or just use user_id = 1 directly in the other API calls without logging in.
INSERT INTO Users (username, email, password) VALUES
('demo_user', 'demo@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- ---------------- Sample Playlist ----------------
INSERT INTO Playlists (user_id, playlist_name) VALUES
(1, 'My Favorites');

INSERT INTO PlaylistSongs (playlist_id, song_id) VALUES
(1,1),(1,5),(1,11),(1,20),(1,39);

-- ---------------- Sample Recently Played (so recommendations have data to work with) ----------------
INSERT INTO RecentlyPlayed (user_id, song_id, played_at) VALUES
(1,1, NOW() - INTERVAL 5 DAY),
(1,5, NOW() - INTERVAL 4 DAY),
(1,6, NOW() - INTERVAL 3 DAY),
(1,39, NOW() - INTERVAL 2 DAY),
(1,40, NOW() - INTERVAL 1 DAY),
(1,20, NOW());
