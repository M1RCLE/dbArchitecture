CREATE TABLE Subscription
(
    UserID       INT NOT NULL,
    SubscriberID INT NOT NULL,
    PRIMARY KEY (UserID, SubscriberID),
    FOREIGN KEY (UserID) REFERENCES "user" (UserID),
    FOREIGN KEY (SubscriberID) REFERENCES "user" (UserID)
);