SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE procedure [dbo].[usp_PLCOMP_pl_comparison_report]                                    
(      
   @root_port_num    int,                                                        
   @cob_date1        datetime = NULL,                                    
   @cob_date2        datetime = NULL,      
   @tag_xml_string   xml = NULL,      
   @debugon          bit = 0,    
   @show_transfer_prices bit = 0     
)                                   
as                                   
set nocount on                                                        
declare @my_top_port_num   int,                                                        
        @smsg              varchar(255),                                                        
        @status            int,                                                        
        @errcode           int,                                                        
        @asofdate          datetime,                                                        
        @rows_affected     int,      
        @time_started      varchar(20),      
        @time_finished     varchar(20)      
        
   set @my_top_port_num = @root_port_num          
   if @debugon = 1      
      print 'usp_PLCOMP_pl_comparison_report V4 - 07/03/2014'      
                                                        
   set @status = 0                                                        
   set @errcode = 0                                                        
   if @my_top_port_num is null                                                        
      select @my_top_port_num = 0                                           
                                                              
   if not exists (select 1                                                        
                  from dbo.portfolio WITH (NOLOCK)                                                        
                  where port_num = @root_port_num)                                                        
   begin                                                        
      print '=> You must provide a valid port # for the argument @root_port_num!'                                                        
      print 'Usage: exec dbo.usp_PLCOMP_pl_comparison_report @root_port_num = ?, @cob_date1 = ''mm/dd/yyyy'', @cob_date2 = ''mm/dd/yyyy'' [, @debugon = ?]'                                                        
      return 2                                                        
   end                                                                       
        
   if isnull(@cob_date2, '01/01/1900') = '01/01/1900'        
      select @cob_date2 = max(pl_asof_date)       
      from dbo.portfolio_profit_loss WITH (NOLOCK)       
      where port_num = @root_port_num        
         
   if isnull(@cob_date1, '01/01/1900') = '01/01/1900'        
      select @cob_date1 = max(pl_asof_date)       
      from dbo.portfolio_profit_loss WITH (NOLOCK)       
      where port_num = @root_port_num and      
            pl_asof_date < @cob_date2           
                                    
   create table #children                                                        
   (                                                        
      port_num    int PRIMARY KEY,                                                        
      port_type   char(2)                                                      
   )                                                        
         
   set @time_started = (select convert(varchar, getdate(), 109))                               
   begin try                                                            
     exec dbo.usp_get_child_port_nums @my_top_port_num, 1                                                        
   end try                                                        
   begin catch                                                        
     print '=> Failed to execute the ''usp_get_child_port_nums'' sp due to the following error:'                                  
     print '==> ERROR: ' + ERROR_MESSAGE()      
     set @errcode = ERROR_NUMBER()                                                        
     goto endofsp                                                        
   end catch                                                        
                                     
   delete #children                                     
   from #children c                                    
   where exists (select 1                                     
                 from (select real_port_num,      
                              isnull(summary_pl_amt, 0) + isnull(total_pl_no_sec_cost, 0) as amt      
                       from dbo.v_PLCOMP_portfolio_pl_info      
                       where pl_asof_date = @cob_date1 and      
                             real_port_num = c.port_num) as ppl1      
                          join (select real_port_num,      
                                       isnull(summary_pl_amt, 0) + isnull(total_pl_no_sec_cost, 0) as amt      
                                from dbo.v_PLCOMP_portfolio_pl_info      
                                where pl_asof_date = @cob_date2 and      
                                      real_port_num = c.port_num) as ppl2      
                              on ppl1.real_port_num = ppl2.real_port_num       
                 where ppl1.amt = ppl2.amt)      
                         
   if @debugon = 1      
   begin      
      declare @num_of_portfolios  int      
            
      set @num_of_portfolios = (select count(*) from #children)      
      RAISERROR ('**********************', 0, 1) WITH NOWAIT          
      set @smsg = '=> REAL portfolio count in portfolio hierarchy #' + cast(@my_top_port_num as varchar) + ' = ' + cast(@num_of_portfolios as varchar)      
      RAISERROR (@smsg, 0, 1) WITH NOWAIT      
      set @smsg = '=> These portfolioes were found that their PL amounts are different'      
      RAISERROR (@smsg, 0, 1) WITH NOWAIT            
      set @time_finished = (select convert(varchar, getdate(), 109))      
      set @smsg = '==> Started : ' + @time_started      
      RAISERROR (@smsg, 0, 1) WITH NOWAIT      
      set @smsg = '==> Finished: ' + @time_finished      
      RAISERROR (@smsg, 0, 1) WITH NOWAIT           
   end      
                      
   create table #pl_hist1                                  
   (                                  
      pl_record_key           int,                                  
      pl_owner_code           char(8) NULL,                                   
      pl_asof_date            datetime,                                  
      real_port_num           int,                                  
      pl_owner_sub_code       char(20) NULL,                                   
      pl_record_owner_key     int NULL,                                  
      pl_primary_owner_key1   int NULL,                                  
      pl_primary_owner_key2   int NULL,                                  
      pl_primary_owner_key3   int NULL,                                  
      pl_primary_owner_key4   int NULL,                                  
      pl_secondary_owner_key1 int NULL,                                  
      pl_secondary_owner_key2 int NULL,                                  
      pl_secondary_owner_key3 int NULL,                                  
      pl_type                 char(8) NULL,                                   
      pl_category_type        char(8) NULL,                                   
      pl_realization_date     datetime NULL,                                  
      pl_cost_status_code     char(8) NULL,                                   
      pl_cost_prin_addl_ind   char(8) NULL,                                   
      pl_mkt_price            float NULL,                                  
      pl_amt                  float NULL,                                  
      trans_id                int NULL,                                  
      currency_fx_rate        float NULL,                                  
      pl_record_qty           numeric NULL,                                  
      pl_record_qty_uom_code  char(4) NULL,         
      pos_num                 int NULL,      
      cost_num                int NULL,      
      pl_owner                varchar(18) NULL,         
      trade_key               varchar(92) NULL,                                                          
      trade_cost_type         varchar(16) NULL,                                   
      pl_type_desc            varchar(20) NULL                                                                                                                         
   )                                  
      
   select * into #pl_hist2 from #pl_hist1      
         
   create nonclustered index xx10189_pl_hist1_idx1       
      on #pl_hist1 (pl_asof_date,      
                   pl_secondary_owner_key1,       
                   pl_secondary_owner_key2,      
                   pl_secondary_owner_key3,       
                   real_port_num)                                                             
      
   create nonclustered index xx10189_pl_hist1_idx2       
      on #pl_hist1 (pl_asof_date,      
                   pos_num)                                                             
      
   create nonclustered index xx10189_pl_hist1_idx3       
      on #pl_hist1 (pl_asof_date,      
                   pl_record_key,      
                   pl_owner_code)                                                             
      
   create nonclustered index xx10189_pl_hist2_idx1       
      on #pl_hist2 (pl_asof_date,      
                   pl_secondary_owner_key1,       
                   pl_secondary_owner_key2,      
                   pl_secondary_owner_key3,       
                   real_port_num)                                                             
      
   create nonclustered index xx10189_pl_hist2_idx2       
      on #pl_hist2 (pl_asof_date,      
                   pos_num)                                                             
      
   create nonclustered index xx10189_pl_hist2_idx3       
      on #pl_hist2 (pl_asof_date,      
                   pl_record_key,      
                   pl_owner_code)      
                                                                                                                                              
   create table #pl                                    
   (                                       
      pl_record_key          int,                                    
      pl_asof_date           datetime,                                    
      real_port_num          int,                                   
      cost_num               int NULL,                                    
      pos_num                int NULL,                                    
      pl_owner_code          char(8) NULL,                                    
      pl_owner               varchar(18) NULL,                                
      trade_key              varchar(92) NULL,             
      trade_num              int NULL,        
      order_num              int NULL,        
      item_num               int NULL,                               
      trade_cost_type        varchar(16) NULL,                                    
      pl_type_code           char(8) NULL,                                    
      pl_type_desc           varchar(20) NULL,                                    
      trade_type             varchar(9) NULL,                                    
      alloc_num              int NULL,                                    
      alloc_item_num         int NULL,                                    
      pl_amt                 float NULL,                                    
      contr_qty              float NULL,    
   sch_qty      float NULL,  
      open_qty      float NULL,     
      qty_uom                char(8) NULL,               
      price_uom              char(8) NULL,                      
      cmdty_short_name       varchar(15) NULL,                                    
      mkt_short_name         varchar(15) NULL,                                    
      trading_prd_desc       varchar(40) NULL,                                    
      trading_prd_date       datetime NULL,                                    
  pl_mkt_price           float NULL,                                    
      contr_date             datetime NULL,                                    
      trade_mod_date         datetime NULL,                                    
      avg_price              float NULL,                                    
      fx_rate                float NULL,                                    
      inhouse_ind            char(1) NULL,                   
      pl_realization_date    datetime NULL,                                    
      counterparty           nvarchar(80) NULL,          
      clearing_brkr          nvarchar(80) NULL,          
      price_curr_code        char(8) NULL,                                    
      alloc_creation_date    datetime NULL,                                    
      alloc_trans_id         int NULL,                                    
      cost_creation_date     datetime NULL,                                    
      cost_trans_id          int NULL,                                    
      trade_trans_id         int NULL,                                    
      pl_trans_id            int NULL,                                    
      creator_init           char(3) NULL,      
      trader_name            varchar(50) NULL ,    
      --inv_trans_price        int NULL,    
      --cross_port_trans_price  int NULL     
   )                                    
      
   create nonclustered index xx10189_pl_idx1       
      on #pl (pl_asof_date,      
              real_port_num)                                                             
                                  
   begin try                               
     insert into #pl_hist2         
       exec dbo.usp_PLCOMP_get_plhist_for_a_cob_date @cob_date2, @debugon                               
   end try      
   begin catch      
     set @smsg = '=> Failed to copy history records for a given COB DATE ''' + convert(varchar, @cob_date2, 101) + ''' to temp table due to the error:'      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @status = 1      
     goto endofsp            
   end catch      
      
   begin try                               
     insert into #pl_hist1         
       exec dbo.usp_PLCOMP_get_plhist_for_a_cob_date @cob_date1, @debugon                               
   end try      
   begin catch      
     set @smsg = '=> Failed to copy history records for a given COB DATE ''' + convert(varchar, @cob_date1, 101) + ''' to temp table due to the error:'      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @status = 1      
     goto endofsp            
   end catch      
                                                                                  
   begin try      
     insert into #pl                                     
       exec dbo.usp_PLCOMP_get_pl_details_for_a_cob_date @cob_date2, 0, @debugon                               
   end try      
   begin catch      
     set @smsg = '=> Failed to copy PL details for a given COB DATE ''' + convert(varchar, @cob_date2, 101) + ''' to temp table due to the error:'      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @status = 1      
     goto endofsp            
   end catch      
      
   begin try      
     insert into #pl                                     
       exec dbo.usp_PLCOMP_get_pl_details_for_a_cob_date @cob_date1, 1, @debugon                             
   end try      
   begin catch      
     set @smsg = '=> Failed to copy PL details for a given COB DATE ''' + convert(varchar, @cob_date1, 101) + ''' to temp table due to the error:'      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @status = 1      
     goto endofsp            
   end catch      
      
   set @time_started = (select convert(varchar, getdate(), 109))      
      
   begin try                                                                      
     update #pl                          
     set clearing_brkr = ac.acct_short_name        
     from #pl pl       
             join dbo.trade_item_fut tif with (nolock)      
                on pl.trade_num = tif.trade_num and       
                   pl.order_num = tif.order_num and       
                   pl.item_num = tif.item_num      
             join dbo.account ac with (nolock)         
                on ac.acct_num = tif.clr_brkr_num        
     set @rows_affected = @@rowcount      
   end try      
   begin catch      
     set @smsg = '=> Failed to update the clearing_brkr column in the #pl with the acct_short_name (trade_item_fut) due to the error:'      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @status = 1      
     goto endofsp            
   end catch      
   if @debugon = 1      
   begin      
     RAISERROR ('**********************', 0, 1) WITH NOWAIT          
     set @smsg = '=> ' + cast(@rows_affected as varchar) + ' #pl records were updated for the clearing_brkr column (trade_item_fut)!'      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @time_finished = (select convert(varchar, getdate(), 109))      
     set @smsg = '==> Started : ' + @time_started      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @smsg = '==> Finished: ' + @time_finished      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT           
   end      
      
   set @time_started = (select convert(varchar, getdate(), 109))      
         
   begin try                                                                      
     update #pl                          
     set clearing_brkr = ac.acct_short_name        
     from #pl pl       
             join dbo.trade_item_exch_opt exchopt with (nolock)      
                on pl.trade_num = exchopt.trade_num and       
                   pl.order_num = exchopt.order_num and       
                   pl.item_num = exchopt.item_num      
             join dbo.account ac with (nolock)         
                on ac.acct_num = exchopt.clr_brkr_num        
     set @rows_affected = @@rowcount      
   end try      
   begin catch      
     set @smsg = '=> Failed to update the clearing_brkr column in the #pl with the acct_short_name (trade_item_exch_opt) due to the error:'      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @status = 1      
     goto endofsp            
   end catch      
   if @debugon = 1      
   begin      
     RAISERROR ('**********************', 0, 1) WITH NOWAIT          
     set @smsg = '=> ' + cast(@rows_affected as varchar) + ' #pl records were updated for the clearing_brkr column (trade_item_exch_opt)!'      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @time_finished = (select convert(varchar, getdate(), 109))      
     set @smsg = '==> Started : ' + @time_started      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT      
     set @smsg = '==> Finished: ' + @time_finished      
     RAISERROR (@smsg, 0, 1) WITH NOWAIT           
   end      
            
   if object_id('tempdb..#pl_hist', 'U') is not null      
      exec('drop table tempdb..#pl_hist')      
            
   exec dbo.usp_PLCOMP_report_pl_delta @cob_date1, @cob_date2, @tag_xml_string, @debugon ,@show_transfer_prices   
          
endofsp:        
if object_id('tempdb..#pl', 'U') is not null      
   exec('drop table #pl')      
if object_id('tempdb..#pl_hist1', 'U') is not null      
   exec('drop table #pl_hist1')      
if object_id('tempdb..#pl_hist2', 'U') is not null      
   exec('drop table #pl_hist2')      
if object_id('tempdb..#children', 'U') is not null      
   exec('drop table #children')      
      
if @errcode > 0      
   return 2      
return @status   
GO
GRANT EXECUTE ON  [dbo].[usp_PLCOMP_pl_comparison_report] TO [next_usr]
GO
