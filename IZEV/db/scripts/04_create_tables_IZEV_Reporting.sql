USE IZEV_Reporting;

CREATE TABLE dbo.Incentives(
	Id INT NOT NULL IDENTITY,
	Request_Date DATE NOT NULL,
	Month_Year VARCHAR(100) NOT NULL,
	Fiscal_Year VARCHAR(100) NOT NULL,
	Calendar_Year INT NOT NULL,
	Dealership_Province VARCHAR(50) NOT NULL,
	Dealership_Code VARCHAR(50) NOT NULL,
	Purchase_or_Lease VARCHAR(50) NOT NULL,
	Vehicle_Year INT NOT NULL,
	Vehicle_Make VARCHAR(100) NOT NULL,
	Vehicle_Make_Model VARCHAR(100) NOT NULL,
	Battery_Type VARCHAR(20) NOT NULL,
	Range_Above_50KM VARCHAR(3) NOT NULL,
	Move_Range_KM_24042022 VARCHAR(3) NOT NULL,
	Eligible_Incentive_Amount INT NOT NULL,
	Recipient VARCHAR(50) NOT NULL,
	Recipient_Province VARCHAR(50) NOT NULL,

    CONSTRAINT PK_dbo_Incentives PRIMARY KEY (Id)
)  ON [PRIMARY];

SELECT name, crdate FROM SYSOBJECTS WHERE xtype = 'U';