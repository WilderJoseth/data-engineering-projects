
----------------- START staging sp -----------------
CREATE PROCEDURE staging.usp_load_FactFinance
    @year INT
AS
BEGIN
    -- Add new data
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
    -- Remove data from previous executions
    TRUNCATE TABLE staging.DimDate;

    -- Calculate date range
    DECLARE @start_date DATE;
    DECLARE @end_date DATE;
    
    SELECT @start_date = DATEFROMPARTS(MIN(year), 1, 1), @end_date = DATEFROMPARTS(MAX(year), 12, 31) FROM staging.FactFinance;

    -- Add new data
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
    -- Add new data
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
    -- Add new data
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
    -- Add new data
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
    -- Add new data
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
