
CREATE PROCEDURE work.usp_load_Customers
AS
BEGIN
SET NOCOUNT ON;

    INSERT INTO work.Customer (CustomerID, Title, FirstName, MiddleName, LastName, AccountNumber)
    SELECT
        c.CustomerID,
        p.Title,
        p.FirstName,
        p.MiddleName,
        p.LastName,
        c.AccountNumber
    FROM staging.Customer c
    LEFT JOIN staging.Person p ON p.BusinessEntityID = c.PersonID;

SET NOCOUNT OFF;
END;

CREATE PROCEDURE work.usp_validate_Customers
AS
BEGIN
SET NOCOUNT ON;

    SELECT
        SUM(IIF(Title IS NULL, 1, 0)) AS Title,
        SUM(IIF(FirstName IS NULL, 1, 0)) AS FirstName,
        SUM(IIF(MiddleName IS NULL, 1, 0)) AS MiddleName,
        SUM(IIF(LastName IS NULL, 1, 0)) AS LastName,
        SUM(IIF(AccountNumber IS NULL, 1, 0)) AS AccountNumber
    FROM work.Customer;

    UPDATE work.Customer
        SET FirstName = 'Default'
    WHERE FirstName IS NULL;

SET NOCOUNT OFF;
END;


CREATE PROCEDURE work.usp_load_Customers
AS
BEGIN
SET NOCOUNT ON;

    INSERT INTO prod.Customer (CustomerIDOrigin, Title, FirstName, MiddleName, LastName, AccountNumber, created_at, created_by, run_id, is_active)
    SELECT
        CustomerID,
        Title,
        FirstName,
        MiddleName,
        LastName,
        AccountNumber,
        GETDATE() AS created_at,
        USERNAME() AS created_by,
        0 AS run_id,
        1 AS is_active
    FROM work.Customer;

SET NOCOUNT OFF;
END;

CREATE PROCEDURE work.usp_validate_SalesOrderHeaders
AS
BEGIN
SET NOCOUNT ON;

    INSERT INTO work.SalesOrderHeader (
        SalesOrderID,
        RevisionNumber,
        OrderDate,
        DueDate,
        ShipDate,
        Status,
        CustomerID,
        SalesPersonID,
        CreditCardApprovalCode,
        SubTotal,
        TaxAmtL,
        Freight,
        TotalDue,
        Comment
    )
    SELECT
        SalesOrderID,
        RevisionNumber,
        OrderDate,
        DueDate,
        ShipDate,
        Status,
        CustomerID,
        SalesPersonID,
        CreditCardApprovalCode,
        SubTotal,
        TaxAmtL,
        Freight,
        TotalDue,
        Comment
    FROM staging.SalesOrderHeader;

    DELETE h
    FROM work.SalesOrderHeader h
    WHERE NOT EXISTS (SELECT 1 FROM prod.Customer c WHERE c.CustomerIDOrigin = h.CustomerID)

SET NOCOUNT OFF;
END;

CREATE PROCEDURE work.usp_load_SalesOrderHeaders
AS
BEGIN
SET NOCOUNT ON;

    INSERT INTO prod.SalesOrderHeader (
        SalesOrderID,
        RevisionNumber,
        OrderDate,
        DueDate,
        ShipDate,
        Status,
        CustomerID,
        SalesPersonID,
        CreditCardApprovalCode,
        SubTotal,
        TaxAmtL,
        Freight,
        TotalDue,
        Comment,
        created_at,
        created_by,
        run_id,
        is_active
    )
    SELECT
        SalesOrderID,
        RevisionNumber,
        OrderDate,
        DueDate,
        ShipDate,
        Status,
        CustomerID,
        SalesPersonID,
        CreditCardApprovalCode,
        SubTotal,
        TaxAmtL,
        Freight,
        TotalDue,
        Comment,
        GETDATE() AS created_at,
        USERNAME() AS created_by,
        0 AS run_id,
        1 AS is_active
    FROM work.SalesOrderHeader;

SET NOCOUNT OFF;
END;
