CREATE TABLE Photo
(
    PhotoID       SERIAL PRIMARY KEY,
    AlbumID       INT,
    LocationID    INT,
    UserID        INT,
    UpdateDate    DATE not null,
    Views         INT  NOT NULL,
    InstagramPath uuid,
    Likes         INT,
    FOREIGN KEY (AlbumID) REFERENCES Album (AlbumID),
    FOREIGN KEY (LocationID) REFERENCES Location (LocationID),
    FOREIGN KEY (UserID) REFERENCES "user" (UserID)
);