SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
    
CREATE procedure [dbo].[find_external_trades]                    
(                    
 @instance_num smallint,                      
 @batch_size int = 1,                      
 @debugon bit = 0                    
)                      
AS                      
SET NOCOUNT ON                      
SET ANSI_NULLS OFF  /* In this case, if buyer_account in both tables is null, the comparison will return TRUE */                    
                    /* When ANSI_NULL ON, the comparison will return FALSE */                    
SET XACT_ABORT ON                      
declare @query         nvarchar(max),                      
  @load_criteria nvarchar(max),                      
  @trans_id      bigint,                    
  @rows_affected int                    
                      
   create table #temp_ets_rows                    
   (                      
      external_trade_oid    int,                      
      external_trade_source_oid  int,                      
      exch_tools_trade_num    varchar(60),                      
      commodity      varchar(256),                      
      creation_date     datetime,                      
      buyer_account     varchar(75)                      
   )                      
                      
   create table #ets_rows                    
   (                      
      ATTRIBUTE1 int,                      
      ATTRIBUTE2 int,                      
      ATTRIBUTE3 varchar(60),                      
      ATTRIBUTE4 varchar(256),                      
      ATTRIBUTE5 varchar(40),                      
      ATTRIBUTE6 varchar(75),                      
      ATTRIBUTE7 numeric(32, 0)                     
   )                      
                      
  create nonclustered index xx0292_ets_rows_idx                     
     on #ets_rows (ATTRIBUTE1)                      
                      
  SELECT @load_criteria = LTRIM(RTRIM(isnull(load_criteria, '@@@') ))                    
  FROM dbo.ets_load_criteria WITH (NOLOCK)                      
  WHERE instance_num = @instance_num                      
                      
  SELECT @query =  'SELECT TOP 1                     
           mainET.oid AS external_trade_oid,                    
           mainET.external_trade_source_oid,                    
           mainEX.exch_tools_trade_num,                    
        mainEX.commodity,                    
        mainEX.creation_date,                    
        mainEX.buyer_account                    
     FROM dbo.external_trade mainET WITH (NOLOCK),                    
          dbo.exch_tools_trade mainEX WITH (NOLOCK)                    
     WHERE mainET.oid = mainEX.external_trade_oid AND                   
           mainET.external_trade_status_oid = 1 AND                   
        NOT EXISTS (SELECT 1                    
                       FROM dbo.ets_run                    
                       WHERE external_trade_oid = mainET.oid AND instance_num!= ' +convert(varchar,@instance_num)                
                       +' AND start_time IS NOT NULL AND end_time IS NULL)  AND            
  NOT EXISTS (SELECT 1 FROM #ets_rows where ATTRIBUTE1 = mainET.oid)'                     
                      
  IF @load_criteria <> '@@@'                      
     set @query = @query + ' AND (' + @load_criteria + ')'                    
  set @query = @query + ' ORDER BY mainET.oid'                      
                      
  IF @debugon = 1                      
  BEGIN                      
    PRINT @query                      
  END            
            
  pending:            
            
  delete #temp_ets_rows              
                        
  INSERT INTO #temp_ets_rows                      
     EXEC (@query)                      
  set @rows_affected = @@rowcount                    
          
   delete #ets_rows  -- PLEASE don't change this place.        
          
  if @rows_affected = 0             
  begin            
     goto endofsp               
  end               
            
                      
 INSERT INTO #ets_rows                        
    SELECT                      
       mainET.oid AS ATTRIBUTE1,                      
       mainET.external_trade_source_oid AS ATTRIBUTE2,                      
       mainEX.exch_tools_trade_num AS ATTRIBUTE3,                      
       mainEX.commodity AS ATTRIBUTE4,                      
       CONVERT(char(40), mainEX.creation_date, 101) AS ATTRIBUTE5,                      
       mainEX.buyer_account AS ATTRIBUTE6,                      
       mainET.trans_id AS ATTRIBUTE7                      
    FROM dbo.external_trade mainET WITH (NOLOCK)                      
            JOIN dbo.exch_tools_trade mainEX WITH (NOLOCK)                      
               ON mainET.oid = mainEX.external_trade_oid                      
    WHERE mainET.external_trade_status_oid = 1 and                    
       exists (select 1                    
            from #temp_ets_rows tmpETS                      
                  where tmpETS.external_trade_source_oid = mainET.external_trade_source_oid and                     
               tmpETS.commodity = mainEX.commodity and                           
            isnull(tmpETS.buyer_account,'@') = isnull(mainEX.buyer_account,'@') and                     
            (tmpETS.exch_tools_trade_num = mainEX.exch_tools_trade_num or                  
    (CHARINDEX('/', tmpETS.exch_tools_trade_num) > 0 and                     
             SUBSTRING(tmpETS.exch_tools_trade_num, 0, CHARINDEX('/', tmpETS.exch_tools_trade_num)) =                      
                          SUBSTRING(mainEX.exch_tools_trade_num, 0, CHARINDEX('/', mainEX.exch_tools_trade_num))) ) and                     
             CONVERT(DATE ,mainEX.creation_date) = CONVERT(DATE ,tmpETS.creation_date) )                    
    --ORDER BY mainET.oid                      
    set @rows_affected = @@rowcount                    
    if @rows_affected = 0                    
 BEGIN            
  goto endofsp                    
 END            
             
    IF EXISTS (SELECT 1                      
               FROM dbo.ets_run r with(nolock)                     
                       JOIN #ets_rows e                      
                          ON e.ATTRIBUTE1 = r.external_trade_oid  AND instance_num!=@instance_num                    
               WHERE r.start_time IS NOT NULL AND                     
            r.end_time IS NULL)                      
 begin            
 GOTO pending                    
 end                     
                      
    INSERT INTO dbo.ets_run                     
      (external_trade_oid, instance_num, start_time, et_trans_id)                      
      SELECT                      
         ATTRIBUTE1,                      
         @instance_num,                      
         GETDATE(),                      
         ATTRIBUTE7                      
      FROM #ets_rows er                
      WHERE NOT EXISTS  (select 1 from dbo.ets_run with(nolock) where external_trade_oid=er.ATTRIBUTE1 and et_trans_id=er.ATTRIBUTE7)        
  
endofsp:                       
SELECT                      
   e.ATTRIBUTE1,                      
   e.ATTRIBUTE2,                      
   e.ATTRIBUTE3,                      
   e.ATTRIBUTE4,                      
   e.ATTRIBUTE5,                      
   e.ATTRIBUTE6,                      
   e.ATTRIBUTE7                      
FROM #ets_rows e    
where EXISTS  (select 1 from dbo.ets_run with(nolock) where external_trade_oid=e.ATTRIBUTE1 and et_trans_id=e.ATTRIBUTE7   
                and instance_num=@instance_num   
                and start_time is not null and end_time is null)                      
                    
drop table #ets_rows                    
drop table #temp_ets_rows                     
GO
GRANT EXECUTE ON  [dbo].[find_external_trades] TO [next_usr]
GO
