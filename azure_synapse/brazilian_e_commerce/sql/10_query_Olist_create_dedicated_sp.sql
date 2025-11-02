
CREATE PROCEDURE OLIST_DB.usp_load_Dim_Date
AS
BEGIN
    DECLARE @start_date DATE = '2025-01-01'
    DECLARE @end_date DATE = '2025-01-10'
    
    SELECT @start_date = MIN(order_purchase_timestamp), @end_date = MAX(order_purchase_timestamp) FROM OLIST_DB.Fact_Orders;

    WHILE @start_date <= @end_date
    BEGIN
        INSERT INTO OLIST_DB.Dim_Date
        (
            date_id,
            date_id_alternate,
            day_of_month,
            day_of_week,
            day_name,
            month_of_year,
            month_name,
            calendar_quarter,
            calendar_year
        )
        SELECT
            CONVERT(INT, CONVERT(NVARCHAR(8), @start_date, 112)) AS date_id,
            @start_date AS date_id_alternate,
            DAY(@start_date) AS day_of_month,
            DATEPART(DW, @start_date) AS day_of_week,
            DATENAME(DW, @start_date) AS day_name,
            MONTH(@start_date) AS month_of_year,
            DATENAME(MM, @start_date) AS month_name,
            DATEPART(QQ, @start_date) AS calendar_quarter,
            YEAR(@start_date) AS calendar_year;

        SET @start_date = DATEADD(DD, 1, @start_date);
    END
END;

CREATE PROCEDURE OLIST_DB.usp_clean_tables
AS
BEGIN
    TRUNCATE TABLE OLIST_DB.Fact_Orders;
    TRUNCATE TABLE OLIST_DB.Dim_Customers;
    TRUNCATE TABLE OLIST_DB.Dim_Products;
    TRUNCATE TABLE OLIST_DB.Dim_Sellers;
    TRUNCATE TABLE OLIST_DB.Dim_Date;
END;


