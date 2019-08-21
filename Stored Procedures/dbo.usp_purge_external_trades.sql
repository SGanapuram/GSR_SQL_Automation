SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_purge_external_trades]  
   @priortodays        int = 90,  
   @archive_needed     bit = 1,  
   @debugon            bit = 0  
as  
set nocount on  
declare @tempdate                     datetime,  
        @n                            int,  
        @cutoffdate                   datetime,  
        @yyyy1                        smallint,  
        @month1                       smallint,  
        @yyyy2                        smallint,  
        @month2                       smallint,  
        @day                          smallint,  
        @min_oid                      int,  
        @max_oid                      int,  
        @rows_affected                int,  
        @errcode                      int,  
        @total_ETT_rows_deleted       int,  
        @total_IT_rows_deleted        int,  
        @total_ET_rows_deleted        int,  
        @total_EC_rows_deleted        int,  
        @total_ETT_arch_rows_deleted  int,  
        @total_IT_arch_rows_deleted   int,  
        @total_ET_arch_rows_deleted   int,  
        @total_EC_arch_rows_deleted   int,  
        @smsg                         varchar(255),  
        @starttime                    varchar(30),  
        @finishtime                   varchar(30),  
        @archived_date                datetime,  
        @archive_cutoffdate           datetime  
          
   set @archived_date = getdate()  
   select @starttime = convert(varchar, getdate(), 109)  
     
   select @errcode = 0  
     
   create table #log  
   (  
      oid                   numeric(18, 0) IDENTITY,  
      year                  smallint,  
      month                 smallint,  
      tablename             varchar(80),  
      rows_deleted          int  
   )  
        
   create table #oids  
   (  
      oid    int primary key  
   )  
  
      
   select @tempdate = max(it.tran_date)  
   from dbo.icts_transaction it  
           INNER JOIN dbo.external_trade ext  
              on it.trans_id = ext.trans_id  
  
   if @tempdate is null  
   begin  
      print 'Could not find an icts_transaction record tied to an external trade!'  
      goto endofsp  
   end  
  
   select @n = -1 * @priortodays            
   select @cutoffdate = dateadd(day, @n, @tempdate)  
   select @archive_cutoffdate = dateadd(day, -14, @cutoffdate)  
  
   set @total_ETT_arch_rows_deleted = 0  
   set @total_IT_arch_rows_deleted = 0  
   set @total_ET_arch_rows_deleted = 0  
   set @total_EC_arch_rows_deleted = 0  
  
   begin try  
     delete ext  
     from dbo.external_trade_archive ext  
     where exists (select 1  
                   from dbo.icts_transaction it  
                   where it.tran_date < @archive_cutoffdate and  
                         it.trans_id = ext.trans_id)  
     select @total_ET_arch_rows_deleted = @@rowcount  
   end try  
   begin catch  
     print '=> Failed to remove external_trade_archive records due to the error:'  
     print '==> ERROR: ' + ERROR_MESSAGE()  
     goto endofsp  
   end catch  
     
   begin try  
     delete ice  
     from dbo.ice_trade_archive ice  
     where not exists (select 1  
                       from dbo.external_trade_archive ext  
                       where ice.external_trade_oid = ext.oid)  
     select @total_IT_arch_rows_deleted = @@rowcount  
   end try  
   begin catch  
     print '=> Failed to remove ice_trade_archive records due to the error:'  
     print '==> ERROR: ' + ERROR_MESSAGE()  
     goto endofsp  
   end catch  
  
   begin try  
     delete exch  
     from dbo.exch_tools_trade_archive exch  
     where not exists (select 1  
                       from dbo.external_trade_archive ext  
                       where exch.external_trade_oid = ext.oid)  
     select @total_ETT_arch_rows_deleted = @@rowcount  
   end try  
   begin catch  
     print '=> Failed to remove exch_tools_trade_archive records due to the error:'  
     print '==> ERROR: ' + ERROR_MESSAGE()  
     goto endofsp  
   end catch  
  
   begin try  
     delete cmt   
     from dbo.external_comment_archive cmt  
     where not exists (select 1  
                       from dbo.external_trade_archive ext  
                       where cmt.oid = ext.external_comment_oid) and  
           not exists (select 1  
                       from dbo.exch_tools_trade_archive ext  
                       where cmt.oid = ext.external_comment_oid)             
     select @total_EC_arch_rows_deleted = @@rowcount  
   end try  
   begin catch  
     print '=> Failed to remove external_comment_archive records due to the error:'  
     print '==> ERROR: ' + ERROR_MESSAGE()  
     goto endofsp  
   end catch  
  
  
   if @debugon = 1  
   begin  
      select @smsg = 'Archiving old records before ' + convert(varchar, @cutoffdate, 101) + ' ... ' + convert(varchar, getdate(), 109)  
      print @smsg  
      select @smsg = 'Purging old records in archived tables before ' + convert(varchar, @archive_cutoffdate, 101) + ' ... ' + convert(varchar, getdate(), 109)  
      print @smsg  
   end  
     
   select @yyyy2 = year(@cutoffdate),  
          @month2 = month(@cutoffdate)  
         
   select @tempdate = min(it.tran_date)  
   from dbo.icts_transaction it  
           INNER JOIN dbo.external_trade ext  
              on it.trans_id = ext.trans_id  
  
   if datediff(day, @tempdate, @cutoffdate) < 0  
   begin  
      select @smsg = 'The earliest tran_date ''' + convert(varchar, @tempdate, 101) + ''' is newer than the cutoff date ''' + convert(varchar, @cutoffdate, 101) + '''. In this case, no records are purged!'  
      print @smsg  
      goto report  
   end  
  
   if @debugon = 1  
   begin  
      select @smsg = 'DEBUG: oldest tran date = ' + convert(varchar, @tempdate, 101)   
      print @smsg  
   end  
     
   if OBJECTPROPERTY(object_id('dbo.exch_tools_trade_deltrg'), 'ExecIsTriggerDisabled') = 0  
      exec('alter table dbo.exch_tools_trade disable trigger exch_tools_trade_deltrg')  
   if OBJECTPROPERTY(object_id('dbo.ice_trade_deltrg'), 'ExecIsTriggerDisabled') = 0  
      exec('alter table dbo.ice_trade disable trigger ice_trade_deltrg')  
   if OBJECTPROPERTY(object_id('dbo.external_trade_deltrg'), 'ExecIsTriggerDisabled') = 0  
      exec('alter table dbo.external_trade disable trigger external_trade_deltrg')  
   if OBJECTPROPERTY(object_id('dbo.external_comment_deltrg'), 'ExecIsTriggerDisabled') = 0  
      exec('alter table dbo.external_comment disable trigger external_comment_deltrg')  
  
   select @yyyy1 = year(@tempdate),  
          @month1 = month(@tempdate)  
  
   while (1 = 1)  
   begin           
      if @yyyy1 = @yyyy2 and @month1 = @month2  
         select @day = day(@cutoffdate)  
      else  
         select @day = 31  
    
      select @errcode = 0  
      truncate table #oids  
        
      if @debugon = 1  
      begin  
         print '***********************'  
         print '=> DEBUG: Getting oids from the ''external_trade'' table for '  
         select @smsg = '    (Year ' + cast(@yyyy1 as varchar) + ', month ' + cast(@month1 as varchar)  
         select @smsg = @smsg + ', day ' + cast(@day as varchar) + ') ... ' + convert(varchar, getdate(), 109)   
         print @smsg  
      end  
        
      insert into #oids  
      select ext.oid  
      from dbo.icts_transaction it  
              INNER JOIN dbo.external_trade ext  
                 on it.trans_id = ext.trans_id  
      where year(it.tran_date) = @yyyy1 and  
            month(it.tran_date) = @month1 and  
            day(it.tran_date) <= @day  
      select @rows_affected = @@rowcount,  
             @errcode = @@error  
      if @errcode > 0  
      begin  
         select @smsg = '=> Failed to obtain oid in the ''external_trade'' table for (Year ' + cast(@yyyy1 as varchar) + ', month ' + cast(@month1 as varchar) + ')!'  
         print @smsg  
         goto endofsp  
      end  
        
      if @debugon = 1  
      begin  
         select @smsg = '=> DEBUG: # of oids found = ' + convert(varchar, @rows_affected)  
         print @smsg  
      end  
               
      /* ---------------------------------------------------------  
          Below is the code snippet to perform purge  
         --------------------------------------------------------- */           
  
      select @total_ETT_rows_deleted = 0                  
      select @total_IT_rows_deleted = 0                  
      select @total_ET_rows_deleted = 0     
                       
      if @rows_affected > 0  
      begin  
         set rowcount 10000  
         set @n = 0  
         while (1 = 1)  
         begin  
            set @n = @n + 1  
            print '**********'  
            print 'Processing the batch (every 10000 rows) #' + cast(@n as varchar) + ' ... ' + convert(varchar, getdate(), 109)  
            if @debugon = 1  
            begin  
               print '***'  
               select @smsg = '==> DEBUG: Deleting the ''exch_tools_trade'' table ... ' + convert(varchar, getdate(), 109)  
               print @smsg  
            end  
  
            begin tran  
            begin try  
              if @archive_needed = 1  
              begin  
                 delete dbo.exch_tools_trade  
                 output deleted.external_trade_oid,deleted.accepted_action,deleted.accepted_broker,deleted.accepted_company,
				 deleted.accepted_trader,deleted.buyer_account,deleted.commodity,deleted.creation_date,deleted.exch_tools_trade_num,deleted.input_action,deleted.input_broker,deleted.
				 input_company,deleted.input_trader,deleted.price,deleted.quantity,deleted.seller_account,deleted.trading_period,deleted.begin_date,deleted.end_date,deleted.call_put,deleted.
				 strike_price,deleted.buyer_comm_cost,deleted.buyer_comm_curr,deleted.seller_comm_cost,deleted.seller_comm_curr,deleted.trans_id,deleted.buyer_clrng_broker,deleted.
				 seller_clrng_broker,deleted.external_comment_oid,deleted.acct_contact,deleted.gtc,deleted.trade_type,deleted.risk_market,deleted.title_market,deleted.qty_uom,deleted.
				 del_date_from,deleted.del_date_to,deleted.mot,deleted.title_transfer,deleted.price_type,deleted.formula_name,deleted.event_deemed_date,deleted.price_uom,deleted.price_currency,deleted.
				 template_trade_num,deleted.float_market_quote1,deleted.float_market_quote2,deleted.float_qty1,deleted.float_qty2,deleted.premium_date,deleted.auto_exerc_ind,deleted.
				 product_id,@archived_date,deleted.memo_code   
                 into dbo.exch_tools_trade_archive(external_trade_oid,accepted_action,accepted_broker,accepted_company,
				 accepted_trader,buyer_account,commodity,creation_date,exch_tools_trade_num,input_action,input_broker,
				 input_company,input_trader,price,quantity,seller_account,trading_period,begin_date,end_date,call_put,
				 strike_price,buyer_comm_cost,buyer_comm_curr,seller_comm_cost,seller_comm_curr,trans_id,buyer_clrng_broker,
				 seller_clrng_broker,external_comment_oid,acct_contact,gtc,trade_type,risk_market,title_market,qty_uom,
				 del_date_from,del_date_to,mot,title_transfer,price_type,formula_name,event_deemed_date,price_uom,price_currency,
				 template_trade_num,float_market_quote1,float_market_quote2,float_qty1,float_qty2,premium_date,auto_exerc_ind,
				 product_id,archived_date,memo_code)
                 where exists (select 1  
                               from #oids a  
                               where a.oid = exch_tools_trade.external_trade_oid)  
              end  
              else  
              begin  
                 delete dbo.exch_tools_trade  
                 where exists (select 1  
                               from #oids a  
                               where a.oid = exch_tools_trade.external_trade_oid)  
              end  
              select @rows_affected = @@rowcount  
            end try  
            begin catch  
              if @@trancount > 0  
                 rollback tran  
              print '=> Failed to delete exch_tools_trade records due to the error:'  
              print '==> ERROR: ' + ERROR_MESSAGE()  
              goto endofsp  
            end catch  
            select @total_ETT_rows_deleted = @total_ETT_rows_deleted + @rows_affected                  
  
            if @debugon = 1  
            begin  
               select @smsg = '==> DEBUG: Deleting the ''ice_trade'' table ... ' + convert(varchar, getdate(), 109)  
               print @smsg  
            end  
       
            begin try  
              if @archive_needed = 1  
              begin  
                 delete dbo.ice_trade  
                 output deleted.*, @archived_date  
                 into dbo.ice_trade_archive  
                 where exists (select 1  
                               from #oids a  
                               where a.oid = ice_trade.external_trade_oid)  
              end  
              else  
              begin  
                 delete dbo.ice_trade  
                 where exists (select 1  
                               from #oids a  
                               where a.oid = ice_trade.external_trade_oid)  
              end  
              select @rows_affected = @@rowcount  
            end try  
            begin catch  
              if @@trancount > 0  
                 rollback tran  
              print '=> Failed to delete ice_trade records due to the error:'  
              print '==> ERROR: ' + ERROR_MESSAGE()  
              goto endofsp  
            end catch  
            select @total_IT_rows_deleted = @total_IT_rows_deleted + @rows_affected                  
  
            if @debugon = 1  
            begin  
               select @smsg = '==> DEBUG: Deleting the ''external_trade'' table ... ' + convert(varchar, getdate(), 109)  
               print @smsg  
            end  
  
            begin try  
              if @archive_needed = 1  
              begin  
                 delete dbo.external_trade  
                 output deleted.*, @archived_date  
                 into dbo.external_trade_archive  
                 where exists (select 1  
                               from #oids a  
                               where a.oid = external_trade.oid) and   
                       oid not in (select external_trade_oid   
                                   from dbo.exch_tools_trade)  
              end  
              else  
              begin  
                 delete dbo.external_trade  
                 where exists (select 1  
                               from #oids a  
                               where a.oid = external_trade.oid) and   
                       oid not in (select external_trade_oid   
                                   from dbo.exch_tools_trade)  
              end  
              select @rows_affected = @@rowcount  
            end try  
            begin catch  
              if @@trancount > 0  
                 rollback tran  
              print '=> Failed to delete external_trade records due to the error:'  
              print '==> ERROR: ' + ERROR_MESSAGE()  
              goto endofsp  
            end catch  
            commit tran  
            select @total_ET_rows_deleted = @total_ET_rows_deleted + @rows_affected     
            if @rows_affected = 0  
               break              
         end /* while */  
         set rowcount 0  
      end /* if */  
  
      if @debugon = 1  
      begin  
         select @smsg = '==> DEBUG: Saving delete rowcount to the temp. table ''#log'' ... ' + convert(varchar, getdate(), 109)  
         print @smsg  
      end  
      
      insert into #log  
          (year, month, tablename, rows_deleted)  
         values(@yyyy1, @month1, 'exch_tools_trade', @total_ETT_rows_deleted)  
      insert into #log  
          (year, month, tablename, rows_deleted)  
         values(@yyyy1, @month1, 'ice_trade', @total_IT_rows_deleted)  
      insert into #log  
          (year, month, tablename, rows_deleted)  
         values(@yyyy1, @month1, 'external_trade', @total_ET_rows_deleted)  
     
      -- Here, if we have done the last month in the purge window, then exit while loop now  
      print '@yyyy1/month1 = ' + cast(@yyyy1 as varchar) + '/' + cast(@month1 as varchar)  
      print '@yyyy2/month2 = ' + cast(@yyyy2 as varchar) + '/' + cast(@month2 as varchar)  
        
      if @yyyy1 = @yyyy2 and @month1 = @month2  
         break  
  
      select @month1 = @month1 + 1  
      if @month1 > 12  
      begin  
         select @yyyy1 = @yyyy1 + 1  
         select @month1 = 1  
      end    
      print 'NEW @yyyy1/month1 = ' + cast(@yyyy1 as varchar) + '/' + cast(@month1 as varchar)  
   end  
  
   if @debugon = 1  
   begin  
      print ' '  
      print 'DEBUG: Viewing the content of #log ...'  
      select * from #log order by oid  
      print ' '  
   end  
     
   /* purge orphan external_comment records */  
   if @debugon = 1  
   begin  
      select @smsg = '=> DEBUG: Removing orphan external_comment records ... ' + convert(varchar, getdate(), 109)  
      print @smsg  
   end  
  
   select @total_EC_rows_deleted = 0  
   set rowcount 50000  
   while (1 = 1)  
   begin  
      begin tran  
      begin try  
        if @archive_needed = 1  
        begin  
           delete dbo.external_comment  
           output deleted.*, @archived_date  
           into dbo.external_comment_archive  
           where not exists (select 1  
                             from dbo.external_trade a  
                             where external_comment.oid = a.external_comment_oid) and  
                 not exists (select 1  
                             from dbo.exch_tools_trade a  
                             where external_comment.oid = a.external_comment_oid)                       
        end  
        else  
        begin  
           delete dbo.external_comment  
           where not exists (select 1  
                             from dbo.external_trade a  
                             where external_comment.oid = a.external_comment_oid) and  
                 not exists (select 1  
                             from dbo.exch_tools_trade a  
                             where external_comment.oid = a.external_comment_oid)    
        end          
        select @rows_affected = @@rowcount  
      end try  
      begin catch  
        if @@trancount > 0  
           rollback tran  
        print '=> Failed to delete external_comment records due to the error:'  
        print '==> ERROR: ' + ERROR_MESSAGE()  
        goto endofsp  
      end catch  
      commit tran  
      if @rows_affected = 0  
         break  
      select @total_EC_rows_deleted = @total_EC_rows_deleted + @rows_affected                  
   end  
  
report:   
   select @total_ETT_rows_deleted = 0                  
   select @total_IT_rows_deleted = 0                  
   select @total_ET_rows_deleted = 0                  
   select @total_ETT_rows_deleted = sum(isnull(rows_deleted, 0))  
   from #log  
   where tablename = 'exch_tools_trade'  
   select @total_IT_rows_deleted = sum(isnull(rows_deleted, 0))  
   from #log  
   where tablename = 'ice_trade'  
   select @total_ET_rows_deleted = sum(isnull(rows_deleted, 0))  
   from #log  
   where tablename = 'external_trade'  
  
   select @finishtime = convert(varchar, getdate(), 109)  
   print ' '  
   print '============================================================='  
   print 'ARCHIVE/PURGE session'  
   select @smsg = '   Records before ' + convert(varchar, @cutoffdate, 101) + ' were archived'  
   print @smsg  
   select @smsg = '   Archived records before ' + convert(varchar, @archive_cutoffdate, 101) + ' were purged'  
   print @smsg  
   print ' '  
   select @smsg = '     Session started  at    ' + @starttime  
   print @smsg  
   select @smsg = '     Session finished at    ' + @finishtime  
   print @smsg  
   print '-------------------------------------------------------------'  
     
   if @total_ETT_rows_deleted > 0  
      select @smsg = '=> exch_tools_trade         : ' + cast(@total_ETT_rows_deleted as varchar) + ' records were archived'  
   else  
      select @smsg = '=> exch_tools_trade         : No records were archived'  
   print @smsg     
   if @total_IT_rows_deleted > 0  
      select @smsg = '=> ice_trade                : ' + cast(@total_IT_rows_deleted as varchar) + ' records were archived'  
   else  
      select @smsg = '=> ice_trade                : No records were archived'  
   print @smsg     
   if @total_ET_rows_deleted > 0  
      select @smsg = '=> external_trade           : ' + cast(@total_ET_rows_deleted as varchar) + ' records were archived'  
   else  
      select @smsg = '=> external_trade           : No records were archived'  
   print @smsg     
   if @total_EC_rows_deleted > 0  
      select @smsg = '=> external_comment         : ' + cast(@total_EC_rows_deleted as varchar) + ' records were archived'  
   else  
      select @smsg = '=> external_comment         : No records were archived'  
   print @smsg     
   print ' '  
  
   if @total_ETT_arch_rows_deleted > 0  
      select @smsg = '=> exch_tools_trade_archive : ' + cast(@total_ETT_arch_rows_deleted as varchar) + ' records were purged'  
   else  
      select @smsg = '=> exch_tools_trade_archive : No records were purged'  
   print @smsg     
   if @total_IT_arch_rows_deleted > 0  
      select @smsg = '=> ice_trade_archive        : ' + cast(@total_IT_arch_rows_deleted as varchar) + ' records were purged'  
   else  
      select @smsg = '=> ice_trade_archive        : No records were purged'  
   print @smsg     
   if @total_ET_arch_rows_deleted > 0  
      select @smsg = '=> external_trade_archive   : ' + cast(@total_ET_arch_rows_deleted as varchar) + ' records were purged'  
   else  
      select @smsg = '=> external_trade_archive   : No records were purged'  
   print @smsg     
   if @total_EC_arch_rows_deleted > 0  
      select @smsg = '=> external_comment_archive : ' + cast(@total_EC_arch_rows_deleted as varchar) + ' records were purged'  
   else  
      select @smsg = '=> external_comment_archive : No records were purged'  
   print @smsg     
   print ' '  
                       
endofsp:  
drop table #log  
drop table #oids  
  
if OBJECTPROPERTY(object_id('dbo.exch_tools_trade_deltrg'), 'ExecIsTriggerDisabled') = 1  
   exec('alter table dbo.exch_tools_trade enable trigger exch_tools_trade_deltrg')  
if OBJECTPROPERTY(object_id('dbo.ice_trade_deltrg'), 'ExecIsTriggerDisabled') = 1  
   exec('alter table dbo.ice_trade enable trigger ice_trade_deltrg')  
if OBJECTPROPERTY(object_id('dbo.external_trade_deltrg'), 'ExecIsTriggerDisabled') = 1  
   exec('alter table dbo.external_trade enable trigger external_trade_deltrg')  
if OBJECTPROPERTY(object_id('dbo.external_comment_deltrg'), 'ExecIsTriggerDisabled') = 1  
   exec('alter table dbo.external_comment enable trigger external_comment_deltrg')  
  
if @errcode = 0  
   return 0  
return 1  
GO
GRANT EXECUTE ON  [dbo].[usp_purge_external_trades] TO [next_usr]
GO
