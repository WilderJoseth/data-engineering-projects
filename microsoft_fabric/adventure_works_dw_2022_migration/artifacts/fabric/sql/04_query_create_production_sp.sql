
----------------- START production sp -----------------
CREATE PROCEDURE production.usp_load_DimDate
AS
BEGIN
    -- Remove data from previous executions by year, based on years loaded in current process
    DELETE p
    FROM production.DimDate p
    WHERE EXISTS (SELECT 1 FROM staging.DimDate d WHERE d.CalendarYear = p.CalendarYear);

    -- Add new data
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
    -- Deactivate data from previous executions
    UPDATE p SET 
        p.IsActive = 0,
        p.ValidTo = GETDATE()
    FROM production.DimOrganization p
    WHERE EXISTS (SELECT 1 FROM staging.DimOrganization s WHERE s.OrganizationKey = p.OrganizationKey)

    -- Add new data
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
    -- Deactivate data from previous executions
    UPDATE p SET 
        p.IsActive = 0,
        p.ValidTo = GETDATE()
    FROM production.DimDepartmentGroup p
    WHERE EXISTS (SELECT 1 FROM staging.DimDepartmentGroup s WHERE s.DepartmentGroupKey = p.DepartmentGroupKey)

    -- Add new data
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
    -- Deactivate data from previous executions
    UPDATE p SET 
        p.IsActive = 0,
        p.ValidTo = GETDATE()
    FROM production.DimScenario p
    WHERE EXISTS (SELECT 1 FROM staging.DimScenario s WHERE s.ScenarioKey = p.ScenarioKey)

    -- Add new data
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
    -- Deactivate data from previous executions
    UPDATE p SET 
        p.IsActive = 0,
        p.ValidTo = GETDATE()
    FROM production.DimAccount p
    WHERE EXISTS (SELECT 1 FROM staging.DimAccount s WHERE s.AccountKey = p.AccountKey)

    -- Add new data
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
    -- Remove data from previous executions by year
    DELETE f
    FROM production.FactFinance f
    WHERE EXISTS (SELECT 1 FROM production.DimDate d WHERE d.DateKey = f.DateKey AND d.CalendarYear = @year);

    -- Add new data
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
