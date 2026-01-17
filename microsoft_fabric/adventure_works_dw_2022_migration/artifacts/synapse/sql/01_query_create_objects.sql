
----------------- START schemas -----------------
CREATE SCHEMA AdventureWorksDW2022_prod;
----------------- END schemas -----------------

----------------- START fact tables -----------------
CREATE TABLE AdventureWorksDW2022_prod.FactFinance
(
    FinanceKey INT NULL,
    DateKey INT NULL,
    OrganizationKey INT NULL,
    DepartmentGroupKey INT NULL,
    ScenarioKey INT NULL,
    AccountKey INT NULL,
    Amount DECIMAL(10, 2) NULL,
    Date DATETIME NULL
)
WITH
(
    DISTRIBUTION = HASH(OrganizationKey),
    CLUSTERED COLUMNSTORE INDEX
);
----------------- END fact tables -----------------

----------------- START dimension tables -----------------
CREATE TABLE AdventureWorksDW2022_prod.DimDate
(
	DateKey INT NOT NULL,
	FullDateAlternateKey DATE NOT NULL,
	DayNumberOfWeek TINYINT NOT NULL,
	EnglishDayNameOfWeek NVARCHAR(10) NOT NULL,
	SpanishDayNameOfWeek NVARCHAR(10) NOT NULL,
	FrenchDayNameOfWeek NVARCHAR(10) NOT NULL,
	DayNumberOfMonth TINYINT NOT NULL,
	DayNumberOfYear SMALLINT NOT NULL,
	WeekNumberOfYear TINYINT NOT NULL,
	EnglishMonthName NVARCHAR(10) NOT NULL,
	SpanishMonthName NVARCHAR(10) NOT NULL,
	FrenchMonthName NVARCHAR(10) NOT NULL,
	MonthNumberOfYear TINYINT NOT NULL,
	CalendarQuarter TINYINT NOT NULL,
	CalendarYear SMALLINT NOT NULL,
	CalendarSemester TINYINT NOT NULL,
	FiscalQuarter TINYINT NOT NULL,
	FiscalYear SMALLINT NOT NULL,
	FiscalSemester TINYINT NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_prod.DimOrganization
(
	OrganizationKey INT NULL,
	ParentOrganizationKey INT NULL,
	PercentageOfOwnership DECIMAL(3, 2) NULL,
	OrganizationName NVARCHAR(50) NULL,
	CurrencyKey INT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_prod.DimDepartmentGroup
(
	DepartmentGroupKey INT NULL,
	ParentDepartmentGroupKey INT NULL,
	DepartmentGroupName NVARCHAR(50) NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_prod.DimScenario
(
	ScenarioKey INT NULL,
	ScenarioName NVARCHAR(50) NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_prod.DimAccount
(
	AccountKey INT NULL,
	ParentAccountKey INT NULL,
	AccountCodeAlternateKey INT NULL,
	ParentAccountCodeAlternateKey INT NULL,
	AccountDescription NVARCHAR(50) NULL,
	AccountType NVARCHAR(50) NULL,
	Operator NVARCHAR(50) NULL,
    CustomMembers NVARCHAR(300) NULL,
	ValueType NVARCHAR(50) NULL,
    CustomMemberOptions NVARCHAR(200) NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
----------------- END dimension tables -----------------
