SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_column_exists](@TableName varchar(100), @ColumnName varchar(100))  
RETURNS varchar(1) AS  
BEGIN  
DECLARE @Result varchar(1);  
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName AND COLUMN_NAME = @ColumnName)  
BEGIN  
    SET @Result = 'T'  
END  
ELSE  
BEGIN  
    SET @Result = 'F'  
END  
RETURN @Result;  
END  
GO
GRANT EXECUTE ON  [dbo].[udf_column_exists] TO [next_usr]
GO
