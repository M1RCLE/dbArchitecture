INSERT INTO PhotoCategory (CategoryID, PhotoID)
SELECT DISTINCT ON (CategoryID, PhotoID)
    (SELECT CategoryID FROM Categories ORDER BY random() LIMIT 1) as CategoryID,
    (SELECT PhotoID FROM Photo ORDER BY random() LIMIT 1) as PhotoID
FROM generate_series(1, 500000);