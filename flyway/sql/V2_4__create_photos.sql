INSERT INTO Photo (AlbumID, LocationID, UserID, UpdateDate, Views, InstagramPath, Likes)
SELECT
    (SELECT AlbumID FROM Album ORDER BY random() LIMIT 1) as AlbumID,
    (SELECT LocationID FROM Location ORDER BY random() LIMIT 1) as LocationID,
    (SELECT UserID FROM "user" ORDER BY random() LIMIT 1) as UserID,
    faker.date_time_this_year()::date,
    floor(random() * 500000),
    gen_random_uuid(),
    floor(random() * 500000)
FROM generate_series(1, 500000);