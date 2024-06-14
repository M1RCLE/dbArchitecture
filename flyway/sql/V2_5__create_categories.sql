INSERT INTO Categories (CategoryName)
SELECT 
    faker.word()
FROM generate_series(1, 500000);