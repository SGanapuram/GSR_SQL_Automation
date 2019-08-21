SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[refresh_a_last_num]
(
   @owner_table          varchar(30),
   @owner_column         varchar(30),
   @num_col_name         varchar(30) = null,
   @show_progress        bit = 0
)
as
set nocount on
set xact_abort on
declare @max_num              int,
        @max_trans_id         bigint,
		@max_strg			  varchar(30),
        @max_ref_num          varchar(30),
        @sql                  varchar(512),
        @rowcount             int,
        @errcode              int,
        @full_owner_table     sysname,
        @full_audit_tablename sysname,
        @smsg                 varchar(max),
		@seqname              sysname

   set @rowcount = 0
   set @errcode = 0
               
   set @full_owner_table = 'dbo.' + @owner_table
   set @full_audit_tablename = 'dbo.aud_' + @owner_table
  
   select @max_num = -1
   if not exists (select 1
                  from sys.columns with (nolock)
                  where object_id = object_id(@full_owner_table) and
                        name = @owner_column)
   begin
      RAISERROR('The column/table (%s/%s) does not exist in database!', 0, 1, @owner_column, @owner_table) with nowait
	  set @errcode = 1
      goto endofsp
   end

   set @seqname = dbo.udf_sqlserver_sequence_name_4_a_consumer(@owner_table, @owner_column)
   
   if @owner_table = 'icts_transaction' and @owner_column = 'trans_id'
   begin
      select @max_trans_id = isnull(max(trans_id), 0)
      from dbo.icts_transaction
 
      -- The icts_transaction table is empty, let's add the default record into this table  
      if @max_trans_id = 0
      begin
         begin tran 
         begin try		 
           insert into dbo.icts_transaction 
                 (trans_id, type, user_init, tran_date, app_name, 
                  app_revision, spid, workstation_id)
               values(1, 'S', 'SAA', getdate(), 'System', NULL, @@spid, NULL)
		 end try
		 begin catch
            set @errcode = ERROR_NUMBER()
			set @smsg = ERROR_MESSAGE()
            if @@trancount > 0
               rollback tran
		    RAISERROR('=> Failed to add default icts_transaction record due to the error below:', 0, 1, @seqname) with nowait
		    RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
			goto endofsp
		 end catch
        
         begin try
		    alter sequence dbo.icts_transaction_SEQ
			   restart with 1;
		 end try
		 begin catch
            set @errcode = ERROR_NUMBER()
			set @smsg = ERROR_MESSAGE()
            if @@trancount > 0
               rollback tran
		    RAISERROR('=> Failed to reset next sequence number for the sequence ''icts_transaction_SEQ'' due to the error below:', 0, 1) with nowait
		    RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
			goto endofsp
		 end catch		 
         commit tran
         goto endofsp
      end
	  else if @max_trans_id > 0
	  begin
	  set @max_trans_id=@max_trans_id+1
	  set @max_strg=convert(varchar,@max_trans_id)
	  set @sql = 'alter sequence dbo.' + @seqname + ' restart with ' + cast(@max_trans_id as varchar)
      begin tran
	  begin try
		exec(@sql)
      end try
      begin catch
        set @errcode = ERROR_NUMBER()
		set @smsg = ERROR_MESSAGE()
        if @@trancount > 0
           rollback tran
		RAISERROR('=> Failed to reset sequence number for the sequence ''%s'' due to the error below:', 0, 1, @seqname) with nowait
		RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
		RAISERROR('===> SQL: %s', 0, 1, @sql) with nowait
		goto endofsp
      end catch		 
      commit tran
      RAISERROR('The next sequence number for the sequence ''%s'' (%s.%s) was reset to %s successfully!', 0, 1, @seqname, @owner_table, @owner_column, @max_strg) with nowait
         goto endofsp
	  end
	  
	  goto updlastnum
   end
   
  /* if @owner_table = 'trade_item' and @owner_column = 'idms_bb_ref_num'
   begin
      select @max_ref_num = isnull(max(idms_bb_ref_num), '0') 
	  from dbo.trade_item
	  
      set @max_ref_num = right(@max_ref_num, len(@max_ref_num)-1)
      set @max_num = cast(@max_ref_num as int)
      goto updlastnum
   end */

   if @owner_table = 'trade' and @owner_column = 'trade_num' 
   begin 
      if @num_col_name = 'trade_num' or @num_col_name is null
	  begin
	     set @seqname = 'trade_SEQ'
         select @max_num = isnull(max(trade_num), 0) 
	     from dbo.trade 
	     where trade_num < 80000000
	  
         select @max_num = isnull(max(trade_num), @max_num) 
         from dbo.aud_trade 
	     where trade_num > @max_num and 
	           trade_num < 80000000			
         goto updlastnum
	  end

      if @num_col_name = 'qf_num'
	  begin
	     set @seqname = 'quickfill_SEQ'
         select @max_num = isnull(max(trade_num), 0) 
		 from dbo.trade 
		 where trade_num >= 80000000
		 
         select @max_num = isnull(max(trade_num), @max_num) 
         from dbo.aud_trade 
		 where trade_num > @max_num and 
		       trade_num >= 80000000
			   
		 if isnull(@max_num, 0) < 80000000
		    set @max_num = 80000000 - 1
	  end	  
      goto updlastnum
   end

   /* The agreement_num starts at 90000000 */
   if @owner_table = 'gtc' and @owner_column = 'agreement_num'
   begin
      select @max_num = isnull(max(agreement_num), 90000000) 
	  from dbo.gtc
	  
      select @max_num = isnull(max(agreement_num), @max_num) 
      from dbo.aud_gtc 
	  where agreement_num > @max_num

	  if isnull(@max_num, 0) < 90000000
		 set @max_num = 90000000 - 1

      goto updlastnum
   end

   /* The agreement_num starts at 90000000 */
   if @owner_table = 'account_agreement' and @owner_column = 'agreement_num'
   begin
      select @max_num = isnull(max(agreement_num), 90000000) 
	  from dbo.account_agreement
	  
      select @max_num = isnull(max(agreement_num), @max_num) 
      from dbo.aud_account_agreement 
	  where agreement_num > @max_num

	  if isnull(@max_num, 0) < 90000000
		 set @max_num = 90000000 - 1
	  
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
      from dbo.aud_icts_function 
	  where function_num > @max_num

	  if isnull(@max_num, 0) < 20000
		 set @max_num = 20000
      goto updlastnum
   end

   create table #seqnum
   (
      oid                int not null,
      max_num            int default 0
   )

   if object_id(@full_owner_table) is not null
   begin       
      set @sql = 'select 1, isnull(max(' + @owner_column + '), 0) from ' + @full_owner_table
      truncate table #seqnum
      insert into #seqnum (oid, max_num) exec(@sql)
	  
      select @max_num = max_num 
	  from #seqnum 
	  where oid = 1
   end
   if object_id(@full_audit_tablename) is not null
   begin
      set @sql = 'select 1, isnull(max(' + @owner_column + '), ' + convert(varchar, @max_num) + ') '
      set @sql = @sql + 'from ' + @full_audit_tablename + ' where ' + @owner_column + ' > ' + convert(varchar, @max_num)
      truncate table #seqnum
      insert into #seqnum (oid, max_num) exec(@sql)
	  
      select @max_num = max_num 
	  from #seqnum 
	  where oid = 1
   end
   drop table #seqnum
        
updlastnum:
   if @max_num > -1
   begin
		set @max_strg= convert(varchar,@max_num)
      if @show_progress = 1
         RAISERROR('Setting the next sequence number for the sequence ''%s'' (%s.%s) to be %s ...', 0, 1, @seqname, @owner_table, @owner_column, @max_strg) with nowait
	
	  set @max_num = @max_num + 1
	  set @max_strg= convert(varchar,@max_num)
	  set @sql = 'alter sequence dbo.' + @seqname + ' restart with ' + cast(@max_num as varchar)
      begin tran
	  begin try
		exec(@sql)
      end try
      begin catch
        set @errcode = ERROR_NUMBER()
		set @smsg = ERROR_MESSAGE()
        if @@trancount > 0
           rollback tran
		RAISERROR('=> Failed to reset sequence number for the sequence ''%s'' due to the error below:', 0, 1, @seqname) with nowait
		RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
		RAISERROR('===> SQL: %s', 0, 1, @sql) with nowait
		goto endofsp
      end catch		 
      commit tran
      RAISERROR('The next sequence number for the sequence ''%s'' (%s.%s) was reset to %s successfully!', 0, 1, @seqname, @owner_table, @owner_column, @max_strg) with nowait
   end

endofsp:
if @errcode > 0
   return 1
return 0
GO
GRANT EXECUTE ON  [dbo].[refresh_a_last_num] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[refresh_a_last_num] TO [next_usr]
GO
