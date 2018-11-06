SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[set_last_nums]
(
   @loc_num         smallint = 0,
   @show_progress   bit = 0
)
as
begin
set nocount on
set xact_abort on
-- use SET ANSI_WARNINGS OFF to avoid the following warning:
--   Warning: Null value is eliminated by an aggregate or other SET operation
--
--  Peter Lo   4/27/2006
SET ANSI_WARNINGS OFF
declare @num_col_name    varchar(30),
        @owner_table     varchar(30),
        @owner_column    varchar(30),
        @max_num         int,
        @max_ref_num     varchar(30),
        @my_loc_num      smallint,
        @audit_tablename varchar(30),
        @sql             varchar(512),
        @rowcount        int,
        @errcode         int,
        @objtype         varchar(2)

   if @loc_num is null
      select @my_loc_num = 0
   else
      select @my_loc_num = @loc_num

   select @rowcount = 0,
          @errcode = 0
          
   create table #seqnum
   (
      oid                int not null,
      max_num            int default 0
   )
     
   select @num_col_name = min(num_col_name)
   from dbo.new_num 
   where loc_num = @my_loc_num and
         owner_table is not null and
         owner_column is not null

   while @num_col_name is not null
   begin
      select @owner_table = owner_table,
             @owner_column = owner_column
      from dbo.new_num 
      where loc_num = @my_loc_num and
            num_col_name = @num_col_name
      select @audit_tablename = 'aud_' + @owner_table
  
      select @max_num = -1
      select @objtype = xtype
      from dbo.sysobjects
      where name = @owner_table
      
      if @objtype is null
      begin
         print '=> The db object ''' + @owner_table + ''' does not exist in database!'
         goto updlastnum         
      end
      
      if @objtype <> 'U'
      begin
         print '=> The db object ''' + @owner_table + ''' is not a table!'
         goto updlastnum
      end

      if not exists (select 1
                     from dbo.syscolumns with (nolock)
                     where id = object_id(@owner_table) and
                           name = @owner_column)
      begin
         print 'The column/table (' + @owner_column + '/' + @owner_table + ') does not exist in database!'
         goto updlastnum
      end

      if @owner_table = 'trade_item' and @owner_column = 'idms_bb_ref_num'
         goto nextkey

      if @owner_table = 'trade' and @owner_column = 'trade_num'
      begin 
         if @num_col_name = 'trade_num'
         begin
            select @max_num = isnull(max(trade_num), 0) from dbo.trade where trade_num < 80000000
            select @max_num = isnull(max(trade_num), @max_num) 
            from dbo.aud_trade where trade_num > @max_num and trade_num < 80000000
            goto updlastnum
         end
         if @num_col_name = 'qf_num'
         begin
            select @max_num = isnull(max(trade_num), 0) from dbo.trade where trade_num >= 80000000
            select @max_num = isnull(max(trade_num), @max_num) 
            from dbo.aud_trade where trade_num > @max_num and trade_num >= 80000000
            goto updlastnum
         end
      end

      /* The agreement_num starts at 90000000 */
      if @owner_table = 'gtc' and @owner_column = 'agreement_num'
      begin
         select @max_num = isnull(max(agreement_num), 90000000) from dbo.gtc
         select @max_num = isnull(max(agreement_num), @max_num) 
         from dbo.aud_gtc where agreement_num > @max_num
         goto updlastnum
      end

      /* The agreement_num starts at 90000000 */
      if @owner_table = 'account_agreement' and @owner_column = 'agreement_num'
      begin
         select @max_num = isnull(max(agreement_num), 90000000) from dbo.account_agreement
         select @max_num = isnull(max(agreement_num), @max_num) 
         from dbo.aud_account_agreement where agreement_num > @max_num
         goto updlastnum
      end
      
      /* ------------------------------------------------------------------
          We reserve 20001..30000 for dynamically assigned function_num
          for the security objects so that records can be setup in the
          user_permission table to control whether a used can edit the
          data in portfolio_tag table and related tables
         ------------------------------------------------------------------ */
 
      if @owner_table = 'icts_function' and @owner_column = 'function_num'
      begin
         select @max_num = isnull(max(function_num), 20000) 
         from dbo.icts_function
         where function_num > 20000
         select @max_num = isnull(max(function_num), @max_num) 
         from dbo.aud_icts_function where function_num > @max_num
         goto updlastnum
      end

      if object_id(@owner_table) is not null
      begin       
         select @sql = 'select 1, isnull(max(' + @owner_column + '), 0) from ' + @owner_table
         truncate table #seqnum
         insert into #seqnum (oid, max_num) exec(@sql)
         select @max_num = max_num from #seqnum where oid = 1
      end
      if object_id(@audit_tablename) is not null
      begin
         select @sql = 'select 1, isnull(max(' + @owner_column + '), ' + convert(varchar, @max_num) + ') '
         select @sql = @sql + 'from ' + @audit_tablename + ' where ' + @owner_column + ' > ' + convert(varchar, @max_num)
         truncate table #seqnum
         insert into #seqnum (oid, max_num) exec(@sql)
         select @max_num = max_num from #seqnum where oid = 1
      end
        
updlastnum:
      if @max_num > -1
      begin
         if @show_progress = 1
            print 'Updating last_num for (' + @owner_table + ' / ' + @owner_column + '): ' + convert(varchar, @max_num)
         begin tran
         update dbo.new_num
         set last_num = @max_num, 
             trans_id = trans_id
         where num_col_name = @num_col_name and 
               loc_num = @my_loc_num and
               last_num <> @max_num
         select @rowcount = @@rowcount,
                @errcode = @@error
         if @errcode > 0 or @rowcount = 0
         begin
            rollback tran
            if @errcode > 0
               break               
         end
         else
            commit tran
      end

nextkey:
      select @num_col_name = min(num_col_name)
      from dbo.new_num 
      where loc_num = @my_loc_num and
            num_col_name > @num_col_name and
            owner_table is not null and
            owner_column is not null
   end
   drop table #seqnum

   select @max_num = isnull(max(trans_id), 0)
   from dbo.icts_transaction
   
   if @max_num = 0
   begin
      begin tran   
      insert into dbo.icts_transaction (
        trans_id, type, user_init, tran_date, app_name, app_revision, spid, workstation_id)
       values(1, 'S', 'SAA', getdate(), 'System', NULL, 40, NULL)
      select @rowcount = @@rowcount,
             @errcode = @@error
      if @errcode > 0 or @rowcount = 0
         rollback tran
      else
      begin
         commit tran
         select @max_num = 1
      end
   end
   
   if @max_num > 0
   begin
      begin tran   
      update dbo.icts_trans_sequence
      set last_num = @max_num
      where oid = 1
      select @rowcount = @@rowcount,
             @errcode = @@error
      if @errcode > 0 or @rowcount = 0
         rollback tran
      else
         commit tran
   end

   begin tran   
   update dbo.TI_feed_trans_sequence
   set last_num = (select isnull(max(oid), 0)
                   from dbo.TI_feed_transaction)
   where oid = 1
   select @rowcount = @@rowcount,
          @errcode = @@error
   if @errcode > 0 or @rowcount = 0
      rollback tran
   else
      commit tran
end
GO
GRANT EXECUTE ON  [dbo].[set_last_nums] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[set_last_nums] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'set_last_nums', NULL, NULL
GO
