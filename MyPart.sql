-- VIEW 1:
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
    

-- VIEW 2:
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

    SUM(
        CASE
            WHEN lh.completed_seconds >= t.duration_seconds * 0.9 THEN 1
            ELSE 0
        END
    ) AS almost_completed_plays
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


-- TEST VIEWS
SELECT *
FROM vw_subscription_revenue_report;

SELECT *
FROM vw_track_engagement_report
ORDER BY total_plays DESC, unique_listeners DESC;


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

    -- CASE 1: 
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

    -- CASE 2:
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


-- TRIGGER TEST:
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
    999999,
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
ORDER BY created_at DESC;


START TRANSACTION;

INSERT INTO playlists (
    playlist_id,
    owner_user_id,
    playlist_name,
    is_public,
    created_at
)
VALUES (
    10001,
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
    10001,
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
    (10001, 10001, 1, 1, CURRENT_TIMESTAMP, 1),
    (10002, 10001, 2, 1, CURRENT_TIMESTAMP, 2),
    (10003, 10001, 3, 1, CURRENT_TIMESTAMP, 3);

COMMIT;


-- CHECK COMMITTED DATA
SELECT *
FROM playlists
WHERE playlist_id = 10001;

SELECT *
FROM playlist_tracks
WHERE playlist_id = 10001;


START TRANSACTION;

UPDATE user_subscription
SET status = 'cancelled'
WHERE user_id = 27
  AND status = 'active';

-- CHECK TEMPORARY RESULT BEFORE ROLLBACK
SELECT *
FROM user_subscription
WHERE user_id = 27;

ROLLBACK;


-- CHECK THAT DATA WAS RESTORED
SELECT *
FROM user_subscription
WHERE user_id = 27;



-- 4. INDEXING AND OPTIMIZATION

EXPLAIN
SELECT
    lh.user_id,
    u.username,
    COUNT(*) AS total_plays,
    COUNT(DISTINCT lh.track_id) AS unique_tracks,
    MAX(lh.played_at) AS last_played_at
FROM listening_history lh
JOIN users u
    ON lh.user_id = u.user_id
WHERE lh.played_at >= '2026-01-01'
GROUP BY
    lh.user_id,
    u.username
ORDER BY total_plays DESC;


EXPLAIN
SELECT
    t.track_id,
    t.track_title,
    COUNT(lh.history_id) AS total_plays
FROM tracks t
JOIN listening_history lh
    ON t.track_id = lh.track_id
WHERE lh.played_at >= '2026-01-01'
GROUP BY
    t.track_id,
    t.track_title
ORDER BY total_plays DESC;


-- INDEXES


CREATE INDEX idx_listening_history_user_date_track
ON listening_history (user_id, played_at, track_id);

CREATE INDEX idx_listening_history_track_date_user
ON listening_history (track_id, played_at, user_id);

CREATE INDEX idx_user_subscription_status_dates
ON user_subscription (status, start_date, end_date, plan_id, user_id);



EXPLAIN
SELECT
    lh.user_id,
    u.username,
    COUNT(*) AS total_plays,
    COUNT(DISTINCT lh.track_id) AS unique_tracks,
    MAX(lh.played_at) AS last_played_at
FROM listening_history lh
JOIN users u
    ON lh.user_id = u.user_id
WHERE lh.played_at >= '2026-01-01'
GROUP BY
    lh.user_id,
    u.username
ORDER BY total_plays DESC;


EXPLAIN
SELECT
    t.track_id,
    t.track_title,
    COUNT(lh.history_id) AS total_plays
FROM tracks t
JOIN listening_history lh
    ON t.track_id = lh.track_id
WHERE lh.played_at >= '2026-01-01'
GROUP BY
    t.track_id,
    t.track_title
ORDER BY total_plays DESC;
