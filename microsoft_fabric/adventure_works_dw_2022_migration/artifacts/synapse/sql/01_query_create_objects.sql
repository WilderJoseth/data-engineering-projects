
----------------- START schemas -----------------
CREATE SCHEMA AdventureWorksDW2022_stag

CREATE SCHEMA AdventureWorksDW2022_prod
----------------- END schemas -----------------

----------------- START staging tables -----------------
----------------- START fact tables -----------------
CREATE TABLE AdventureWorksDW2022_stag.FactFinance
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
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
----------------- END fact tables -----------------

----------------- START dimension tables -----------------
CREATE TABLE AdventureWorksDW2022_stag.DimDate 
(
	DateKey INT NULL,
	FullDateAlternateKey DATE NULL,
	DayNumberOfWeek TINYINT NULL,
	EnglishDayNameOfWeek NVARCHAR(10) NULL,
	SpanishDayNameOfWeek NVARCHAR(10) NULL,
	FrenchDayNameOfWeek NVARCHAR(10) NULL,
	DayNumberOfMonth TINYINT NULL,
	DayNumberOfYear SMALLINT NULL,
	WeekNumberOfYear TINYINT NULL,
	EnglishMonthName NVARCHAR(10) NULL,
	SpanishMonthName NVARCHAR(10) NULL,
	FrenchMonthName NVARCHAR(10) NULL,
	MonthNumberOfYear TINYINT NULL,
	CalendarQuarter TINYINT NULL,
	CalendarYear SMALLINT NULL,
	CalendarSemester TINYINT NULL,
	FiscalQuarter TINYINT NULL,
	FiscalYear SMALLINT NULL,
	FiscalSemester TINYINT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_stag.DimOrganization
(
	OrganizationKey INT NULL,
	ParentOrganizationKey INT NULL,
	PercentageOfOwnership DECIMAL(3, 2) NULL,
	OrganizationName NVARCHAR(50) NULL,
	CurrencyKey INT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_stag.DimDepartmentGroup
(
	DepartmentGroupKey INT NULL,
	ParentDepartmentGroupKey INT NULL,
	DepartmentGroupName NVARCHAR(50) NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_stag.DimScenario
(
	ScenarioKey INT NULL,
	ScenarioName NVARCHAR(50) NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_stag.DimAccount
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
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
----------------- END dimension tables -----------------
----------------- END staging tables -----------------

----------------- START production tables -----------------
----------------- START fact tables -----------------
CREATE TABLE AdventureWorksDW2022_prod.FactFinance
(
    FinanceKey INT NOT NULL,
    DateKey INT NOT NULL,
    OrganizationKey INT NOT NULL,
    DepartmentGroupKey INT NOT NULL,
    ScenarioKey INT NOT NULL,
    AccountKey INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Date DATETIME NOT NULL
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
	OrganizationKey INT NOT NULL,
	ParentOrganizationKey INT NOT NULL,
	PercentageOfOwnership DECIMAL(3, 2) NOT NULL,
	OrganizationName NVARCHAR(50) NOT NULL,
	CurrencyKey INT NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_prod.DimDepartmentGroup
(
	DepartmentGroupKey INT NOT NULL,
	ParentDepartmentGroupKey INT NOT NULL,
	DepartmentGroupName NVARCHAR(50) NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_prod.DimScenario
(
	ScenarioKey INT NOT NULL,
	ScenarioName NVARCHAR(50) NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE AdventureWorksDW2022_prod.DimAccount
(
	AccountKey INT NOT NULL,
	ParentAccountKey INT NOT NULL,
	AccountCodeAlternateKey INT NOT NULL,
	ParentAccountCodeAlternateKey INT NOT NULL,
	AccountDescription NVARCHAR(50) NOT NULL,
	AccountType NVARCHAR(50) NOT NULL,
	Operator NVARCHAR(50) NOT NULL,
	ValueType NVARCHAR(50) NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
----------------- END dimension tables -----------------
----------------- END production tables -----------------


SELECT * FROM dbo.FactFinance

