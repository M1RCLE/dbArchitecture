INSERT INTO Comment (PhotoID, PostDate, Content, UserID)
SELECT DISTINCT ON (PhotoID, UserID)
    (SELECT PhotoID FROM Photo ORDER BY random() LIMIT 1) as PhotoID,
    faker.date_time_this_year()::date,
    faker.sentence(),
    (SELECT UserID FROM "user" ORDER BY random() LIMIT 1) as UserID
FROM generate_series(1, 500000);