INSERT INTO Tag (PhotoID, UserID, Coordinate)
SELECT DISTINCT ON (PhotoID, UserID)
    (SELECT PhotoID FROM Photo ORDER BY random() LIMIT 1) as PhotoID,
    (SELECT UserID FROM "user" ORDER BY random() LIMIT 1) as UserID,
    point((random() * 180) - 90, (random() * 360) - 180)
FROM generate_series(1, 500000);