SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[pass_result_save]   
   @before_pass_run_trans_id bigint,          
   @debugon  bit = 0          
as          
set nocount on          
declare @resp_trans_id  bigint,          
        @oid   numeric(18, 0),          
        @errcode  int,          
        @rows_affected  int,          
        @sql   varchar(max),          
        @tablename  sysname,          
        @audtablename  sysname,          
        @keycolumn  sysname,          
        @smsg   varchar(600),          
        @collist  varchar(max)          
          
          
   set @collist = ''          
          
   create table #tables          
   (          
      oid             numeric(18, 0) IDENTITY PRIMARY KEY,          
      tablename       sysname,          
      audtablename    sysname,          
      keycolumn       sysname,          
      rows_copied     int default 0,          
      collist         varchar(max)          
   )          
          
   create table #tablelist          
   (          
      oid                  int IDENTITY primary key,          
      tablename            sysname,          
      audtablename         sysname,          
      table_id             int null,          
      audtable_id          int null,          
      keycolumn            sysname          
   )          
          
          
   insert into #tablelist (tablename, audtablename, keycolumn)          
     select 'pl_history', 'aud_pl_history', 'before_pass_run_trans_id'          
     union all          
     select 'tid_mark_to_market', 'aud_tid_mark_to_market', 'before_pass_run_trans_id'          
     union all          
     select 'portfolio_profit_loss', 'aud_portfolio_profit_loss', 'before_pass_run_trans_id'          
     union all          
     select 'position_mark_to_market', 'aud_position_mark_to_market', 'before_pass_run_trans_id'          
     union all          
     select 'tid_mtm_volatility', 'aud_tid_mtm_volatility', 'before_pass_run_trans_id'          
     union all          
     select 'ti_mark_to_market', 'aud_ti_mark_to_market', 'before_pass_run_trans_id'          
     union all          
     select 'tid_pl', 'aud_tid_pl', 'before_pass_run_trans_id'          
     union all          
     select 'trade_item_pl', 'aud_trade_item_pl', 'before_pass_run_trans_id'          
     union all          
     select 'cost_ext_info', 'aud_cost_ext_info', 'before_pass_run_trans_id'          
     union all          
     select 'fx_exposure', 'aud_fx_exposure', 'before_pass_run_trans_id'          
     union all          
     select 'fx_exposure_dist', 'aud_fx_exposure_dist', 'before_pass_run_trans_id'          
     union all          
     select 'inventory_history', 'aud_inventory_history', 'before_pass_run_trans_id'            
  union all        
  select 'position_history', 'aud_position_history', 'before_pass_run_trans_id'            
  union all        
  select 'portfolio_eod', 'aud_portfolio_eod', 'before_pass_run_trans_id'            
  union all        
  select 'position_group_eod', 'aud_position_group_eod', 'before_pass_run_trans_id'            
  union all        
  select 'portfolio_group_eod', 'aud_portfolio_group_eod', 'before_pass_run_trans_id'            
          
     delete #tablelist          
     where object_id('dbo.' + tablename, 'U') is null or          
           object_id('dbo.' + audtablename, 'U') is null          
             
   select @errcode = 0;          
             
   select @oid = min(oid)          
   from #tablelist          
             
   while @oid is not null          
   begin          
      select @tablename = tablename,          
             @audtablename = audtablename,          
             @keycolumn = keycolumn          
      from #tablelist          
      where oid = @oid          
                
      select @collist = '';          
      select @collist = dbo.udf_table_column_list(@tablename);          
           
     if len(@collist) > 0          
     begin          
        insert into #tables (tablename, audtablename, keycolumn, rows_copied, collist)           
            values(@tablename, @audtablename, @keycolumn, 0, @collist)          
      end          
                
      select @oid = min(oid)          
      from #tablelist          
      where oid > @oid          
  end          
          
   begin try           
     exec dbo.gen_new_transaction @app_name = 'sp_PassResultSave'          
   end try          
   begin catch          
   print '=> Failed to execute the ''gen_new_transaction'' sp to create a new icts_transaction record due to the error:'          
     print '==> ERROR: ' + ERROR_MESSAGE()          
     select @errcode = ERROR_NUMBER();          
     goto endofsp          
   end catch          
             
   select @resp_trans_id = 0          
   select @resp_trans_id = isnull(last_num, 0)           
   from dbo.icts_trans_sequence          
   where oid = 1          
             
   if @resp_trans_id = 0          
   begin          
      print '=> Failed to obtain the new resp_trans_id for the newly created icts_transaction record!'          
      select @errcode = 1;          
      goto endofsp          
   end          
             
   select @oid = min(oid)          
   from #tables          
          
   while @oid is not null          
   begin          
      select @tablename = tablename,          
             @audtablename = audtablename,          
             @keycolumn = keycolumn,          
            @collist= collist          
      from #tables          
      where oid = @oid                   
                 
         select @sql = 'insert into dbo.' + @audtablename + ' (' + @collist + ', resp_trans_id)' +  ' select ' + @collist + ',' + cast(@resp_trans_id as varchar) + ' from dbo.' + @tablename          
         select @sql = @sql + ' where trans_id ' + ' >= ' + convert(varchar, @before_pass_run_trans_id) + ''             
        
      if @debugon = 1          
      begin          
          select @smsg = 'DEBUG: ' + @sql          
          print @smsg          
      end          
      begin try          
          exec(@sql)          
          select @rows_affected = @@rowcount          
      end try          
      begin catch          
          print '=> Failed to execute the following query due to the error:'          
          print '==> ERROR: ' + ERROR_MESSAGE()          
          print '==> SQL: ' + @sql          
          select @errcode = ERROR_NUMBER();          
          goto nextoid          
      end catch          
                
          
      update #tables          
      set rows_copied = @rows_affected          
      where oid = @oid          
                
nextoid:          
      select @oid = min(oid)          
      from #tables          
      where oid > @oid          
   end  /* while */          
             
if @errcode = 0          
begin          
   print ' '          
   select @oid = min(oid)          
   from #tables          
             
   while @oid is not null          
   begin          
      select @tablename = tablename,          
             @rows_affected = rows_copied          
      from #tables          
      where oid = @oid          
          
      select @smsg = '   ' + cast(@tablename as char(30)) + ' : ' + cast(@rows_affected as varchar) + ' records were copied to audit companion table'          
      print @smsg          
          
      select @oid = min(oid)          
      from #tables          
      where oid > @oid          
   end          
end          
          
endofsp:          
if object_id('tempdb..#tables', 'U') is not null          
   exec('drop table #tables')          
if object_id('tempdb..#tablelist', 'U') is not null          
   exec('drop table #tablelist')          
if object_id('tempdb..#passRunId', 'U') is not null          
   exec('drop table #passRunId')          
if object_id('tempdb..#realPortNum', 'U') is not null          
   exec('drop table #realPortNum')            

GO
GRANT EXECUTE ON  [dbo].[pass_result_save] TO [next_usr]
GO
