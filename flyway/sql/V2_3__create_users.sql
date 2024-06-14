INSERT INTO "user" (Age, Name, ViewedInformation)
SELECT 
    faker.date_time_this_year()::date,
    faker.name(),
    faker.sentence()
FROM generate_series(1, 500000);