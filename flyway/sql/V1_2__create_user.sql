CREATE TABLE "user"
(
    UserID            SERIAL PRIMARY KEY,
    Age               DATE NOT NULL,
    Name              VARCHAR(100),
    ViewedInformation VARCHAR(500)
);