
/*
======================================
TẠO DATABASE VÀ SCHEMA
======================================

MÔ TẢ MỤC ĐÍCH:
	Tập lệnh này tạo mới một cơ sở dữ liệu có tên 'DataWarehouse' sau khi kiểm tra xem nó đã tồn tại hay chưa.
	Nếu cơ sở dữ liệu đã tồn tại, nó sẽ bị xóa và tạo lại từ đầu. 
	Ngoài ra, tập lệnh cũng tạo ra ba schema bên trong cơ sở dữ liệu: 'bronze', 'silver' và 'gold'.

CẢNH BÁO:
	Khi chạy tập lệnh này, toàn bộ cơ sở dữ liệu 'DataWarehouse' sẽ bị xóa nếu tồn tại trước đó.
	Tất cả dữ liệu trong cơ sở dữ liệu sẽ bị xóa vĩnh viễn. 
	Hãy cẩn trọng và đảm bảo bạn đã sao lưu dữ liệu trước khi chạy tập lệnh này.
*/

USE master;

-- Xóa và tạo lại CSDL 
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END
GO

-- Tạo CSDL DataWarehouse
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Tạo SCHEMA
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
