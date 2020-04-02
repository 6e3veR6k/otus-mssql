SELECT 1;

SELECT *
FROM Application.Cities;

SELECT CityID, CityName, StateProvinceID
FROM Application.Cities;

SELECT 
	CityID, 
	CityName,
	CityName AS City, 
	CityName City2, 
	City3=CityName,
	StateProvinceID
FROM Application.Cities AS C;

--а так будет работать?
SELECT 
	CityID as ID, 
	CityName AS City, 
	CityName City, 
	City=CityName,
	StateProvinceID
FROM Application.Cities;

SELECT DISTINCT 
	CityName AS City
FROM Application.Cities;

SELECT DISTINCT 
	CityName AS City,
	CityID, 
	StateProvinceID
FROM Application.Cities;

-- как не работает 
SELECT DISTINCT 
	(CityName), 
	CityID, 
	StateProvinceID
FROM Application.Cities;

SELECT  
	CityName, 
	CityID, 
	StateProvinceID
FROM Application.Cities
GROUP BY CityName, 	CityID, StateProvinceID;

SELECT 
	CityName AS City,
	Min(CityID), 
	Min(StateProvinceID)
FROM Application.Cities
GROUP BY CityName;

SELECT
	CityID, 
	CityName AS City, 
	CityName City2, 
	City3=CityName,
	StateProvinceID
FROM Application.Cities
ORDER BY City DESC;

SELECT TOP (10) 
	CityID, 
	CityName AS City, 
	CityName City2, 
	City3=CityName,
	StateProvinceID
FROM Application.Cities;

SELECT TOP 10 
	CityID, 
	CityName AS City, 
	CityName City2, 
	City3=CityName,
	StateProvinceID
FROM Application.Cities
ORDER BY City;

SELECT TOP 3 WITH TIES
	CityID, 
	CityName AS City, 
	CityName City2, 
	City3=CityName,
	StateProvinceID
FROM Application.Cities
ORDER BY City;

SELECT TOP 3 WITH TIES
	CityID, 
	CityName AS City, 
	CityName City2, 
	City3=CityName,
	StateProvinceID
FROM Application.Cities
ORDER BY City;

SELECT 
	CityID, 
	CityName AS [Город На Неве], 
	CityName City2, 
	City3=CityName,
	StateProvinceID
FROM Application.Cities
ORDER BY [Город На Неве];

SELECT 
	CityID, 
	CityName AS [Город На Неве], 
	CityName City2, 
	City3=CityName,
	StateProvinceID
FROM Application.Cities
ORDER BY [Город На Неве]
OFFSET 1 ROWS FETCH FIRST 5 ROWS ONLY;
 
SELECT 
	CityID, 
	CityName AS City, 
	CityName City2, 
	City3=CityName,
	StateProvinceID
FROM Application.Cities
ORDER BY City
OFFSET 10 ROWS;

DECLARE 
	@pagesize BIGINT = 10, 
	@pagenum BIGINT = 3;

SELECT 
	CityID, 
	CityName AS City,
	StateProvinceID
FROM Application.Cities
ORDER BY City, CityID
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY; 

