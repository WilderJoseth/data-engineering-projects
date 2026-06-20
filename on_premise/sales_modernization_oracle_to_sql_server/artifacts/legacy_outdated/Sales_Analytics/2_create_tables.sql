
CREATE TABLE prod.DimCustomer (
	Id INT IDENTITY(1, 1) NOT NULL,
    CustomerBusinessID INT NOT NULL,
	Title VARCHAR(8) NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	MiddleName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
    AccountNumber VARCHAR(20) NOT NULL,
	created_at DATETIME NOT NULL,
    created_by VARCHAR(50) NOT NULL,
    updated_at DATETIME NULL,
    updated_by VARCHAR(50) NULL,
    created_run_id INT NOT NULL,
    is_active BIT NOT NULL,

	CONSTRAINT pk_prod_DimCustomer PRIMARY KEY CLUSTERED (Id ASC)
) ON [PRIMARY];

CREATE TABLE prod.FactSalesOrderHeader (
	Id INT IDENTITY(1, 1) NOT NULL,
	SalesOrderID INT NOT NULL,
	RevisionNumber TINYINT NOT NULL,
	OrderDate DATETIME NOT NULL,
	DueDate DATETIME NOT NULL,
	ShipDate DATETIME NOT NULL,
	Status TINYINT NOT NULL,
	CustomerID INT NOT NULL,
	SalesPersonID INT NOT NULL,
	CreditCardApprovalCode VARCHAR(15) NOT NULL,
	SubTotal DECIMAL(14, 4) NOT NULL,
	TaxAmt DECIMAL(14, 4) NOT NULL,
	Freight DECIMAL(14, 4) NOT NULL,
	TotalDue DECIMAL(14, 4) NOT NULL,
	Comment NVARCHAR(128) NOT NULL,
	created_at DATETIME NOT NULL,
    created_by VARCHAR(50) NOT NULL,
    created_run_id INT NOT NULL,

	CONSTRAINT pk_prod_FactSalesOrderHeader PRIMARY KEY CLUSTERED (Id ASC)
) ON [PRIMARY];
