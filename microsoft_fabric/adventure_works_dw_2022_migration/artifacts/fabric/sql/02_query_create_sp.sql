
----------------- START staging sp -----------------
CREATE PROCEDURE staging.usp_load_FactFinance
    @year INT
AS
BEGIN
    INSERT INTO staging.FactFinance (
        FinanceKey,
        DateKey,
        OrganizationKey,
        DepartmentGroupKey,
        ScenarioKey,
        AccountKey,
        Amount,
        Date,
        year
    )
    SELECT
        FinanceKey,
        DateKey,
        OrganizationKey,
        DepartmentGroupKey,
        ScenarioKey,
        AccountKey,
        Amount,
        Date,
        year
    FROM lakehouse_main.silver.FactFinance
    WHERE year = @year;

    SELECT @@ROWCOUNT AS end_count;
END;

CREATE PROCEDURE staging.usp_load_DimDate
AS
BEGIN
    TRUNCATE TABLE staging.DimDate;

    DECLARE @start_date DATE;
    DECLARE @end_date DATE;
    
    SELECT @start_date = DATEFROMPARTS(MIN(year), 1, 1), @end_date = DATEFROMPARTS(MAX(year), 12, 31) FROM staging.FactFinance;

    ;WITH days AS (
        SELECT DATEADD(day, s.value, @start_date) AS FullDate
        FROM GENERATE_SERIES(0, DATEDIFF(day, @start_date, @end_date)) AS s
    )
    INSERT INTO staging.DimDate
    (
        DateKey,
        FullDateAlternateKey,
        DayNumberOfMonth,
        DayNumberOfWeek,
        EnglishDayNameOfWeek,
        MonthNumberOfYear,
        EnglishMonthName,
        CalendarQuarter,
        CalendarYear
    )
    SELECT
        CONVERT(INT, CONVERT(NVARCHAR(8), FullDate, 112)) AS DateKey,
        FullDate AS FullDateAlternateKey,
        DAY(FullDate) AS DayNumberOfMonth,
        DATEPART(DW, FullDate) AS DayNumberOfWeek,
        DATENAME(DW, FullDate) AS EnglishDayNameOfWeek,
        MONTH(FullDate) AS MonthNumberOfYear,
        DATENAME(MM, FullDate) AS EnglishMonthName,
        DATEPART(QQ, FullDate) AS CalendarQuarter,
        YEAR(FullDate) AS CalendarYear
    FROM days;
END;

CREATE PROCEDURE staging.usp_load_DimOrganization
AS
BEGIN
    INSERT INTO staging.DimOrganization (
        OrganizationKey,
        ParentOrganizationKey,
        PercentageOfOwnership,
        OrganizationName,
        CurrencyKey
    )
    SELECT
        OrganizationKey,
        ParentOrganizationKey,
        PercentageOfOwnership,
        OrganizationName,
        CurrencyKey
    FROM lakehouse_main.silver.DimOrganization;

    SELECT @@ROWCOUNT AS end_count;
END;

CREATE PROCEDURE staging.usp_load_DimDepartmentGroup
AS
BEGIN
    INSERT INTO staging.DimDepartmentGroup (
        DepartmentGroupKey,
        ParentDepartmentGroupKey,
        DepartmentGroupName
    )
    SELECT
        DepartmentGroupKey,
        ParentDepartmentGroupKey,
        DepartmentGroupName
    FROM lakehouse_main.silver.DimDepartmentGroup;

    SELECT @@ROWCOUNT AS end_count;
END;

CREATE PROCEDURE staging.usp_load_DimScenario
AS
BEGIN
    INSERT INTO staging.DimScenario (
        ScenarioKey,
	    ScenarioName
    )
    SELECT
        ScenarioKey,
	    ScenarioName
    FROM lakehouse_main.silver.DimScenario;

    SELECT @@ROWCOUNT AS end_count;
END;

CREATE PROCEDURE staging.usp_load_DimAccount
AS
BEGIN
    INSERT INTO staging.DimAccount (
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
        ParentAccountKey,
        AccountCodeAlternateKey,
        ParentAccountCodeAlternateKey,
        AccountDescription,
        AccountType,
        Operator,
        ValueType
    FROM lakehouse_main.silver.DimAccount;

    SELECT @@ROWCOUNT AS end_count;
END;
----------------- END staging sp -----------------

----------------- START production sp -----------------
CREATE PROCEDURE production.usp_load_DimDate
AS
BEGIN
    DELETE p
    FROM production.DimDate p
    WHERE EXISTS (SELECT 1 FROM staging.DimDate d WHERE d.CalendarYear = p.CalendarYear);

    INSERT INTO production.DimDate (
        DateKey,
        FullDateAlternateKey,
        DayNumberOfMonth,
        DayNumberOfWeek,
        EnglishDayNameOfWeek,
        MonthNumberOfYear,
        EnglishMonthName,
        CalendarQuarter,
        CalendarYear
    )
    SELECT
        DateKey,
        FullDateAlternateKey,
        DayNumberOfMonth,
        DayNumberOfWeek,
        EnglishDayNameOfWeek,
        MonthNumberOfYear,
        EnglishMonthName,
        CalendarQuarter,
        CalendarYear
    FROM staging.DimDate;
END;

CREATE PROCEDURE production.usp_load_DimOrganization
AS
BEGIN
    UPDATE p SET 
        p.IsActive = 0,
        p.ValidTo = GETDATE()
    FROM production.DimOrganization p
    WHERE EXISTS (SELECT 1 FROM staging.DimOrganization s WHERE s.OrganizationKey = p.OrganizationKey)

    INSERT INTO production.DimOrganization (
        OrganizationKey,
        ParentOrganizationKey,
        PercentageOfOwnership,
        OrganizationName,
        CurrencyKey,
        IsActive,
        ValidFrom
    )
    SELECT
        OrganizationKey,
        ParentOrganizationKey,
        PercentageOfOwnership,
        OrganizationName,
        CurrencyKey,
        1 AS IsActive,
        GETDATE() AS ValidFrom
    FROM staging.DimOrganization;

    SELECT @@ROWCOUNT AS end_count;
END;

CREATE PROCEDURE production.usp_load_DimDepartmentGroup
AS
BEGIN
    UPDATE p SET 
        p.IsActive = 0,
        p.ValidTo = GETDATE()
    FROM production.DimDepartmentGroup p
    WHERE EXISTS (SELECT 1 FROM staging.DimDepartmentGroup s WHERE s.DepartmentGroupKey = p.DepartmentGroupKey)

    INSERT INTO production.DimDepartmentGroup (
        DepartmentGroupKey,
        ParentDepartmentGroupKey,
        DepartmentGroupName,
        IsActive,
        ValidFrom
    )
    SELECT
        DepartmentGroupKey,
        ParentDepartmentGroupKey,
        DepartmentGroupName,
        1 AS IsActive,
        GETDATE() AS ValidFrom
    FROM staging.DimDepartmentGroup;

    SELECT @@ROWCOUNT AS end_count;
END;

CREATE PROCEDURE production.usp_load_DimScenario
AS
BEGIN
    UPDATE p SET 
        p.IsActive = 0,
        p.ValidTo = GETDATE()
    FROM production.DimScenario p
    WHERE EXISTS (SELECT 1 FROM staging.DimScenario s WHERE s.ScenarioKey = p.ScenarioKey)

    INSERT INTO production.DimScenario (
        ScenarioKey,
        ScenarioName,
        IsActive,
        ValidFrom
    )
    SELECT
        ScenarioKey,
        ScenarioName,
        1 AS IsActive,
        GETDATE() AS ValidFrom
    FROM staging.DimScenario;

    SELECT @@ROWCOUNT AS end_count;
END;

CREATE PROCEDURE production.usp_load_DimAccount
AS
BEGIN
    UPDATE p SET 
        p.IsActive = 0,
        p.ValidTo = GETDATE()
    FROM production.DimAccount p
    WHERE EXISTS (SELECT 1 FROM staging.DimAccount s WHERE s.AccountKey = p.AccountKey)

    INSERT INTO production.DimAccount (
        AccountKey,
        ParentAccountKey,
        AccountCodeAlternateKey,
        ParentAccountCodeAlternateKey,
        AccountDescription,
        AccountType,
        Operator,
        ValueType,
        IsActive,
        ValidFrom
    )
    SELECT
        AccountKey,
        ParentAccountKey,
        AccountCodeAlternateKey,
        ParentAccountCodeAlternateKey,
        AccountDescription,
        AccountType,
        Operator,
        ValueType,
        1 AS IsActive,
        GETDATE() AS ValidFrom
    FROM staging.DimAccount;

    SELECT @@ROWCOUNT AS end_count;
END;

CREATE PROCEDURE production.usp_load_FactFinance
    @year INT
AS
BEGIN
    DELETE f
    FROM production.FactFinance f
    WHERE EXISTS (SELECT 1 FROM production.DimDate d WHERE d.DateKey = f.DateKey AND d.CalendarYear = @year);

    INSERT INTO production.FactFinance (
        DateKey,
        OrganizationKey,
        DepartmentGroupKey,
        ScenarioKey,
        AccountKey,
        Amount,
        Date
    )
    SELECT
        DateKey,
        (SELECT MAX(OrganizationSurrogateKey)
        FROM production.DimOrganization d
        WHERE d.IsActive = 1 AND d.OrganizationKey = f.OrganizationKey) AS OrganizationKey,
        (SELECT MAX(DepartmentGroupSurrogateKey)
        FROM production.DimDepartmentGroup d
        WHERE d.IsActive = 1 AND d.DepartmentGroupKey = f.DepartmentGroupKey) AS DepartmentGroupKey,
        (SELECT MAX(ScenarioSurrogateKey)
        FROM production.DimScenario d
        WHERE d.IsActive = 1 AND d.ScenarioKey = f.ScenarioKey) AS ScenarioKey,
        (SELECT MAX(AccountSurrogateKey)
        FROM production.DimAccount d
        WHERE d.IsActive = 1 AND d.AccountKey = f.AccountKey) AS AccountKey,
        Amount,
        Date
    FROM staging.FactFinance f
    WHERE f.year = @year;

    SELECT @@ROWCOUNT AS end_count;
END;
----------------- END production sp -----------------
