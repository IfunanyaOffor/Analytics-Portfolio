CREATE TABLE Afritech (
CustomerID INT,
CustomerName TEXT,
Region TEXT,
Age INT,
Income Numeric(10, 2),
CustomerType Text,
TransactionYear Text,
TransactionDate DATE,
ProductPurchased Text,
PurchasedAmount Numeric(10, 2),
ProductRecalled Boolean,
Competitor_x TEXT,
InteractionDate DATE,
Platform TEXT,
PostType TEXT,
EngagementLikes INT,
EngagementShares INT,
EngagementComments INT,
UserFollowers INT,
InfluncerScore Numeric(10, 2),
BrandMention Boolean,
CompetitorMention Boolean,
Sentiment TEXT,
CrisisEventTime DATE,
FirstResponseTime DATE,
ResolutionStatus Boolean,
NPSResponse INT
);


CREATE TABLE CustomerData(
CustomerID INT primary Key,
CustomerName VARCHAR(50),
Region VARCHAR(50),
Age INT,
Income Numeric(10, 2),
CustomerType VARCHAR(20)
);

CREATE TABLE TransactionData(
TransactionID SERIAL Primary Key,
CustomerID INT,
TransactionYear VARCHAR(4),
TransactionDate DATE,
ProductPurchased VARCHAR(255),
PurchasedAmount Numeric(10, 2),
ProductRecalled Boolean,
Competitor_x VARCHAR(255),
FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);

CREATE TABLE SocialMedia(
PostID SERIAL Primary Key,
CustomerID INT,
InteractionDate DATE,
Platform VARCHAR(50),
PostType VARCHAR(20),
EngagementLikes INT,
EngagementShares INT,
EngagementComments INT,
UserFollowers INT,
InfluncerScore Numeric(10,2),
BrandMention Boolean,
CompetitorMention Boolean,
Sentiment VARCHAR(50),
Competitor_x VARCHAR(255),
CrisisEventTime DATE,
FirstResponseTime Date,
ResolutionStatus Boolean,
NPSResponse INT,
FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);


INSERT INTO CustomerData(CustomerID, CustomerName, Region, Age, Income, CustomerType)
SELECT DISTINCT CustomerID, CustomerName, Region, Age, Income, CustomerType
FROM Afritech;


INSERT INTO TransactionData(CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchasedAmount, ProductRecalled, Competitor_x)
SELECT CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchasedAmount, ProductRecalled, Competitor_x
FROM Afritech
WHERE TransactionDate IS NOT NULL;

INSERT INTO SocialMedia(CustomerID, InteractionDate,Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, Userfollowers, 
InfluncerScore, BrandMention, CompetitorMention, Sentiment, Competitor_x, CrisisEventTime, FirstResponseTime,ResolutionStatus,NPSResponse)
SELECT CustomerID, InteractionDate,Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, Userfollowers, 
InfluncerScore, BrandMention, CompetitorMention, Sentiment, Competitor_x, CrisisEventTime, FirstResponseTime,ResolutionStatus,NPSResponse
FROM Afritech
WHERE InteractionDate IS NOT NULL;

SELECT * FROM Afritech;
SELECT * FROM CustomerData;

SELECT CustomerName,Age
FROM CustomerData;


SELECT * FROM TransactionData;



SELECT Platform, Engagementlikes
FROM SocialMedia;

ALTER TABLE SocialMedia
RENAME COLUMN InfluncerScore TO InfluencerScore;



--Data Cleaning

SELECT COUNT(*)
FROM CustomerData 
WHERE CustomerID is null;

-- EXPLORATORY DATA ANALYSIS

-- 1,CUSTOMER DATA

-- HOW MANY CUSTOMERS IN EACH REGION
SELECT Region,
COUNT(*) AS Region_Count
FROM CustomerData
GROUP BY Region
ORDER BY COUNT(*) DESC;
 
--HOW MANY UNIQUE CUSTOMERS DO WE HAVE
SELECT COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM CustomerData;

--What is the highest, lowest, and average Age of the Customer?
SELECT MAX(Age) AS Highest_Age,
MIN(Age) AS Lowest_Age,
ROUND(AVG(Age),0) AS Average_Age 
FROM CustomerData;

-- WHAT IS THE CUSTOMER DISTRIBUTION

SELECT CustomerType, COUNT(*) AS Type_Count
FROM CustomerData
GROUP BY CustomerType
ORDER BY Type_Count DESC;

--INCOME DISTRIBUTION

SELECT ROUND(MAX(Income),2) AS Highest_Income,
ROUND(AVG(income),2) AS Average_Income,
ROUND(MIN(Income),2) AS Lowest_Income
FROM CustomerData;

--TRANSACTION DATA
-- What is the productpricing distribution at afritech? 

SELECT ROUND(MAX(PurchasedAmount), 2) AS Highest_Price,
ROUND(MIN(PurchasedAmount), 2) AS Lowest_Price,
ROUND(AVG(PurchasedAmount), 2) AS Average_Price
FROM TransactionData;

-- What are the product purchased behavior? 

SELECT ProductPurchased, COUNT(*) AS PurchaseQuantity, SUM(PurchasedAmount) AS TotalSales 
FROM TransactionData 
GROUP BY ProductPurchased 
ORDER BY TotalSales DESC; 

-- What are the product recalled behavior? 

SELECT ProductRecalled, COUNT(*) AS PurchaseQuality, 
SUM(PurchasedAmount) AS TotalSales 
FROM TransactionData 
Group BY ProductRecalled 
ORDER BY SUM(PurchasedAmount) DESC; 

-- Social Media Data 
-- what are the likes behavior per platform? 

SELECT platform, SUM(EngagementLikes) AS Total_Likes,AVG(EngagementLiKes) AS Average_Likes
FROM SocialMedia 
GROUP BY platform 
ORDER BY SUM(EngagementLikes) DESC;

-- what are the Shares behavior per platform? 

SELECT platform, SUM(EngagementShares) AS Total_Shares, AVG(EngagementShares) AS Average_Shares 
FROM SocialMedia 
GROUP BY platform 
ORDER BY SUM(EngagementShares) DESC; 

-- what are the Comments behavior per platform? 

SELECT platform, SUM(EngagementComments) AS Total_Comments, AVG(EngagementComments) AS Average_Comments 
FROM SocialMedia 
GROUP BY platform 
ORDER BY SUM(EngagementComments) DESC; 

-- what is the sentiment distribution? 

SELECT Sentiment, COUNT(*) AS count 
FROM SocialMedia 
GROUP BY Sentiment 
ORDER BY COUNT (*) DESC; 

SELECT COUNT(*) AS NumberofMentions 
FROM SocialMedia 
WHERE BrandMention = 'True'; 

-- Platform by Brand Mentions 

SELECT platform, COUNT(*) AS NumberofMentions 
FROM SocialMedia 
WHERE BrandMention = 'True' 
GROUP BY platform 
ORDER BY COUNT (*) DESC; 

-- Brand Mentions vs Competitor mentions 
SELECT SUM(CASE 
WHEN BrandMention = 'True' THEN 1 
ELSE 0 
END) AS BrandMentionCount, 
SUM(CASE 
WHEN CompetitorMention = 'True' THEN 1 
ELSE 0 
END) AS CompetitorMentionCount
FROM SocialMedia; 

-- what does engagement rate per post look like? 

SELECT AVG(EngagementLikes + EngagementShares + EngagementComments) / NULLIF (UserFollowers, 0) AS EngagementRate 
FROM SocialMedia 
GROUP BY UserFollowers;

-- Response Time 

SELECT AVG(DATE_PART('epoch', CAST(firstresponsetime AS timestamp) - CAST(crisiseventtime AS timestamp)) / 3600) AS averageresponsetimehours FROM SocialMedia 
WHERE crisiseventtime IS NOT NULL 
AND firstresponsetime IS NOT NULL;

-- Top Influencers 

SELECT CustomerID, AVG(InfluencerScore) AS Influencescore FROM SocialMedia 
GROUP BY CustomerID 
ORDER BY Influencescore DESC 
LIMIT 10; 

-- Total Revenue by platform 

SELECT s.platform, sum(t.purchasedamount) AS Total_Revenue 
FROM SocialMedia s 
LEFT JOIN Transactiondata t 
ON s.customerid = t.customerid 
WHERE t.purchasedamount IS NOT NULL 
GROUP BY s.platform 
ORDER BY SUM(t.purchasedamount) 
LIMIT 5; 


-- Create a view for average purchase amount by product 

CREATE VIEW avg_purchase_per_product AS 
SELECT productpurchased, AVG(purchasedamount) AS avg_purchase_amount 
FROM transactiondata 
GROUP BY productpurchased; 
SELECT * FROM avg_purchase_per_product; 



SELECT * FROM total_engagement;

SELECT platform,
 COUNT (EngagementLikes + EngagementShares +
  EngagementComments)
   AS TotalEngagement
FROM Socialmedia
WHERE Platform IS NOT NULL
GROUP BY Platform ;


SELECT TransactionData.ProductPurchased,
 COUNT (EngagementLikes + EngagementShares +
  EngagementComments)
   AS Total_Engagement
FROM Socialmedia
LEFT JOIN TransactionData
ON SocialMedia.CustomerID=TransactionData.CustomerID
WHERE TransactionData.ProductPurchased  IS NOT NULL
GROUP BY ProductPurchased 
ORDER BY Total_Engagement DESC;





