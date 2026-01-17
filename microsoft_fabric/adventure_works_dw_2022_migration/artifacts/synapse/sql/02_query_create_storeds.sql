CREATE PROCEDURE AdventureWorksDW2022_prod.usp_truncate_tables
AS
BEGIN
	TRUNCATE TABLE AdventureWorksDW2022_prod.FactFinance;
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimOrganization;
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimDepartmentGroup;
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimScenario;
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimAccount;
	TRUNCATE TABLE AdventureWorksDW2022_prod.DimDate;
END;