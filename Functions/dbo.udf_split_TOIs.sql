SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE FUNCTION [dbo].[udf_split_TOIs] (          
      @InputTradeString                  VARCHAR(MAX),          
      @InputOrderString                  VARCHAR(MAX),          
      @InputItemString                  VARCHAR(MAX),        
      @InputPortNumString                  VARCHAR(MAX),          
      @Delimiter                    VARCHAR(1)          
)          
          
RETURNS @TOItems TABLE   
(  
      Trade         VARCHAR(20),          
      Order1        VARCHAR(20),          
      Item          VARCHAR(20)  ,        
      PortNum       VARCHAR(20)        
)          
AS          
BEGIN          
      IF @Delimiter = ' '          
      BEGIN          
            SET @Delimiter = ','          
            SET @InputTradeString = REPLACE(@InputTradeString, ' ', @Delimiter)          
            SET @InputOrderString = REPLACE(@InputOrderString, ' ', @Delimiter)          
            SET @InputItemString = REPLACE(@InputItemString, ' ', @Delimiter)          
            SET @InputPortNumString = REPLACE(@InputPortNumString, ' ', @Delimiter)          
      END          
          
      IF (@Delimiter IS NULL OR @Delimiter = '')          
            SET @Delimiter = ','          
          
      DECLARE @Trade           VARCHAR(20)          
      DECLARE @TradeList       VARCHAR(8000)          
      DECLARE @Order           VARCHAR(20)          
      DECLARE @OrderList       VARCHAR(8000)          
      DECLARE @Item           VARCHAR(20)          
      DECLARE @ItemList       VARCHAR(8000)          
      DECLARE @PortNum           VARCHAR(20)          
      DECLARE @PortNumList       VARCHAR(8000)          
              
      DECLARE @DelimIndexTrade     INT          
      DECLARE @DelimIndexOrder     INT          
      DECLARE @DelimIndexItem     INT          
      DECLARE @DelimIndexPortNum     INT          
          
   SET @TradeList = @InputTradeString          
   SET @OrderList = @InputOrderString          
      SET @ItemList  = @InputItemString          
      SET @PortNumList  = @InputPortNumString          
              
      SET @DelimIndexTrade = CHARINDEX(@Delimiter, @TradeList, 0)          
      SET @DelimIndexOrder = CHARINDEX(@Delimiter, @OrderList, 0)          
      SET @DelimIndexItem = CHARINDEX(@Delimiter, @ItemList, 0)          
      SET @DelimIndexPortNum = CHARINDEX(@Delimiter, @PortNumList, 0)          
                
     --select @InputTradeString,@InputOrderString,@InputItemString,@DelimIndex          
      WHILE (@DelimIndexTrade != 0 and @DelimIndexOrder != 0 and @DelimIndexItem != 0 and @DelimIndexPortNum != 0 )          
      BEGIN          
      SET @Trade = SUBSTRING(@TradeList, 0, @DelimIndexTrade)          
      SET @Order = SUBSTRING(@OrderList, 0, @DelimIndexOrder)          
            SET @Item  = SUBSTRING(@ItemList, 0, @DelimIndexItem)          
            SET @PortNum  = SUBSTRING(@PortNumList, 0, @DelimIndexPortNum)          
                    
            INSERT INTO @TOItems VALUES (@Trade,@Order,@Item,@PortNum)          
          
            -- Set @ItemList = @ItemList minus one less item          
            SET @TradeList = SUBSTRING(@TradeList, @DelimIndexTrade+1, LEN(@TradeList)-@DelimIndexTrade)          
            SET @OrderList = SUBSTRING(@OrderList, @DelimIndexOrder+1, LEN(@OrderList)-@DelimIndexOrder)          
            SET @ItemList  = SUBSTRING(@ItemList, @DelimIndexItem+1, LEN(@ItemList)-@DelimIndexItem)          
            SET @PortNumList  = SUBSTRING(@PortNumList, @DelimIndexPortNum+1, LEN(@PortNumList)-@DelimIndexPortNum)          
                      
            SET @DelimIndexTrade = CHARINDEX(@Delimiter, @TradeList, 0)          
            SET @DelimIndexOrder = CHARINDEX(@Delimiter, @OrderList, 0)          
            SET @DelimIndexItem = CHARINDEX(@Delimiter, @ItemList, 0)          
            SET @DelimIndexPortNum = CHARINDEX(@Delimiter, @PortNumList, 0)                   
      END -- End WHILE          
          
      IF @Item IS NOT NULL or @Item IS NOT NULL or @Item IS NOT NULL or @PortNum IS NOT NULL -- At least one delimiter was encountered in @InputString          
      BEGIN          
     SET @Trade = @TradeList          
     SET @Order = @OrderList          
        SET @Item  = @ItemList          
        SET @PortNum  = @PortNumList          
        INSERT INTO @TOItems VALUES (@Trade,@Order,@Item, @PortNum)          
      END -- No delimiters were encountered in @InputString, so just return @InputString          
      ELSE INSERT INTO @TOItems VALUES (@InputTradeString,@InputOrderString,@InputItemString,@InputPortNumString)          
          
      RETURN          
          
END -- End Function 
GO
GRANT SELECT ON  [dbo].[udf_split_TOIs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_split_TOIs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[udf_split_TOIs] TO [public]
GO
