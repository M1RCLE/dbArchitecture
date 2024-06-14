CREATE TABLE PhotoCategory
(
    CategoryID INT NOT NULL,
    PhotoID    INT NOT NULL,
    PRIMARY KEY (CategoryID, PhotoID),
    FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID),
    FOREIGN KEY (CategoryID) REFERENCES Photo (PhotoID)
);