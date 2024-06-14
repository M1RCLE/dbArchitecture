INSERT INTO Location (Name, ShortName)
SELECT 
    faker.address(),
    faker.word()
FROM generate_series(1, 500000);