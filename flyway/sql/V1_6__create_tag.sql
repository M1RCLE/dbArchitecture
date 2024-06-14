CREATE TABLE Tag
(
    PhotoID    INT NOT NULL,
    UserID     INT NOT NULL,
    Coordinate point,
    PRIMARY KEY (PhotoID, UserID),
    FOREIGN KEY (PhotoID) REFERENCES Photo (PhotoID),
    FOREIGN KEY (UserID) REFERENCES "user" (UserID)
);