SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_VAR_portnums] 
(
   @top_port_num          int,
   @trading_entity_num    int = 0
)
as
set nocount on
declare @rows_affected     int,
        @start_time        datetime,
        @end_time          datetime

   begin try
     set @start_time = getdate()
     INSERT INTO #portnums
     SELECT port_num, 0, port_type, trading_entity_num
     FROM dbo.udf_portfolio_list(@top_port_num) a
     WHERE not exists (select 1
                       from #portnums p
                       where a.port_num = p.port_num) and
           port_type = 'R' and
           port_locked = 0 and
           1 = case when @trading_entity_num = 0 then 1
                    when isnull(trading_entity_num, 0) = @trading_entity_num then 1
                    else 0
               end
     select @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to copy children port # into the temp table #portnums due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto endofsp
   end catch
   print '# of children port # saved into the temp table ''#portnums'' = ' + cast(@rows_affected as varchar)

   begin try
     set @start_time = getdate()
     DELETE p1
     FROM #portnums p1
     WHERE exists (select 1
                   from dbo.jms_reports jms
                   where p1.port_num = jms.port_num AND
                         jms.classification_code NOT like '[A,a]%') and
           p1.port_type = 'R'
     select @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to remove inactive REAL port # from temp table due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto endofsp
   end catch
   print '# of inactive REAL port # were removed from the temp table ''#portnums'' = ' + cast(@rows_affected as varchar)
   
endofsp:
return 1
GO
GRANT EXECUTE ON  [dbo].[usp_get_VAR_portnums] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_VAR_portnums', NULL, NULL
GO
