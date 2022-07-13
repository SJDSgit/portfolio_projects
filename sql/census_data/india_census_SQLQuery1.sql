--Exploring the data
SELECT * 
FROM dbo.data1;
SELECT * 
FROM dbo.data2;

--Number of  Rows in our data
SELECT COUNT(*) AS NoOfRows 
FROM data1;
SELECT COUNT(*) AS NoOfRows 
FROM data2;

--Distinct States and Union territories available in our data
SELECT DISTINCT State 
FROM data1 
GROUP BY State;
SELECT DISTINCT State 
FROM data2 
GROUP BY State;

--Number of Distinct States and Union territories available in our data
SELECT COUNT(DISTINCT State) AS NoOfStatesData1 
FROM data1;
SELECT COUNT(DISTINCT State) AS NoOfStatesData2 
FROM data2;

--Analyzing Western India
SELECT SUM(Population) AS WesternRegionPopulation 
FROM data2 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu');

--Average growth in population in Western India
SELECT AVG(Growth)*100 AS 'AvgGrowth(%)' 
FROM data1 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu');

--Average growth in population in each State of Western India
SELECT State, CAST((AVG(Growth)*100) AS DECIMAL(4,2)) AS 'AvgGrowth(%)' 
FROM data1 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu') 
GROUP BY State 
ORDER BY 2 DESC;

--Regionwise population according to ISCS
SELECT sub.Region, SUM(sub.Population) AS Population
FROM (SELECT CASE WHEN State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu') THEN 'WR'
				  WHEN State IN ('Chhattisgarh','Madhya Pradesh','Uttar Pradesh','Uttarakhand') THEN 'CR'
				  WHEN State IN ('Bihar','Jharkhand','Orissa','West Bengal') THEN 'ER'
				  WHEN State IN ('Haryana','Himachal Pradesh','Punjab','Rajasthan','Delhi','Chandigarh','Jammu and Kashmir','Ladakh') THEN 'NR'
				  WHEN State IN ('Andhra Pradesh','Karnataka','Kerala','Tamil Nadu','Telangana','Puducherry') THEN 'SR'
				  ELSE 'Others' END AS Region,
			Population		
FROM data2) sub
GROUP BY Region
ORDER BY Population DESC;

--Average Sex Ratio in population in each State of Western India
SELECT State, CAST(AVG(Sex_Ratio) AS DECIMAL(3,0)) AS AvgSexRatio 
FROM data1 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu') 
GROUP BY State 
ORDER BY 2 DESC;

--Average Literacy in Western India
SELECT State, CAST(AVG(Literacy) AS DECIMAL(4,2)) AS AvgLiteracy 
FROM data1 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu') 
GROUP BY State 
ORDER BY 2 DESC;

--Literacy in Western India greater than 80%
SELECT State, CAST(AVG(Literacy) AS DECIMAL(4,2)) AS 'AvgLiteracy(%)' 
FROM data1 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu') 
GROUP BY State 
HAVING CAST(AVG(Literacy) AS DECIMAL(4,2))>=80
ORDER BY 2 DESC;

--State with highest Literacy rate in Western India
SELECT TOP 1 State, CAST(AVG(Literacy) AS DECIMAL(4,2)) AS 'HighestAvgLiteracy(%)' 
FROM data1 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu') 
GROUP BY State 
ORDER BY 2 DESC;

--State with lowest Literacy rate in Western India
SELECT TOP 1 State, CAST(AVG(Literacy) AS DECIMAL(4,2)) AS 'LowestAvgLiteracy(%)' 
FROM data1 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu') 
GROUP BY State 
ORDER BY 2 ASC;

--Top and Bottom most States with respect to literacy in Western India
DROP TABLE IF EXISTS #topstates
CREATE TABLE #topstates
(
State NVARCHAR(255),
Literacy FLOAT
)

INSERT INTO #topstates
SELECT State, CAST(AVG(Literacy) AS DECIMAL(4,2)) AS 'AvgLiteracy(%)' 
FROM data1 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu') 
GROUP BY State 
ORDER BY 2 DESC;

SELECT TOP 1 * FROM #topstates ORDER BY Literacy DESC;

DROP TABLE IF EXISTS #bottomstates
CREATE TABLE #bottomstates
(
State NVARCHAR(255),
Literacy FLOAT
)

INSERT INTO #bottomstates
SELECT State, CAST(AVG(Literacy) AS DECIMAL(4,2)) AS 'AvgLiteracy(%)' 
FROM data1 
WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu') 
GROUP BY State 
ORDER BY 2 ASC;

SELECT TOP 1 * FROM #bottomstates;

--Using UNION convey the result in same table
SELECT * FROM(SELECT TOP 1 * FROM #topstates ORDER BY Literacy DESC) a
UNION
SELECT * FROM(SELECT TOP 1 * FROM #bottomstates) b
ORDER BY Literacy DESC;

--Population of Male vs Female Statewise in Western Maharashtra
SELECT sub1.State, SUM(sub1.Males) Males, SUM(sub1.Females) Females
FROM (SELECT sub.District, sub.State, ROUND(sub.Population/(sub.Sex_Ratio+1),0) Males, ROUND((sub.Population*sub.Sex_Ratio)/(sub.Sex_Ratio+1),0) Females
	  FROM (SELECT d1.District, d1.State, d1.Sex_ratio/1000 Sex_Ratio, d2.Population 
		    FROM data1 d1 INNER JOIN data2 d2 ON d1.District=d2.District 
		    WHERE d1.State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu')) sub) sub1
GROUP BY sub1.State;

--Literate vs Illiterate Population in Western India
SELECT sub1.State, SUM(Literate) Literate, SUM(Illiterate) Illiterate 
FROM	(SELECT sub.District, sub.State, ROUND(sub.Literacy_Ratio*sub.Population,0) Literate, ROUND((1-sub.Literacy_Ratio)*sub.Population,0) Illiterate
		 FROM(SELECT d1.District, d1.State, d1.Literacy/100 Literacy_Ratio, d2.Population 
			  FROM data1 d1 INNER JOIN data2 d2 ON d1.District=d2.District 
			  WHERE d1.State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu')) sub) sub1
GROUP BY sub1.State
ORDER BY Literate DESC;

--Previous vs Current Population in Western India
SELECT SUM(sub2.PrevCensusPop) PrevCensusPop, SUM(sub2.CurrCensusPop) CurrCensusPop
FROM    (SELECT sub1.State, SUM(sub1.PrevCensusPop) PrevCensusPop, SUM(sub1.CurrCensusPop) CurrCensusPop 
		FROM (SELECT sub.District, sub.State, ROUND(sub.Population/(1+sub.Growth),0) PrevCensusPop, sub.Population CurrCensusPop
			 FROM (SELECT d1.District, d1.State, d1.Growth, d2.Population
				  FROM data1 d1 INNER JOIN data2 d2 ON d1.District=d2.District
				  WHERE d1.State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu')) sub) sub1
		GROUP BY sub1.State) sub2;

--Population vs Area in Western India
SELECT (sub7.TotalArea/sub7.PrevCensusPop) PrevCensusPopvsArea, (sub7.TotalArea/sub7.CurrCensusPop) CurrCensusPopvsArea
FROM (SELECT sub4.*, sub6.TotalArea
	 FROM (SELECT '1' PrimKey, sub3.*
		  FROM (SELECT SUM(sub2.PrevCensusPop) PrevCensusPop, SUM(sub2.CurrCensusPop) CurrCensusPop
			   FROM    (SELECT sub1.State, SUM(sub1.PrevCensusPop) PrevCensusPop, SUM(sub1.CurrCensusPop) CurrCensusPop 
					   FROM (SELECT sub.District, sub.State, ROUND(sub.Population/(1+sub.Growth),0) PrevCensusPop, sub.Population CurrCensusPop
						    FROM (SELECT d1.District, d1.State, d1.Growth, d2.Population
								 FROM data1 d1 INNER JOIN data2 d2 ON d1.District=d2.District
								 WHERE d1.State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu')) sub) sub1
					   GROUP BY sub1.State) sub2) sub3) sub4 INNER JOIN(

SELECT '1' PrimKey, sub5.*
FROM (SELECT SUM(area_km2) TotalArea
	 FROM data2) sub5) sub6 ON sub4.PrimKey=sub6.PrimKey)sub7

--Top District in each State of Western Region of India
SELECT sub.*
FROM (SELECT District, State, Literacy, RANK() OVER(PARTITION BY State ORDER BY Literacy DESC) Rank_ 
	 FROM data1 WHERE State IN ('Goa','Gujarat','Maharashtra','Dadra and Nagar Haveli','Daman and Diu')) sub
WHERE sub.Rank_ IN (1)
ORDER BY State;