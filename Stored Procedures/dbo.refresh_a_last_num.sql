SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[refresh_a_last_num]
(
   @owner_table          varchar(30),
   @owner_column         varchar(30),
   @show_progress        bit = 0
)
as
set nocount on
set xact_abort on
declare @max_num              int,
        @max_ref_num          varchar(30),
        @audit_tablename      varchar(30),
        @sql                  varchar(512),
        @rowcount             int,
        @errcode              int,
        @full_owner_table     varchar(30),
        @full_audit_tablename varchar(30),
        @smsg                 varchar(255)

   select @rowcount = 0,
          @errcode = 0
               
   select @audit_tablename = 'aud_' + @owner_table
   select @full_owner_table = 'dbo.' + @owner_table
   select @full_audit_tablename = 'dbo.' + @audit_tablename
  
   select @max_num = -1
   if not exists (select 1
                  from dbo.syscolumns with (nolock)
                  where id = object_id(@full_owner_table) and
                        name = @owner_column)
   begin
      select @smsg = 'The column/table (' + @owner_column + '/' + @owner_table + ') does not exist in database!'
      print @smsg
      goto endofsp
   end
      
   if @owner_table = 'icts_transaction' and @owner_column = 'trans_id'
   begin
      select @max_num = isnull(max(trans_id), 0)
      from dbo.icts_transaction
 
      -- The icts_transaction table is empty, let's add the default record into this table  
      if @max_num = 0
      begin
         begin tran   
         insert into dbo.icts_transaction 
              (trans_id, type, user_init, tran_date, app_name, 
               app_revision, spid, workstation_id)
             values(1, 'S', 'SAA', getdate(), 'System', NULL, @@spid, NULL)
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
   
      -- refresh the counter in the icts_trans_sequence table
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
      goto endofsp
   end

   if @owner_table = 'TI_feed_transaction' and @owner_column = 'oid'
   begin
      select @max_num = isnull(max(oid), 0)
      from dbo.TI_feed_transaction
 
      -- refresh the counter in the TI_feed_trans_sequence table
      if @max_num > 0
      begin
         begin tran   
         update dbo.TI_feed_trans_sequence
         set last_num = @max_num
         where oid = 1
         select @rowcount = @@rowcount,
                @errcode = @@error
         if @errcode > 0 or @rowcount = 0
            rollback tran
         else
            commit tran
      end
      goto endofsp
   end
   
   if @owner_table = 'trade_item' and @owner_column = 'idms_bb_ref_num'
   begin
      select @max_ref_num = isnull(max(idms_bb_ref_num), '0') from dbo.trade_item
      select @max_ref_num = right(@max_ref_num, len(@max_ref_num)-1)
      select @max_num = convert(int, @max_ref_num)
      goto updlastnum
   end

   if @owner_table = 'trade' and @owner_column = 'trade_num'
   begin 
      select @max_num = isnull(max(trade_num), 0) from dbo.trade where trade_num < 80000000
      select @max_num = isnull(max(trade_num), @max_num) 
      from dbo.aud_trade where trade_num > @max_num and trade_num < 80000000
      goto updlastnum
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

   create table #seqnum
   (
      oid                int not null,
      max_num            int default 0
   )

   if object_id(@full_owner_table) is not null
   begin       
      select @sql = 'select 1, isnull(max(' + @owner_column + '), 0) from ' + @full_owner_table
      truncate table #seqnum
      insert into #seqnum (oid, max_num) exec(@sql)
      select @max_num = max_num from #seqnum where oid = 1
   end
   if object_id(@full_audit_tablename) is not null
   begin
      select @sql = 'select 1, isnull(max(' + @owner_column + '), ' + convert(varchar, @max_num) + ') '
      select @sql = @sql + 'from ' + @full_audit_tablename + ' where ' + @owner_column + ' > ' + convert(varchar, @max_num)
      truncate table #seqnum
      insert into #seqnum (oid, max_num) exec(@sql)
      select @max_num = max_num from #seqnum where oid = 1
   end
   drop table #seqnum
        
updlastnum:
   if @max_num > -1
   begin
      if @show_progress = 1
         print 'Updating last_num for (' + @owner_table + ' / ' + @owner_column + ') with the value ' + convert(varchar, @max_num)
      begin tran
      update dbo.new_num
      set last_num = @max_num, 
          trans_id = trans_id
      where owner_table = @owner_table and 
            owner_column = @owner_column and
            loc_num = 0 and
            last_num <> @max_num
      select @rowcount = @@rowcount,
             @errcode = @@error
      if @errcode > 0 or @rowcount = 0
         rollback tran
      else
      begin
         commit tran
         print 'The counter for the column ''' + @owner_column + ''' in the ''' + @owner_table + ''' table was refreshed. The new value is ' + convert(varchar, @max_num)
      end
   end

endofsp:
GO
GRANT EXECUTE ON  [dbo].[refresh_a_last_num] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[refresh_a_last_num] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'refresh_a_last_num', NULL, NULL
GO
