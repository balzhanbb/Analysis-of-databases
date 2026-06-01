CREATE DATABASE StreamMaster;
USE StreamMaster;

-- 1. Users
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    birth_date DATE NOT NULL CHECK (birth_date >= '1900-01-01'),
    phone_number VARCHAR(20) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    account_status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (account_status IN ('active', 'suspended', 'deleted', 'banned'))
);

-- 2. Subscription_Plans
CREATE TABLE Subscription_Plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL UNIQUE,
    monthly_price DECIMAL(10,2) NOT NULL DEFAULT 0
        CHECK (monthly_price >= 0),
    audio_quality VARCHAR(20) NOT NULL
        CHECK (audio_quality IN ('low', 'medium', 'high', 'lossless')),
    ads_free BOOLEAN NOT NULL DEFAULT FALSE,
    offline_mode BOOLEAN NOT NULL DEFAULT FALSE
);


-- 3. User_Subscription
CREATE TABLE User_Subscription (
    subscription_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'expired', 'cancelled', 'paused')),

    CONSTRAINT chk_subscription_dates
        CHECK (end_date > start_date),

    CONSTRAINT fk_user_subscription_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id),

    CONSTRAINT fk_user_subscription_plan
        FOREIGN KEY (plan_id) REFERENCES Subscription_Plans(plan_id)
);


-- 4. Devices
CREATE TABLE Devices (
    device_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    device_type VARCHAR(30) NOT NULL
        CHECK (device_type IN ('mobile', 'desktop', 'tablet', 'web', 'smart_tv', 'speaker')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_devices_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


-- 5. Playlists
CREATE TABLE Playlists (
    playlist_id INT PRIMARY KEY,
    owner_user_id INT NOT NULL,
    playlist_name VARCHAR(100) NOT NULL CHECK (playlist_name <> ''),
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_playlists_owner
        FOREIGN KEY (owner_user_id) REFERENCES Users(user_id),

    CONSTRAINT unique_playlist_name_per_user
        UNIQUE (owner_user_id, playlist_name)
);


-- 6. Genres
CREATE TABLE Genres (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE CHECK (genre_name <> ''),
    description TEXT
);


-- 7. Albums
CREATE TABLE Albums (
    album_id INT PRIMARY KEY,
    album_title VARCHAR(150) NOT NULL CHECK (album_title <> ''),
    release_date DATE CHECK (
        release_date IS NULL 
        OR release_date >= '1900-01-01'
    )
);

-- 8. Artists
CREATE TABLE Artists (
    artist_id INT PRIMARY KEY,
    artist_name VARCHAR(150) NOT NULL CHECK (artist_name <> ''),
    country VARCHAR(100)
);


-- 9. Tracks
CREATE TABLE Tracks (
    track_id INT PRIMARY KEY,
    album_id INT,
    track_title VARCHAR(150) NOT NULL CHECK (track_title <> ''),
    duration_seconds INT NOT NULL CHECK (duration_seconds > 0),
    release_date DATE CHECK (
        release_date IS NULL 
        OR release_date >= '1900-01-01'
    ),
    language VARCHAR(50) NOT NULL DEFAULT 'Unknown'
        CHECK (language <> ''),

    CONSTRAINT fk_tracks_album
        FOREIGN KEY (album_id) REFERENCES Albums(album_id)
);


-- 10. Playlist_Collaborators
CREATE TABLE Playlist_Collaborators (
    playlist_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'editor'
        CHECK (role IN ('owner', 'editor', 'viewer')),
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_playlist_collaborators
        PRIMARY KEY (playlist_id, user_id),

    CONSTRAINT fk_playlist_collaborators_playlist
        FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id),

    CONSTRAINT fk_playlist_collaborators_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


-- 11. Playlist_Tracks
CREATE TABLE Playlist_Tracks (
    playlist_track_id INT PRIMARY KEY,
    playlist_id INT NOT NULL,
    track_id INT NOT NULL,
    added_by_user_id INT NOT NULL,
    added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    position_no INT NOT NULL CHECK (position_no > 0),

    CONSTRAINT fk_playlist_tracks_playlist
        FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id),

    CONSTRAINT fk_playlist_tracks_track
        FOREIGN KEY (track_id) REFERENCES Tracks(track_id),

    CONSTRAINT fk_playlist_tracks_added_by_user
        FOREIGN KEY (added_by_user_id) REFERENCES Users(user_id),

    CONSTRAINT unique_playlist_position
        UNIQUE (playlist_id, position_no)
);


-- 12. Listening_History
CREATE TABLE Listening_History (
    history_id BIGINT PRIMARY KEY,
    user_id INT NOT NULL,
    track_id INT NOT NULL,
    playlist_id INT DEFAULT NULL,
    subscription_id INT DEFAULT NULL,
    device_id INT DEFAULT NULL,
    played_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_seconds INT NOT NULL DEFAULT 0
        CHECK (completed_seconds >= 0),

    CONSTRAINT fk_listening_history_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id),

    CONSTRAINT fk_listening_history_track
        FOREIGN KEY (track_id) REFERENCES Tracks(track_id),

    CONSTRAINT fk_listening_history_playlist
        FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id),

    CONSTRAINT fk_listening_history_subscription
        FOREIGN KEY (subscription_id) REFERENCES User_Subscription(subscription_id),

    CONSTRAINT fk_listening_history_device
        FOREIGN KEY (device_id) REFERENCES Devices(device_id)
);


-- 13. Track_Genres
CREATE TABLE Track_Genres (
    track_id INT NOT NULL,
    genre_id INT NOT NULL,

    CONSTRAINT pk_track_genres
        PRIMARY KEY (track_id, genre_id),

    CONSTRAINT fk_track_genres_track
        FOREIGN KEY (track_id) REFERENCES Tracks(track_id),

    CONSTRAINT fk_track_genres_genre
        FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
);


-- 14. Album_Artists
CREATE TABLE Album_Artists (
    album_id INT NOT NULL,
    artist_id INT NOT NULL,

    CONSTRAINT pk_album_artists
        PRIMARY KEY (album_id, artist_id),

    CONSTRAINT fk_album_artists_album
        FOREIGN KEY (album_id) REFERENCES Albums(album_id),

    CONSTRAINT fk_album_artists_artist
        FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);


-- 15. Track_Artists
CREATE TABLE Track_Artists (
    track_id INT NOT NULL,
    artist_id INT NOT NULL,

    CONSTRAINT pk_track_artists
        PRIMARY KEY (track_id, artist_id),

    CONSTRAINT fk_track_artists_track
        FOREIGN KEY (track_id) REFERENCES Tracks(track_id),

    CONSTRAINT fk_track_artists_artist
        FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);

INSERT INTO Users
(user_id, username, email, password_hash, birth_date, phone_number, created_at, account_status)
VALUES
(1, 'peach_beach', 'madina_sarsembayeva@gmail.com', '47a7bbcb95a533e2b7d1019566441e10b797595d74cdcebc988d6c84d67b8745', '2006-03-12', '+77014598231', '2020-02-17 10:15:43', 'active'),
(2, 'dias.b', 'dias.bektas_02@mail.ru', '7d29d73105d636d04ca9fffcf979986d373ac874140bcb76ba86bc6975eae6a8', '2001-07-19', '+77753841692', '2021-06-03 14:20:11', 'active'),
(3, 'dopydop', 'adel.d.g@gmail.com', 'e2fc232b438bc0319da406cade44c25d44bd7a0572ad5c6d90a837c24f227f5b', '1998-11-04', '+77057824016', '2022-11-21 09:10:57', 'suspended'),
(4, 'NURik_77', 'nurik77@yandex.ru', '1231ae501ca6afa16aabb5ef427ad5a5d57211015efe63fbe41e185d0a69d186', '1989-05-22', '+77083917425', '2023-04-08 18:40:29', 'active'),
(5, 'cutelofi', 'aliya.sarsenbayeva@gmail.com', '5a28b684b47b080b523defa25b2b5466b85e22d2380370a63f70498712116222', '2007-02-01', '+77471263804', '2024-09-14 11:25:06', 'active'),
(6, 'rus.def', 'ruslan.gabishev@outlook.com', '165c7c16217e1df75ed48ecb3d6f5438d017442d7a389191cf264d53ea3bf383', '1994-09-14', '+77762490583', '2025-01-29 20:05:48', 'banned'),
(7, 'sasha_mix', 'ale2andrra_tolmacheva@gmail.com', '489cd5dbc708c7e541de4d7cd91ce6d0f1613573b7fc5b40d3942ccb9555cf35', '2003-06-30', '+77076638149', '2020-07-12 08:45:21', 'active'),
(8, 'fa3eless_poet', 'Damir_Zhanas@gmail.com', '63caacd4d826f3fc75d0ce130ab7c78cbce5823cf05a1d6382869aad54db4686', '1999-12-25', '+77018953470', '2021-12-30 16:30:52', 'deleted'),
(9, 'assel_almaty', 'assel_mukhtarina@mail.ru', 'e7f75340c4258f3f4c4b2c7930ce7993c1c2e67c83621f16fad47d33b7289c5a', '1986-04-17', '+77751620894', '2022-03-25 12:11:37', 'active'),
(10, 'ZHAN_2004', 'zhandos_2004@mail.ru', '90c32f3e4a4ac3ba9db6106eba2448d923f95bc91e8071e858462f44c3666740', '2004-08-09', '+77055791236', '2023-10-06 19:55:09', 'active'),
(11, 'nurziyathink', 'Nurza_Seidakhmet@yandex.ru', '7fa14492a1a1ba15152dbd3133e3a619b1c329e883eefa4a0b3400ed4e569650', '1997-01-28', '+77082467105', '2024-02-18 13:15:44', 'active'),
(12, 'syma_bb', 'bekzat.q@mail.ru', 'fdbcd110cdcbc35e5e5e99b8a4ef4c3d76102b4d0b6aa5e1e4fd44b460d09e6a', '2000-10-13', '+77476503428', '2025-08-11 22:05:33', 'active'),
(13, 'azekowka', 'lofikid@gmail.com', '3f79bb7b435b05321651daefd374cdc681dc06faa65e374e38337b88ca046dea', '2006-02-20', '+77768415290', '2026-01-07 09:50:18', 'active'),
(14, 'ibhane', 'tyrsyn_inabatt@yandex.ru', 'd7889ec50c6e8024cfdbb68c684cdc9006ddd31e49bed388de9ee3b96c555c7d', '1992-03-11', '+77071298653', '2020-11-09 23:20:05', 'banned'),
(15, 'simple_ayan', 'ayan_suleiman@gmail.com', '88b78f7ad2c0edac506536c13a3b71f21706625fca24f60bc2e25d5ec5d6dac5', '2005-05-08', '+77013807524', '2021-04-27 17:30:41', 'active'),
(16, 'hayshindev', 'dana.hyshineva@gmail.com', '96cae35ce8a9b0244178bf28e4966c2ce1b8385723a96a6b838858cdd6ca0a1e', '1996-09-01', '+77759268140', '2022-08-19 10:00:26', 'active'),
(17, 'a1massssss', 'a1mass_karim@gmail.com', '18e351e2d80f67c2d2001ecd8a02c40637b37ef8931fb43e47f004ac99b9959c', '1982-12-12', '+77052681397', '2023-01-12 15:15:59', 'active'),
(18, '6kmbs', 'kumbel_marat@mail.ru', '22818963d28b5bf5fa197a7654c5cb43797e857f6d8b080962ce04022258fba0', '1991-07-07', '+77089350461', '2024-07-04 11:40:12', 'active'),
(19, 'saltanat_s', 'saltanat.s@gmail.com', 'ea313b0d3b319fee982506b585ddc5002fad6d296e71c34dcf67a28e2d548cf9', '2004-04-04', '+77471956283', '2025-12-16 21:05:47', 'active'),
(20, 'MaksiMax', 'Glebov_Maxim@yandex.ru', 'c0996de8f68ae87567e3f2825ea1e999be6c7d1baf370a33ed9c58fd8dd75a22', '1987-08-30', '+77760384721', '2026-03-03 07:55:30', 'suspended'),
(21, 'aminakul', 'kuldakhmet_amina@outlook.com', '99e6250df2a473230aad68184e50e10e3583e33dfe77eaae085c842534c0c239', '2002-11-18', '+77074361985', '2020-05-22 19:15:22', 'active'),
(22, 'assellxflow', 'assell_alimzhan@mail.ru', '9adbd91124c2382d698af71415df7da95be711a503b20d76d96069ba47836e6b', '1995-06-06', '+77012175064', '2021-09-15 13:25:56', 'active'),
(23, '0rai', 'arai.kabyl@outlook.com', 'c4cd4f5fc3790a48f2ede2e0b2d361c249a1ed83d07164a27dbb6a4bc8da07d9', '2001-03-03', '+77753809462', '2022-12-01 16:45:14', 'active'),
(24, 'NARUTOmix', 'alexXjohn@yandex.ru', '2d0c2e5ffa3bbf86bba5ead93319cc789a62211b82608548c12df32e42ef6c8d', '2007-10-21', '+77056817304', '2023-06-24 22:35:49', 'active'),
(25, 'ddaurren', 'daurren_rasul@gmail.com', '346c1241e83a396fe7414687ccdd771413ea1e322410b98a9f05ad06ed3219c7', '2003-01-15', '+77084902576', '2024-10-31 10:10:02', 'deleted'),
(26, 'sul_da1', 'dulat.sultan@gmail.com', '0a143f192cc9f0be3fa50ab95ccdf2cf36dfa7e229ad76d8fbb08bfebd19f9d1', '1985-02-14', '+77470631859', '2025-03-18 14:50:38', 'active'),
(27, 'aubakirovavv', 'erke_vav777@mail.ru', 'f9430a30431829bfa9420368fc97bbb354b2218bde0d0dacf03cc5cb701082ae', '2004-09-09', '+77765981703', '2026-05-13 18:45:27', 'active'),
(28, 'moonlady__', 'aibike.zhaksylyk@yandex.ru', '4bc0c27d05b1333722d943ed0de8ef4693064d79c1db33ab246cf09a41ee0d08', '1993-05-28', '+77073850612', '2020-01-30 08:20:51', 'active'),
(29, 'amore_e_denaro', 'dana.aubakirova@gmail.com', '3e3bb57cfbe4bee4c567ff05f868f3b2367818d746da5a806e62a606ba87e1be', '1990-12-01', '+77016892475', '2021-07-08 12:10:35', 'active'),
(30, 'victory_mine', 'victorya_Mm@gmail.com', '3a1c019f1b62ddaac46bdba4e708b27c44537a80fe394b479e751538f3fad23c', '2000-07-16', '+77752074186', '2022-02-14 20:30:24', 'active'),
(31, 'aslanGym', 'aslan_arti@outlook.com', '2f15e2ba9dfddb459d5819a5e86fa2a8517bc6bf8664be9e13ceea1668354988', '1988-11-29', '+77059163824', '2023-09-22 06:50:16', 'banned'),
(32, 'whosamrr', 'amir.namatov@gmail.com', '00b33804e2e6ae0ec87faf10cb7cf9553c508a93c97d59d9df2c5f168949c6bc', '2004-06-03', '+77084205796', '2024-04-13 09:15:55', 'active'),
(33, 'sf3sh', 'marat.sharipov@yandex.ru', 'aa97e53f94839bd40bb9be6d3dd0307fa206191830d1406d15095ef112c87daa', '1984-01-01', '+77471539608', '2025-10-09 23:00:07', 'active'),
(34, 'maxximwe', 'maxim.stanislav@mail.ru', 'fd915a52d51f91d1921bf3726aac3fc54f803a25db992f1a476db05f7d092cb4', '1999-04-22', '+77768403015', '2026-02-21 13:13:19', 'active'),
(35, 'k_tolmacheva', 'katerina_tolmachova@gmail.com', '3aa9d122caa4fd598981f6a6ef91cb052abae26602ee4b24d4ab6e9b0affcff8', '2005-12-12', '+77071468239', '2020-10-26 17:17:46', 'active'),
(36, 'delixios_z', 'sofia_morozova@yandex.ru', '8a46b417251f6b9695104ef47faa6feae44b7b83ee7bb1d78a3c157eb783b588', '1998-08-08', '+77012690574', '2021-03-07 11:11:31', 'active'),
(37, '__yekate', 'Ekaterina.Shakheldyan@gmail.com', '07b9c5da3f339d3bc1712026bcbe501d70cdc0e84e36d9e79b628ce58e48adb9', '2006-03-09', '+77754831760', '2022-07-29 21:45:04', 'suspended'),
(38, 'Madi_Run', 'madi_rymkulov@gmail.com', 'a98817fb5c711aab80271f45ec7d36dc5163656407e903bebebd288427fa0030', '1991-10-10', '+77058026413', '2023-12-11 07:40:58', 'active'),
(39, 'nuraikaaaa2', 'nurai_askhozhina_2@mail.ru', 'af090949dca6a87f0d0a5d442133826fa80f21d0c5360c4f695837d03132b3aa', '1997-05-05', '+77089173542', '2024-08-25 15:00:13', 'active'),
(40, 'dts_privat', 'askar_aidar@yandex.ru', 'c2f5b5d798b8fee2a7a10b7c2a6438c13a080e8919fb4d2720658f611ab810db', '1986-07-27', '+77472834691', '2025-04-19 18:18:40', 'active'),
(41, 'welcome.to.my.cinema', 'tomiris_tasmagambet@outlook.com', 'f3b8d019b3c50c912c4e23c7206301161538eb73399e21572b9125515f623532', '2004-02-18', '+77769350817', '2026-04-27 12:35:23', 'active'),
(42, 'alskual', 'alua.skulova@gmail.com', '752bb1587a5bc7e6c51a1a1e764f7a3e7d5026c7a1bbb6cbdcb3e6650dc256ba', '1992-09-23', '+77074628053', '2020-08-05 19:40:54', 'active'),
(43, 'gambojaa', 'kariya_glebovna@yandex.ru', 'cc26348405b3e4c9c25af3d8590f219d07c9c9a40821469eebe0eb8cf9141208', '2003-11-11', '+77019374826', '2021-11-18 08:05:36', 'deleted'),
(44, 'malina.web', 'alina_malina@gmail.com', '7a846c4c6a2b17457809ddd82edbfd6622cc4eea8ac53b3611be273b860c834b', '1987-06-06', '+77752603984', '2022-05-06 22:15:10', 'active'),
(45, 'jeka_loops', 'zharaskhan__adilet@gmail.com', '4c71443942ef7c3818ed8c7691f859fd61611b618e586778387d5adaf106899d', '2001-01-13', '+77054187926', '2023-02-28 16:20:45', 'active'),
(46, 'kiiraarr', 'davydova_kira05@gmail.com', 'b870d3e3827088d978fbc2606395548df80ab0027fbfbf806a300b7b4f9bbe01', '2006-04-19', '+77086047135', '2024-12-05 10:30:28', 'active'),
(47, 'elina_dream', 'FedorovaE@yandex.ru', 'b7d24ad4946d5e64b352825f1e387bd569c23752a900e82572d62fa30eb65cf6', '1994-10-02', '+77470928356', '2025-06-17 14:05:50', 'active'),
(48, 'bek_dek', 'bekmurzin_adilet@mail.ru', '27813d47d07495d31e62bf1e92cf3d72801ec64629331fb41544bff26e02ca42', '1996-12-29', '+77765184729', '2026-01-30 17:55:17', 'banned'),
(49, '_salta_', 'saltanat.kudaibergen@yandex.ru', 'ac60e7d0f31e44521345648ca5933c2c9e8fbd33ae21824996cf93d547e43a9a', '2002-02-22', '+77073096418', '2020-04-11 09:45:34', 'active'),
(50, 'igor_latte', 'latyn_igor@example.com', '88d2a61887a57df74b49089a7a17a4ae4ebe9de26d8bd4b5ff675f94290721e6', '1983-03-31', '+77012487560', '2021-01-23 23:50:01', 'suspended'),
(51, 'akhmeeeeed', 'akhmed_dayan@gmail.com', 'b4a5dc31218adc5cfcd80c5b5d5a8e7277ca50d116109f648cfc329661faff5a', '2005-05-14', '+77758361049', '2022-09-09 13:00:42', 'active'),
(52, 'mels_znb', 'zeinab_mels@gmail.com', 'a818067d4e9d3cfc00146bafca95d87af8e0a5277d01e694070d732ebd0b6396', '1979-09-09', '+77051643782', '2023-05-16 06:15:25', 'active'),
(53, 'zhoninks', 'Zzhannel_zhan@gmail.com', 'c66c0f017f93aac0baa7eeebaeeda92df1594c8d1dd687893963fd17c90ccbc4', '1993-08-08', '+77089702541', '2024-03-03 18:20:53', 'active'),
(54, 'ramina_rus', 'ruslanovna_r@mail.ru', 'f6f72d74a612634b6f8fee13c49cb6c40bf792c2fc921c881a70c4ffcf157fbf', '2000-06-24', '+77475801392', '2025-11-27 15:35:15', 'active'),
(55, 'altair_first', 'altair_amankulov@yandex.ru', '496234c2ad96ea09256353d648227c0d44d340b025fc5484afdfaa07be3199cf', '2003-10-30', '+77760297418', '2026-05-06 21:15:39', 'active'),
(56, '_laura.iz_', 'Izbasar.Laura@gmail.com', '2c99ac0bc78d3c33b28b11ce209d9ad20161864045b612e16bd30506a0069fc5', '2007-07-07', '+77075924863', '2020-12-19 11:30:08', 'banned'),
(57, 'mk_alinak', 'kirill_alina_79@gmail.com', '28a7f41ab2dd6eca18d0b1d6a038c15909633fcb8df07cbd92eb2bb88d799214', '1990-04-16', '+77018630495', '2021-08-28 20:20:46', 'active'),
(58, 'My_Blue_Stars', 'raushan.x@yandex.ru', '8bb7eb36852fe9bb369ec8d22f786f6afa0581bffe21c51c2ed7a099ed5a5526', '1999-01-20', '+77754279160', '2022-01-05 09:05:32', 'active'),
(59, 'dauka_plus_vibe', 'amankulov_daulet@yandex.ru', '841696dea610a78e8361f5b68af66cb7cbb95eabb1ccd0b79e8c4707f9dc6528', '1988-05-18', '+77052804697', '2023-11-02 16:40:20', 'active'),
(60, 'Maryaa08', 'mari_loveee@gmail.com', '5e30a9a345af71c9c535b9c168ff4186eef167dc05c69357669f17dc407dadc7', '2002-12-04', '+77083951620', '2026-04-10 22:25:57', 'active');

INSERT INTO Subscription_Plans
(plan_id, plan_name, monthly_price, audio_quality, ads_free, offline_mode)
VALUES
(1, 'Student', 1490.00, 'medium', TRUE, TRUE),
(2, 'Individual', 3499.00, 'high', TRUE, TRUE),
(3, 'Family', 5990.00, 'high', TRUE, TRUE),
(4, 'Premium Plus', 4999.00, 'lossless', TRUE, TRUE);


INSERT INTO User_Subscription
(subscription_id, user_id, plan_id, start_date, end_date, status)
VALUES
(28, 28, 3, '2020-01-31', '2020-04-30', 'expired'),
(1, 1, 1, '2020-02-18', '2020-03-18', 'expired'),
(49, 49, 3, '2020-04-12', '2020-07-12', 'expired'),
(21, 21, 1, '2020-05-23', '2020-06-23', 'expired'),
(7, 7, 2, '2020-07-13', '2020-08-13', 'expired'),
(42, 42, 2, '2020-08-06', '2020-09-06', 'expired'),
(35, 35, 1, '2020-10-27', '2020-11-27', 'expired'),
(14, 14, 1, '2020-11-10', '2020-12-10', 'cancelled'),
(56, 56, 1, '2020-12-20', '2021-01-20', 'cancelled'),
(50, 50, 1, '2021-01-24', '2021-02-24', 'paused'),
(36, 36, 3, '2021-03-08', '2021-06-08', 'expired'),
(15, 15, 2, '2021-04-28', '2021-05-28', 'expired'),
(2, 2, 2, '2021-06-05', '2021-07-05', 'expired'),
(29, 29, 2, '2021-07-09', '2021-08-09', 'expired'),
(57, 57, 2, '2021-08-29', '2021-09-29', 'expired'),
(22, 22, 2, '2021-09-16', '2021-10-16', 'expired'),
(43, 43, 1, '2021-11-19', '2021-12-19', 'cancelled'),
(8, 8, 1, '2021-12-31', '2022-01-30', 'cancelled'),
(58, 58, 1, '2022-01-06', '2022-02-06', 'expired'),
(30, 30, 1, '2022-02-15', '2022-03-15', 'expired'),
(9, 9, 4, '2022-03-26', '2022-06-26', 'expired'),
(44, 44, 1, '2022-05-07', '2022-06-07', 'expired'),
(37, 37, 1, '2022-07-30', '2022-08-30', 'paused'),
(16, 16, 4, '2022-08-20', '2022-11-20', 'expired'),
(51, 51, 2, '2022-09-10', '2022-10-10', 'expired'),
(3, 3, 1, '2022-11-22', '2022-12-22', 'paused'),
(23, 23, 3, '2022-12-02', '2023-03-02', 'expired'),
(17, 17, 3, '2023-01-13', '2023-04-13', 'expired'),
(45, 45, 4, '2023-03-01', '2023-06-01', 'expired'),
(4, 4, 3, '2023-04-10', '2023-07-10', 'expired'),
(52, 52, 4, '2023-05-17', '2023-08-17', 'expired'),
(24, 24, 1, '2023-06-25', '2023-07-25', 'expired'),
(31, 31, 1, '2023-09-23', '2023-10-23', 'cancelled'),
(10, 10, 1, '2023-10-07', '2023-11-07', 'expired'),
(59, 59, 3, '2023-11-03', '2024-02-03', 'expired'),
(38, 38, 2, '2023-12-12', '2024-01-12', 'expired'),
(11, 11, 2, '2024-02-19', '2024-04-19', 'expired'),
(53, 53, 1, '2024-03-04', '2024-04-04', 'expired'),
(32, 32, 1, '2024-04-14', '2024-05-14', 'expired'),
(18, 18, 1, '2024-07-05', '2024-08-05', 'expired'),
(39, 39, 1, '2024-08-26', '2024-09-26', 'expired'),
(5, 5, 1, '2024-09-15', '2024-10-15', 'expired'),
(25, 25, 1, '2024-11-01', '2024-12-01', 'cancelled'),
(46, 46, 1, '2024-12-06', '2025-01-06', 'expired'),
(6, 6, 2, '2025-01-30', '2025-02-28', 'cancelled'),
(26, 26, 4, '2025-03-19', '2025-06-19', 'expired'),
(40, 40, 4, '2025-04-20', '2025-07-20', 'expired'),
(47, 47, 2, '2025-06-18', '2025-07-18', 'expired'),
(12, 12, 3, '2025-08-12', '2025-11-12', 'expired'),
(33, 33, 4, '2025-10-10', '2026-01-10', 'expired'),
(54, 54, 3, '2025-11-28', '2026-02-28', 'expired'),
(19, 19, 2, '2025-12-17', '2026-01-17', 'expired'),
(13, 13, 1, '2026-01-08', '2026-02-08', 'expired'),
(48, 48, 1, '2026-01-31', '2026-02-28', 'cancelled'),
(65, 7, 4, '2026-02-15', '2026-05-15', 'expired'),
(34, 34, 2, '2026-02-22', '2026-03-22', 'expired'),
(73, 17, 3, '2026-02-22', '2026-05-22', 'active'),
(72, 16, 4, '2026-03-01', '2026-06-01', 'active'),
(20, 20, 2, '2026-03-04', '2026-04-04', 'paused'),
(81, 28, 3, '2026-03-05', '2026-06-05', 'active'),
(76, 21, 1, '2026-03-14', '2026-04-14', 'expired'),
(62, 2, 3, '2026-03-20', '2026-06-20', 'active'),
(88, 40, 4, '2026-03-27', '2026-06-27', 'active'),
(68, 11, 2, '2026-03-29', '2026-04-29', 'expired'),
(85, 34, 2, '2026-04-02', '2026-05-02', 'cancelled'),
(66, 9, 3, '2026-04-03', '2026-07-03', 'active'),
(86, 36, 3, '2026-04-06', '2026-07-06', 'active'),
(70, 13, 1, '2026-04-08', '2026-05-08', 'expired'),
(60, 60, 2, '2026-04-11', '2026-05-11', 'expired'),
(79, 24, 1, '2026-04-11', '2026-05-11', 'expired'),
(69, 12, 3, '2026-04-12', '2026-07-12', 'active'),
(106, 21, 1, '2026-04-14', '2026-05-14', 'expired'),
(80, 26, 4, '2026-04-16', '2026-07-16', 'active'),
(61, 1, 2, '2026-04-18', '2026-05-18', 'active'),
(89, 49, 3, '2026-04-19', '2026-07-19', 'active'),
(74, 18, 1, '2026-04-20', '2026-05-20', 'active'),
(83, 30, 1, '2026-04-24', '2026-05-24', 'active'),
(63, 4, 2, '2026-04-25', '2026-05-25', 'active'),
(41, 41, 3, '2026-04-28', '2026-07-28', 'active'),
(77, 22, 2, '2026-04-28', '2026-05-28', 'active'),
(98, 11, 2, '2026-04-29', '2026-05-29', 'active'),
(64, 5, 1, '2026-05-01', '2026-06-01', 'active'),
(78, 23, 3, '2026-05-01', '2026-08-01', 'active'),
(75, 19, 2, '2026-05-02', '2026-06-02', 'active'),
(115, 34, 2, '2026-05-02', '2026-06-02', 'active'),
(87, 38, 2, '2026-05-03', '2026-06-03', 'active'),
(67, 10, 1, '2026-05-05', '2026-06-05', 'active'),
(82, 29, 2, '2026-05-06', '2026-06-06', 'active'),
(55, 55, 4, '2026-05-07', '2026-08-07', 'active'),
(100, 13, 1, '2026-05-08', '2026-06-08', 'active'),
(71, 15, 2, '2026-05-10', '2026-06-10', 'active'),
(109, 24, 1, '2026-05-11', '2026-06-11', 'active'),
(84, 32, 1, '2026-05-12', '2026-06-12', 'active'),
(27, 27, 2, '2026-05-13', '2026-06-13', 'active'),
(90, 60, 2, '2026-05-13', '2026-06-13', 'active'),
(95, 7, 4, '2026-05-15', '2026-11-15', 'active'),
(91, 1, 2, '2026-05-18', '2026-06-18', 'active'),
(104, 18, 1, '2026-05-20', '2026-06-20', 'active'),
(103, 17, 3, '2026-05-22', '2026-08-22', 'active'),
(113, 30, 1, '2026-05-24', '2026-06-24', 'active'),
(93, 4, 2, '2026-05-25', '2026-06-25', 'active'),
(107, 22, 2, '2026-05-28', '2026-06-28', 'active'),
(94, 5, 1, '2026-06-01', '2026-07-01', 'active'),
(102, 16, 4, '2026-06-01', '2026-12-01', 'active'),
(105, 19, 2, '2026-06-02', '2026-07-02', 'active'),
(117, 38, 2, '2026-06-03', '2026-07-03', 'active'),
(97, 10, 1, '2026-06-05', '2026-07-05', 'active'),
(111, 28, 3, '2026-06-05', '2026-09-05', 'active'),
(112, 29, 2, '2026-06-06', '2026-07-06', 'active'),
(101, 15, 2, '2026-06-10', '2026-07-10', 'active'),
(114, 32, 1, '2026-06-12', '2026-07-12', 'active'),
(120, 60, 2, '2026-06-13', '2026-07-13', 'active'),
(92, 2, 3, '2026-06-20', '2027-06-20', 'active'),
(118, 40, 4, '2026-06-27', '2026-12-27', 'active'),
(96, 9, 3, '2026-07-03', '2027-07-03', 'active'),
(116, 36, 3, '2026-07-06', '2027-07-06', 'active'),
(99, 12, 3, '2026-07-12', '2027-07-12', 'active'),
(110, 26, 4, '2026-07-16', '2027-07-16', 'active'),
(119, 49, 3, '2026-07-19', '2027-07-19', 'active'),
(108, 23, 3, '2026-08-01', '2027-08-01', 'active');



INSERT INTO Devices
(device_id, user_id, device_type, created_at)
VALUES
(63, 28, 'tablet', '2020-01-30 08:33:10'),
(64, 28, 'mobile', '2020-02-02 19:18:57'),
(1, 1, 'mobile', '2020-02-17 10:21:09'),
(2, 1, 'web', '2020-03-01 23:14:52'),
(110, 49, 'web', '2020-04-11 10:02:18'),
(111, 49, 'mobile', '2020-04-15 16:24:44'),
(47, 21, 'mobile', '2020-05-22 19:24:36'),
(48, 21, 'tablet', '2020-07-01 15:38:09'),
(14, 7, 'mobile', '2020-07-12 09:01:05'),
(95, 42, 'mobile', '2020-08-05 19:55:28'),
(15, 7, 'speaker', '2020-08-30 20:33:48'),
(96, 42, 'desktop', '2020-09-14 12:11:03'),
(79, 35, 'mobile', '2020-10-26 17:26:12'),
(31, 14, 'desktop', '2020-11-09 23:32:06'),
(32, 14, 'mobile', '2020-11-14 17:43:51'),
(80, 35, 'speaker', '2020-12-14 21:33:53'),
(125, 56, 'mobile', '2020-12-19 11:42:41'),
(126, 56, 'tablet', '2021-01-06 17:09:12'),
(112, 50, 'mobile', '2021-01-24 00:03:29'),
(81, 36, 'web', '2021-03-07 11:20:45'),
(113, 50, 'speaker', '2021-03-08 18:50:06'),
(82, 36, 'mobile', '2021-03-09 07:48:02'),
(16, 7, 'desktop', '2021-03-19 13:24:15'),
(33, 15, 'mobile', '2021-04-27 17:45:20'),
(65, 28, 'smart_tv', '2021-05-06 22:07:44'),
(3, 2, 'desktop', '2021-06-03 14:33:40'),
(4, 2, 'mobile', '2021-06-05 09:07:18'),
(34, 15, 'speaker', '2021-06-10 23:05:14'),
(66, 29, 'mobile', '2021-07-08 12:22:03'),
(67, 29, 'web', '2021-07-20 09:40:58'),
(127, 57, 'mobile', '2021-08-28 20:34:08'),
(49, 22, 'desktop', '2021-09-15 13:39:46'),
(50, 22, 'mobile', '2021-09-20 07:18:22'),
(97, 43, 'mobile', '2021-11-18 08:18:42'),
(98, 43, 'web', '2021-12-01 22:36:09'),
(17, 8, 'tablet', '2021-12-30 16:39:07'),
(18, 8, 'mobile', '2022-01-02 12:18:50'),
(129, 58, 'web', '2022-01-05 09:19:46'),
(130, 58, 'mobile', '2022-01-07 23:51:27'),
(5, 2, 'speaker', '2022-01-12 21:45:03'),
(35, 15, 'web', '2022-02-02 11:11:47'),
(128, 57, 'desktop', '2022-02-11 12:26:53'),
(68, 30, 'desktop', '2022-02-14 20:46:30'),
(69, 30, 'mobile', '2022-03-01 11:14:05'),
(19, 9, 'mobile', '2022-03-25 12:29:13'),
(20, 9, 'web', '2022-04-11 07:52:39'),
(99, 44, 'tablet', '2022-05-06 22:29:51'),
(100, 44, 'mobile', '2022-05-07 07:17:40'),
(83, 36, 'desktop', '2022-05-27 13:05:29'),
(51, 22, 'speaker', '2022-06-05 23:31:18'),
(84, 37, 'mobile', '2022-07-29 21:56:36'),
(85, 37, 'tablet', '2022-08-02 18:42:17'),
(36, 16, 'desktop', '2022-08-19 10:12:08'),
(37, 16, 'mobile', '2022-09-03 14:28:37'),
(114, 51, 'mobile', '2022-09-09 13:16:37'),
(115, 51, 'tablet', '2022-10-30 20:26:15'),
(6, 3, 'mobile', '2022-11-21 09:18:44'),
(52, 23, 'mobile', '2022-12-01 16:59:04'),
(101, 44, 'speaker', '2023-01-03 20:41:12'),
(7, 3, 'tablet', '2023-01-04 18:26:31'),
(38, 17, 'mobile', '2023-01-12 15:33:12'),
(39, 17, 'smart_tv', '2023-02-25 21:49:05'),
(102, 45, 'mobile', '2023-02-28 16:35:03'),
(103, 45, 'desktop', '2023-03-17 11:53:26'),
(53, 23, 'web', '2023-03-18 10:21:45'),
(8, 4, 'web', '2023-04-08 19:02:10'),
(116, 52, 'desktop', '2023-05-16 06:32:08'),
(117, 52, 'mobile', '2023-05-16 19:41:36'),
(9, 4, 'smart_tv', '2023-05-19 22:41:59'),
(54, 24, 'mobile', '2023-06-24 22:50:28'),
(21, 9, 'smart_tv', '2023-09-07 22:11:28'),
(70, 31, 'mobile', '2023-09-22 07:03:26'),
(22, 10, 'mobile', '2023-10-06 20:03:42'),
(71, 31, 'speaker', '2023-10-11 19:27:41'),
(131, 59, 'mobile', '2023-11-02 16:52:40'),
(23, 10, 'desktop', '2023-11-15 16:27:09'),
(86, 38, 'mobile', '2023-12-11 07:52:13'),
(55, 24, 'smart_tv', '2023-12-31 01:03:33'),
(132, 59, 'smart_tv', '2024-01-19 21:35:05'),
(87, 38, 'speaker', '2024-01-20 22:19:44'),
(24, 11, 'web', '2024-02-18 13:26:31'),
(25, 11, 'mobile', '2024-02-19 08:17:55'),
(119, 53, 'mobile', '2024-03-03 18:35:49'),
(118, 52, 'web', '2024-04-02 23:18:20'),
(72, 32, 'mobile', '2024-04-13 09:31:14'),
(73, 32, 'web', '2024-04-13 22:08:50'),
(120, 53, 'smart_tv', '2024-06-19 22:52:11'),
(40, 18, 'mobile', '2024-07-04 11:54:49'),
(41, 18, 'web', '2024-07-04 23:16:30'),
(88, 39, 'mobile', '2024-08-25 15:12:58'),
(89, 39, 'web', '2024-09-03 10:06:31'),
(10, 5, 'mobile', '2024-09-14 11:31:27'),
(11, 5, 'desktop', '2024-10-02 08:56:11'),
(56, 25, 'mobile', '2024-10-31 10:25:17'),
(57, 25, 'web', '2024-11-02 14:45:06'),
(104, 46, 'mobile', '2024-12-05 10:43:47'),
(42, 18, 'tablet', '2025-01-15 09:22:41'),
(105, 46, 'web', '2025-01-19 00:24:32'),
(12, 6, 'mobile', '2025-01-29 20:17:22'),
(13, 6, 'web', '2025-02-03 01:08:36'),
(74, 32, 'tablet', '2025-02-28 16:16:34'),
(58, 26, 'mobile', '2025-03-18 15:04:44'),
(133, 59, 'speaker', '2025-03-27 19:04:33'),
(59, 26, 'desktop', '2025-04-09 08:32:21'),
(90, 40, 'desktop', '2025-04-19 18:29:22'),
(91, 40, 'mobile', '2025-04-20 06:40:55'),
(106, 47, 'mobile', '2025-06-17 14:22:05'),
(26, 12, 'mobile', '2025-08-11 22:18:04'),
(107, 47, 'smart_tv', '2025-08-22 21:08:19'),
(27, 12, 'tablet', '2025-09-01 10:40:22'),
(60, 26, 'speaker', '2025-09-21 20:59:13'),
(75, 33, 'desktop', '2025-10-09 23:12:22'),
(76, 33, 'mobile', '2025-10-12 08:44:11'),
(92, 40, 'smart_tv', '2025-11-11 23:18:47'),
(121, 54, 'mobile', '2025-11-27 15:46:32'),
(122, 54, 'web', '2025-12-02 09:08:48'),
(43, 19, 'mobile', '2025-12-16 21:14:33'),
(28, 12, 'speaker', '2025-12-24 19:56:33'),
(44, 19, 'desktop', '2026-01-03 18:50:27'),
(29, 13, 'mobile', '2026-01-07 10:04:44'),
(30, 13, 'web', '2026-01-10 00:12:19'),
(108, 48, 'mobile', '2026-01-30 18:03:41'),
(109, 48, 'desktop', '2026-02-05 09:37:56'),
(77, 34, 'mobile', '2026-02-21 13:28:37'),
(78, 34, 'web', '2026-03-03 00:57:49'),
(45, 20, 'web', '2026-03-03 08:09:10'),
(46, 20, 'mobile', '2026-03-06 20:42:55'),
(134, 60, 'mobile', '2026-04-10 22:38:16'),
(135, 60, 'web', '2026-04-12 10:15:47'),
(93, 41, 'mobile', '2026-04-27 12:47:35'),
(94, 41, 'web', '2026-04-30 09:22:16'),
(123, 55, 'mobile', '2026-05-06 21:28:50'),
(124, 55, 'speaker', '2026-05-09 23:13:27'),
(61, 27, 'mobile', '2026-05-13 18:52:39'),
(62, 27, 'web', '2026-05-13 23:47:18');


INSERT INTO Genres
(genre_id, genre_name, description)
VALUES
(1, 'Pop', 'Populyarnaya muzyka, radio hits, TikTok songs, legko slushat na fone'),
(2, 'Hip-Hop', 'bity, flow, street vibe'),
(3, 'Rap', 'rap from different countries: US, Russian, and Kazakh tracks can all appear in one playlist.'),
(4, 'R&B', 'Уже 50+ пользователей добавили R&B-треки в свои playlists, особенно для вечернего прослушивания и романтического настроения.'),
(5, 'Rock', 'Guitars, drums, and band energy. Old rock and new rock are mixed together.'),
(6, 'Indie', 'Independent music with a softer, more personal sound that often feels less commercial than mainstream pop. It can include bedroom-pop, alternative, acoustic, or experimental elements depending on the artist. 
Users may listen to this genre for a calm, emotional, or “not too polished” atmosphere.'),
(7, 'Electronic', 'Цифровая и synth-based музыка с клубными, экспериментальными или атмосферными элементами.'),
(8, 'EDM', 'Festival-style dance music with big drops, high energy, and tracks often used for gym or party playlists.'),
(9, 'Techno', 'Temnaya elektronnaya muzyka s povtoryayushchimisya bitami, rovnym ritmom i atmosferoy underground kluba.'),
(10, 'House', 'Dance music built around a steady four-on-the-floor beat, warm grooves, and a club-friendly atmosphere. It is often used in party playlists, background lounge mixes, and upbeat daily listening. 
Some users confuse it with EDM, but House usually feels smoother, more rhythmic, and less focused on dramatic drops.'),
(11, 'Lo-fi', 'Soft low-fidelity beats often used for studying, relaxing, late-night work, or background focus.'),
(12, 'Jazz', 'ЖИВАЯ МУЗЫКА: саксофон, пианино, контрабас, живая импровизация и мягкая атмосфера для тех моментов, когда хочется чего-то более глубокого и спокойного.'),
(13, 'Classical', 'Orchestral, piano, chamber, and academic music with a more structured sound, often used for concentration, studying, 
calm background listening, or when users want something without strong pop vocals.'),
(14, 'K-Pop', '2026 TOP PICKS: Корейская поп-музыка с яркими idol groups, запоминающимися припевами, сильной визуальной подачей и очень активными fandom streams. 
Этот жанр отлично подходит для тех, кто любит энергичные треки, красивую хореографию, стильные клипы и атмосферу большого музыкального комьюнити. Скорее заходи послушать!'),
(15, 'J-Pop', 'さくら vibe: Japanese pop with anime openings, soft idol tracks, catchy melodies, and sometimes a soundtrack-like atmosphere.'),
(16, 'Latin', 'Latin music with Spanish-language pop, reggaeton, salsa-inspired rhythms, bachata influences, and warm summer energy. It is often used in dance playlists, party mixes, travel mood collections, and high-energy social listening. 
The genre feels rhythmic, colorful, and easy to enjoy even when listeners do not fully understand the lyrics.'),
(17, 'Reggaeton', 'Latin urban dance music with a strong dembow rhythm, catchy hooks, and a very party-friendly sound. It is often associated with Spanish-language hits, club playlists, 
summer mood, and high-energy dancing. Users may mix it with Latin pop or dance tracks because the genre is rhythmic, accessible, and popular in social settings.'),
(18, 'Afrobeats', 'african pop rhythm, teplyi bit, good for dance and summer mood'),
(19, 'Soul', 'ПЕСНИ ДЛЯ ДУШИ: эмоциональный вокал, теплое old-school звучание и глубокая атмосфера, которая часто подходит для спокойных вечеров, размышлений или романтичного настроения. Этот жанр иногда пересекается с R&B, но обычно звучит более мягко, искренне и “живее”.'),
(20, 'Folk', 'Traditional and acoustic music based on cultural storytelling, local instruments, simple melodies, and community or regional heritage. 
Users often listen to this genre for nostalgia, national identity, calm mood, or a more authentic sound.'),
(21, 'Kazakh Pop', 'Қазақша поп әндер, радиоға ыңғайлы, жеңіл тыңдалатын тректер.'),
(22, 'Q-pop', 'Modern Kazakh music from rising artists. Moldanazar, Yenlik, Ayau, Juzim, Ninety One, etc.'),
(23, 'Russian Pop', 'Твое любимое: поп-музыка, радио, сторис, караоке, иногда очень разный вайб.'),
(24, 'Russian Rap', 'RUSSIAN RAP RADAR: artists like Miyagi, Endspiel, Oxxxymiron, Noize MC, Скриптонит, ATL, Markul, Big Baby Tape, Pharaoh, Boulevard Depo, and Morgenshtern often appear in this category. This genre includes lyrical rap, trap, melodic rap, darker street-inspired tracks, and more experimental internet-driven sounds. '),
(25, 'Arabic Songs', 'HABIBI VIBES: Arabic-language songs with warm vocals, emotional melodies, eastern rhythms, and a romantic atmosphere 
for listeners who love Middle Eastern culture and expressive music. This category includes Arabic pop, love songs, viral social media tracks, traditional-inspired sounds, and danceable songs that feel dramatic, beautiful, and full of feeling.'),
(26, 'Alternative', 'Between indie and rock: not fully mainstream, not fully underground either.'),
(27, 'Metal', 'LOUD. Guitars, heavy drums, intense vocals.'),
(28, 'Punk', 'fast, raw, noisy, sometimes political, sometimes just chaotic energy'),
(29, 'Ambient', 'Атмосферная музыка без сильного ритма: фон, сон, концентрация.'),
(30, 'Instrumental', 'No main vocals, mostly piano/guitar/beats. Great for studying or working.'),
(31, 'Acoustic', 'Минимальная обработка, Живой звук, гитара, пианино.'),
(32, 'Dance Pop', 'pop but more danceable: clubs, parties, shopping mall playlist vibe'),
(33, 'Trap', '808 bass, hi-hats, modern rap production. users may tag it as rap too.'),
(34, 'Drill', 'Drill is a darker subgenre of rap built around cold beats, sharp hi-hats, heavy bass, and an aggressive rhythmic flow.'),
(35, 'Phonk', '404 PHONK MODE: internet-driven music with loud bass, drift-video energy, Memphis rap influence, cowbells, distorted samples, and an aggressive mood. It is often used in car edits, gym playlists, gaming clips, and short-form video trends. The sound is usually fast, dark, and energetic, so users add it when they want something intense, chaotic, and powerful.'),
(36, 'Hyperpop', 'Bright, glitchy, and highly digital music that intentionally sounds overloaded, chaotic, and over-produced.'),
(37, 'Synthpop', 'Synthpop is a pop-oriented electronic genre built around synthesizers, soft digital textures, catchy melodies, and a nostalgic 80s-inspired sound. Creates a neon, night-city atmosphere with smooth vocals, dreamy production.'),
(38, 'Traditional Kazakh Songs', 'Қазақтың дәстүрлі әндері мен ескі халықтық әуендері ұлттық мәдениетке, тарихқа, дала рухына және ауыз әдебиетіне жақын музыканы қамтиды. Бұл жанрға домбырамен орындалатын халық әндері, терме, жыр, күйге жақын вокалдық шығармалар, сондай-ақ ата-аналар мен үлкен буын жиі тыңдайтын ескі қазақ әндері кіруі мүмкін.'),
(39, 'Country', 'It is strongly connected with American rural culture, but modern country can also include pop, rock, and folk influences. Works well for road trips, calm evenings, nostalgic playlists, or users who enjoy narrative-driven songs.'),
(40, 'Chanson', 'Русский шансон, старая эстрада, “такси-плейлист” и песни с узнаваемым настроением дороги, воспоминаний и жизненных историй. Этот жанр часто звучит более взрослым, ностальгичным и разговорным, чем обычная поп-музыка.'),
(41, 'Soundtrack', 'Movie, anime, game and series music.'),
(42, 'Kazakh Toi Songs', 'Kazakh Toi Songs are energetic celebration tracks often played at weddings, family events, birthdays, and large gatherings. They immediately create a familiar and joyful atmosphere.'),
(43, 'Meditation', 'calm breathing audio, sleep sounds, relax, nature background.'),
(44, 'Workout', 'ENERGETIC MIX. Playlist for your workout: rap, phonk, EDM, pop.'),
(45, 'Study', 'Focus music, lofi, piano, ambient, often listened during exams and deadlines.'),
(46, 'Love Songs', 'Love Songs include romantic pop, emotional ballads, soft R&B, acoustic tracks, and songs about attraction, relationships, missing someone, or heartbreak. The mood is not always happy: some tracks feel warm and dreamy, while others are dramatic, nostalgic, or painful.'),
(47, 'Sad', 'For rainy days, late-night bus rides, quiet walks, breakup mood. Billie Eilish, Lana Del Rey, Joji, Mitski, The Weeknd, Adele, Olivia Rodrigo. The sound is usually soft, emotional, melancholic, or dramatic, so users often add these tracks when they want music that matches a heavy mood.'),
(48, 'Party', 'Для вечеринок: dance, pop, rap, latin, club hits и любые треки, под которые хочется двигаться.'),
(49, 'Oldies', 'This category includes old pop, rock classics, retro dance tracks, Soviet-era songs, 80s and 90s hits, early 2000s favorites, and tracks that people still recognize years later.'),
(50, 'Experimental', 'Niche sound for weirdos, curious listeners, and people who enjoy music that does not follow normal genre rules. This category can include unusual production, strange vocals, abstract electronic sounds, noise elements, unexpected song structures, or tracks that feel more like an audio experiment than a regular hit.');


INSERT INTO Artists
(artist_id, artist_name, country)
VALUES
(1, 'Raye', 'UK'),
(2, 'Giveon', 'USA'),
(3, 'Billie Eilish', 'USA'),
(4, 'Harry Styles', 'UK'),
(5, 'Taylor Swift', 'USA'),
(6, 'The Weeknd', 'Canada'),
(7, 'Doja Cat', 'USA'),
(8, 'Dua Lipa', 'UK'),
(9, 'Kendrick Lamar', 'USA'),
(10, 'Travis Scott', 'USA'),
(11, 'Ariana Grande', 'USA'),
(12, 'Olivia Rodrigo', 'USA'),
(13, 'Lana Del Rey', 'USA'),
(14, 'Post Malone', 'USA'),
(15, 'Ed Sheeran', 'UK'),
(16, 'Adele', 'UK'),
(17, 'Bruno Mars', 'USA'),
(18, 'Rihanna', 'Barbados'),
(19, 'Frank Ocean', 'USA'),
(20, 'Tyler, The Creator', 'USA'),
(21, 'Mitski', 'USA'),
(22, 'Phoebe Bridgers', 'USA'),
(23, 'Bon Iver', 'USA'),
(24, 'Cigarettes After Sex', 'USA'),
(25, 'Tame Impala', 'Australia'),
(26, 'Arctic Monkeys', 'UK'),
(27, 'Imagine Dragons', 'USA'),
(28, 'Coldplay', 'UK'),
(29, 'Radiohead', 'UK'),
(30, 'The Neighbourhood', 'USA'),
(31, 'Calvin Harris', 'UK'),
(32, 'Avicii', 'Sweden'),
(33, 'Martin Garrix', 'Netherlands'),
(34, 'David Guetta', 'France'),
(35, 'Fred again..', 'UK'),
(36, 'Daft Punk', 'France'),
(37, 'Aphex Twin', 'Ireland'),
(38, 'Peggy Gou', 'South Korea'),
(39, 'Charlotte de Witte', 'Belgium'),
(40, 'Anyma', 'Italy'),
(41, 'Kamasi Washington', 'USA'), 
(42, 'Lianne La Havas', 'UK'),   
(43, 'Gregory Porter', 'USA'),    
(44, 'Cécile McLorin Salvant', 'France'), 
(45, 'Ludovico Einaudi', 'Italy'),
(46, 'Hans Zimmer', 'Germany'),
(47, 'Yiruma', 'South Korea'),
(48, 'Joe Hisaishi', 'Japan'),
(49, 'Ryuichi Sakamoto', 'Japan'),
(50, 'Nujabes', 'Japan'),
(51, 'BTS', 'South Korea'),
(52, 'BLACKPINK', 'South Korea'),
(53, 'NewJeans', 'South Korea'),
(54, 'Stray Kids', 'South Korea'),
(55, 'TWICE', 'South Korea'),
(56, 'LE SSERAFIM', 'South Korea'),
(57, 'IVE', 'South Korea'),
(58, 'Joji', 'Japan'),
(59, 'Aimer', 'Japan'),
(60, 'Kenshi Yonezu', 'Japan'),
(61, 'Bad Bunny', 'Puerto Rico'),
(62, 'Rosalía', 'Spain'),
(63, 'J Balvin', 'Colombia'),
(64, 'Karol G', 'Colombia'),
(65, 'Shakira', 'Colombia'),
(66, 'Rema', 'Nigeria'),
(67, 'Burna Boy', 'Nigeria'),
(68, 'Wizkid', 'Nigeria'),
(69, 'Tems', 'Nigeria'),
(70, 'Ayra Starr', 'Nigeria'),
(71, 'Moldanazar', 'Kazakhstan'),
(72, 'Ninety One', 'Kazakhstan'),
(73, 'Ayau', 'Kazakhstan'),
(74, 'Yenlik', 'Kazakhstan'),
(75, 'Rusha', 'Kazakhstan'),
(76, 'Bella K', 'Kazakhstan'),
(77, 'Kanuraichik', 'Kazakhstan'),
(78, 'Juzim', 'Kazakhstan'),
(79, 'Mad Men', 'Kazakhstan'),
(80, 'DNA', 'Kazakhstan'),
(81, 'Irina Kairatovna', 'Kazakhstan'),
(82, 'Scriptonite', 'Kazakhstan'),
(83, 'Dequine', 'Kazakhstan'),
(84, 'Dose', 'Kazakhstan'),
(85, 'Jah Khalib', 'Kazakhstan'),
(86, 'Raim', 'Kazakhstan'),
(87, 'A-Studio', 'Kazakhstan'),
(88, 'Dimash Qudaibergen', 'Kazakhstan'),
(89, 'Qanay', 'Kazakhstan'),
(90, 'MDee', 'Kazakhstan'),
(91, 'Miyagi & Andy Panda', 'Russia'),
(92, 'Oxxxymiron', 'Russia'),
(93, 'Noize MC', 'Russia'),
(94, 'Morgenshtern', 'Russia'),
(95, 'Molchat Doma', 'Belarus'),
(96, 'Zivert', 'Russia'),
(97, 'Monetochka', 'Russia'),
(98, 'МакSим', 'Russia'),
(99, 'Zemfira', 'Russia'),
(100, 'Kino', 'Russia');


INSERT INTO Albums
(album_id, album_title, release_date)
VALUES
(1, 'My 21st Century Blues', '2023-02-03'),
(2, 'Give Or Take', '2022-06-24'),
(3, 'Happier Than Ever', '2021-07-30'),
(4, 'Harry''s House', '2022-05-20'),
(5, 'Midnights', '2022-10-21'),
(6, 'After Hours', '2020-03-20'),
(7, 'Planet Her', '2021-06-25'),
(8, 'Future Nostalgia', '2020-03-27'),
(9, 'DAMN.', '2017-04-14'),
(10, 'UTOPIA', '2023-07-28'),
(11, 'Positions', '2020-10-30'),
(12, 'SOUR', '2021-05-21'),
(13, 'Born To Die', '2012-01-27'),
(14, 'Hollywood''s Bleeding', '2019-09-06'),
(15, '÷', '2017-03-03'),
(16, '30', '2021-11-19'),
(17, 'An Evening with Silk Sonic', '2021-11-12'),
(18, 'ANTI', '2016-01-28'),
(19, 'Blonde', '2016-08-20'),
(20, 'IGOR', '2019-05-17'),
(21, 'Laurel Hell', '2022-02-04'),
(22, 'Punisher', '2020-06-18'),
(23, 'For Emma, Forever Ago', '2007-07-08'),
(24, 'Cigarettes After Sex', '2017-06-09'),
(25, 'Currents', '2015-07-17'),
(26, 'AM', '2013-09-09'),
(27, 'Mercury – Act 1', '2021-09-03'),
(28, 'Music of the Spheres', '2021-10-15'),
(29, 'OK Computer', '1997-05-21'),
(30, 'I Love You.', '2013-04-22'),
(31, 'Motion', '2014-10-31'),
(32, 'True', '2013-09-13'),
(33, 'Sentio', '2022-04-29'),
(34, 'Nothing but the Beat', '2011-08-26'),
(35, 'Actual Life 3', '2022-10-28'),
(36, 'Random Access Memories', '2013-05-17'),
(37, 'Selected Ambient Works 85–92', '1992-02-12'),
(38, 'I Hear You', '2024-06-07'),
(39, 'Genesys II', '2024-03-29'),
(40, 'New World', '2024-03-29'),
(41, 'Heaven and Earth', '2018-06-22'),
(42, 'Blood', '2015-07-31'),
(43, 'Liquid Spirit', '2013-09-02'),
(44, 'For One to Love', '2015-09-04'),
(45, 'Una Mattina', '2004-09-06'),
(46, 'Interstellar: Original Motion Picture Soundtrack', '2014-11-18'),
(47, 'First Love', '2001-12-01'),
(48, 'Spirited Away Soundtrack', '2001-07-18'),
(49, 'async', '2017-03-29'),
(50, 'Modal Soul', '2005-11-11'),
(51, 'BE', '2020-11-20'),
(52, 'THE ALBUM', '2020-10-02'),
(53, 'Get Up', '2023-07-21'),
(54, '5-STAR', '2023-06-02'),
(55, 'Formula of Love: O+T=<3', '2021-11-12'),
(56, 'UNFORGIVEN', '2023-05-01'),
(57, 'I''ve IVE', '2023-04-10'),
(58, 'SMITHEREENS', '2022-11-04'),
(59, 'Deep Down', '2022-12-14'),
(60, 'STRAY SHEEP', '2020-08-05'),
(61, 'Un Verano Sin Ti', '2022-05-06'),
(62, 'MOTOMAMI +', '2022-09-09'),
(63, 'Vibras', '2018-05-25'),
(64, 'MAÑANA SERÁ BONITO', '2023-02-24'),
(65, 'Laundry Service', '2001-11-13'),
(66, 'Rave & Roses', '2022-03-25'),
(67, 'Love, Damini', '2022-07-08'),
(68, 'Made in Lagos', '2020-10-30'),
(69, 'For Broken Ears', '2020-09-25'),
(70, 'The Year I Turned 21', '2024-05-31'),
(71, 'Jaz', '2023-07-28'),
(72, 'Qarangy Zharyq', '2017-05-05'),
(73, 'AYAULYM', '2023-11-22'),
(74, 'Good Zhan EP', '2024-01-01'),
(75, 'Sheker', '2024-12-30'),
(76, 'Bella K', '2023-03-17'),
(77, 'I Am a Star', '2022-12-01'),
(78, 'Juzim Radio', '2019-01-01'),
(79, 'Tokhtar', '2024-12-20'),
(80, 'DNA', '2022-01-01'),
(81, 'Arriva', '2020-10-09'),
(82, '2004', '2019-12-24'),
(83, 'labum', '2020-06-19'),
(84, 'Dose Demo', '2021-09-09'),
(85, 'E.G.O.', '2018-08-24'),
(86, 'O2', '2018-11-30'),
(87, 'Всё о любви', '2013-09-30'),
(88, 'iD', '2019-06-14'),
(89, 'Tulki', '2023-03-01'),
(90, 'The Bedroom Sessions', '2006-01-01'),
(91, 'Hajime, Pt. 2', '2016-09-20'),
(92, 'Красота и уродство', '2021-12-01'),
(93, 'Выход в город', '2020-12-04'),
(94, 'Million Dollar: Happiness', '2021-05-21'),
(95, 'Этажи', '2018-09-07'),
(96, 'Vinyl #1', '2019-09-27'),
(97, 'Я Лиза', '2018-05-25'),
(98, 'Трудный возраст', '2006-03-28'),
(99, 'Земфира', '1999-05-10'),
(100, 'Группа крови', '1988-01-05');



INSERT INTO Tracks
(track_id, album_id, track_title, duration_seconds, release_date, language)
VALUES
(1, 1, 'Escapism.', 272, '2022-10-12', 'English'),
(2, 1, 'Oscar Winning Tears', 213, '2023-02-03', 'English'),
(3, 2, 'For Tonight', 193, '2021-09-24', 'English'),
(4, 2, 'Lie Again', 185, '2022-04-29', 'English'),
(5, 3, 'Happier Than Ever', 298, '2021-07-30', 'English'),
(6, 3, 'Therefore I Am', 174, '2020-11-12', 'English'),
(7, 4, 'As It Was', 167, '2022-04-01', 'English'),
(8, 4, 'Late Night Talking', 177, '2022-05-20', 'English'),
(9, 5, 'Anti-Hero', 200, '2022-10-21', 'English'),
(10, 5, 'Lavender Haze', 202, '2022-10-21', 'English'),
(11, 6, 'Blinding Lights', 200, '2019-11-29', 'English'),
(12, 6, 'Save Your Tears', 215, '2020-03-20', 'English'),
(13, 7, 'Woman', 172, '2021-06-25', 'English'),
(14, 7, 'Need To Know', 210, '2021-06-11', 'English'),
(15, 8, 'Levitating', 203, '2020-03-27', 'English'),
(16, 8, 'Physical', 193, '2020-01-30', 'English'),
(17, 9, 'HUMBLE.', 177, '2017-03-30', 'English'),
(18, 9, 'DNA.', 185, '2017-04-14', 'English'),
(19, 10, 'FE!N', 191, '2023-07-28', 'English'),
(20, 10, 'MY EYES', 251, '2023-07-28', 'English'),
(21, 11, 'positions', 172, '2020-10-30', 'English'),
(22, 11, 'pov', 201, '2020-10-30', 'English'),
(23, 12, 'drivers license', 242, '2021-01-08', 'English'),
(24, 12, 'good 4 u', 178, '2021-05-14', 'English'),
(25, 13, 'Born To Die', 286, '2012-01-27', 'English'),
(26, 13, 'Video Games', 282, '2011-10-07', 'English'),
(27, 14, 'Circles', 215, '2019-08-30', 'English'),
(28, 14, 'Sunflower', 158, '2018-10-18', 'English'),
(29, 15, 'Shape of You', 233, '2017-01-06', 'English'),
(30, 15, 'Perfect', 263, '2017-03-03', 'English'),
(31, 16, 'Easy On Me', 224, '2021-10-15', 'English'),
(32, 16, 'Love Is A Game', 403, '2021-11-19', 'English'),
(33, 17, 'Leave The Door Open', 242, '2021-03-05', 'English'),
(34, 17, 'Smokin Out The Window', 197, '2021-11-05', 'English'),
(35, 18, 'Work', 219, '2016-01-27', 'English'),
(36, 18, 'Needed Me', 191, '2016-03-30', 'English'),
(37, 19, 'Nights', 307, '2016-08-20', 'English'),
(38, 19, 'Pink + White', 184, '2016-08-20', 'English'),
(39, 20, 'EARFQUAKE', 190, '2019-05-17', 'English'),
(40, 20, 'A BOY IS A GUN', 210, '2019-05-17', 'English'),
(41, 21, 'Working for the Knife', 158, '2021-10-05', 'English'),
(42, 21, 'Love Me More', 212, '2022-02-04', 'English'),
(43, 22, 'Kyoto', 184, '2020-04-09', 'English'),
(44, 22, 'I Know The End', 344, '2020-06-18', 'English'),
(45, 23, 'Skinny Love', 238, '2007-07-08', 'English'),
(46, 23, 'For Emma', 221, '2007-07-08', 'English'),
(47, 24, 'Apocalypse', 290, '2017-03-21', 'English'),
(48, 24, 'K.', 320, '2016-11-14', 'English'),
(49, 25, 'The Less I Know The Better', 216, '2015-07-17', 'English'),
(50, 25, 'Let It Happen', 467, '2015-03-10', 'English'),
(51, 26, 'Do I Wanna Know?', 272, '2013-06-19', 'English'),
(52, 26, 'R U Mine?', 201, '2012-02-27', 'English'),
(53, 27, 'Enemy', 173, '2021-10-28', 'English'),
(54, 27, 'Wrecked', 244, '2021-07-02', 'English'),
(55, 28, 'Higher Power', 211, '2021-05-07', 'English'),
(56, 28, 'My Universe', 228, '2021-09-24', 'English/Korean'),
(57, 29, 'No Surprises', 229, '1997-05-21', 'English'),
(58, 29, 'Karma Police', 264, '1997-05-21', 'English'),
(59, 30, 'Sweater Weather', 240, '2013-03-28', 'English'),
(60, 30, 'Afraid', 251, '2013-04-22', 'English'),
(61, 31, 'Summer', 222, '2014-03-14', 'English'),
(62, 31, 'Blame', 212, '2014-09-05', 'English'),
(63, 32, 'Wake Me Up', 249, '2013-06-17', 'English'),
(64, 32, 'Hey Brother', 255, '2013-10-28', 'English'),
(65, 33, 'Starlight', 204, '2022-04-29', 'English'),
(66, 33, 'Follow', 186, '2022-03-25', 'English'),
(67, 34, 'Titanium', 245, '2011-08-26', 'English'),
(68, 34, 'Without You', 208, '2011-09-27', 'English'),
(69, 35, 'Delilah (Pull Me Out Of This)', 330, '2022-10-28', 'English'),
(70, 35, 'Kammy (Like I Do)', 241, '2022-10-28', 'English'),
(71, 36, 'Get Lucky', 369, '2013-04-19', 'English'),
(72, 36, 'Instant Crush', 337, '2013-05-17', 'English'),
(73, 37, 'Xtal', 293, '1992-02-12', 'Instrumental'),
(74, 37, 'Tha', 545, '1992-02-12', 'Instrumental'),
(75, 38, '(It Goes Like) Nanana', 231, '2023-06-15', 'English'),
(76, 38, 'I Believe in Love Again', 176, '2023-11-08', 'English'),
(77, 39, 'Overdrive', 209, '2023-10-19', 'Instrumental'),
(78, 39, 'Reflection', 236, '2023-10-19', 'Instrumental'),
(79, 40, 'Pictures Of You', 248, '2024-03-29', 'English'),
(80, 40, 'Syren', 224, '2024-03-29', 'English'),
(81, 41, 'Fists of Fury', 521, '2018-06-22', 'Instrumental'),
(82, 41, 'The Space Travelers Lullaby', 914, '2018-06-22', 'Instrumental'),
(83, 42, 'Unstoppable', 354, '2015-07-31', 'English'),
(84, 42, 'What You Don''t Do', 220, '2015-07-31', 'English'),
(85, 43, 'Liquid Spirit', 187, '2013-09-02', 'English'),
(86, 43, 'Hey Laura', 197, '2013-09-02', 'English'),
(87, 44, 'Wives and Lovers', 200, '2015-09-04', 'English'),
(88, 44, 'Fog', 275, '2015-09-04', 'English'),
(89, 45, 'Una Mattina', 206, '2004-09-06', 'Instrumental'),
(90, 45, 'Nuvole Bianche', 357, '2004-09-06', 'Instrumental'),
(91, 46, 'Cornfield Chase', 126, '2014-11-18', 'Instrumental'),
(92, 46, 'No Time for Caution', 247, '2014-11-18', 'Instrumental'),
(93, 47, 'River Flows In You', 187, '2001-12-01', 'Instrumental'),
(94, 47, 'Kiss The Rain', 255, '2001-12-01', 'Instrumental'),
(95, 48, 'One Summer''s Day', 229, '2001-07-18', 'Instrumental'),
(96, 48, 'The Sixth Station', 218, '2001-07-18', 'Instrumental'),
(97, 49, 'Andata', 278, '2017-03-29', 'Instrumental'),
(98, 49, 'Solari', 233, '2017-03-29', 'Instrumental'),
(99, 50, 'Feather', 175, '2005-11-11', 'English'),
(100, 50, 'Luv(sic) Part 3', 336, '2005-11-11', 'English'),
(101, 51, 'Life Goes On', 207, '2020-11-20', 'Korean'),
(102, 51, 'Dynamite', 199, '2020-08-21', 'English'),
(103, 52, 'How You Like That', 181, '2020-06-26', 'Korean/English'),
(104, 52, 'Lovesick Girls', 194, '2020-10-02', 'Korean/English'),
(105, 53, 'Super Shy', 154, '2023-07-07', 'Korean/English'),
(106, 53, 'ETA', 151, '2023-07-21', 'Korean/English'),
(107, 54, 'S-Class', 195, '2023-06-02', 'Korean'),
(108, 54, 'Hall of Fame', 171, '2023-06-02', 'Korean'),
(109, 55, 'The Feels', 198, '2021-10-01', 'English'),
(110, 55, 'Scientist', 194, '2021-11-12', 'Korean'),
(111, 56, 'UNFORGIVEN', 182, '2023-05-01', 'Korean/English'),
(112, 56, 'Eve, Psyche & The Bluebeard''s wife', 186, '2023-05-01', 'Korean'),
(113, 57, 'I AM', 183, '2023-04-10', 'Korean'),
(114, 57, 'Kitsch', 195, '2023-03-27', 'Korean'),
(115, 58, 'Glimpse of Us', 233, '2022-06-10', 'English'),
(116, 58, 'Die For You', 211, '2022-11-04', 'English'),
(117, 59, 'Zankyosanka', 184, '2021-12-06', 'Japanese'),
(118, 59, 'Deep Down', 202, '2022-12-14', 'Japanese'),
(119, 60, 'Lemon', 256, '2018-03-14', 'Japanese'),
(120, 60, 'Kanden', 267, '2020-08-05', 'Japanese'),
(121, 61, 'Tití Me Preguntó', 243, '2022-05-06', 'Spanish'),
(122, 61, 'Me Porto Bonito', 178, '2022-05-06', 'Spanish'),
(123, 62, 'DESPECHÁ', 157, '2022-07-28', 'Spanish'),
(124, 62, 'SAOKO', 137, '2022-02-04', 'Spanish'),
(125, 63, 'Mi Gente', 189, '2017-06-30', 'Spanish'),
(126, 63, 'Ambiente', 249, '2018-04-13', 'Spanish'),
(127, 64, 'TQG', 198, '2023-02-24', 'Spanish'),
(128, 64, 'Provenza', 210, '2022-04-21', 'Spanish'),
(129, 65, 'Whenever, Wherever', 196, '2001-08-27', 'English'),
(130, 65, 'Suerte', 196, '2001-08-27', 'Spanish'),
(131, 66, 'Calm Down', 239, '2022-02-11', 'English'),
(132, 66, 'Soundgasm', 204, '2021-06-11', 'English'),
(133, 67, 'Last Last', 172, '2022-05-13', 'English'),
(134, 67, 'For My Hand', 159, '2022-07-08', 'English'),
(135, 68, 'Essence', 248, '2020-10-30', 'English'),
(136, 68, 'Ginger', 196, '2020-10-30', 'English'),
(137, 69, 'Free Mind', 247, '2020-09-25', 'English'),
(138, 69, 'Higher', 197, '2020-09-25', 'English'),
(139, 70, 'Commas', 157, '2024-02-02', 'English'),
(140, 70, 'Goodbye', 181, '2024-05-31', 'English'),
(141, 71, 'Ақпен бірге', 240, '2019-07-24', 'Kazakh'),
(142, 71, 'Сен емес', 232, '2023-07-28', 'Kazakh'),
(143, 72, 'Ah!Yah!Mah!', 271, '2017-05-05', 'Kazakh'),
(144, 72, 'Qarangy Zharyq', 250, '2017-05-05', 'Kazakh'),
(145, 73, 'Aiyau', 215, '2023-11-22', 'Kazakh'),
(146, 73, 'Tynyshtyq', 200, '2023-11-22', 'Kazakh'),
(147, 74, 'Seni Oilap', 190, '2024-01-01', 'Kazakh'),
(148, 74, 'Koktem', 207, '2024-01-01', 'Kazakh'),
(149, 75, 'Rusha Mood', 188, '2024-12-30', 'Kazakh'),
(150, 75, 'Janym Online', 190, '2024-12-30', 'Kazakh'),
(151, 76, 'Bella Night', 185, '2023-03-17', 'Kazakh'),
(152, 76, 'Qaladan Qashyp', 209, '2023-03-17', 'Kazakh'),
(153, 77, 'Pop Star Bala', 167, '2022-12-01', 'Kazakh'),
(154, 77, 'Barin Tusicem', 181, '2022-12-01', 'Kazakh'),
(155, 78, 'Juzim Radio', 195, '2019-01-01', 'Kazakh'),
(156, 78, 'Sen Bar', 206, '2019-01-01', 'Kazakh'),
(157, 79, 'Tokhtar', 203, '2024-12-20', 'Kazakh'),
(158, 79, 'Bugin Tunde', 217, '2024-12-20', 'Kazakh'),
(159, 80, 'DNA Mix 01', 184, '2022-01-01', 'Kazakh'),
(160, 80, 'Jas Qala', 199, '2022-01-01', 'Kazakh'),
(161, 81, 'Arriva', 285, '2020-10-09', 'Kazakh'),
(162, 81, 'Nege?', 196, '2020-10-09', 'Kazakh/Russian'),
(163, 82, 'Poligon', 230, '2019-12-24', 'Russian'),
(164, 82, 'Baby mama', 227, '2019-12-24', 'Russian'),
(165, 83, 'labum Intro', 119, '2020-06-19', 'Kazakh'),
(166, 83, 'Qyzyl Alma', 212, '2020-06-19', 'Kazakh'),
(167, 84, 'Dose Demo One', 178, '2021-09-09', 'Kazakh/Russian'),
(168, 84, 'Не спросят', 193, '2026-03-13', 'Russian'),
(169, 85, 'Medina', 222, '2018-08-24', 'Russian'),
(170, 85, 'Leyla', 185, '2018-08-24', 'Russian'),
(171, 86, 'О2', 203, '2018-11-30', 'Kazakh'),
(172, 86, 'Saulem', 211, '2018-11-30', 'Kazakh'),
(173, 87, 'Джулия', 244, '2013-09-30', 'Russian'),
(174, 87, 'Солдат любви', 232, '2013-09-30', 'Russian'),
(175, 88, 'S.O.S d''un terrien en détresse', 246, '2019-06-14', 'French'),
(176, 88, 'Ұмытылмас күн', 239, '2019-06-14', 'Kazakh'),
(177, 89, 'Qanay Indie Night', 203, '2023-03-01', 'Kazakh'),
(178, 89, 'Almaty Balkon', 215, '2023-03-01', 'Kazakh/Russian'),
(179, 90, 'MDee Bedroom Loop', 192, '2006-01-01', 'Kazakh'),
(180, 90, 'Coffee After 2AM', 206, '2006-01-01', 'English'),
(181, 91, 'Hajime Intro', 111, '2016-09-20', 'Russian'),
(182, 91, 'Самурай', 238, '2016-09-20', 'Russian'),
(183, 92, 'Красота и уродство', 204, '2021-12-01', 'Russian'),
(184, 92, 'Кто убил Марка?', 216, '2021-12-01', 'Russian'),
(185, 93, 'Выход в город', 218, '2020-12-04', 'Russian'),
(186, 93, 'Все как у людей', 201, '2020-12-04', 'Russian'),
(187, 94, 'Million Dollar', 198, '2021-05-21', 'Russian'),
(188, 94, 'Ice', 185, '2021-05-21', 'Russian'),
(189, 95, 'Тамада', 244, '2018-09-07', 'Russian'),
(190, 95, 'Люби меня', 232, '2018-09-07', 'Russian'),
(191, 96, 'Vinyl #1', 174, '2019-09-27', 'Russian'),
(192, 96, 'Beverly Hills', 220, '2019-09-27', 'Russian'),
(193, 97, 'Нимфоманка', 160, '2018-05-25', 'Russian'),
(194, 97, 'Каждый раз', 208, '2018-05-25', 'Russian'),
(195, 98, 'Знаешь ли ты', 242, '2006-03-28', 'Russian'),
(196, 98, 'Трудный возраст', 215, '2006-03-28', 'Russian'),
(197, 99, 'СПИД', 277, '1999-05-10', 'Russian'),
(198, 99, 'Ромашки', 289, '1999-05-10', 'Russian'),
(199, 100, 'Группа крови', 285, '1988-01-05', 'Russian'),
(200, 100, 'Спокойная ночь', 366, '1988-01-05', 'Russian');


INSERT INTO Album_Artists
(album_id, artist_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),

(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),

(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30),

(31, 31),
(32, 32),
(33, 33),
(34, 34),
(35, 35),
(36, 36),
(37, 37),
(38, 38),
(39, 39),
(40, 40),

(41, 41),
(42, 42),
(43, 43),
(44, 44),
(45, 45),
(46, 46),
(47, 47),
(48, 48),
(49, 49),
(50, 50),

(51, 51),
(52, 52),
(53, 53),
(54, 54),
(55, 55),
(56, 56),
(57, 57),
(58, 58),
(59, 59),
(60, 60),

(61, 61),
(62, 62),
(63, 63),
(64, 64),
(65, 65),
(66, 66),
(67, 67),
(68, 68),
(69, 69),
(70, 70),

(71, 71),
(72, 72),
(73, 73),
(74, 74),
(75, 75),
(76, 76),
(77, 77),
(78, 78),
(79, 79),
(80, 80),

(81, 81),
(82, 82),
(83, 83),
(84, 84),
(85, 85),
(86, 86),
(87, 87),
(88, 88),
(89, 89),
(90, 90),

(91, 91),
(92, 92),
(93, 93),
(94, 94),
(95, 95),
(96, 96),
(97, 97),
(98, 98),
(99, 99),
(100, 100);


INSERT INTO Track_Artists
(track_id, artist_id)
VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 3),
(6, 3),
(7, 4),
(8, 4),
(9, 5),
(10, 5),

(11, 6),
(12, 6),
(13, 7),
(14, 7),
(15, 8),
(16, 8),
(17, 9),
(18, 9),
(19, 10),
(20, 10),

(21, 11),
(22, 11),
(23, 12),
(24, 12),
(25, 13),
(26, 13),
(27, 14),
(28, 14),
(29, 15),
(30, 15),

(31, 16),
(32, 16),
(33, 17),
(34, 17),
(35, 18),
(36, 18),
(37, 19),
(38, 19),
(39, 20),
(40, 20),

(41, 21),
(42, 21),
(43, 22),
(44, 22),
(45, 23),
(46, 23),
(47, 24),
(48, 24),
(49, 25),
(50, 25),

(51, 26),
(52, 26),
(53, 27),
(54, 27),
(55, 28),
(56, 28),
(57, 29),
(58, 29),
(59, 30),
(60, 30),

(61, 31),
(62, 31),
(63, 32),
(64, 32),
(65, 33),
(66, 33),
(67, 34),
(68, 34),
(69, 35),
(70, 35),

(71, 36),
(72, 36),
(73, 37),
(74, 37),
(75, 38),
(76, 38),
(77, 39),
(78, 39),
(79, 40),
(80, 40),

(81, 41),
(82, 41),
(83, 42),
(84, 42),
(85, 43),
(86, 43),
(87, 44),
(88, 44),
(89, 45),
(90, 45),

(91, 46),
(92, 46),
(93, 47),
(94, 47),
(95, 48),
(96, 48),
(97, 49),
(98, 49),
(99, 50),
(100, 50),

(101, 51),
(102, 51),
(103, 52),
(104, 52),
(105, 53),
(106, 53),
(107, 54),
(108, 54),
(109, 55),
(110, 55),

(111, 56),
(112, 56),
(113, 57),
(114, 57),
(115, 58),
(116, 58),
(117, 59),
(118, 59),
(119, 60),
(120, 60),

(121, 61),
(122, 61),
(123, 62),
(124, 62),
(125, 63),
(126, 63),
(127, 64),
(128, 64),
(129, 65),
(130, 65),

(131, 66),
(132, 66),
(133, 67),
(134, 67),
(135, 68),
(136, 68),
(137, 69),
(138, 69),
(139, 70),
(140, 70),

(141, 71),
(142, 71),
(143, 72),
(144, 72),
(145, 73),
(146, 73),
(147, 74),
(148, 74),
(149, 75),
(150, 75),

(151, 76),
(152, 76),
(153, 77),
(154, 77),
(155, 78),
(156, 78),
(157, 79),
(158, 79),
(159, 80),
(160, 80),

(161, 81),
(162, 81),
(163, 82),
(164, 82),
(165, 83),
(166, 83),
(167, 84),
(168, 84),
(169, 85),
(170, 85),

(171, 86),
(172, 86),
(173, 87),
(174, 87),
(175, 88),
(176, 88),
(177, 89),
(178, 89),
(179, 90),
(180, 90),

(181, 91),
(182, 91),
(183, 92),
(184, 92),
(185, 93),
(186, 93),
(187, 94),
(188, 94),
(189, 95),
(190, 95),

(191, 96),
(192, 96),
(193, 97),
(194, 97),
(195, 98),
(196, 98),
(197, 99),
(198, 99),
(199, 100),
(200, 100);


INSERT INTO Track_Genres
(track_id, genre_id)
VALUES
(1, 1),
(2, 4),
(3, 4),
(4, 4),
(5, 47),
(6, 1),
(7, 1),
(8, 1),
(9, 1),
(10, 37),

(11, 37),
(12, 47),
(13, 1),
(14, 2),
(15, 32),
(16, 32),
(17, 3),
(18, 3),
(19, 33),
(20, 3),

(21, 1),
(22, 4),
(23, 47),
(24, 5),
(25, 47),
(26, 47),
(27, 1),
(28, 1),
(29, 1),
(30, 46),

(31, 47),
(32, 19),
(33, 19),
(34, 19),
(35, 32),
(36, 4),
(37, 4),
(38, 4),
(39, 2),
(40, 2),

(41, 6),
(42, 6),
(43, 6),
(44, 47),
(45, 20),
(46, 6),
(47, 47),
(48, 47),
(49, 6),
(50, 26),

(51, 5),
(52, 5),
(53, 5),
(54, 5),
(55, 1),
(56, 1),
(57, 5),
(58, 5),
(59, 6),
(60, 6),

(61, 8),
(62, 8),
(63, 8),
(64, 8),
(65, 8),
(66, 8),
(67, 8),
(68, 8),
(69, 10),
(70, 10),

(71, 32),
(72, 37),
(73, 29),
(74, 29),
(75, 10),
(76, 10),
(77, 9),
(78, 9),
(79, 9),
(80, 9),

(81, 12),
(82, 12),
(83, 12),
(84, 19),
(85, 12),
(86, 12),
(87, 12),
(88, 12),
(89, 13),
(90, 13),

(91, 41),
(92, 41),
(93, 13),
(94, 13),
(95, 41),
(96, 41),
(97, 29),
(98, 29),
(99, 11),
(100, 11),

(101, 14),
(102, 14),
(103, 14),
(104, 14),
(105, 14),
(106, 14),
(107, 14),
(108, 14),
(109, 14),
(110, 14),

(111, 14),
(112, 14),
(113, 14),
(114, 14),
(115, 47),
(116, 47),
(117, 15),
(118, 15),
(119, 15),
(120, 15),

(121, 17),
(122, 17),
(123, 16),
(124, 17),
(125, 17),
(126, 16),
(127, 17),
(128, 16),
(129, 16),
(130, 16),

(131, 18),
(132, 18),
(133, 18),
(134, 18),
(135, 18),
(136, 18),
(137, 18),
(138, 18),
(139, 18),
(140, 18),

(141, 21),
(142, 21),
(143, 22),
(144, 22),
(145, 22),
(146, 22),
(147, 22),
(148, 22),
(149, 22),
(150, 22),

(151, 22),
(152, 21),
(153, 22),
(154, 22),
(155, 22),
(156, 22),
(157, 22),
(158, 22),
(159, 22),
(160, 22),

(161, 21),
(162, 21),
(163, 24),
(164, 24),
(165, 21),
(166, 21),
(167, 24),
(168, 21), 
(169, 23),
(170, 23),

(171, 21),
(172, 21),
(173, 23),
(174, 23),
(175, 13),
(176, 21),
(177, 6),
(178, 6),
(179, 4),
(180, 11),

(181, 24),
(182, 24),
(183, 24),
(184, 24),
(185, 24),
(186, 24),
(187, 24),
(188, 33),
(189, 26),
(190, 26),

(191, 23),
(192, 23),
(193, 23),
(194, 23),
(195, 23),
(196, 23),
(197, 5),
(198, 5),
(199, 5),
(200, 5);


INSERT INTO Playlists
(playlist_id, owner_user_id, playlist_name, is_public, created_at)
VALUES
(25, 28, 'moonlady midnight', FALSE, '2020-02-05 22:58:55'),
(1, 1, 'concert 2024', TRUE, '2020-03-05 22:14:39'),
(32, 49, 'Saltanat radio', FALSE, '2020-04-20 11:43:12'),
(19, 21, 'Amina rnb', TRUE, '2020-06-02 21:11:44'),
(12, 7, 'Mix favourites', TRUE, '2020-07-20 13:14:22'),
(56, 42, 'hidden gem', TRUE, '2020-08-12 15:35:12'),
(2, 1, 'PRIVATE', FALSE, '2020-08-19 19:33:12'),
(53, 35, 'АРХИВ 2020', TRUE, '2020-11-02 22:58:55'),
(26, 28, 'depression', FALSE, '2020-11-11 14:08:19'),
(13, 7, 'KPOP shower concert', TRUE, '2021-01-08 16:09:03'),
(3, 1, 'main character vibes', TRUE, '2021-02-11 18:45:08'),
(20, 21, 'казакша', FALSE, '2021-02-20 14:25:30'),
(75, 36, 'FOR HER', FALSE, '2021-03-15 15:44:22'),
(27, 28, 'классическая музыка(25)', FALSE, '2021-04-03 08:31:40'),
(41, 15, 'Ayanchik songs', TRUE, '2021-05-03 10:18:47'),
(7, 2, 'dias random', FALSE, '2021-06-10 09:21:17'),
(50, 29, '2023: latino dance', FALSE, '2021-07-15 17:33:50'),
(33, 49, 'ALA02', TRUE, '2021-08-12 12:24:10'),
(59, 57, 'kirill old but gold', FALSE, '2021-09-05 11:43:12'),
(14, 7, 'Anime openings', TRUE, '2021-09-17 23:21:09'),
(47, 22, 'asselxflow playlist', TRUE, '2021-10-01 18:02:31'),
(62, 58, 'my meditation', FALSE, '2022-01-11 09:42:36'),
(28, 28, 'тыныш', FALSE, '2022-01-16 08:21:57'),
(34, 49, 'Ата-Анамның Вайбы', FALSE, '2022-02-15 12:40:28'),
(8, 2, 'cardio workout', TRUE, '2022-03-18 07:50:19'),
(65, 9, 'assel yoga playlist', TRUE, '2022-04-02 11:18:47'),
(21, 21, 'әндерім', TRUE, '2022-04-17 13:29:08'),
(57, 42, '14.07.2023', TRUE, '2022-05-01 15:35:12'),
(15, 7, 'әдемі енді', FALSE, '2022-05-04 18:18:18'),
(54, 35, 'bike rides', TRUE, '2022-05-08 22:58:55'),
(77, 44, 'music for coding', FALSE, '2022-05-10 02:48:37'),
(4, 1, 'Studying', TRUE, '2022-06-25 11:10:54'),
(44, 16, 'ночной курсор', FALSE, '2022-08-25 02:48:37'),
(60, 57, 'bridgerton vibe', FALSE, '2023-03-01 17:39:27'),
(51, 29, 'GRADUATION', TRUE, '2023-03-01 19:20:15'),
(63, 58, 'for hard lock in', TRUE, '2023-03-04 01:12:59'),
(16, 7, 'edits maybe', TRUE, '2023-03-15 19:44:29'),
(48, 22, 'for crying', TRUE, '2023-03-25 20:44:01'),
(9, 2, 'Madina''s favorite', FALSE, '2023-04-11 20:09:03'),
(45, 16, '___house for walking fast___', TRUE, '2023-04-20 19:10:24'),
(78, 52, 'Adel''s archive', FALSE, '2023-05-20 23:49:27'),
(29, 28, 'absolute cinema', TRUE, '2023-05-25 09:19:33'),
(42, 15, 'английская попса', TRUE, '2023-06-02 13:20:44'),
(22, 21, 'qpop 2023 new wave', TRUE, '2023-06-13 17:05:11'),
(71, 24, 'naruto mix anime', TRUE, '2023-07-01 23:21:09'),
(5, 1, 'после 2 ночи', FALSE, '2023-09-14 01:25:30'),
(37, 10, 'almaty night drive', TRUE, '2023-10-12 23:10:54'),
(35, 49, 'ұмытылған әндер', FALSE, '2024-02-06 15:27:19'),
(67, 11, 'nurziya think mode', FALSE, '2024-02-20 10:02:33'),
(38, 10, 'мен және терезе', FALSE, '2024-02-24 21:55:36'),
(76, 36, 'jazz cafe background', FALSE, '2024-03-07 15:44:22'),
(66, 9, 'утром', FALSE, '2024-04-06 09:07:26'),
(73, 32, 'MY WORKOUT', TRUE, '2024-04-20 07:36:49'),
(58, 42, 'folder 17', FALSE, '2024-05-04 18:42:07'),
(30, 28, 'Біртүрлі плейлист', FALSE, '2024-05-22 23:49:27'),
(52, 29, 'spanish songs', TRUE, '2024-06-10 19:37:05'),
(72, 24, 'Late Night', FALSE, '2024-06-29 23:01:15'),
(39, 10, '_dance_dance_dance_', TRUE, '2024-07-07 22:22:22'),
(69, 18, 'marat chill waves', TRUE, '2024-07-10 20:11:44'),
(55, 35, 'depression', FALSE, '2024-07-19 01:30:09'),
(10, 2, 'vibes from 2021', TRUE, '2024-07-29 18:40:28'),
(23, 21, '...', FALSE, '2024-08-11 23:16:33'),
(17, 7, 'black guys music', TRUE, '2024-08-23 20:09:18'),
(6, 1, '2025 top hits', TRUE, '2025-01-04 16:12:07'),
(43, 15, 'tiktok songs', TRUE, '2025-01-13 18:14:03'),
(40, 10, 'my loveeee', TRUE, '2025-01-17 21:08:46'),
(68, 11, 'exam panic piano', FALSE, '2025-01-25 23:45:10'),
(24, 21, 'random', FALSE, '2025-02-10 01:11:08'),
(11, 2, 'Old (do not delete)', FALSE, '2025-02-10 12:18:47'),
(64, 58, 'FOCUS', FALSE, '2025-02-14 09:42:36'),
(18, 7, 'без причины', FALSE, '2025-03-05 07:28:49'),
(46, 16, 'Deadline', FALSE, '2025-03-09 14:50:02'),
(49, 22, 'Послушать позже', FALSE, '2025-03-17 16:20:31'),
(61, 57, 'makeup songs', FALSE, '2025-03-21 11:09:46'),
(74, 32, 'beach songs', TRUE, '2025-05-18 07:36:49'),
(36, 49, 'nostalgia 2000s russian', TRUE, '2025-06-22 18:27:56'),
(31, 28, 'focus time', FALSE, '2025-07-23 10:13:54'),
(70, 18, 'Airport songs', TRUE, '2025-07-27 06:44:12'),
(79, 60, 'marya 2026 favourites', TRUE, '2026-04-15 18:14:03'),
(80, 60, '혼자 듣기', FALSE, '2026-05-02 22:37:50');

# chronological order
INSERT INTO Playlist_Collaborators
(playlist_id, user_id, role, joined_at)
VALUES
(25, 28, 'owner', '2020-02-05 22:58:55'),
(1, 1, 'owner', '2020-03-05 22:14:39'),
(32, 49, 'owner', '2020-04-20 11:43:12'),
(25, 49, 'viewer', '2020-04-22 12:12:12'),
(32, 28, 'viewer', '2020-05-01 10:20:14'),
(19, 21, 'owner', '2020-06-02 21:11:44'),
(19, 1, 'viewer', '2020-06-08 21:44:19'),
(12, 7, 'owner', '2020-07-20 13:14:22'),
(1, 7, 'editor', '2020-07-25 12:10:09'),
(12, 1, 'viewer', '2020-07-28 15:20:44'),
(1, 21, 'viewer', '2020-08-03 18:44:21'),
(56, 42, 'owner', '2020-08-12 15:35:12'),
(2, 1, 'owner', '2020-08-19 19:33:12'),
(56, 28, 'viewer', '2020-08-20 16:00:29'),
(2, 28, 'viewer', '2020-09-02 22:01:11'),
(53, 35, 'owner', '2020-11-02 22:58:55'),
(53, 49, 'viewer', '2020-11-08 13:49:39'),
(26, 28, 'owner', '2020-11-11 14:08:19'),
(26, 42, 'editor', '2020-11-20 15:02:37'),
(13, 7, 'owner', '2021-01-08 16:09:03'),
(13, 21, 'editor', '2021-02-05 19:13:06'),
(3, 1, 'owner', '2021-02-11 18:45:08'),
(20, 21, 'owner', '2021-02-20 14:25:30'),
(20, 49, 'editor', '2021-03-02 16:09:25'),
(75, 36, 'owner', '2021-03-15 15:44:22'),
(75, 42, 'viewer', '2021-03-20 18:29:55'),
(27, 28, 'owner', '2021-04-03 08:31:40'),
(27, 36, 'viewer', '2021-04-14 09:55:50'),
(41, 15, 'owner', '2021-05-03 10:18:47'),
(3, 15, 'editor', '2021-05-06 13:25:40'),
(41, 7, 'viewer', '2021-05-10 10:39:16'),
(7, 2, 'owner', '2021-06-10 09:21:17'),
(7, 21, 'viewer', '2021-06-18 18:33:48'),
(50, 29, 'owner', '2021-07-15 17:33:50'),
(33, 49, 'owner', '2021-08-12 12:24:10'),
(33, 21, 'editor', '2021-08-20 13:00:38'),
(59, 57, 'owner', '2021-09-05 11:43:12'),
(59, 42, 'viewer', '2021-09-14 12:11:40'),
(14, 7, 'owner', '2021-09-17 23:21:09'),
(50, 22, 'viewer', '2021-10-01 15:18:26'),
(47, 22, 'owner', '2021-10-01 18:02:31'),
(47, 29, 'viewer', '2021-10-09 19:01:20'),
(62, 58, 'owner', '2022-01-11 09:42:36'),
(62, 28, 'viewer', '2022-01-15 10:23:35'),
(28, 28, 'owner', '2022-01-16 08:21:57'),
(28, 58, 'viewer', '2022-01-25 12:00:03'),
(34, 49, 'owner', '2022-02-15 12:40:28'),
(34, 57, 'viewer', '2022-02-20 18:36:44'),
(8, 2, 'owner', '2022-03-18 07:50:19'),
(65, 9, 'owner', '2022-04-02 11:18:47'),
(8, 15, 'editor', '2022-04-03 08:22:19'),
(65, 1, 'viewer', '2022-04-09 13:31:22'),
(21, 21, 'owner', '2022-04-17 13:29:08'),
(21, 28, 'viewer', '2022-04-25 14:18:55'),
(57, 42, 'owner', '2022-05-01 15:35:12'),
(15, 7, 'owner', '2022-05-04 18:18:18'),
(54, 35, 'owner', '2022-05-08 22:58:55'),
(77, 44, 'owner', '2022-05-10 02:48:37'),
(57, 57, 'viewer', '2022-05-11 17:42:18'),
(15, 35, 'viewer', '2022-05-11 22:03:45'),
(54, 42, 'editor', '2022-05-18 23:20:00'),
(4, 1, 'owner', '2022-06-25 11:10:54'),
(4, 22, 'viewer', '2022-07-01 20:17:33'),
(44, 16, 'owner', '2022-08-25 02:48:37'),
(44, 58, 'viewer', '2022-08-30 03:12:49'),
(77, 16, 'viewer', '2022-09-15 03:01:59'),
(60, 57, 'owner', '2023-03-01 17:39:27'),
(51, 29, 'owner', '2023-03-01 19:20:15'),
(63, 58, 'owner', '2023-03-04 01:12:59'),
(60, 49, 'viewer', '2023-03-08 18:55:19'),
(51, 1, 'editor', '2023-03-08 19:26:41'),
(63, 36, 'editor', '2023-03-11 02:04:46'),
(16, 7, 'owner', '2023-03-15 19:44:29'),
(48, 22, 'owner', '2023-03-25 20:44:01'),
(48, 57, 'editor', '2023-03-29 23:10:45'),
(9, 2, 'owner', '2023-04-11 20:09:03'),
(9, 28, 'viewer', '2023-04-18 21:40:05'),
(45, 16, 'owner', '2023-04-20 19:10:24'),
(45, 28, 'editor', '2023-04-28 20:05:18'),
(78, 52, 'owner', '2023-05-20 23:49:27'),
(29, 28, 'owner', '2023-05-25 09:19:33'),
(78, 28, 'viewer', '2023-05-25 23:55:11'),
(29, 16, 'editor', '2023-05-30 10:29:44'),
(42, 15, 'owner', '2023-06-02 13:20:44'),
(42, 1, 'editor', '2023-06-08 16:45:30'),
(22, 21, 'owner', '2023-06-13 17:05:11'),
(71, 24, 'owner', '2023-07-01 23:21:09'),
(14, 24, 'viewer', '2023-07-03 09:10:11'),
(71, 57, 'viewer', '2023-07-09 20:11:01'),
(5, 1, 'owner', '2023-09-14 01:25:30'),
(5, 35, 'viewer', '2023-09-20 23:50:02'),
(37, 10, 'owner', '2023-10-12 23:10:54'),
(37, 16, 'viewer', '2023-10-20 21:19:13'),
(35, 49, 'owner', '2024-02-06 15:27:19'),
(35, 1, 'viewer', '2024-02-10 16:24:32'),
(67, 11, 'owner', '2024-02-20 10:02:33'),
(38, 10, 'owner', '2024-02-24 21:55:36'),
(67, 15, 'viewer', '2024-02-25 11:17:25'),
(38, 49, 'viewer', '2024-03-01 11:11:11'),
(76, 36, 'owner', '2024-03-07 15:44:22'),
(76, 29, 'viewer', '2024-03-13 16:50:07'),
(66, 9, 'owner', '2024-04-06 09:07:26'),
(66, 35, 'editor', '2024-04-10 10:29:54'),
(73, 32, 'owner', '2024-04-20 07:36:49'),
(16, 32, 'editor', '2024-04-24 18:37:12'),
(73, 2, 'viewer', '2024-04-25 08:18:38'),
(58, 42, 'owner', '2024-05-04 18:42:07'),
(58, 22, 'editor', '2024-05-09 19:44:27'),
(30, 28, 'owner', '2024-05-22 23:49:27'),
(30, 57, 'viewer', '2024-05-30 23:58:06'),
(52, 29, 'owner', '2024-06-10 19:37:05'),
(52, 9, 'viewer', '2024-06-14 20:33:33'),
(72, 24, 'owner', '2024-06-29 23:01:15'),
(72, 7, 'editor', '2024-07-01 23:40:48'),
(39, 10, 'owner', '2024-07-07 22:22:22'),
(69, 18, 'owner', '2024-07-10 20:11:44'),
(39, 2, 'editor', '2024-07-12 22:33:08'),
(69, 22, 'viewer', '2024-07-15 21:35:49'),
(55, 35, 'owner', '2024-07-19 01:30:09'),
(55, 58, 'viewer', '2024-07-23 02:08:15'),
(10, 2, 'owner', '2024-07-29 18:40:28'),
(10, 49, 'editor', '2024-08-03 17:15:47'),
(23, 21, 'owner', '2024-08-11 23:16:33'),
(23, 36, 'editor', '2024-08-18 23:40:18'),
(17, 7, 'owner', '2024-08-23 20:09:18'),
(17, 58, 'viewer', '2024-08-30 20:16:52'),
(6, 1, 'owner', '2025-01-04 16:12:07'),
(6, 58, 'editor', '2025-01-09 19:08:14'),
(43, 15, 'owner', '2025-01-13 18:14:03'),
(40, 10, 'owner', '2025-01-17 21:08:46'),
(43, 35, 'viewer', '2025-01-20 18:26:03'),
(40, 21, 'viewer', '2025-01-22 20:04:51'),
(68, 11, 'owner', '2025-01-25 23:45:10'),
(68, 58, 'viewer', '2025-01-30 22:00:17'),
(24, 21, 'owner', '2025-02-10 01:11:08'),
(11, 2, 'owner', '2025-02-10 12:18:47'),
(64, 58, 'owner', '2025-02-14 09:42:36'),
(11, 57, 'viewer', '2025-02-16 11:09:36'),
(64, 21, 'viewer', '2025-02-19 12:12:52'),
(24, 58, 'viewer', '2025-02-20 01:50:29'),
(18, 7, 'owner', '2025-03-05 07:28:49'),
(46, 16, 'owner', '2025-03-09 14:50:02'),
(18, 15, 'editor', '2025-03-11 07:41:09'),
(46, 38, 'viewer', '2025-03-15 15:25:47'),
(49, 22, 'owner', '2025-03-17 16:20:31'),
(61, 57, 'owner', '2025-03-21 11:09:46'),
(49, 15, 'viewer', '2025-03-23 17:56:12'),
(61, 1, 'editor', '2025-03-28 13:13:13'),
(74, 32, 'owner', '2025-05-18 07:36:49'),
(74, 15, 'editor', '2025-05-21 08:06:26'),
(36, 49, 'owner', '2025-06-22 18:27:56'),
(36, 29, 'editor', '2025-06-30 19:11:07'),
(31, 28, 'owner', '2025-07-23 10:13:54'),
(70, 18, 'owner', '2025-07-27 06:44:12'),
(31, 22, 'editor', '2025-07-29 14:41:22'),
(70, 28, 'editor', '2025-07-30 09:24:08'),
(79, 60, 'owner', '2026-04-15 18:14:03'),
(79, 1, 'viewer', '2026-04-18 20:03:44'),
(80, 60, 'owner', '2026-05-02 22:37:50'),
(80, 7, 'viewer', '2026-05-05 23:16:28');


INSERT INTO Playlist_Tracks
(playlist_track_id, playlist_id, track_id, added_by_user_id, added_at, position_no)
VALUES
-- Playlist 25 (3 tracks, chronological group: 2020-02-09 23:15:11 to 2021-02-14 21:49:36)
(94, 25, 26, 28, '2020-02-09 23:15:11', 1),
(95, 25, 44, 28, '2021-02-14 21:49:36', 2),
(96, 25, 47, 28, '2020-02-22 22:07:52', 3),

-- Playlist 32 (3 tracks, chronological group: 2020-04-24 12:18:44 to 2023-08-01 16:33:21)
(118, 32, 141, 49, '2020-04-24 12:18:44', 1),
(119, 32, 142, 49, '2023-08-01 16:33:21', 2),
(120, 32, 143, 49, '2020-05-09 10:55:08', 3),

-- Playlist 12 (5 tracks, chronological group: 2020-08-05 11:33:27 to 2022-09-03 19:21:18)
(44, 12, 5, 7, '2021-08-03 16:11:09', 1),
(45, 12, 11, 7, '2020-08-05 11:33:27', 2),
(46, 12, 15, 7, '2021-08-14 22:47:53', 3),
(47, 12, 49, 7, '2021-08-26 08:09:44', 4),
(48, 12, 59, 7, '2022-09-03 19:21:18', 5),

-- Playlist 56 (3 tracks, chronological group: 2020-08-16 16:22:44 to 2023-08-28 17:44:55)
(195, 56, 99, 42, '2020-08-16 16:22:44', 1),
(196, 56, 100, 42, '2020-08-22 15:33:21', 2),
(197, 56, 73, 42, '2023-08-28 17:44:55', 3),

-- Playlist 2 (3 tracks, chronological group: 2020-09-05 20:12:17 to 2022-06-12 08:44:51)
(6, 2, 37, 1, '2020-09-05 20:12:17', 1),
(7, 2, 115, 1, '2022-06-12 08:44:51', 2),
(8, 2, 47, 1, '2020-11-01 23:05:33', 3),

-- Playlist 53 (3 tracks, chronological group: 2020-11-12 22:44:31 to 2021-01-10 23:22:44)
(186, 53, 23, 35, '2021-01-10 23:22:44', 1),
(187, 53, 25, 35, '2020-11-12 22:44:31', 2),
(188, 53, 29, 35, '2020-11-18 23:17:55', 3),

-- Playlist 26 (4 tracks, chronological group: 2020-11-22 12:07:24 to 2022-12-07 10:13:29)
(97, 26, 5, 28, '2021-08-02 15:28:41', 1),
(98, 26, 12, 28, '2020-11-22 12:07:24', 2),
(99, 26, 25, 28, '2021-11-30 18:45:18', 3),
(100, 26, 44, 28, '2022-12-07 10:13:29', 4),

-- Playlist 13 (6 tracks, chronological group: 2021-01-12 18:55:32 to 2023-07-12 07:31:09)
(49, 13, 101, 7, '2021-01-12 18:55:32', 1),
(50, 13, 102, 7, '2021-01-20 09:44:18', 2),
(51, 13, 103, 7, '2021-02-01 14:23:47', 3),
(52, 13, 105, 7, '2023-07-09 21:07:22', 4),
(53, 13, 107, 7, '2023-07-12 07:31:09', 5),
(54, 13, 109, 7, '2023-03-05 16:16:41', 6),

-- Playlist 20 (5 tracks, chronological group: 2021-02-24 15:37:22 to 2025-01-02 18:08:33)
(77, 20, 141, 21, '2021-02-24 15:37:22', 1),
(78, 20, 142, 21, '2023-07-30 09:48:55', 2),
(79, 20, 145, 21, '2023-11-24 21:11:18', 3),
(80, 20, 147, 21, '2024-01-03 13:29:47', 4),
(81, 20, 149, 21, '2025-01-02 18:08:33', 5),

-- Playlist 75 (3 tracks, chronological group: 2021-03-19 16:22:44 to 2022-03-27 17:44:55)
(246, 75, 22, 36, '2021-03-19 16:22:44', 1),
(247, 75, 30, 36, '2022-03-23 15:33:21', 2),
(248, 75, 33, 36, '2022-03-27 17:44:55', 3),

-- Playlist 27 (4 tracks, chronological group: 2021-04-07 09:34:12 to 2021-04-26 11:44:38)
(101, 27, 89, 28, '2021-04-07 09:34:12', 1),
(102, 27, 90, 28, '2021-04-12 13:56:47', 2),
(103, 27, 93, 28, '2021-04-19 17:23:55', 3),
(104, 27, 94, 28, '2021-04-26 11:44:38', 4),

-- Playlist 3 (4 tracks, chronological group: 2021-04-18 12:17:45 to 2022-05-05 19:56:23)
(9, 3, 5, 1, '2021-08-01 15:22:09', 1),
(10, 3, 39, 1, '2021-04-18 12:17:45', 2),
(11, 3, 49, 1, '2022-05-05 19:56:23', 3),
(12, 3, 59, 1, '2021-06-20 07:09:17', 4),

-- Playlist 41 (3 tracks, chronological group: 2021-05-07 11:27:44 to 2023-05-18 10:18:22)
(146, 41, 29, 15, '2021-05-07 11:27:44', 1),
(147, 41, 30, 15, '2021-05-12 14:55:31', 2),
(148, 41, 7, 15, '2023-05-18 10:18:22', 3),

-- Playlist 19 (4 tracks, chronological group: 2021-06-28 11:22:09 to 2023-02-05 22:09:18)
(73, 19, 2, 21, '2023-02-05 22:09:18', 1),
(74, 19, 4, 21, '2022-05-02 17:33:44', 2),
(75, 19, 22, 21, '2021-06-28 11:22:09', 3),
(76, 19, 36, 21, '2021-07-05 09:55:31', 4),

-- Playlist 33 (3 tracks, chronological group: 2021-08-16 13:22:36 to 2022-08-30 11:14:55)
(121, 33, 101, 49, '2021-08-16 13:22:36', 1),
(122, 33, 102, 49, '2021-08-22 19:47:21', 2),
(123, 33, 103, 49, '2022-08-30 11:14:55', 3),

-- Playlist 59 (3 tracks, chronological group: 2021-09-09 12:22:44 to 2022-09-19 13:44:55)
(203, 59, 29, 57, '2021-09-09 12:22:44', 1),
(204, 59, 30, 57, '2021-09-14 11:33:21', 2),
(205, 59, 57, 57, '2022-09-19 13:44:55', 3),

-- Playlist 14 (4 tracks, chronological group: 2021-10-15 19:24:38 to 2022-12-16 14:08:55)
(55, 14, 117, 7, '2021-12-08 23:35:11', 1),
(56, 14, 118, 7, '2022-12-16 14:08:55', 2),
(57, 14, 119, 7, '2021-10-15 19:24:38', 3),
(58, 14, 120, 7, '2021-10-28 12:11:02', 4),

-- Playlist 7 (3 tracks, chronological group: 2021-10-30 16:24:11 to 2022-07-01 22:13:47)
(27, 7, 53, 2, '2021-10-30 16:24:11', 1),
(28, 7, 54, 2, '2022-06-20 10:58:33', 2),
(29, 7, 163, 2, '2022-07-01 22:13:47', 3),

-- Playlist 62 (3 tracks, chronological group: 2022-01-15 10:22:44 to 2022-01-25 11:44:55)
(212, 62, 73, 58, '2022-01-15 10:22:44', 1),
(213, 62, 97, 58, '2022-01-20 09:33:21', 2),
(214, 62, 99, 58, '2022-01-25 11:44:55', 3),

-- Playlist 28 (3 tracks, chronological group: 2022-01-20 09:27:16 to 2022-02-03 20:18:47)
(105, 28, 73, 28, '2022-01-20 09:27:16', 1),
(106, 28, 97, 28, '2022-01-27 14:55:23', 2),
(107, 28, 99, 28, '2022-02-03 20:18:47', 3),

-- Playlist 34 (3 tracks, chronological group: 2022-02-19 13:44:22 to 2023-03-03 09:27:44)
(124, 34, 195, 49, '2022-02-19 13:44:22', 1),
(125, 34, 196, 49, '2022-02-25 17:31:09', 2),
(126, 34, 197, 49, '2023-03-03 09:27:44', 3),

-- Playlist 8 (5 tracks, chronological group: 2022-03-21 09:15:22 to 2023-07-30 19:07:32)
(30, 8, 61, 2, '2022-03-21 09:15:22', 1),
(31, 8, 63, 2, '2022-03-28 17:42:09', 2),
(32, 8, 67, 2, '2022-04-10 08:23:44', 3),
(33, 8, 19, 2, '2023-07-30 19:07:32', 4),
(34, 8, 188, 2, '2023-05-05 12:14:51', 5),

-- Playlist 65 (3 tracks, chronological group: 2022-04-06 12:22:44 to 2023-04-15 13:44:55)
(220, 65, 73, 9, '2022-04-06 12:22:44', 1),
(221, 65, 89, 9, '2022-04-10 11:33:21', 2),
(222, 65, 99, 9, '2023-04-15 13:44:55', 3),

-- Playlist 21 (3 tracks, chronological group: 2022-04-20 14:16:27 to 2023-05-05 22:33:18)
(82, 21, 143, 21, '2022-04-20 14:16:27', 1),
(83, 21, 144, 21, '2022-04-27 10:59:44', 2),
(84, 21, 151, 21, '2023-05-05 22:33:18', 3),

-- Playlist 47 (3 tracks, chronological group: 2022-05-01 18:44:17 to 2023-02-06 19:22:33)
(166, 47, 2, 22, '2023-02-06 19:22:33', 1),
(167, 47, 4, 22, '2022-05-01 18:44:17', 2),
(168, 47, 22, 22, '2022-10-15 21:08:51', 3),

-- Playlist 15 (4 tracks, chronological group: 2022-05-07 20:14:33 to 2023-07-31 09:47:21)
(59, 15, 141, 7, '2022-05-07 20:14:33', 1),
(60, 15, 142, 7, '2023-07-31 09:47:21', 2),
(61, 15, 143, 7, '2022-05-22 18:06:44', 3),
(62, 15, 144, 7, '2022-06-01 11:33:09', 4),

-- Playlist 50 (4 tracks, chronological group: 2022-05-08 18:33:17 to 2022-08-05 20:44:32)
(175, 50, 121, 29, '2022-05-08 18:33:17', 1),
(176, 50, 122, 29, '2022-05-10 17:55:44', 2),
(177, 50, 123, 29, '2022-07-30 19:21:08', 3),
(178, 50, 124, 29, '2022-08-05 20:44:32', 4),

-- Playlist 54 (3 tracks, chronological group: 2022-05-12 23:33:21 to 2022-05-24 23:44:09)
(189, 54, 49, 35, '2022-05-12 23:33:21', 1),
(190, 54, 51, 35, '2022-05-18 22:18:44', 2),
(191, 54, 59, 35, '2022-05-24 23:44:09', 3),

-- Playlist 77 (3 tracks, chronological group: 2022-05-14 03:22:44 to 2023-05-22 04:44:55)
(252, 77, 99, 44, '2022-05-14 03:22:44', 1),
(253, 77, 89, 44, '2022-05-18 02:33:21', 2),
(254, 77, 73, 44, '2023-05-22 04:44:55', 3),

-- Playlist 57 (2 tracks, chronological group: 2022-06-12 16:22:33 to 2023-05-10 15:44:18)
(198, 57, 115, 42, '2022-06-12 16:22:33', 1),
(199, 57, 47, 42, '2023-05-10 15:44:18', 2),

-- Playlist 4 (5 tracks, chronological group: 2022-06-28 11:15:22 to 2023-08-19 21:10:36)
(13, 4, 99, 1, '2022-06-28 11:15:22', 1),
(14, 4, 89, 1, '2022-07-10 09:43:08', 2),
(15, 4, 73, 1, '2023-07-22 16:21:44', 3),
(16, 4, 91, 1, '2023-08-05 08:57:19', 4),
(17, 4, 97, 1, '2023-08-19 21:10:36', 5),

-- Playlist 44 (3 tracks, chronological group: 2022-08-29 03:22:17 to 2022-09-08 02:33:49)
(156, 44, 115, 16, '2022-08-29 03:22:17', 1),
(157, 44, 44, 16, '2022-09-03 01:45:32', 2),
(158, 44, 47, 16, '2022-09-08 02:33:49', 3),

-- Playlist 60 (3 tracks, chronological group: 2023-03-05 18:22:44 to 2023-03-15 19:11:21)
(206, 60, 33, 57, '2023-03-05 18:22:44', 1),
(207, 60, 34, 57, '2023-03-10 17:44:32', 2),
(208, 60, 83, 57, '2023-03-15 19:11:21', 3),

-- Playlist 51 (3 tracks, chronological group: 2023-03-05 20:22:44 to 2023-03-15 21:44:17)
(179, 51, 1, 29, '2023-03-05 20:22:44', 1),
(180, 51, 7, 29, '2023-03-10 19:33:21', 2),
(181, 51, 11, 29, '2023-03-15 21:44:17', 3),

-- Playlist 63 (3 tracks, chronological group: 2023-03-08 02:22:44 to 2023-03-17 03:44:55)
(215, 63, 89, 58, '2023-03-08 02:22:44', 1),
(216, 63, 90, 58, '2023-03-12 01:33:21', 2),
(217, 63, 91, 58, '2023-03-17 03:44:55', 3),

-- Playlist 16 (4 tracks, chronological group: 2023-03-18 21:25:16 to 2024-04-08 08:09:27)
(63, 16, 39, 7, '2023-03-18 21:25:16', 1),
(64, 16, 40, 7, '2023-03-27 13:17:43', 2),
(65, 16, 19, 7, '2024-04-08 08:09:27', 3),
(66, 16, 20, 7, '2023-08-02 22:36:15', 4),

-- Playlist 48 (4 tracks, chronological group: 2023-03-29 21:33:44 to 2024-04-13 20:11:35)
(169, 48, 5, 22, '2023-03-29 21:33:44', 1),
(170, 48, 12, 22, '2023-04-03 19:17:22', 2),
(171, 48, 25, 22, '2023-04-08 22:44:09', 3),
(172, 48, 44, 22, '2024-04-13 20:11:35', 4),

-- Playlist 9 (3 tracks, chronological group: 2023-04-13 21:33:17 to 2023-05-01 10:27:43)
(35, 9, 1, 2, '2023-04-13 21:33:17', 1),
(36, 9, 2, 2, '2023-04-20 14:49:55', 2),
(37, 9, 141, 2, '2023-05-01 10:27:43', 3),

-- Playlist 45 (4 tracks, chronological group: 2023-04-24 20:11:24 to 2024-05-12 20:55:33)
(159, 45, 69, 16, '2023-04-24 20:11:24', 1),
(160, 45, 70, 16, '2023-04-30 18:44:51', 2),
(161, 45, 75, 16, '2023-06-17 19:27:08', 3),
(162, 45, 76, 16, '2024-05-12 20:55:33', 4),

-- Playlist 78 (2 tracks, chronological group: 2023-05-24 00:22:44 to 2024-05-28 23:33:21)
(255, 78, 23, 52, '2023-05-24 00:22:44', 1),
(256, 78, 25, 52, '2024-05-28 23:33:21', 2),

-- Playlist 29 (4 tracks, chronological group: 2023-05-28 10:22:34 to 2023-06-20 22:33:18)
(108, 29, 91, 28, '2023-05-28 10:22:34', 1),
(109, 29, 92, 28, '2023-06-03 15:47:21', 2),
(110, 29, 95, 28, '2023-06-12 09:14:55', 3),
(111, 29, 96, 28, '2023-06-20 22:33:18', 4),

-- Playlist 42 (4 tracks, chronological group: 2023-06-06 14:22:16 to 2023-06-23 09:27:34)
(149, 42, 1, 15, '2023-06-06 14:22:16', 1),
(150, 42, 7, 15, '2023-06-11 11:39:45', 2),
(151, 42, 11, 15, '2023-06-17 13:11:08', 3),
(152, 42, 15, 15, '2023-06-23 09:27:34', 4),

-- Playlist 22 (5 tracks, chronological group: 2023-06-17 18:27:11 to 2024-07-10 16:53:22)
(85, 22, 143, 21, '2023-06-17 18:27:11', 1),
(86, 22, 144, 21, '2023-06-22 11:44:33', 2),
(87, 22, 145, 21, '2024-06-30 07:19:08', 3),
(88, 22, 146, 21, '2024-07-10 16:53:22', 4),
(89, 22, 147, 21, '2024-01-04 22:08:45', 5),

-- Playlist 71 (3 tracks, chronological group: 2023-07-05 00:22:44 to 2023-07-13 01:44:55)
(234, 71, 117, 24, '2023-07-05 00:22:44', 1),
(235, 71, 118, 24, '2023-07-09 23:33:21', 2),
(236, 71, 119, 24, '2023-07-13 01:44:55', 3),

-- Playlist 5 (4 tracks, chronological group: 2023-09-25 01:47:22 to 2024-10-08 03:33:51)
(18, 5, 26, 1, '2024-09-17 23:15:08', 1),
(19, 5, 44, 1, '2023-09-25 01:47:22', 2),
(20, 5, 115, 1, '2024-10-08 03:33:51', 3),
(21, 5, 47, 1, '2023-10-20 22:09:14', 4),

-- Playlist 37 (4 tracks, chronological group: 2023-10-16 23:35:21 to 2024-10-30 11:49:08)
(133, 37, 163, 10, '2023-10-16 23:35:21', 1),
(134, 37, 164, 10, '2023-10-22 19:16:44', 2),
(135, 37, 169, 10, '2024-10-30 11:49:08', 3),
(136, 37, 181, 10, '2023-11-05 22:27:33', 4),

-- Playlist 35 (3 tracks, chronological group: 2024-02-10 16:21:38 to 2024-02-24 22:33:56)
(127, 35, 141, 49, '2024-02-10 16:21:38', 1),
(128, 35, 143, 49, '2024-02-17 10:49:17', 2),
(129, 35, 145, 49, '2024-02-24 22:33:56', 3),

-- Playlist 67 (2 tracks, chronological group: 2024-02-24 11:22:44 to 2024-02-28 10:33:21)
(225, 67, 99, 11, '2024-02-24 11:22:44', 1),
(226, 67, 89, 11, '2024-02-28 10:33:21', 2),

-- Playlist 38 (2 tracks, chronological group: 2024-02-28 22:14:47 to 2025-03-05 20:33:22)
(137, 38, 115, 10, '2024-02-28 22:14:47', 1),
(138, 38, 47, 10, '2025-03-05 20:33:22', 2),

-- Playlist 76 (3 tracks, chronological group: 2024-03-11 16:22:44 to 2024-03-19 17:44:55)
(249, 76, 81, 36, '2024-03-11 16:22:44', 1),
(250, 76, 82, 36, '2024-03-15 15:33:21', 2),
(251, 76, 85, 36, '2024-03-19 17:44:55', 3),

-- Playlist 66 (2 tracks, chronological group: 2024-04-10 10:22:44 to 2025-04-14 09:33:21)
(223, 66, 1, 9, '2024-04-10 10:22:44', 1),
(224, 66, 7, 9, '2025-04-14 09:33:21', 2),

-- Playlist 73 (4 tracks, chronological group: 2024-04-24 08:22:44 to 2024-05-06 06:11:17)
(239, 73, 61, 32, '2024-04-24 08:22:44', 1),
(240, 73, 63, 32, '2024-04-28 07:33:21', 2),
(241, 73, 67, 32, '2024-05-02 09:44:55', 3),
(242, 73, 19, 32, '2024-05-06 06:11:17', 4),

-- Playlist 58 (3 tracks, chronological group: 2024-05-08 19:22:44 to 2025-05-18 20:11:17)
(200, 58, 17, 42, '2024-05-08 19:22:44', 1),
(201, 58, 18, 42, '2024-05-13 18:44:32', 2),
(202, 58, 39, 42, '2025-05-18 20:11:17', 3),

-- Playlist 1 (5 tracks, chronological group: 2024-05-15 18:23:11 to 2025-08-03 11:33:27)
(1, 1, 1, 1, '2024-05-15 18:23:11', 1),
(2, 1, 7, 1, '2024-06-01 09:47:32', 2),
(3, 1, 11, 1, '2024-06-10 22:15:04', 3),
(4, 1, 15, 1, '2024-07-20 14:08:49', 4),
(5, 1, 29, 1, '2025-08-03 11:33:27', 5),

-- Playlist 30 (3 tracks, chronological group: 2024-05-26 23:17:44 to 2024-06-11 21:08:12)
(112, 30, 141, 28, '2024-05-26 23:17:44', 1),
(113, 30, 163, 28, '2024-06-02 15:52:31', 2),
(114, 30, 183, 28, '2024-06-11 21:08:12', 3),

-- Playlist 52 (4 tracks, chronological group: 2024-06-14 20:11:32 to 2024-07-29 21:22:44)
(182, 52, 121, 29, '2024-06-14 20:11:32', 1),
(183, 52, 122, 29, '2024-06-19 18:44:55', 2),
(184, 52, 125, 29, '2024-06-24 19:33:18', 3),
(185, 52, 127, 29, '2024-07-29 21:22:44', 4),

-- Playlist 72 (2 tracks, chronological group: 2024-07-03 00:22:44 to 2024-07-07 23:33:21)
(237, 72, 115, 24, '2024-07-03 00:22:44', 1),
(238, 72, 47, 24, '2024-07-07 23:33:21', 2),

-- Playlist 39 (4 tracks, chronological group: 2024-07-11 23:09:15 to 2024-07-30 22:55:41)
(139, 39, 61, 10, '2024-07-11 23:09:15', 1),
(140, 39, 63, 10, '2024-07-17 21:44:32', 2),
(141, 39, 67, 10, '2024-07-23 20:17:56', 3),
(142, 39, 15, 10, '2024-07-30 22:55:41', 4),

-- Playlist 69 (3 tracks, chronological group: 2024-07-14 21:22:44 to 2024-07-22 22:44:55)
(229, 69, 47, 18, '2024-07-14 21:22:44', 1),
(230, 69, 48, 18, '2024-07-18 20:33:21', 2),
(231, 69, 49, 18, '2024-07-22 22:44:55', 3),

-- Playlist 55 (3 tracks, chronological group: 2024-07-23 02:22:44 to 2025-08-02 02:11:17)
(192, 55, 5, 35, '2024-07-23 02:22:44', 1),
(193, 55, 12, 35, '2024-07-28 01:44:32', 2),
(194, 55, 44, 35, '2025-08-02 02:11:17', 3),

-- Playlist 10 (4 tracks, chronological group: 2024-08-01 19:16:21 to 2024-08-22 17:19:36)
(38, 10, 23, 2, '2024-08-01 19:16:21', 1),
(39, 10, 25, 2, '2024-08-07 12:03:47', 2),
(40, 10, 26, 2, '2024-08-15 23:41:08', 3),
(41, 10, 33, 2, '2024-08-22 17:19:36', 4),

-- Playlist 23 (2 tracks, chronological group: 2024-08-14 23:51:17 to 2025-08-20 20:14:32)
(90, 23, 115, 21, '2024-08-14 23:51:17', 1),
(91, 23, 47, 21, '2025-08-20 20:14:32', 2),

-- Playlist 17 (4 tracks, chronological group: 2024-08-27 21:08:33 to 2025-09-10 10:24:47)
(67, 17, 17, 7, '2024-08-27 21:08:33', 1),
(68, 17, 18, 7, '2025-09-03 14:56:21', 2),
(69, 17, 39, 7, '2025-09-10 10:24:47', 3),
(70, 17, 169, 7, '2024-09-18 17:41:08', 4),

-- Playlist 6 (5 tracks, chronological group: 2025-01-06 12:22:33 to 2025-02-01 20:56:28)
(22, 6, 7, 1, '2025-01-06 12:22:33', 1),
(23, 6, 11, 1, '2025-01-10 18:44:17', 2),
(24, 6, 15, 1, '2025-01-15 09:11:42', 3),
(25, 6, 29, 1, '2025-01-25 14:27:05', 4),
(26, 6, 131, 1, '2025-02-01 20:56:28', 5),

-- Playlist 43 (3 tracks, chronological group: 2025-01-17 19:33:22 to 2025-01-28 20:11:43)
(153, 43, 23, 15, '2025-01-17 19:33:22', 1),
(154, 43, 24, 15, '2025-01-22 17:48:56', 2),
(155, 43, 131, 15, '2025-01-28 20:11:43', 3),

-- Playlist 40 (3 tracks, chronological group: 2025-01-21 22:18:33 to 2025-02-02 21:07:58)
(143, 40, 22, 10, '2025-01-21 22:18:33', 1),
(144, 40, 30, 10, '2025-01-27 19:44:21', 2),
(145, 40, 33, 10, '2025-02-02 21:07:58', 3),

-- Playlist 68 (2 tracks, chronological group: 2025-01-29 00:22:44 to 2025-02-02 23:33:21)
(227, 68, 89, 11, '2025-01-29 00:22:44', 1),
(228, 68, 90, 11, '2025-02-02 23:33:21', 2),

-- Playlist 24 (2 tracks, chronological group: 2025-02-13 02:33:19 to 2025-02-17 23:41:44)
(92, 24, 61, 21, '2025-02-13 02:33:19', 1),
(93, 24, 63, 21, '2025-02-17 23:41:44', 2),

-- Playlist 11 (2 tracks, chronological group: 2025-02-13 13:22:15 to 2025-02-18 09:54:42)
(42, 11, 29, 2, '2025-02-13 13:22:15', 1),
(43, 11, 30, 2, '2025-02-18 09:54:42', 2),

-- Playlist 64 (2 tracks, chronological group: 2025-02-18 10:22:44 to 2025-02-22 09:33:21)
(218, 64, 99, 58, '2025-02-18 10:22:44', 1),
(219, 64, 89, 58, '2025-02-22 09:33:21', 2),

-- Playlist 18 (2 tracks, chronological group: 2025-03-09 08:12:33 to 2025-03-14 19:44:27)
(71, 18, 115, 7, '2025-03-09 08:12:33', 1),
(72, 18, 47, 7, '2025-03-14 19:44:27', 2),

-- Playlist 46 (3 tracks, chronological group: 2025-03-13 15:22:44 to 2025-03-23 14:11:06)
(163, 46, 99, 16, '2025-03-13 15:22:44', 1),
(164, 46, 89, 16, '2025-03-18 13:47:21', 2),
(165, 46, 73, 16, '2025-03-23 14:11:06', 3),

-- Playlist 49 (2 tracks, chronological group: 2025-03-21 17:22:18 to 2025-03-26 18:44:32)
(173, 49, 117, 22, '2025-03-21 17:22:18', 1),
(174, 49, 118, 22, '2025-03-26 18:44:32', 2),

-- Playlist 61 (3 tracks, chronological group: 2025-03-25 12:22:44 to 2025-04-04 13:44:55)
(209, 61, 1, 57, '2025-03-25 12:22:44', 1),
(210, 61, 7, 57, '2025-03-30 11:33:21', 2),
(211, 61, 15, 57, '2025-04-04 13:44:55', 3),

-- Playlist 74 (3 tracks, chronological group: 2025-05-22 08:22:44 to 2025-05-30 09:44:55)
(243, 74, 121, 32, '2025-05-22 08:22:44', 1),
(244, 74, 122, 32, '2025-05-26 07:33:21', 2),
(245, 74, 131, 32, '2025-05-30 09:44:55', 3),

-- Playlist 36 (3 tracks, chronological group: 2025-06-26 19:22:14 to 2025-07-10 09:11:02)
(130, 36, 173, 49, '2025-06-26 19:22:14', 1),
(131, 36, 174, 49, '2025-07-03 14:47:36', 2),
(132, 36, 195, 49, '2025-07-10 09:11:02', 3),

-- Playlist 31 (3 tracks, chronological group: 2025-07-26 11:27:53 to 2025-08-07 09:44:17)
(115, 31, 89, 28, '2025-07-26 11:27:53', 1),
(116, 31, 99, 28, '2025-08-01 14:16:28', 2),
(117, 31, 73, 28, '2025-08-07 09:44:17', 3),

-- Playlist 70 (2 tracks, chronological group: 2025-07-31 07:22:44 to 2025-08-04 06:33:21)
(232, 70, 115, 18, '2025-07-31 07:22:44', 1),
(233, 70, 47, 18, '2025-08-04 06:33:21', 2),

-- Playlist 79 (4 tracks, chronological group: 2026-04-19 19:22:44 to 2026-05-01 17:11:18)
(257, 79, 1, 60, '2026-04-19 19:22:44', 1),
(258, 79, 7, 60, '2026-04-23 18:33:21', 2),
(259, 79, 11, 60, '2026-04-27 20:44:55', 3),
(260, 79, 15, 60, '2026-05-01 17:11:18', 4),

-- Playlist 80 (3 tracks, chronological group: 2026-05-06 23:22:44 to 2026-05-12 00:44:55)
(261, 80, 101, 60, '2026-05-06 23:22:44', 1),
(262, 80, 102, 60, '2026-05-09 22:33:21', 2),
(263, 80, 105, 60, '2026-05-12 00:44:55', 3);


INSERT INTO Listening_History
(history_id, user_id, track_id, playlist_id, subscription_id, device_id, played_at, completed_seconds)
VALUES
(1, 28, 86, NULL, 28, 63, '2020-02-09 16:45:22', 173),
(2, 28, 36, NULL, 28, 64, '2020-02-10 17:42:40', 172),
(3, 28, 26, 25, 28, 64, '2020-02-11 10:26:40', 259),
(4, 1, 25, NULL, 1, 1, '2020-02-19 20:39:36', 269),
(5, 1, 155, NULL, 1, 1, '2020-02-20 20:35:19', 187),
(6, 1, 26, 25, 1, 1, '2020-02-23 01:36:07', 276),
(7, 28, 47, 25, 28, 64, '2020-02-23 09:09:58', 249),
(8, 28, 26, 25, 28, 64, '2020-02-23 13:38:59', 248),
(9, 1, 47, 25, 1, 1, '2020-02-23 15:19:52', 261),
(10, 1, 26, 25, 1, 1, '2020-02-23 16:52:37', 259),
(11, 28, 193, NULL, 28, 64, '2020-02-25 01:25:11', 150),
(12, 1, 26, 25, 1, 1, '2020-02-28 00:44:57', 271),
(13, 1, 141, NULL, 1, 1, '2020-03-02 22:09:15', 236),
(14, 1, 26, 25, 1, 1, '2020-03-05 11:22:14', 243),
(15, 1, 192, NULL, 1, 1, '2020-03-05 23:47:10', 194),
(16, 28, 129, NULL, 28, 64, '2020-03-08 07:05:31', 176),
(17, 1, 47, 25, 1, 2, '2020-03-09 14:29:29', 289),
(18, 1, 47, 25, 1, 1, '2020-03-09 22:08:29', 273),
(19, 28, 47, 25, NULL, 63, '2020-03-10 11:25:07', 278),
(20, 1, 26, 25, 1, 2, '2020-03-16 01:56:49', 278),
(21, 1, 26, 25, 1, 1, '2020-03-16 23:31:44', 274),
(22, 28, 47, 25, 28, 64, '2020-04-06 10:00:33', 255),
(23, 49, 47, 25, 49, 110, '2020-04-12 10:40:39', 261),
(24, 49, 26, 25, 49, 110, '2020-04-14 20:09:46', 259),
(25, 28, 26, 25, 28, 64, '2020-04-15 18:06:19', 279),
(26, 49, 141, 32, 49, 111, '2020-04-27 23:01:59', 230),
(27, 49, 163, NULL, 49, 110, '2020-05-07 01:58:43', 225),
(28, 49, 181, NULL, 49, 111, '2020-05-21 09:18:41', 109),
(29, 49, 26, 25, 49, 110, '2020-05-21 11:25:10', 268),
(30, 21, 57, NULL, 21, 47, '2020-05-28 12:36:03', 206),
(31, 49, 200, NULL, 49, 111, '2020-05-29 01:47:51', 337),
(32, 49, 26, 25, 49, 111, '2020-06-05 06:57:28', 265),
(33, 21, 143, 32, 21, 47, '2020-06-06 12:07:12', 260),
(34, 21, 143, 32, 21, 47, '2020-06-12 20:38:42', 269),
(35, 21, 91, NULL, 21, 47, '2020-06-14 16:15:05', 108),
(36, 49, 16, NULL, 49, 111, '2020-06-16 11:50:15', 170),
(37, 49, 67, NULL, 49, 110, '2020-06-18 05:15:06', 220),
(38, 49, 26, 25, 49, 111, '2020-06-18 21:52:32', 259),
(39, 49, 26, 25, 49, 111, '2020-06-27 11:17:20', 277),
(40, 49, 81, NULL, 49, 110, '2020-06-28 07:43:02', 500),
(41, 49, 25, NULL, NULL, 111, '2020-07-03 04:58:33', 280),
(42, 21, 26, 25, NULL, 47, '2020-07-15 01:00:49', 243),
(43, 28, 26, 25, NULL, 64, '2020-07-17 23:47:43', 248),
(44, 7, 143, 32, 7, 14, '2020-07-18 21:10:34', 244),
(45, 7, 47, 25, 7, 14, '2020-07-19 07:29:18', 267),
(46, 7, 81, NULL, 7, 14, '2020-07-19 14:02:02', 514),
(47, 7, 181, NULL, 7, 14, '2020-07-26 23:27:07', 107),
(48, 7, 93, NULL, 7, 14, '2020-08-01 01:39:36', 183),
(49, 7, 141, 32, 7, 14, '2020-08-01 20:15:40', 224),
(50, 7, 47, NULL, 7, 14, '2020-08-02 08:49:59', 287),
(51, 21, 37, NULL, NULL, 47, '2020-08-07 12:21:32', 243),
(52, 42, 94, NULL, 42, 95, '2020-08-08 05:58:15', 255),
(53, 7, 26, 25, 7, 14, '2020-08-09 05:46:38', 265),
(54, 42, 11, 12, 42, 95, '2020-08-10 22:54:22', 192),
(55, 7, 143, 32, 7, 14, '2020-08-11 05:24:49', 266),
(56, 42, 26, 25, NULL, 95, '2020-08-12 14:04:46', 264),
(57, 42, 141, 32, 42, 95, '2020-08-14 14:10:52', 222),
(58, 42, 26, 25, 42, 95, '2020-08-16 16:22:56', 254),
(59, 7, 26, 25, NULL, 14, '2020-08-17 19:54:49', 259),
(60, 42, 100, 56, NULL, 95, '2020-08-25 05:24:24', 316),
(61, 42, 99, 56, 42, 95, '2020-09-05 10:33:34', 168),
(62, 7, 37, NULL, NULL, 14, '2020-09-09 15:31:42', 301),
(63, 21, 141, 32, NULL, 47, '2020-09-15 11:43:14', 239),
(64, 49, 37, NULL, NULL, 111, '2020-10-04 22:03:28', 270),
(65, 1, 143, 32, NULL, 1, '2020-10-25 05:11:20', 253),
(66, 7, 37, 2, NULL, 14, '2020-10-25 20:39:07', 307),
(67, 35, 171, NULL, 35, 79, '2020-10-31 00:53:40', 191),
(68, 35, 165, NULL, 35, 79, '2020-11-02 08:27:01', 116),
(69, 35, 72, NULL, 35, 79, '2020-11-03 05:00:24', 330),
(70, 35, 143, 32, 35, 79, '2020-11-03 11:38:56', 270),
(71, 7, 143, 32, NULL, 14, '2020-11-04 05:04:40', 248),
(72, 35, 182, NULL, 35, 79, '2020-11-04 23:14:39', 214),
(73, 35, 47, 2, 35, 79, '2020-11-08 11:05:37', 267),
(74, 35, 35, NULL, 35, 79, '2020-11-09 09:46:41', 206),
(75, 35, 26, 25, 35, 79, '2020-11-10 12:09:08', 271),
(76, 35, 37, 2, 35, 79, '2020-11-11 00:59:27', 303),
(77, 35, 141, 32, 35, 79, '2020-11-11 05:36:33', 237),
(78, 42, 135, NULL, NULL, 96, '2020-11-11 06:53:43', 182),
(79, 35, 47, 25, 35, 79, '2020-11-16 11:31:40', 261),
(80, 35, 190, NULL, 35, 79, '2020-11-16 20:05:52', 213),
(81, 35, 25, 53, 35, 79, '2020-11-22 02:37:23', 269),
(82, 35, 26, 25, 35, 79, '2020-11-23 21:32:28', 271),
(83, 35, 100, 56, NULL, 79, '2020-12-01 00:27:13', 329),
(84, 21, 39, NULL, NULL, 47, '2020-12-04 19:37:50', 184),
(85, 7, 12, 26, NULL, 14, '2020-12-09 17:32:46', 155),
(86, 35, 99, 56, NULL, 79, '2021-02-12 03:02:56', 158),
(87, 36, 73, NULL, 36, 82, '2021-03-19 23:31:18', 270),
(88, 36, 143, NULL, 36, 82, '2021-04-05 03:22:49', 255),
(89, 36, 22, 75, 36, 82, '2021-04-13 15:21:59', 196),
(90, 36, 59, NULL, 36, 82, '2021-04-16 12:18:31', 235),
(91, 1, 12, 26, NULL, 2, '2021-04-24 01:08:23', 140),
(92, 36, 26, 25, 36, 81, '2021-04-28 05:20:05', 248),
(93, 15, 141, 32, 15, 33, '2021-04-29 10:29:25', 216),
(94, 15, 89, 27, 15, 33, '2021-04-29 16:47:42', 190),
(95, 15, 23, 53, 15, 33, '2021-04-30 15:30:00', 227),
(96, 36, 100, 56, 36, 82, '2021-05-01 05:32:22', 323),
(97, 36, 44, 25, 36, 82, '2021-05-02 01:29:43', 337),
(98, 15, 101, 13, 15, 33, '2021-05-02 16:33:50', 178),
(99, 36, 103, 13, 36, 82, '2021-05-05 01:50:07', 176),
(100, 15, 82, NULL, 15, 33, '2021-05-05 06:53:44', 823),
(101, 36, 47, 2, 36, 82, '2021-05-05 07:20:18', 269),
(102, 15, 93, 27, 15, 33, '2021-05-06 12:48:40', 185),
(103, 28, 29, 53, NULL, 64, '2021-05-06 19:35:18', 224),
(104, 15, 141, 32, 15, 33, '2021-05-08 06:59:51', 205),
(105, 15, 22, 75, 15, 33, '2021-05-10 12:59:26', 173),
(106, 36, 47, 2, 36, 81, '2021-05-13 08:10:36', 255),
(107, 1, 26, 25, NULL, 1, '2021-05-16 21:53:06', 254),
(108, 15, 30, 41, 15, 33, '2021-05-17 12:15:00', 242),
(109, 15, 22, 75, 15, 33, '2021-05-20 01:19:34', 189),
(110, 15, 30, 41, 15, 33, '2021-05-20 20:09:16', 252),
(111, 15, 102, 13, 15, 33, '2021-05-22 01:52:24', 195),
(112, 15, 89, 27, 15, 33, '2021-05-22 22:38:44', 198),
(113, 15, 156, NULL, 15, 33, '2021-05-25 17:20:59', 181),
(114, 36, 25, 53, 36, 82, '2021-05-30 22:42:08', 265),
(115, 36, 182, NULL, 36, 81, '2021-06-04 16:18:25', 219),
(116, 36, 23, NULL, 36, 82, '2021-06-05 23:32:16', 227),
(117, 2, 100, 56, 2, 4, '2021-06-06 19:42:32', 281),
(118, 2, 22, 75, 2, 4, '2021-06-10 13:19:51', 197),
(119, 2, 94, 27, 2, 4, '2021-06-11 09:21:59', 213),
(120, 28, 89, 27, NULL, 64, '2021-06-17 14:38:38', 181),
(121, 2, 198, NULL, 2, 4, '2021-06-19 16:55:32', 271),
(122, 2, 141, 20, 2, 3, '2021-06-23 08:46:07', 226),
(123, 15, 191, NULL, NULL, 33, '2021-06-25 15:32:11', 164),
(124, 2, 102, 13, 2, 4, '2021-06-26 16:38:46', 191),
(125, 2, 23, 53, 2, 4, '2021-06-29 22:44:52', 237),
(126, 2, 44, 25, 2, 4, '2021-06-30 01:39:42', 296),
(127, 29, 100, 56, 29, 66, '2021-07-10 15:04:09', 317),
(128, 29, 197, NULL, 29, 66, '2021-07-11 10:11:42', 249),
(129, 29, 22, 19, 29, 66, '2021-07-11 20:22:28', 189),
(130, 29, 101, 13, 29, 66, '2021-07-14 03:52:00', 200),
(131, 36, 99, 56, NULL, 82, '2021-07-15 01:02:08', 168),
(132, 29, 39, 3, 29, 66, '2021-07-22 11:59:38', 186),
(133, 29, 100, 56, 29, 67, '2021-07-23 07:04:33', 308),
(134, 29, 120, NULL, 29, 66, '2021-07-27 09:08:47', 243),
(135, 29, 30, 41, 29, 66, '2021-08-01 02:50:59', 238),
(136, 29, 11, 12, 29, 66, '2021-08-06 11:23:00', 144),
(137, 29, 37, 2, 29, 67, '2021-08-07 05:53:38', 289),
(138, 2, 40, NULL, NULL, 4, '2021-08-15 10:38:12', 202),
(139, 29, 26, 25, NULL, 66, '2021-08-24 05:40:11', 276),
(140, 29, 30, 41, NULL, 66, '2021-08-24 06:53:49', 249),
(141, 21, 11, 12, NULL, 47, '2021-08-31 03:56:52', 197),
(142, 57, 22, 19, 57, 127, '2021-09-01 05:07:51', 192),
(143, 29, 25, NULL, NULL, 66, '2021-09-05 08:01:27', 269),
(144, 57, 99, 56, 57, 127, '2021-09-08 17:10:48', 164),
(145, 57, 44, 25, 57, 127, '2021-09-08 19:23:01', 330),
(146, 57, 22, 19, 57, 127, '2021-09-10 13:57:50', 197),
(147, 57, 47, 2, 57, 127, '2021-09-12 05:25:49', 278),
(148, 57, 59, 3, 57, 127, '2021-09-15 17:59:04', 212),
(149, 57, 25, 53, 57, 127, '2021-09-17 04:06:26', 257),
(150, 57, 93, 27, 57, 127, '2021-09-17 14:46:46', 172),
(151, 57, 29, 41, 57, 127, '2021-09-17 21:10:42', 219),
(152, 22, 22, 75, 22, 50, '2021-09-21 11:05:08', 198),
(153, 57, 101, 33, 57, 127, '2021-09-22 13:54:40', 149),
(154, 22, 59, NULL, 22, 50, '2021-09-24 06:23:37', 206),
(155, 22, 5, 12, 22, 50, '2021-09-24 16:05:33', 262),
(156, 57, 90, 27, 57, 127, '2021-09-24 19:21:53', 354),
(157, 22, 68, NULL, 22, 50, '2021-09-25 18:47:05', 191),
(158, 22, 89, 27, 22, 50, '2021-09-26 22:56:13', 194),
(159, 57, 100, 56, 57, 127, '2021-09-28 16:41:35', 333),
(160, 22, 94, 27, 22, 49, '2021-10-01 01:48:26', 250),
(161, 22, 22, 19, 22, 50, '2021-10-01 21:45:55', 177),
(162, 22, 103, 13, 22, 50, '2021-10-01 21:58:37', 175),
(163, 22, 141, 32, 22, 50, '2021-10-02 21:48:44', 235),
(164, 22, 5, 3, 22, 50, '2021-10-04 14:18:24', 285),
(165, 29, 36, 19, NULL, 66, '2021-10-05 16:32:58', 180),
(166, 35, 195, NULL, NULL, 79, '2021-10-10 07:57:32', 232),
(167, 7, 37, 2, NULL, 14, '2021-10-10 21:30:55', 301),
(168, 1, 25, 53, NULL, 1, '2021-10-29 16:07:58', 246),
(169, 36, 40, NULL, NULL, 82, '2021-11-25 10:21:35', 179),
(170, 1, 49, 12, NULL, 2, '2021-11-26 07:43:03', 189),
(171, 58, 102, 13, 58, 130, '2022-01-08 12:09:57', 183),
(172, 58, 11, 12, 58, 129, '2022-01-09 22:01:07', 188),
(173, 58, 23, 53, 58, 130, '2022-02-01 14:56:14', 232),
(174, 58, 49, 12, 58, 130, '2022-02-01 18:02:20', 212),
(175, 58, 36, 19, 58, 130, '2022-02-04 12:26:14', 164),
(176, 58, 94, 27, 58, 130, '2022-02-05 14:51:46', 224),
(177, 58, 73, 28, 58, 130, '2022-02-05 22:09:58', 290),
(178, 22, 13, NULL, NULL, 50, '2022-02-12 19:21:13', 158),
(179, 30, 199, NULL, 30, 68, '2022-02-16 21:16:50', 282),
(180, 30, 25, 53, 30, 68, '2022-02-16 23:06:43', 281),
(181, 30, 99, 62, 30, 68, '2022-02-17 07:14:34', 172),
(182, 30, 73, 62, 30, 68, '2022-02-22 22:11:26', 199),
(183, 30, 40, NULL, 30, 68, '2022-02-23 11:03:09', 185),
(184, 30, 25, 26, 30, 68, '2022-02-23 17:39:35', 278),
(185, 30, 29, 53, 30, 68, '2022-02-28 10:55:01', 218),
(186, 7, 84, NULL, NULL, 14, '2022-02-28 11:52:28', 207),
(187, 30, 15, 12, 30, 69, '2022-03-02 09:18:39', 199),
(188, 30, 47, 2, 30, 68, '2022-03-02 10:17:09', 284),
(189, 30, 29, 59, 30, 69, '2022-03-07 19:25:48', 200),
(190, 30, 184, NULL, 30, 69, '2022-03-13 18:09:36', 190),
(191, 30, 58, NULL, 30, 69, '2022-03-14 07:34:29', 238),
(192, 42, 22, 19, NULL, 95, '2022-03-23 15:08:52', 185),
(193, 9, 90, 27, 9, 19, '2022-04-06 05:15:42', 336),
(194, 2, 102, 13, NULL, 4, '2022-04-07 11:37:31', 191),
(195, 9, 30, 75, 9, 19, '2022-04-07 13:42:26', 260),
(196, 9, 191, NULL, 9, 19, '2022-04-09 20:24:31', 150),
(197, 9, 37, 2, 9, 20, '2022-04-13 11:28:28', 298),
(198, 35, 94, 27, NULL, 80, '2022-04-15 19:18:45', 252),
(199, 9, 25, 53, 9, 20, '2022-04-16 01:13:41', 263),
(200, 9, 195, 34, 9, 19, '2022-04-16 15:01:54', 227),
(201, 9, 30, 41, 9, 20, '2022-04-22 12:31:40', 252),
(202, 2, 23, 53, NULL, 4, '2022-04-28 17:33:32', 237),
(203, 1, 74, NULL, NULL, 2, '2022-05-01 03:38:47', 469),
(204, 44, 25, 26, 44, 100, '2022-05-07 08:12:04', 206),
(205, 44, 174, NULL, 44, 100, '2022-05-11 09:44:03', 209),
(206, 44, 21, NULL, 44, 100, '2022-05-11 21:46:27', 164),
(207, 44, 22, 19, 44, 100, '2022-05-13 21:28:32', 195),
(208, 44, 73, 65, 44, 100, '2022-05-21 13:56:37', 208),
(209, 44, 13, NULL, 44, 100, '2022-05-23 20:24:06', 169),
(210, 9, 42, NULL, 9, 19, '2022-05-24 00:35:04', 197),
(211, 44, 101, 33, 44, 100, '2022-05-26 07:49:13', 188),
(212, 44, 53, 7, 44, 100, '2022-05-26 11:44:23', 156),
(213, 22, 102, 13, NULL, 50, '2022-06-12 11:28:23', 183),
(214, 9, 39, 3, 9, 19, '2022-06-13 15:43:31', 179),
(215, 9, 99, 77, NULL, 19, '2022-06-17 04:23:41', 168),
(216, 15, 26, 25, NULL, 33, '2022-07-05 19:34:35', 276),
(217, 22, 25, 26, NULL, 51, '2022-07-13 07:54:09', 267),
(218, 58, 13, NULL, NULL, 130, '2022-08-14 21:46:10', 155),
(219, 16, 4, NULL, NULL, 36, '2022-08-26 21:08:30', 167),
(220, 16, 99, 62, 16, 36, '2022-08-27 19:08:45', 170),
(221, 16, 23, 53, 16, 36, '2022-08-31 04:24:36', 240),
(222, 35, 49, 54, NULL, 80, '2022-09-02 16:11:38', 207),
(223, 2, 99, 56, NULL, 5, '2022-09-05 20:32:03', 172),
(224, 44, 141, 15, NULL, 100, '2022-09-06 23:06:28', 234),
(225, 51, 103, 33, 51, 114, '2022-09-10 09:26:23', 180),
(226, 58, 94, NULL, NULL, 130, '2022-09-12 19:39:42', 230),
(227, 51, 73, NULL, 51, 114, '2022-09-13 04:10:51', 292),
(228, 51, 22, NULL, 51, 114, '2022-09-15 22:44:18', 189),
(229, 51, 123, 50, 51, 114, '2022-09-19 19:28:41', 153),
(230, 51, 44, 25, 51, 114, '2022-09-22 05:29:53', 337),
(231, 51, 115, 44, 51, 114, '2022-09-23 08:48:33', 229),
(232, 51, 12, NULL, 51, 114, '2022-09-24 18:27:46', 189),
(233, 16, 29, 59, NULL, 37, '2022-09-27 01:11:40', 210),
(234, 16, 101, 33, 16, 37, '2022-09-28 23:05:08', 173),
(235, 44, 49, 54, NULL, 99, '2022-10-03 05:43:18', 203),
(236, 16, 143, 21, 16, 37, '2022-10-04 21:28:25', 260),
(237, 51, 179, NULL, 51, 114, '2022-10-05 15:16:21', 188),
(238, 51, 99, 62, 51, 114, '2022-10-06 12:01:40', 147),
(239, 51, 144, 21, 51, 114, '2022-10-07 23:10:55', 236),
(240, 16, 185, NULL, 16, 37, '2022-10-15 19:46:53', 205),
(241, 16, 100, 56, 16, 37, '2022-10-16 03:46:06', 309),
(242, 16, 5, 12, 16, 37, '2022-10-22 00:07:11', 280),
(243, 16, 37, 2, 16, 37, '2022-10-23 16:47:51', 295),
(244, 16, 34, NULL, 16, 37, '2022-10-30 20:15:35', 193),
(245, 16, 117, 14, 16, 37, '2022-11-15 11:39:33', 158),
(246, 16, 137, NULL, NULL, 37, '2022-11-21 20:40:27', 242),
(247, 23, 183, NULL, 23, 52, '2022-12-07 01:52:27', 202),
(248, 23, 67, 8, 23, 52, '2022-12-07 16:23:18', 225),
(249, 23, 36, 19, 23, 52, '2022-12-08 11:26:30', 180),
(250, 23, 29, 41, 23, 52, '2022-12-08 14:18:13', 224),
(251, 23, 43, NULL, NULL, 52, '2022-12-10 08:29:43', 184),
(252, 23, 173, NULL, 23, 52, '2022-12-11 23:23:00', 217),
(253, 23, 143, 32, 23, 52, '2022-12-13 14:38:42', 248),
(254, 23, 15, 12, 23, 52, '2022-12-17 07:59:53', 183),
(255, 23, 120, 14, 23, 52, '2022-12-19 20:59:57', 192),
(256, 17, 101, 33, 17, 38, '2023-01-18 03:13:35', 195),
(257, 9, 22, 19, NULL, 20, '2023-01-23 05:23:13', 193),
(258, 23, 103, 13, 23, 52, '2023-02-01 20:08:20', 177),
(259, 23, 162, NULL, 23, 52, '2023-02-08 22:41:07', 169),
(260, 23, 63, 8, 23, 52, '2023-02-13 12:58:24', 154),
(261, 17, 52, NULL, 17, 38, '2023-02-18 22:36:04', 199),
(262, 22, 119, 14, NULL, 51, '2023-02-20 16:24:11', 236),
(263, 23, 36, 19, 23, 52, '2023-02-20 16:51:53', 180),
(264, 17, 49, 3, 17, 38, '2023-02-22 12:53:29', 207),
(265, 17, 5, 3, 17, 38, '2023-02-24 22:36:20', 292),
(266, 17, 44, 26, 17, 38, '2023-03-02 02:49:19', 296),
(267, 42, 44, 44, NULL, 95, '2023-03-02 03:03:23', 316),
(268, 17, 137, NULL, 17, 38, '2023-03-13 01:27:51', 225),
(269, 45, 141, 15, 45, 102, '2023-03-14 10:46:57', 231),
(270, 17, 37, 2, 17, 38, '2023-03-22 14:35:32', 299),
(271, 17, 11, 12, 17, 38, '2023-03-25 17:55:40', 192),
(272, 17, 22, 75, 17, 38, '2023-03-28 23:56:30', 197),
(273, 45, 25, 26, 45, 102, '2023-04-01 06:37:35', 267),
(274, 45, 141, 20, 45, 102, '2023-04-06 01:34:20', 211),
(275, 17, 89, 4, 17, 39, '2023-04-08 13:41:09', 203),
(276, 23, 125, NULL, NULL, 52, '2023-04-17 00:04:54', 184),
(277, 4, 134, NULL, 4, 8, '2023-04-20 10:58:10', 149),
(278, 4, 88, NULL, 4, 8, '2023-04-24 11:55:22', 264),
(279, 58, 144, NULL, NULL, 130, '2023-05-24 16:41:38', 245),
(280, 52, 44, NULL, 52, 117, '2023-05-25 06:29:36', 296),
(281, 52, 115, 57, 52, 117, '2023-05-25 13:46:42', 205),
(282, 57, 89, 27, NULL, 127, '2023-05-26 18:46:59', 194),
(283, 17, 73, 65, NULL, 38, '2023-05-30 21:43:58', 285),
(284, 52, 49, 54, 52, 117, '2023-06-06 23:50:53', 203),
(285, 52, 67, 8, 52, 117, '2023-06-07 03:03:50', 235),
(286, 52, 50, NULL, 52, 117, '2023-06-08 07:02:01', 382),
(287, 4, 30, 41, 4, 8, '2023-06-17 00:47:13', 240),
(288, 1, 17, NULL, NULL, 2, '2023-06-17 11:11:33', 156),
(289, 4, 156, NULL, 4, 9, '2023-06-19 13:08:26', 172),
(290, 24, 93, 27, 24, 54, '2023-06-26 03:11:14', 172),
(291, 21, 121, 50, NULL, 47, '2023-06-27 01:19:44', 228),
(292, 24, 172, NULL, 24, 54, '2023-07-01 12:58:04', 203),
(293, 24, 30, 41, 24, 54, '2023-07-02 05:25:44', 259),
(294, 24, 159, NULL, 24, 54, '2023-07-04 04:48:14', 174),
(295, 24, 163, 7, 24, 54, '2023-07-04 13:33:14', 202),
(296, 4, 73, 65, 4, 8, '2023-07-06 13:03:56', 264),
(297, 24, 59, 54, 24, 54, '2023-07-08 05:18:38', 221),
(298, 52, 117, 71, 52, 117, '2023-07-08 07:41:45', 173),
(299, 24, 144, 22, 24, 54, '2023-07-13 11:13:17', 247),
(300, 24, 177, NULL, 24, 54, '2023-07-14 11:38:56', 201),
(301, 24, 127, NULL, 24, 54, '2023-07-18 19:28:02', 170),
(302, 24, 64, NULL, 24, 54, '2023-07-19 09:15:05', 224),
(303, 24, 33, 60, 24, 54, '2023-07-20 07:50:07', 218),
(304, 24, 15, 42, 24, 54, '2023-07-21 18:37:53', 187),
(305, 24, 22, 19, 24, 54, '2023-07-23 08:15:03', 189),
(306, 52, 95, 29, 52, 117, '2023-07-24 00:15:44', 210),
(307, 42, 141, 32, NULL, 95, '2023-07-26 01:21:03', 235),
(308, 52, 123, 50, 52, 117, '2023-08-13 06:54:16', 135),
(309, 21, 143, 21, NULL, 47, '2023-08-24 01:56:40', 253),
(310, 58, 119, 14, NULL, 129, '2023-10-03 02:55:16', 251),
(311, 10, 142, 20, 10, 22, '2023-10-12 09:46:46', 213),
(312, 10, 49, 54, 10, 22, '2023-10-17 00:15:23', 179),
(313, 9, 163, NULL, NULL, 20, '2023-10-18 01:09:20', 221),
(314, 10, 15, 12, 10, 22, '2023-10-20 16:51:44', 199),
(315, 10, 5, 3, 10, 22, '2023-11-04 13:07:51', 256),
(316, 59, 173, NULL, 59, 131, '2023-11-08 07:59:59', 215),
(317, 59, 7, 51, 59, 131, '2023-11-13 04:49:08', 150),
(318, 23, 99, 28, NULL, 52, '2023-11-19 00:18:22', 170),
(319, 59, 92, NULL, 59, 131, '2023-11-20 07:50:38', 232),
(320, 10, 2, 47, NULL, 22, '2023-11-21 10:38:33', 204),
(321, 24, 7, 51, NULL, 54, '2023-11-24 22:47:27', 164),
(322, 59, 93, 27, 59, 131, '2023-11-30 20:37:24', 171),
(323, 45, 63, 8, NULL, 102, '2023-12-03 09:00:45', 179),
(324, 59, 191, NULL, 59, 131, '2023-12-03 23:49:36', 169),
(325, 59, 47, 44, 59, 131, '2023-12-07 19:40:59', 240),
(326, 59, 44, NULL, 59, 131, '2023-12-11 05:59:24', 323),
(327, 59, 143, 15, 59, 131, '2023-12-12 04:49:18', 260),
(328, 38, 39, NULL, 38, 86, '2023-12-12 19:49:12', 186),
(329, 38, 143, 15, 38, 86, '2023-12-13 03:30:00', 253),
(330, 38, 97, 62, 38, 86, '2023-12-15 01:38:51', 245),
(331, 38, 30, 41, 38, 86, '2023-12-15 16:01:25', 246),
(332, 59, 23, 78, 59, 131, '2023-12-15 23:09:05', 223),
(333, 38, 93, 27, 38, 86, '2023-12-16 00:23:43', 176),
(334, 59, 142, 20, 59, 131, '2023-12-17 04:04:16', 223),
(335, 59, 117, NULL, 59, 131, '2023-12-17 11:20:50', 180),
(336, 38, 103, NULL, 38, 86, '2023-12-17 15:04:03', 156),
(337, 38, 197, 34, 38, 86, '2023-12-19 12:13:46', 260),
(338, 59, 91, 4, NULL, 131, '2023-12-20 23:02:06', 89),
(339, 38, 5, 12, NULL, 86, '2023-12-21 16:19:17', 274),
(340, 38, 81, NULL, NULL, 86, '2023-12-25 10:22:47', 402),
(341, 59, 120, 14, 59, 131, '2024-01-01 09:26:11', 256),
(342, 38, 105, 13, 38, 86, '2024-01-01 16:14:02', 152),
(343, 59, 99, 62, 59, 131, '2024-01-02 09:38:54', 150),
(344, 59, 185, NULL, 59, 131, '2024-01-03 16:21:25', 192),
(345, 38, 191, NULL, 38, 86, '2024-01-05 01:09:16', 157),
(346, 38, 11, 51, 38, 86, '2024-01-05 17:36:22', 184),
(347, 38, 26, NULL, 38, 86, '2024-01-06 14:51:04', 265),
(348, 59, 12, 48, 59, 131, '2024-01-08 14:52:29', 206),
(349, 38, 191, NULL, 38, 86, '2024-01-08 17:24:53', 171),
(350, 38, 98, NULL, 38, 86, '2024-01-09 04:26:07', 200),
(351, 59, 177, NULL, 59, 131, '2024-01-10 08:06:26', 184),
(352, 59, 36, 19, 59, 131, '2024-01-13 10:59:10', 181),
(353, 59, 194, NULL, 59, 131, '2024-01-14 14:41:03', 191),
(354, 17, 143, 21, NULL, 39, '2024-01-15 10:40:37', 270),
(355, 59, 105, 13, 59, 131, '2024-01-16 13:40:06', 148),
(356, 59, 141, 20, 59, 131, '2024-01-18 02:54:45', 235),
(357, 59, 90, 27, 59, 131, '2024-01-20 19:02:05', 287),
(358, 30, 164, NULL, NULL, 69, '2024-02-17 18:19:06', 224),
(359, 59, 124, 50, NULL, 131, '2024-02-27 13:31:38', 123),
(360, 53, 194, NULL, 53, 119, '2024-03-04 10:45:00', 191),
(361, 53, 5, 26, 53, 119, '2024-03-06 23:02:16', 280),
(362, 53, 89, 77, 53, 119, '2024-03-07 07:19:14', 198),
(363, 53, 144, 21, 53, 119, '2024-03-10 21:31:23', 245),
(364, 21, 89, 65, NULL, 47, '2024-03-11 03:21:23', 187),
(365, 11, 97, 62, 11, 25, '2024-03-12 16:04:47', 245),
(366, 11, 101, 13, 11, 25, '2024-03-14 17:54:33', 202),
(367, 28, 147, 22, NULL, 63, '2024-03-17 17:35:59', 175),
(368, 53, 81, NULL, 53, 119, '2024-03-21 04:19:18', 490),
(369, 53, 59, 12, 53, 119, '2024-03-27 09:34:43', 230),
(370, 1, 141, 35, NULL, 1, '2024-03-30 10:55:21', 235),
(371, 53, 192, NULL, 53, 119, '2024-03-30 17:55:49', 214),
(372, 53, 189, NULL, 53, 119, '2024-04-01 09:27:19', 215),
(373, 11, 59, NULL, 11, 25, '2024-04-02 12:25:46', 216),
(374, 53, 15, NULL, 53, 119, '2024-04-03 00:42:21', 155),
(375, 11, 115, NULL, 11, 24, '2024-04-04 02:05:23', 219),
(376, 7, 165, NULL, NULL, 14, '2024-04-07 04:25:38', 114),
(377, 32, 39, 3, 32, 72, '2024-04-15 03:13:58', 129),
(378, 52, 53, 7, NULL, 117, '2024-04-19 09:36:09', 164),
(379, 32, 141, 35, 32, 73, '2024-04-20 03:35:53', 213),
(380, 32, 7, 51, 32, 72, '2024-04-24 10:19:20', 150),
(381, 32, 144, NULL, 32, 73, '2024-04-26 13:08:11', 230),
(382, 32, 14, NULL, 32, 72, '2024-04-26 22:58:47', 197),
(383, 9, 102, NULL, NULL, 19, '2024-05-06 18:30:58', 194),
(384, 32, 19, NULL, 32, 72, '2024-05-07 05:12:09', 187),
(385, 32, 73, 77, 32, 72, '2024-05-11 22:44:51', 252),
(386, 29, 93, 27, NULL, 66, '2024-05-29 02:50:24', 181),
(387, 4, 73, 77, NULL, 9, '2024-07-02 02:07:59', 286),
(388, 18, 19, 8, 18, 41, '2024-07-06 02:49:20', 176),
(389, 18, 1, 66, 18, 40, '2024-07-07 04:49:06', 256),
(390, 18, 5, 48, 18, 40, '2024-07-12 15:49:28', 216),
(391, 18, 115, 38, 18, 40, '2024-07-19 06:15:22', 168),
(392, 18, 48, 69, 18, 40, '2024-07-20 00:26:35', 298),
(393, 18, 16, NULL, 18, 40, '2024-07-25 01:52:33', 170),
(394, 18, 60, NULL, 18, 41, '2024-07-25 19:59:38', 226),
(395, 18, 48, NULL, 18, 41, '2024-07-27 02:28:15', 294),
(396, 18, 47, 44, 18, 40, '2024-07-28 17:22:31', 279),
(397, 18, 84, NULL, 18, 40, '2024-08-04 22:36:48', 211),
(398, 1, 82, 76, NULL, 1, '2024-08-29 18:15:42', 896),
(399, 39, 5, 48, 39, 88, '2024-08-31 09:33:52', 256),
(400, 39, 47, 57, 39, 88, '2024-08-31 15:14:40', 279),
(401, 39, 73, 62, 39, 88, '2024-09-05 07:53:41', 264),
(402, 39, 47, 69, 39, 88, '2024-09-05 08:20:47', 267),
(403, 18, 33, 60, NULL, 41, '2024-09-06 13:07:52', 224),
(404, 39, 183, 30, 39, 88, '2024-09-09 06:40:17', 196),
(405, 39, 172, NULL, 39, 88, '2024-09-13 11:41:50', 207),
(406, 39, 26, 10, 39, 88, '2024-09-15 09:00:23', 243),
(407, 39, 26, 5, 39, 89, '2024-09-18 07:45:07', 249),
(408, 5, 144, 21, 5, 10, '2024-09-18 22:49:33', 206),
(409, 5, 119, 14, 5, 10, '2024-09-19 12:48:53', 236),
(410, 5, 118, 14, 5, 10, '2024-09-19 18:19:00', 190),
(411, 39, 118, 14, NULL, 89, '2024-09-21 16:41:25', 194),
(412, 5, 19, 8, 5, 11, '2024-10-14 23:38:10', 187),
(413, 4, 107, 13, NULL, 8, '2024-10-17 18:40:51', 168),
(414, 39, 81, NULL, NULL, 88, '2024-10-31 07:17:07', 500),
(415, 59, 26, NULL, NULL, 131, '2024-11-02 07:17:19', 254),
(416, 45, 25, 78, NULL, 102, '2024-11-12 08:13:42', 264),
(417, 46, 117, 14, 46, 104, '2024-12-06 00:10:50', 173),
(418, 46, 147, NULL, 46, 104, '2024-12-08 21:47:02', 182),
(419, 46, 185, NULL, 46, 104, '2024-12-09 00:53:05', 214),
(420, 46, 73, 4, 46, 104, '2024-12-09 02:19:37', 253),
(421, 38, 81, 76, NULL, 86, '2024-12-11 01:25:17', 458),
(422, 46, 169, NULL, 46, 104, '2024-12-15 05:41:22', 218),
(423, 46, 30, 59, 46, 104, '2024-12-16 00:04:00', 242),
(424, 46, 59, 3, 46, 104, '2024-12-17 04:12:53', 226),
(425, 52, 30, 41, NULL, 116, '2024-12-25 14:14:06', 258),
(426, 46, 51, 54, 46, 104, '2025-01-02 00:53:46', 267),
(427, 46, 11, 1, 46, 104, '2025-01-02 01:08:29', 172),
(428, 46, 49, 69, 46, 104, '2025-01-04 05:41:21', 203),
(429, 46, 126, NULL, 46, 104, '2025-01-04 16:54:39', 239),
(430, 46, 22, 75, 46, 104, '2025-01-05 00:00:35', 194),
(431, 21, 5, 26, NULL, 47, '2025-01-08 21:14:44', 280),
(432, 2, 61, 73, NULL, 5, '2025-02-05 09:00:56', 213),
(433, 26, 124, 50, 26, 58, '2025-03-27 08:04:03', 134),
(434, 26, 22, 40, 26, 58, '2025-03-27 10:22:27', 196),
(435, 59, 1, 1, NULL, 131, '2025-04-04 18:48:18', 239),
(436, 26, 147, NULL, 26, 58, '2025-04-06 05:02:18', 171),
(437, 40, 61, 8, 40, 90, '2025-04-24 23:45:52', 204),
(438, 40, 89, 65, 40, 91, '2025-05-01 01:00:57', 194),
(439, 26, 59, NULL, 26, 58, '2025-05-04 00:23:15', 230),
(440, 26, 121, 52, 26, 59, '2025-05-04 16:59:58', 238),
(441, 29, 23, 78, NULL, 66, '2025-05-08 14:11:47', 237),
(442, 26, 142, 15, 26, 58, '2025-05-14 23:20:14', 195),
(443, 29, 185, NULL, NULL, 67, '2025-05-17 08:57:06', 196),
(444, 26, 5, 26, 26, 58, '2025-05-18 02:52:33', 274),
(445, 45, 11, NULL, NULL, 103, '2025-05-18 13:02:26', 188),
(446, 26, 71, NULL, 26, 58, '2025-05-19 19:25:51', 354),
(447, 40, 63, 73, 40, 91, '2025-05-20 04:37:08', 244),
(448, 26, 118, 71, 26, 59, '2025-05-26 14:43:55', 200),
(449, 36, 115, 44, NULL, 82, '2025-05-27 17:21:51', 205),
(450, 26, 119, NULL, 26, 58, '2025-05-30 05:34:36', 230),
(451, 26, 121, 52, 26, 59, '2025-06-07 14:22:55', 224),
(452, 47, 18, 58, 47, 106, '2025-06-20 16:17:14', 174),
(453, 47, 47, 72, 47, 106, '2025-06-23 07:13:13', 282),
(454, 47, 196, 34, 47, 106, '2025-06-23 11:03:50', 211),
(455, 47, 179, NULL, 47, 106, '2025-06-24 08:53:07', 166),
(456, 47, 95, 29, 47, 106, '2025-06-27 10:30:53', 221),
(457, 47, 61, 8, 47, 106, '2025-06-27 14:31:30', 200),
(458, 28, 115, 38, NULL, 64, '2025-06-30 16:06:56', 214),
(459, 47, 44, 44, 47, 106, '2025-07-04 17:42:31', 295),
(460, 47, 163, 37, 47, 106, '2025-07-08 00:37:24', 221),
(461, 40, 48, 69, 40, 90, '2025-07-10 07:35:07', 314),
(462, 40, 131, 74, 40, 91, '2025-07-10 22:52:27', 206),
(463, 47, 73, 46, 47, 106, '2025-07-11 16:22:01', 258),
(464, 47, 173, 36, 47, 106, '2025-07-12 23:16:40', 220),
(465, 47, 142, 20, 47, 106, '2025-07-14 00:38:43', 213),
(466, 47, 124, NULL, 47, 106, '2025-07-16 10:47:52', 129),
(467, 47, 44, 25, 47, 106, '2025-07-16 15:10:01', 330),
(468, 26, 33, 10, NULL, 58, '2025-07-29 07:53:16', 197),
(469, 39, 5, NULL, NULL, 88, '2025-08-09 06:48:45', 277),
(470, 12, 44, 5, 12, 26, '2025-08-15 11:02:15', 303),
(471, 12, 26, 25, 12, 26, '2025-09-06 00:39:09', 254),
(472, 42, 181, 37, NULL, 96, '2025-09-20 22:09:25', 102),
(473, 12, 117, 71, 12, 26, '2025-09-23 19:05:41', 173),
(474, 12, 102, 33, 12, 26, '2025-10-19 02:43:38', 194),
(475, 33, 49, 12, 33, 75, '2025-10-21 01:19:15', 212),
(476, 22, 169, 17, NULL, 49, '2025-10-22 10:48:47', 160),
(477, 33, 11, 42, NULL, 76, '2025-10-26 10:24:29', 176),
(478, 12, 49, 3, 12, 26, '2025-10-28 08:03:35', 194),
(479, 33, 89, 64, NULL, 75, '2025-10-30 22:27:46', 190),
(480, 12, 99, 4, 12, 26, '2025-11-04 13:24:07', 164),
(481, 33, 85, 76, 33, 76, '2025-11-05 03:05:17', 186),
(482, 12, 73, 31, 12, 26, '2025-11-09 23:18:32', 287),
(483, 33, 41, NULL, 33, 76, '2025-11-15 01:59:04', 136),
(484, 54, 116, NULL, 54, 121, '2025-12-01 04:34:43', 186),
(485, 54, 108, NULL, 54, 121, '2025-12-03 07:24:34', 154),
(486, 54, 127, 52, 54, 121, '2025-12-04 23:30:21', 198),
(487, 9, 2, 47, NULL, 19, '2025-12-06 10:37:43', 200),
(488, 54, 23, 53, 54, 121, '2025-12-07 05:57:58', 232),
(489, 54, 89, 27, 54, 122, '2025-12-08 22:58:54', 202),
(490, 54, 115, 72, 54, 121, '2025-12-08 23:00:15', 200),
(491, 54, 89, 77, 54, 121, '2025-12-09 00:42:06', 200),
(492, 47, 2, 19, NULL, 107, '2025-12-09 11:35:50', 208),
(493, 33, 73, 77, 33, 76, '2025-12-10 02:24:28', 287),
(494, 33, 51, 54, 33, 75, '2025-12-10 23:05:46', 201),
(495, 54, 80, NULL, 54, 122, '2025-12-12 21:57:24', 224),
(496, 19, 51, NULL, 19, 43, '2025-12-17 11:27:14', 269),
(497, 19, 26, 25, 19, 43, '2025-12-17 11:38:16', 243),
(498, 19, 61, 39, 19, 43, '2025-12-17 14:05:49', 195),
(499, 19, 59, 54, 19, 43, '2025-12-17 23:33:47', 229),
(500, 19, 115, 57, 19, 43, '2025-12-18 07:12:57', 214),
(501, 33, 47, 18, NULL, 76, '2025-12-18 08:56:31', 273),
(502, 19, 99, 4, 19, 43, '2025-12-19 00:27:39', 168),
(503, 10, 83, 60, NULL, 22, '2025-12-19 03:53:46', 347),
(504, 19, 118, 14, 19, 43, '2025-12-19 06:55:51', 174),
(505, 19, 131, 43, 19, 43, '2025-12-19 07:05:20', 235),
(506, 19, 143, 32, 19, 43, '2025-12-19 09:03:30', 270),
(507, 19, 1, 1, 19, 43, '2025-12-20 06:53:17', 185),
(508, 19, 135, NULL, 19, 43, '2025-12-20 12:04:54', 233),
(509, 26, 119, 14, NULL, 58, '2025-12-23 08:05:37', 246),
(510, 24, 163, 7, NULL, 54, '2025-12-23 19:51:56', 229),
(511, 17, 34, 60, NULL, 38, '2026-01-09 10:47:19', 180),
(512, 28, 95, 29, NULL, 64, '2026-01-14 09:04:45', 228),
(513, 12, 102, NULL, NULL, 26, '2026-01-16 15:23:51', 181),
(514, 12, 99, 46, NULL, 26, '2026-01-18 12:12:46', 161),
(515, 1, 73, 65, NULL, 1, '2026-01-23 08:13:23', 275),
(516, 1, 102, NULL, NULL, 1, '2026-02-03 10:38:46', 191),
(517, 2, 23, 43, NULL, 4, '2026-02-04 08:59:23', 237),
(518, 17, 53, NULL, NULL, 38, '2026-02-12 08:35:27', 160),
(519, 2, 2, 19, NULL, 3, '2026-02-16 20:23:00', 187),
(520, 13, 11, 12, NULL, 29, '2026-02-25 03:35:48', 194),
(521, 12, 30, 41, NULL, 26, '2026-03-03 03:10:52', 242),
(522, 34, 47, 44, 34, 78, '2026-03-12 05:22:00', 286),
(523, 16, 122, 50, 72, 37, '2026-03-24 11:21:50', 171),
(524, 2, 73, 56, 62, 3, '2026-03-30 00:30:38', 287),
(525, 34, 1, 51, NULL, 77, '2026-03-31 12:49:58', 234),
(526, 20, 29, 6, NULL, 45, '2026-04-04 07:33:39', 205),
(527, 17, 39, 3, 73, 38, '2026-04-04 08:43:54', 179),
(528, 13, 133, NULL, NULL, 29, '2026-04-06 22:19:50', 169),
(529, 9, 70, 45, 66, 20, '2026-04-21 01:43:48', 227),
(530, 9, 191, NULL, 66, 19, '2026-04-25 19:40:09', 167),
(531, 7, 49, 54, 65, 16, '2026-04-26 00:59:51', 212),
(532, 7, 130, NULL, 65, 14, '2026-04-28 04:53:08', 169),
(533, 55, 89, 4, 55, 123, '2026-05-10 17:11:49', 197),
(534, 55, 143, 15, 55, 123, '2026-05-12 13:55:24', 268),
(535, 27, 1, 66, NULL, 61, '2026-05-13 21:35:28', 250),
(536, 9, 82, 76, 66, 19, '2026-05-15 09:05:22', 914),
(537, 40, 82, 76, 88, 91, '2026-05-16 02:10:42', 905),
(538, 2, 82, 76, 62, 3, '2026-05-16 15:08:15', 896),
(539, 60, 82, 76, 90, 134, '2026-05-16 17:43:19', 914),
(540, 9, 81, 76, NULL, 20, '2026-05-17 02:17:42', 511),
(541, 23, 82, 76, 78, 52, '2026-05-17 02:51:03', 896),
(542, 60, 82, 76, 90, 135, '2026-05-17 05:15:30', 914),
(543, 23, 74, NULL, 78, 52, '2026-05-17 10:12:13', 545),
(544, 5, 99, NULL, 64, 11, '2026-05-18 07:36:25', 161),
(545, 60, 81, 76, 90, 135, '2026-05-18 10:19:18', 521),
(546, 9, 83, 60, 66, 19, '2026-05-18 13:00:41', 347),
(547, 23, 50, NULL, 78, 53, '2026-05-18 21:23:25', 458),
(548, 40, 82, 76, 88, 90, '2026-05-19 07:17:57', 896),
(549, 60, 90, 68, 90, 134, '2026-05-19 19:24:15', 350),
(550, 60, 50, NULL, 90, 135, '2026-05-20 02:48:49', 462),
(551, 2, 82, 76, 62, 4, '2026-05-20 16:05:52', 905),
(552, 60, 82, 76, 90, 134, '2026-05-21 22:15:44', 896),
(553, 1, 1, 79, 91, 1, '2026-05-22 02:44:42', 234),
(554, 23, 90, 68, 78, 52, '2026-05-23 16:05:19', 353),
(555, 23, 82, 76, NULL, 52, '2026-05-24 03:40:55', 914),
(556, 60, 82, 76, 90, 135, '2026-05-24 10:00:22', 905),
(557, 60, 81, 76, 90, 134, '2026-05-24 18:24:54', 521),
(558, 9, 90, 68, 66, 19, '2026-05-25 09:48:12', 350),
(559, 23, 74, NULL, 78, 53, '2026-05-25 17:14:06', 534),
(560, 60, 90, 68, 90, 134, '2026-05-26 00:43:03', 357),
(561, 40, 82, 76, NULL, 91, '2026-05-26 05:56:07', 905),
(562, 23, 50, NULL, 78, 52, '2026-05-26 06:36:02', 458),
(563, 60, 50, NULL, 90, 134, '2026-05-26 08:14:57', 467),
(564, 23, 90, 68, 78, 52, '2026-05-26 18:34:22', 357),
(565, 2, 82, 76, 62, 5, '2026-05-26 19:28:23', 896),
(566, 60, 82, 76, 90, 135, '2026-05-28 06:58:52', 914),
(567, 40, 81, 76, 88, 91, '2026-05-28 11:58:36', 516),
(568, 60, 82, 76, NULL, 134, '2026-05-28 15:45:12', 905),
(569, 60, 81, 76, 90, 134, '2026-05-29 00:21:27', 521),
(570, 23, 82, 76, 78, 53, '2026-05-29 01:37:49', 914),
(571, 9, 82, 76, 66, 20, '2026-05-29 04:26:27', 905),
(572, 2, 82, 76, 62, 4, '2026-05-29 11:31:43', 905),
(573, 23, 74, NULL, 78, 53, '2026-05-30 19:21:10', 545),
(574, 40, 82, 76, 88, 92, '2026-05-31 17:15:04', 914),
(575, 2, 82, 76, 62, 4, '2026-05-31 22:24:07', 905),
(576, 23, 50, NULL, NULL, 52, '2026-06-01 03:29:04', 467),
(577, 40, 82, 76, 88, 92, '2026-06-01 11:18:52', 914),
(578, 2, 82, 76, 62, 5, '2026-06-03 09:25:49', 905),
(579, 40, 82, 76, 88, 91, '2026-06-03 22:13:53', 905),
(580, 23, 90, 68, 78, 53, '2026-06-04 08:00:10', 350),
(581, 23, 82, 76, 78, 52, '2026-06-05 21:16:08', 905),
(582, 9, 81, 76, NULL, 21, '2026-06-06 03:26:15', 511),
(583, 4, 50, NULL, 93, 9, '2026-06-06 04:13:05', 424),
(584, 9, 83, 60, 66, 19, '2026-06-07 01:39:19', 354),
(585, 9, 90, 68, 66, 21, '2026-06-07 11:49:42', 350),
(586, 2, 82, 76, 62, 4, '2026-06-08 07:12:56', 896),
(587, 60, 90, 68, 90, 134, '2026-06-08 14:04:59', 357),
(588, 60, 50, NULL, 90, 134, '2026-06-09 01:05:58', 458),
(589, 40, 81, 76, 88, 91, '2026-06-09 09:04:28', 521),
(590, 60, 82, 76, 90, 134, '2026-06-09 16:37:52', 914),
(591, 9, 82, 76, 66, 19, '2026-06-10 11:37:31', 896),
(592, 60, 82, 76, 90, 134, '2026-06-10 20:07:30', 905),
(593, 40, 82, 76, 88, 91, '2026-06-11 01:59:48', 896),
(594, 23, 74, NULL, NULL, 53, '2026-06-11 03:21:07', 545),
(595, 9, 81, 76, 66, 19, '2026-06-11 19:40:59', 516),
(596, 9, 83, 60, 66, 19, '2026-06-11 22:49:12', 354),
(597, 60, 81, 76, 90, 135, '2026-06-12 04:24:10', 511),
(598, 2, 82, 76, NULL, 5, '2026-06-12 06:34:30', 896),
(599, 9, 90, 68, 66, 20, '2026-06-12 08:19:27', 357),
(600, 40, 82, 76, 88, 92, '2026-06-12 12:17:39', 905);

-- 1. Find the top 5 users with the highest listening time during the last 30 days, including their favorite genre.

-- The last 30 days are calculated relative to the latest played_at value in our dataset.

SELECT
    user_totals.user_id,
    user_totals.username,
    user_totals.total_listening_seconds,
    ROUND(user_totals.total_listening_seconds / 60, 2) AS total_listening_minutes,
    favorite_genres.genre_name AS favorite_genre
FROM
    (
        SELECT
            u.user_id,
            u.username,
            SUM(lh.completed_seconds) AS total_listening_seconds
        FROM Users u
        JOIN Listening_History lh ON u.user_id = lh.user_id
        WHERE lh.played_at >= (
            SELECT MAX(played_at) - INTERVAL 30 DAY
            FROM Listening_History
        )
        GROUP BY u.user_id, u.username
    ) AS user_totals
JOIN
    (
        SELECT
            ranked.user_id,
            ranked.genre_name
        FROM
            (
                SELECT
                    user_genres.user_id,
                    user_genres.genre_name,
                    user_genres.genre_listening_seconds,
                    ROW_NUMBER() OVER (
                        PARTITION BY user_genres.user_id
                        ORDER BY user_genres.genre_listening_seconds DESC, user_genres.genre_name
                    ) AS genre_rank
                FROM
                    (
                        SELECT
                            u.user_id,
                            g.genre_name,
                            SUM(lh.completed_seconds) AS genre_listening_seconds
                        FROM Users u
                        JOIN Listening_History lh ON u.user_id = lh.user_id
                        JOIN Track_Genres tg ON lh.track_id = tg.track_id
                        JOIN Genres g ON tg.genre_id = g.genre_id
                        WHERE lh.played_at >= (
                            SELECT MAX(played_at) - INTERVAL 30 DAY
                            FROM Listening_History
                        )
                        GROUP BY u.user_id, g.genre_name
                    ) AS user_genres
            ) AS ranked
        WHERE ranked.genre_rank = 1
    ) AS favorite_genres
    ON user_totals.user_id = favorite_genres.user_id
ORDER BY user_totals.total_listening_seconds DESC
LIMIT 5;


-- 2. Identify genres whose average track completion rate is higher than the overall platform average.
SELECT
    genre_rates.genre_id,
    genre_rates.genre_name,
    ROUND(AVG(genre_rates.completion_rate) * 100, 2) AS avg_completion_rate_percent,
    ROUND(platform_average.platform_avg_completion_rate * 100, 2) AS platform_avg_completion_rate_percent
FROM
    (
        SELECT
            g.genre_id,
            g.genre_name,
            LEAST(lh.completed_seconds * 1.0 / t.duration_seconds, 1) AS completion_rate
        FROM Listening_History lh
        JOIN Tracks t ON lh.track_id = t.track_id
        JOIN Track_Genres tg ON t.track_id = tg.track_id
        JOIN Genres g ON tg.genre_id = g.genre_id
        WHERE t.duration_seconds > 0
    ) AS genre_rates
CROSS JOIN
    (
        SELECT
            AVG(LEAST(lh.completed_seconds * 1.0 / t.duration_seconds, 1)) AS platform_avg_completion_rate
        FROM Listening_History lh
        JOIN Tracks t ON lh.track_id = t.track_id
        WHERE t.duration_seconds > 0
    ) AS platform_average
GROUP BY
    genre_rates.genre_id,
    genre_rates.genre_name,
    platform_average.platform_avg_completion_rate
HAVING AVG(genre_rates.completion_rate) > platform_average.platform_avg_completion_rate
ORDER BY avg_completion_rate_percent DESC;


-- 3. Find artists whose tracks were added to playlists more often than they were listened to fully.

-- In our database a full listen means the user completed at least 90% of the track.
-- Playlist additions and full listens are counted separately to avoid row multiplication from joins.

SELECT
    playlist_stats.artist_id,
    playlist_stats.artist_name,
    playlist_stats.playlist_additions,
    COALESCE(full_listen_stats.full_listens, 0) AS full_listens
FROM
    (
        SELECT
            a.artist_id,
            a.artist_name,
            COUNT(pt.playlist_track_id) AS playlist_additions
        FROM Artists a
        JOIN Track_Artists ta ON a.artist_id = ta.artist_id
        JOIN Tracks t ON ta.track_id = t.track_id
        LEFT JOIN Playlist_Tracks pt ON t.track_id = pt.track_id
        GROUP BY a.artist_id, a.artist_name
    ) AS playlist_stats
LEFT JOIN
    (
        SELECT
            a.artist_id,
            COUNT(lh.history_id) AS full_listens
        FROM Artists a
        JOIN Track_Artists ta ON a.artist_id = ta.artist_id
        JOIN Tracks t ON ta.track_id = t.track_id
        LEFT JOIN Listening_History lh
            ON t.track_id = lh.track_id
            AND lh.completed_seconds >= t.duration_seconds * 0.90
        GROUP BY a.artist_id
    ) AS full_listen_stats
    ON playlist_stats.artist_id = full_listen_stats.artist_id
WHERE playlist_stats.playlist_additions > COALESCE(full_listen_stats.full_listens, 0)
ORDER BY playlist_stats.playlist_additions DESC, full_listens ASC;


-- 4. Rank tracks within each genre by total number of plays using a window function.
SELECT
    track_play_counts.genre_id,
    track_play_counts.genre_name,
    track_play_counts.track_id,
    track_play_counts.track_title,
    track_play_counts.total_plays,
    RANK() OVER (
        PARTITION BY track_play_counts.genre_id
        ORDER BY track_play_counts.total_plays DESC
    ) AS genre_rank
FROM
    (
        SELECT
            g.genre_id,
            g.genre_name,
            t.track_id,
            t.track_title,
            COUNT(lh.history_id) AS total_plays
        FROM Genres g
        JOIN Track_Genres tg ON g.genre_id = tg.genre_id
        JOIN Tracks t ON tg.track_id = t.track_id
        LEFT JOIN Listening_History lh ON t.track_id = lh.track_id
        GROUP BY
            g.genre_id,
            g.genre_name,
            t.track_id,
            t.track_title
    ) AS track_play_counts
ORDER BY
    track_play_counts.genre_name,
    genre_rank,
    track_play_counts.track_title;


-- 5. Classify users as “Low”, “Medium”, or “High” activity based on their monthly listening time using CASE WHEN.
SELECT
    monthly_activity.user_id,
    monthly_activity.username,
    monthly_activity.listening_year,
    monthly_activity.listening_month,
    monthly_activity.monthly_listening_seconds,
    ROUND(monthly_activity.monthly_listening_seconds / 60, 2) AS monthly_listening_minutes,
    CASE
        WHEN monthly_activity.monthly_listening_seconds < 900 THEN 'Low'
        WHEN monthly_activity.monthly_listening_seconds < 3000 THEN 'Medium'
        ELSE 'High'
    END AS activity_level
FROM
    (
        SELECT
            u.user_id,
            u.username,
            YEAR(lh.played_at) AS listening_year,
            MONTH(lh.played_at) AS listening_month,
            SUM(lh.completed_seconds) AS monthly_listening_seconds
        FROM Users u
        JOIN Listening_History lh ON u.user_id = lh.user_id
        GROUP BY
            u.user_id,
            u.username,
            YEAR(lh.played_at),
            MONTH(lh.played_at)
    ) AS monthly_activity
ORDER BY
    monthly_activity.listening_year DESC,
    monthly_activity.listening_month DESC,
    monthly_activity.monthly_listening_seconds DESC;


-- 6. Analyze which query can be optimized for searching listening history by user and 
-- date, and compare performance before and after creating an index using EXPLAIN

-- Check what primary and FK indexes exists now
SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN (
      'Listening_History',
      'Track_Genres',
      'Track_Artists',
      'Playlist_Tracks'
  )
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;


-- Create indexes

CREATE INDEX idx_ta_artist_track
ON Track_Artists (artist_id, track_id);

CREATE INDEX idx_lh_played_user_track
ON Listening_History (played_at, user_id, track_id, completed_seconds);

CREATE INDEX idx_tg_genre_track
ON Track_Genres (genre_id, track_id);

CREATE INDEX idx_lh_track_played
ON Listening_History (track_id, played_at, completed_seconds);

-- Query 1 Optimization check
EXPLAIN
-- Query 1 below
SELECT
    user_totals.user_id,
    user_totals.username,
    user_totals.total_listening_seconds,
    ROUND(user_totals.total_listening_seconds / 60, 2) AS total_listening_minutes,
    favorite_genres.genre_name AS favorite_genre
FROM
    (
        SELECT
            u.user_id,
            u.username,
            SUM(lh.completed_seconds) AS total_listening_seconds
        FROM Users u
        JOIN Listening_History lh ON u.user_id = lh.user_id
        WHERE lh.played_at >= (
            SELECT MAX(played_at) - INTERVAL 30 DAY
            FROM Listening_History
        )
        GROUP BY u.user_id, u.username
    ) AS user_totals
JOIN
    (
        SELECT
            ranked.user_id,
            ranked.genre_name
        FROM
            (
                SELECT
                    user_genres.user_id,
                    user_genres.genre_name,
                    user_genres.genre_listening_seconds,
                    ROW_NUMBER() OVER (
                        PARTITION BY user_genres.user_id
                        ORDER BY user_genres.genre_listening_seconds DESC, user_genres.genre_name
                    ) AS genre_rank
                FROM
                    (
                        SELECT
                            u.user_id,
                            g.genre_name,
                            SUM(lh.completed_seconds) AS genre_listening_seconds
                        FROM Users u
                        JOIN Listening_History lh ON u.user_id = lh.user_id
                        JOIN Track_Genres tg ON lh.track_id = tg.track_id
                        JOIN Genres g ON tg.genre_id = g.genre_id
                        WHERE lh.played_at >= (
                            SELECT MAX(played_at) - INTERVAL 30 DAY
                            FROM Listening_History
                        )
                        GROUP BY u.user_id, g.genre_name
                    ) AS user_genres
            ) AS ranked
        WHERE ranked.genre_rank = 1
    ) AS favorite_genres
    ON user_totals.user_id = favorite_genres.user_id
ORDER BY user_totals.total_listening_seconds DESC
LIMIT 5;

-- Query 2 Optimization check

EXPLAIN
-- Query 2 below
SELECT
    genre_rates.genre_id,
    genre_rates.genre_name,
    ROUND(AVG(genre_rates.completion_rate) * 100, 2) AS avg_completion_rate_percent,
    ROUND(platform_average.platform_avg_completion_rate * 100, 2) AS platform_avg_completion_rate_percent
FROM
    (
        SELECT
            g.genre_id,
            g.genre_name,
            LEAST(lh.completed_seconds * 1.0 / t.duration_seconds, 1) AS completion_rate
        FROM Listening_History lh
        JOIN Tracks t ON lh.track_id = t.track_id
        JOIN Track_Genres tg ON t.track_id = tg.track_id
        JOIN Genres g ON tg.genre_id = g.genre_id
        WHERE t.duration_seconds > 0
    ) AS genre_rates
CROSS JOIN
    (
        SELECT
            AVG(LEAST(lh.completed_seconds * 1.0 / t.duration_seconds, 1)) AS platform_avg_completion_rate
        FROM Listening_History lh
        JOIN Tracks t ON lh.track_id = t.track_id
        WHERE t.duration_seconds > 0
    ) AS platform_average
GROUP BY
    genre_rates.genre_id,
    genre_rates.genre_name,
    platform_average.platform_avg_completion_rate
HAVING AVG(genre_rates.completion_rate) > platform_average.platform_avg_completion_rate
ORDER BY avg_completion_rate_percent DESC;


-- Query 3 Optimization
EXPLAIN
-- Query 3 below
SELECT
    playlist_stats.artist_id,
    playlist_stats.artist_name,
    playlist_stats.playlist_additions,
    COALESCE(full_listen_stats.full_listens, 0) AS full_listens
FROM
    (
        SELECT
            a.artist_id,
            a.artist_name,
            COUNT(pt.playlist_track_id) AS playlist_additions
        FROM Artists a
        JOIN Track_Artists ta ON a.artist_id = ta.artist_id
        JOIN Tracks t ON ta.track_id = t.track_id
        LEFT JOIN Playlist_Tracks pt ON t.track_id = pt.track_id
        GROUP BY a.artist_id, a.artist_name
    ) AS playlist_stats
LEFT JOIN
    (
        SELECT
            a.artist_id,
            COUNT(lh.history_id) AS full_listens
        FROM Artists a
        JOIN Track_Artists ta ON a.artist_id = ta.artist_id
        JOIN Tracks t ON ta.track_id = t.track_id
        LEFT JOIN Listening_History lh
            ON t.track_id = lh.track_id
            AND lh.completed_seconds >= t.duration_seconds * 0.90
        GROUP BY a.artist_id
    ) AS full_listen_stats
    ON playlist_stats.artist_id = full_listen_stats.artist_id
WHERE playlist_stats.playlist_additions > COALESCE(full_listen_stats.full_listens, 0)
ORDER BY playlist_stats.playlist_additions DESC, full_listens ASC;


-- 	Query 4 optimization check
EXPLAIN
-- Query 4 below
SELECT
    track_play_counts.genre_id,
    track_play_counts.genre_name,
    track_play_counts.track_id,
    track_play_counts.track_title,
    track_play_counts.total_plays,
    RANK() OVER (
        PARTITION BY track_play_counts.genre_id
        ORDER BY track_play_counts.total_plays DESC
    ) AS genre_rank
FROM
    (
        SELECT
            g.genre_id,
            g.genre_name,
            t.track_id,
            t.track_title,
            COUNT(lh.history_id) AS total_plays
        FROM Genres g
        JOIN Track_Genres tg ON g.genre_id = tg.genre_id
        JOIN Tracks t ON tg.track_id = t.track_id
        LEFT JOIN Listening_History lh ON t.track_id = lh.track_id
        GROUP BY
            g.genre_id,
            g.genre_name,
            t.track_id,
            t.track_title
    ) AS track_play_counts
ORDER BY
    track_play_counts.genre_name,
    genre_rank,
    track_play_counts.track_title;



-- VIEW 1:
-- Subscription revenue report for business monitoring.

CREATE VIEW vw_subscription_revenue_report AS
SELECT
    sp.plan_id,
    sp.plan_name,
    sp.monthly_price,
    sp.audio_quality,
    sp.ads_free,
    sp.offline_mode,

    COUNT(us.subscription_id) AS total_subscriptions,

    SUM(CASE WHEN us.status = 'active' THEN 1 ELSE 0 END) AS active_subscriptions,
    SUM(CASE WHEN us.status = 'expired' THEN 1 ELSE 0 END) AS expired_subscriptions,
    SUM(CASE WHEN us.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_subscriptions,
    SUM(CASE WHEN us.status = 'paused' THEN 1 ELSE 0 END) AS paused_subscriptions,

    ROUND(
        SUM(CASE WHEN us.status = 'active' THEN sp.monthly_price ELSE 0 END),
        2
    ) AS current_monthly_recurring_revenue,

    ROUND(
        AVG(DATEDIFF(us.end_date, us.start_date)),
        2
    ) AS avg_subscription_days
FROM subscription_plans sp
LEFT JOIN user_subscription us
    ON sp.plan_id = us.plan_id
GROUP BY
    sp.plan_id,
    sp.plan_name,
    sp.monthly_price,
    sp.audio_quality,
    sp.ads_free,
    sp.offline_mode;

-- TEST VIEW 1

SELECT *
FROM vw_subscription_revenue_report;


-- VIEW 2:
-- Track engagement report for analyzing track performance.

CREATE VIEW vw_track_engagement_report AS
SELECT
    t.track_id,
    t.track_title,
    a.album_title,

    GROUP_CONCAT(DISTINCT ar.artist_name ORDER BY ar.artist_name SEPARATOR ', ') AS artists,
    GROUP_CONCAT(DISTINCT g.genre_name ORDER BY g.genre_name SEPARATOR ', ') AS genres,

    t.duration_seconds,

    COUNT(DISTINCT lh.history_id) AS total_plays,
    COUNT(DISTINCT lh.user_id) AS unique_listeners,

    ROUND(
        AVG(
            CASE
                WHEN lh.history_id IS NOT NULL
                THEN LEAST(lh.completed_seconds / NULLIF(t.duration_seconds, 0), 1) * 100
                ELSE NULL
            END
        ),
        2
    ) AS avg_completion_percent,

    COUNT(DISTINCT CASE
        WHEN lh.completed_seconds >= t.duration_seconds * 0.9
        THEN lh.history_id
    END) AS almost_completed_plays
FROM tracks t
LEFT JOIN albums a
    ON t.album_id = a.album_id
LEFT JOIN track_artists ta
    ON t.track_id = ta.track_id
LEFT JOIN artists ar
    ON ta.artist_id = ar.artist_id
LEFT JOIN track_genres tg
    ON t.track_id = tg.track_id
LEFT JOIN genres g
    ON tg.genre_id = g.genre_id
LEFT JOIN listening_history lh
    ON t.track_id = lh.track_id
GROUP BY
    t.track_id,
    t.track_title,
    a.album_title,
    t.duration_seconds;

-- TEST VIEW 2

SELECT *
FROM vw_track_engagement_report
ORDER BY total_plays DESC, unique_listeners DESC;



-- TRIGGER TABLE

CREATE TABLE fraud_alerts (
    alert_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    history_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    track_id INT NOT NULL,

    alert_type VARCHAR(50) NOT NULL,
    alert_reason VARCHAR(255) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fraud_alert_history
        FOREIGN KEY (history_id) REFERENCES listening_history(history_id),

    CONSTRAINT fk_fraud_alert_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),

    CONSTRAINT fk_fraud_alert_track
        FOREIGN KEY (track_id) REFERENCES tracks(track_id)
);


-- TRIGGER:
-- Automatically creates a fraud alert when a suspicious listening event is inserted.

DELIMITER //

CREATE TRIGGER trg_listening_history_fraud_alert
AFTER INSERT ON listening_history
FOR EACH ROW
BEGIN
    DECLARE v_track_duration INT;
    DECLARE v_recent_plays INT;

    SELECT duration_seconds
    INTO v_track_duration
    FROM tracks
    WHERE track_id = NEW.track_id;

    SELECT COUNT(*)
    INTO v_recent_plays
    FROM listening_history
    WHERE user_id = NEW.user_id
      AND played_at BETWEEN DATE_SUB(NEW.played_at, INTERVAL 5 MINUTE)
                        AND NEW.played_at;

    -- Case 1: completed time is longer than the actual track duration
    IF NEW.completed_seconds > v_track_duration THEN
        INSERT INTO fraud_alerts (
            history_id,
            user_id,
            track_id,
            alert_type,
            alert_reason
        )
        VALUES (
            NEW.history_id,
            NEW.user_id,
            NEW.track_id,
            'invalid_completion_time',
            'completed seconds are greater than the actual track duration'
        );
    END IF;

    -- Case 2: too many listening events within a short time period
    IF v_recent_plays >= 5 THEN
        INSERT INTO fraud_alerts (
            history_id,
            user_id,
            track_id,
            alert_type,
            alert_reason
        )
        VALUES (
            NEW.history_id,
            NEW.user_id,
            NEW.track_id,
            'suspicious_high_frequency',
            'user has too many listening events within 5 minutes'
        );
    END IF;
END//

DELIMITER ;

SELECT *
FROM fraud_alerts;

-- TRIGGER TEST:
-- The test is wrapped in a transaction and rolled back,
-- so it does not permanently insert invalid listening data.

START TRANSACTION;

SET @test_history_id = (
    SELECT COALESCE(MAX(history_id), 0) + 1
    FROM listening_history
);

INSERT INTO listening_history (
    history_id,
    user_id,
    track_id,
    playlist_id,
    subscription_id,
    device_id,
    played_at,
    completed_seconds
)
VALUES (
    @test_history_id,
    1,
    1,
    NULL,
    1,
    1,
    CURRENT_TIMESTAMP,
    999999
);

SELECT *
FROM fraud_alerts
WHERE history_id = @test_history_id;

ROLLBACK;
SELECT *
FROM fraud_alerts
WHERE history_id = @test_history_id;

-- TRANSACTION 1:
-- creating a new playlist with tracks

START TRANSACTION;

SET @new_playlist_id = (
    SELECT COALESCE(MAX(playlist_id), 0) + 1
    FROM playlists
);

SET @new_playlist_track_id = (
    SELECT COALESCE(MAX(playlist_track_id), 0) + 1
    FROM playlist_tracks
);

INSERT INTO playlists (
    playlist_id,
    owner_user_id,
    playlist_name,
    is_public,
    created_at
)
VALUES (
    @new_playlist_id,
    1,
    'weekend analytics mix',
    TRUE,
    CURRENT_TIMESTAMP
);

INSERT INTO playlist_collaborators (
    playlist_id,
    user_id,
    role,
    joined_at
)
VALUES (
    @new_playlist_id,
    1,
    'owner',
    CURRENT_TIMESTAMP
);

INSERT INTO playlist_tracks (
    playlist_track_id,
    playlist_id,
    track_id,
    added_by_user_id,
    added_at,
    position_no
)
VALUES
    (@new_playlist_track_id,     @new_playlist_id, 1, 1, CURRENT_TIMESTAMP, 1),
    (@new_playlist_track_id + 1, @new_playlist_id, 2, 1, CURRENT_TIMESTAMP, 2),
    (@new_playlist_track_id + 2, @new_playlist_id, 3, 1, CURRENT_TIMESTAMP, 3);

COMMIT;


-- CHECK COMMITTED DATA

SELECT *
FROM playlists
WHERE playlist_id = @new_playlist_id;

SELECT *
FROM playlist_collaborators
WHERE playlist_id = @new_playlist_id;

SELECT *
FROM playlist_tracks
WHERE playlist_id = @new_playlist_id;


-- TRANSACTION 2:
-- testing subscription cancellation and then undoing it

START TRANSACTION;

UPDATE user_subscription
SET status = 'cancelled'
WHERE user_id = 27
  AND status = 'active';

-- Temporary result before rollback
SELECT *
FROM user_subscription
WHERE user_id = 27;

ROLLBACK;


-- Check that the data was restored
SELECT *
FROM user_subscription
WHERE user_id = 27;