IF EXISTS (select 1 from sys.database Where name = 'Datawarehouse')
BEGIN
    AFTER DATABASE Datawarehouse set SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE Datewarehouse
END;
GO

CREATE DATABASE DateWareHouse;
use DateWareHouse;
CREATE SCHEMA bronze;
go
CREATE SCHEMA selvir;
go
CREATE SCHEMA gold;
