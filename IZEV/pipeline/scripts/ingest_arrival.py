import os
import pymssql
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

PATH_DATA_INPUT = os.path.join(os.getcwd(), "input/data")

# Read environemnt variables
MSSQL_SERVER = os.getenv("MSSQL_SERVER")
MSSQL_DATABASE_ARRIVAL = os.getenv("MSSQL_DATABASE_ARRIVAL")
MSSQL_USERNAME = os.getenv("MSSQL_USERNAME")
MSSQL_PASSWORD = os.getenv("MSSQL_PASSWORD")

connection_string = f"DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={MSSQL_SERVER};DATABASE={MSSQL_DATABASE_ARRIVAL};UID={MSSQL_USERNAME};PWD={MSSQL_PASSWORD};TrustServerCertificate=yes"

def main():
    print("\n------------------ START ARRIVAL INGESTION PROCESS ------------------")
    conn = pymssql.connect(
        server='<server-address>',
        user='<username>',
        password='<password>',
        database='<database-name>',
        as_dict=True
    )
    cursor = conn.cursor()
    cursor.execute("SELECT @@VERSION")
    cursor.close()
    #incentives_2019()
    print("\n------------------ END ARRIVAL INGESTION PROCESS ------------------")

def incentives_2019():
    print("\n------------------ START INCENTIVES 2019 PROCESS ------------------")
    print("\n------------------ START READ CSV PROCESS ------------------")
    columns = ["Request_Date", "Month_Year", "Fiscal_Year", "Calendar_Year", "Dealership_Province", "Dealership_Code", "Purchase_or_Lease", "Vehicle_Year", "Vehicle_Make", 
                "Vehicle_Model", "Vehicle_Make_Model", "BEV_PHEV_FCEV", "BEV_PHEV_FCEV_15", "BEV_PHEV_FCEV_15_2022", "Eligible_Incentive_Amount",
                "Recipient", "Recipient_Province", "Country"]
    
    df = pd.read_csv(os.path.join(PATH_DATA_INPUT, "iZEV_Data_2019.csv"), sep = ",", header = None, skiprows = 1)
    df.drop(18, axis = 1, inplace = True)
    df.columns = columns

    print("Data:\n", df.head())
    print("\n------------------ END READ CSV PROCESS ------------------")

    print("\n------------------ START INGEST PROCESS ------------------")
    sql_query_columns = ",".join(columns)
    sql_query_values = ",".join(["?" for c in range(len(columns))])
    sql_query = f"INSERT INTO dbo.Incentives_2019 ({sql_query_columns}) VALUES ({sql_query_values})"
    print(sql_query)

    conn = pyodbc.connect(connection_string)
    cursor = conn.cursor()
    for index, row in df.iterrows():
        cursor.execute(sql_query, 
                        row["Request_Date"], 
                        row["Month_Year"], 
                        row["Fiscal_Year"],
                        row["Calendar_Year"],
                        row["Dealership_Province"],
                        row["Dealership_Code"],
                        row["Purchase_or_Lease"],
                        row["Vehicle_Year"],
                        row["Vehicle_Make"],
                        row["Vehicle_Model"],
                        row["Vehicle_Make_Model"],
                        row["BEV_PHEV_FCEV"],
                        row["BEV_PHEV_FCEV_15"],
                        row["BEV_PHEV_FCEV_15_2022"],
                        row["Eligible_Incentive_Amount"],
                        row["Recipient"],
                        row["Recipient_Province"],
                        row["Country"]
                        )
    conn.commit()

    cursor.execute("SELECT COUNT (1) FROM dbo.Incentives_2019")
    row_count = cursor.fetchone()[0]
    print(f"Rows inserted: {row_count}")
    
    cursor.close()
    print("\n------------------ END INGEST PROCESS ------------------")
    print("\n------------------ END INCENTIVES 2019 PROCESS ------------------")


