CREATE TABLE Comment
(
    CommentID SERIAL PRIMARY KEY,
    PhotoID   INT NOT NULL,
    PostDate  DATE,
    Content   VARCHAR(250),
    UserID    INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES "user" (UserID),
    FOREIGN KEY (PhotoID) REFERENCES Photo (PhotoID)
);