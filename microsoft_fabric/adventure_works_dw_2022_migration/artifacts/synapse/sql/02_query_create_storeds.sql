

CREATE PROCEDURE AdventureWorksDW2022_prod.usp_truncate_tables
AS
BEGIN
	TRUNCATE TABLE AdventureWorksDW2022_prod.FactFinance
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimDate
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimOrganization
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimDepartmentGroup
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimScenario
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimAccount
END;

CREATE PROCEDURE AdventureWorksDW2022_prod.usp_load_FactFinance
AS
BEGIN
	INSERT INTO AdventureWorksDW2022_prod.FactFinance
	SELECT * FROM AdventureWorksDW2022_stag.FactFinance
END;

CREATE PROCEDURE AdventureWorksDW2022_prod.usp_load_DimDate
AS
BEGIN
	INSERT INTO AdventureWorksDW2022_prod.DimDate
	SELECT * FROM AdventureWorksDW2022_stag.DimDate
END;

CREATE PROCEDURE AdventureWorksDW2022_prod.usp_load_DimOrganization
AS
BEGIN
	INSERT INTO AdventureWorksDW2022_prod.DimOrganization (
		OrganizationKey,
		ParentOrganizationKey,
		PercentageOfOwnership,
		OrganizationName,
		CurrencyKey
	)
	SELECT
		OrganizationKey,
		ISNULL(ParentOrganizationKey, 0) AS ParentOrganizationKey,
		PercentageOfOwnership,
		OrganizationName,
		CurrencyKey
	FROM AdventureWorksDW2022_stag.DimOrganization
END;

CREATE PROCEDURE AdventureWorksDW2022_prod.usp_load_DimDepartmentGroup
AS
BEGIN
	INSERT INTO AdventureWorksDW2022_prod.DimDepartmentGroup (
		DepartmentGroupKey,
		ParentDepartmentGroupKey,
		DepartmentGroupName
	)
	SELECT
		DepartmentGroupKey,
		ISNULL(ParentDepartmentGroupKey, 0) AS ParentDepartmentGroupKey,
		DepartmentGroupName
	FROM AdventureWorksDW2022_stag.DimDepartmentGroup
END;

CREATE PROCEDURE AdventureWorksDW2022_prod.usp_load_DimScenario
AS
BEGIN
	INSERT INTO AdventureWorksDW2022_prod.DimScenario
	SELECT * FROM AdventureWorksDW2022_stag.DimScenario
END;

CREATE PROCEDURE AdventureWorksDW2022_prod.usp_load_DimAccount
AS
BEGIN
	INSERT INTO AdventureWorksDW2022_prod.DimAccount (
		AccountKey,
		ParentAccountKey,
		AccountCodeAlternateKey,
		ParentAccountCodeAlternateKey,
		AccountDescription,
		AccountType,
		Operator,
		ValueType	
	)
	SELECT
		AccountKey,
		ISNULL(ParentAccountKey, 0) AS ParentAccountKey,
		AccountCodeAlternateKey,
		ISNULL(ParentAccountCodeAlternateKey, 0) AS ParentAccountCodeAlternateKey,
		AccountDescription,
		ISNULL(AccountType, '') AS AccountType,
		Operator,
		ValueType
	FROM AdventureWorksDW2022_stag.DimAccount
END;

EXEC AdventureWorksDW2022_prod.usp_load_FactFinance
EXEC AdventureWorksDW2022_prod.usp_load_DimDate
EXEC AdventureWorksDW2022_prod.usp_load_DimOrganization
EXEC AdventureWorksDW2022_prod.usp_load_DimDepartmentGroup
EXEC AdventureWorksDW2022_prod.usp_load_DimScenario
EXEC AdventureWorksDW2022_prod.usp_load_DimAccount

SELECT
	d.CalendarYear,
	d.EnglishMonthName,
	d.EnglishDayNameOfWeek,
	o.OrganizationName,
	dg.DepartmentGroupName,
	s.ScenarioName,
	f.Amount
FROM AdventureWorksDW2022_prod.FactFinance f
INNER JOIN AdventureWorksDW2022_prod.DimDate d ON d.DateKey = f.DateKey
INNER JOIN AdventureWorksDW2022_prod.DimOrganization o ON o.OrganizationKey = f.OrganizationKey
INNER JOIN AdventureWorksDW2022_prod.DimDepartmentGroup dg ON dg.DepartmentGroupKey = f.DepartmentGroupKey
INNER JOIN AdventureWorksDW2022_prod.DimScenario s ON s.ScenarioKey = f.ScenarioKey
INNER JOIN AdventureWorksDW2022_prod.DimAccount a ON a.AccountKey = f.AccountKey


SELECT * FROM AdventureWorksDW2022_prod.FactFinance
