INSERT INTO Album (Title, Description)
SELECT
    faker.word(),
    faker.sentence()
FROM generate_series(1, 500000);