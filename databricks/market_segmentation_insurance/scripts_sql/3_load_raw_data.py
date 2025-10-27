spark.sql('''
          COPY INTO training_catalog.market_segmentation_insurance_db.raw_data
          FROM "/Volumes/training_catalog/market_segmentation_insurance_db/training_files/"
          FILEFORMAT = CSV
          FORMAT_OPTIONS (
            "header" = "true",
            "inferSchema" = "false" -- Use schema defined during table creation
          )
          ''').display()