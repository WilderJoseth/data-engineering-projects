
----------------- START schemas -----------------
CREATE SCHEMA staging;
----------------- END schemas -----------------

----------------- START fact tables -----------------
CREATE TABLE staging.FactFinance
(
    FinanceKey INT NOT NULL,
    DateKey INT NOT NULL,
    OrganizationKey INT NOT NULL,
    DepartmentGroupKey INT NOT NULL,
    ScenarioKey INT NOT NULL,
    AccountKey INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Date DATETIME2(2) NOT NULL,
	year INT NOT NULL
);
----------------- END fact tables -----------------

----------------- START dimension tables -----------------
CREATE TABLE staging.DimDate 
(
	DateKey INT NOT NULL,
	FullDateAlternateKey DATE NOT NULL,
	DayNumberOfWeek SMALLINT NOT NULL,
	EnglishDayNameOfWeek VARCHAR(10) NOT NULL,
	DayNumberOfMonth SMALLINT NOT NULL,
	EnglishMonthName VARCHAR(10) NOT NULL,
	MonthNumberOfYear SMALLINT NOT NULL,
	CalendarQuarter SMALLINT NOT NULL,
	CalendarYear INT NOT NULL
);

CREATE TABLE staging.DimOrganization
(
	OrganizationKey INT NOT NULL,
	ParentOrganizationKey INT NOT NULL,
	PercentageOfOwnership DECIMAL(3, 2) NOT NULL,
	OrganizationName VARCHAR(50) NOT NULL,
	CurrencyKey INT NOT NULL
);

CREATE TABLE staging.DimDepartmentGroup
(
	DepartmentGroupKey INT NOT NULL,
	ParentDepartmentGroupKey INT NOT NULL,
	DepartmentGroupName VARCHAR(50) NOT NULL
);

CREATE TABLE staging.DimScenario
(
	ScenarioKey INT NOT NULL,
	ScenarioName VARCHAR(50) NOT NULL
);

CREATE TABLE staging.DimAccount
(
	AccountKey INT NOT NULL,
	ParentAccountKey INT NOT NULL,
	AccountCodeAlternateKey INT NOT NULL,
	ParentAccountCodeAlternateKey INT NOT NULL,
	AccountDescription VARCHAR(50) NOT NULL,
	AccountType VARCHAR(50) NOT NULL,
	Operator VARCHAR(50) NOT NULL,
	ValueType VARCHAR(50) NOT NULL
);
----------------- END dimension tables -----------------
