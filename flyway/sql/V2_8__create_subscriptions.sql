INSERT INTO Subscription (UserID, SubscriberID)
SELECT DISTINCT ON (UserID, SubscriberID)
    (SELECT UserID FROM "user" ORDER BY random() LIMIT 1) as UserID,
    (SELECT UserID FROM "user" ORDER BY random() LIMIT 1) as SubscriberID
FROM generate_series(1, 500000);