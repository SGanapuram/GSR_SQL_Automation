SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
create function [dbo].[fnToSplit]    
(    
   @sInputList         varchar(max),      -- List of delimited items    
   @sDelimiter         varchar(8000) = ',' -- delimiter that separates items    
)     
RETURNS @List TABLE (item varchar(100))    
begin    
declare @sItem    varchar(100)    
    
   while charindex(@sDelimiter, @sInputList, 0) <> 0    
   begin    
      select @sItem = RTRIM(LTRIM(SUBSTRING(@sInputList, 1, CHARINDEX(@sDelimiter, @sInputList, 0) - 1))),    
             @sInputList = RTRIM(LTRIM(SUBSTRING(@sInputList, CHARINDEX(@sDelimiter, @sInputList, 0) + LEN(@sDelimiter), LEN(@sInputList))))    
     
      if len(@sItem) > 0    
         insert into @List select @sItem    
   end    
    
   if len(@sInputList) > 0    
      insert into @List values(@sInputList) -- Put the last item in    
   return    
end     
GO
