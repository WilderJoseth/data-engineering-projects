
CREATE PROCEDURE AdventureWorksDW2022_prod.usp_truncate_tables
AS
BEGIN
	-- Remove data from previous executions
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

