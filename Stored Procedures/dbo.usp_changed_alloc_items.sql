SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_changed_alloc_items]
(    
   @port_num         int = null,    
   @port_group_name  varchar(50) = null,    
   @on_or_before     datetime = null,    
   @nth_previous     int = null,    
   @real_time_flag   char(1) = 'N',
   @debugon          bit = 0
)
as 
set nocount on   
declare @next_port_num     int,
        @errcode           int,
        @rows_affected     int,
        @status            int,
        @smsg              varchar(255)

   select @errcode = 0  
   create table #children(port_num int not null, port_type char(2) not null)    
   create table #selectedportfolios(port_num int not null)    
   create table #allportfolio(port_num int not null, port_type char(2) not null)    
   create clustered index xx0100_allport_idx1 
        on #allportfolio(port_num, port_type)

   create table #portpl 
   (    
      port_num          int not null,    
      pl_asof_date      datetime null
   )  
   create clustered index xx0100_portpl_idx1 
        on #portpl(port_num, pl_asof_date)
    
   create table #portfolio_recent_plasof 
   (    
      port_num          int not null,    
      last_asof_date    datetime not null,    
      last_trans_id     bigint null,    
      nthprev_asof_date datetime null,    
      nthprev_trans_id  bigint null
   )    
   create nonclustered index xx0101_port_recent_plasof_idx1 
        on #portfolio_recent_plasof(port_num, last_asof_date)
   create nonclustered index xx0101_port_recent_plasof_idx2 
        on #portfolio_recent_plasof(port_num, nthprev_asof_date)
   create nonclustered index xx0101_port_recent_plasof_idx3 
        on #portfolio_recent_plasof(last_trans_id)
    
   create table #allocationitems 
   (    
      change_type              varchar(100) null,    
      alloc_num                int null,    
      alloc_item_num           int null,    
      trade_num                int null,    
      order_num                int null,    
      item_num                 int null,    
      curr_pl_asof_date        datetime null,    
      prev_pl_asof_date        datetime null,    
      prev_sch_qty             numeric(20, 8) null,    
      curr_sch_qty             numeric(20, 8) null,    
      prev_nomin_qty           numeric(20, 8) null,    
      curr_nomin_qty           numeric(20, 8) null,    
      prev_actual_gross_qty    numeric(20, 8) null,    
      curr_actual_gross_qty    numeric(20, 8) null,    
      curr_contr_qty           numeric(20, 8) null,    
      curr_contr_qty_uom       char(4),    
      prev_contr_qty           numeric(20, 8) null,    
      prev_contr_qty_uom       char(4),    
      event_name               varchar(40) null,    
      prev_event_date          datetime null,    
      curr_event_date          datetime null,
      est_event_date           datetime null,
      prev_pricing_date_from   datetime null,    
      prev_pricing_date_to     datetime null,    
      curr_pricing_date_from   datetime null,    
      curr_pricing_date_to     datetime null,    
      change_date              datetime null,    
   -- Additional Fields requested for reporting purposes only    
      alloc_status             char(1) null,    
      alloc_creator            char(3) null,    
      trade_price              numeric(20, 8) null,    
      price_currency           char(8) null,    
      price_uom                char(4) null,    
      price_status             varchar(10) null,    
      trade_totsch_qty         numeric(20, 8) null,    
      trade_totsch_qty_uom     char(4),    
      trade_open_qty           numeric(20, 8) null,    
      trade_open_qty_uom       char(4) null,    
      port_num                 int null,    
      prev_sch_uom             char(4) null,    
      prev_nomin_uom           char(4) null,    
      prev_actual_gross_uom    char(4) null,     
      curr_sch_uom             char(4) null,    
      curr_nomin_uom           char(4) null,    
      curr_actual_gross_uom    char(4) null,     
      alloc_qty_status         varchar(15) null,    
      cmdty_short_name         varchar(15) null,    
      alloc_last_modifier      varchar(30) null,    
   -- Internal fields    
      curr_pl_trans_id         bigint null,    
      prev_pl_trans_id         bigint null    
   )    
   create nonclustered index xx0102_allocitems_idx1 
        on #allocationitems(alloc_num, alloc_item_num, trade_num, order_num, item_num)
   create nonclustered index xx0102_allocitems_idx2 
        on #allocationitems(trade_num, order_num, item_num, curr_pricing_date_from)
   create nonclustered index xx0102_allocitems_idx3 
        on #allocationitems(change_type)
   create nonclustered index xx0102_allocitems_idx4 
        on #allocationitems(alloc_num, alloc_item_num, change_type)
   
   if @port_num is null
      select @port_num = 0
      
   if @on_or_before is null
      select @on_or_before = getdate()
      
   if @nth_previous is null
      select @nth_previous = 1
      
   if @real_time_flag is null
      select @real_time_flag = 'N'

   if @port_num = 0
   begin
      if (@port_group_name is null or len(rtrim(ltrim(@port_group_name))) = 0) 
      begin
         print 'You must give a value to the argument @port_group_name when you did not'
         print 'give a non-zero positive value for the argument @port_num!'
         goto result
      end   
   end
      
   if @debugon = 1
   begin
      print 'usp_changed_alloc_items (DEBUG): Argument values'
      select @smsg = '   @port_num       : ' + convert(varchar, @port_num)    
      print @smsg
      select @smsg = '   @port_group_name: ' + isnull(@port_group_name, 'NULL')    
      print @smsg
      select @smsg = '   @on_or_before   : ' + convert(varchar, @on_or_before, 101)
      print @smsg
      select @smsg = '   @nth_previous   : ' + convert(varchar, @nth_previous)
      print @smsg      
      select @smsg = '   @real_time_flag : ' + isnull(@real_time_flag, 'N')
      print @smsg    
      print ' '  
   end
    
   if @port_num > 0   
   begin    
      if @debugon = 1
      begin
         print '***************'
         select @smsg = 'usp_changed_alloc_items - Debug 1: Getting REAL port_nums for the part_num #' + convert(varchar, @port_num) + ' ... '
         print @smsg
         select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
         print @smsg
      end

      insert into #selectedportfolios (port_num)     
      select @port_num 

      exec dbo.usp_port_list_children 'R', 0    
      insert into #allportfolio select * from #children  

      if @debugon = 1
      begin
         select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
         print @smsg
         print ' '
      end   
   end    
   else if (@port_group_name is not null and len(rtrim(ltrim(@port_group_name))) > 0)    
   begin    
      if @debugon = 1
      begin
         print '***************'
         select @smsg = 'usp_changed_alloc_items - Debug 2: Getting REAL port_nums from the portfolio_tag table for group ''' + @port_group_name + ''' ... '
         print @smsg
         select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
         print @smsg
      end      

      insert into #selectedportfolios (port_num)     
      select distinct port_num 
      from dbo.portfolio_tag 
      where tag_name = 'GROUP' and 
            tag_value = @port_group_name   

      exec dbo.usp_port_list_children 'R', 0    
         
      insert into #allportfolio 
      select * from #children
  
      if @debugon = 1
      begin
         select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
         print @smsg
         print ' '
      end   
   end    

   -- If no REAl PORTFOLIOs found, then exit here immediately
   if (select count(*) from #allportfolio) = 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): No real portfolios found'        
      goto result
   end
              
   exec @status = dbo.usp_port_recent_plasof @on_or_before, @nth_previous, @debugon
   if @status > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred in usp_port_recent_plasof!'        
      goto result
   end
             
   if (@real_time_flag = 'Y')    
   begin    
      if @debugon = 1
      begin
         print '***************'
         select @smsg = 'usp_changed_alloc_items - Debug 3: Updating last_trans_id in the #portfolio_recent_plasof table ... '
         print @smsg
         select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
         print @smsg
      end      
      update #portfolio_recent_plasof    
      set last_trans_id = (select max(trans_id) 
                           from dbo.icts_transaction)  
      select @errcode = @@error
      if @errcode > 0
      begin
         if @debugon = 1
            print 'usp_changed_alloc_items (DEBUG): Error occurred while updating last_trans_id in the #portfolio_recent_plasof table!'        
         goto result
      end      
      if @debugon = 1
      begin
         select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
         print @smsg
         print ' '
      end   
   end     
   
   -- Query to find Trades/Allocations with no deemed event dates
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_changed_alloc_items - Debug 4: Finding trades with no deemed event dates ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end     

      insert into #allocationitems     
       (alloc_num, alloc_item_num, trade_num, order_num, item_num, curr_pl_trans_id,
        prev_pl_trans_id ,curr_pl_asof_date, prev_pl_asof_date, prev_sch_qty,
        curr_sch_qty, prev_nomin_qty, curr_nomin_qty, prev_actual_gross_qty,
        curr_actual_gross_qty, change_date, change_type, alloc_status, alloc_creator, 
        trade_price, price_currency, price_uom, price_status, curr_contr_qty,
        curr_contr_qty_uom, prev_contr_qty, prev_contr_qty_uom,
	      trade_totsch_qty,trade_totsch_qty_uom,trade_open_qty,
        trade_open_qty_uom, port_num, prev_sch_uom, prev_nomin_uom, prev_actual_gross_uom, 
        curr_sch_uom, curr_nomin_uom, curr_actual_gross_uom, alloc_qty_status, 
        cmdty_short_name, alloc_last_modifier, event_name, est_event_date)    
   select ai.alloc_num, 
          ai.alloc_item_num, 
          ti.trade_num, 
          ti.order_num, 
          ti.item_num,      
          plasof.last_trans_id, 
          plasof.nthprev_trans_id,
          plasof.last_asof_date, 
          plasof.nthprev_asof_date,    
          audai.sch_qty, 
          ai.sch_qty, 
          audai.nomin_qty_max, 
          ai.nomin_qty_max, 
          audai.actual_gross_qty,    
          ai.actual_gross_qty,    
          it.tran_date change_date, 
	        case when ai.alloc_num is null then 'Trade with no deemed event date' 
	             else 'Allocation with no deemed event date' 
	        end change_type,    
          case when al.alloc_status is not null then al.alloc_status
	             else 'U'
	        end alloc_status, 
	        al.sch_init, 
          ti.avg_price, 
          ti.price_curr_code, 
          ti.price_uom_code,     
          case when ti.estimate_ind = 'Y' then 'Estimated' 
               else 'Actual' 
          end price_status,    
          ti.contr_qty, 
          ti.contr_qty_uom_code,
          audti.contr_qty, 
          audti.contr_qty_uom_code,
          ti.total_sch_qty, 
          ti.sch_qty_uom_code, 
          ti.open_qty, 
          ti.open_qty_uom_code,    
          ti.real_port_num, 
          null prev_sch_uom, 
          null prev_nomin_uom, 
          null prev_actual_gross_uom, 
          ai.sch_qty_uom_code, 
          ai.nomin_qty_max_uom_code, 
          ai.actual_gross_uom_code,    
          case when ai.alloc_num is null then 'Unallocated'
	             when ai.fully_actualized = 'Y' then 'Actual' 
               else 'Estimated' 
          end alloc_qty_status,    
          c.cmdty_short_name, 
          it.user_init,
          case when ept.event_include_ind = 'Y' then 'DEEMED' 
               else ept.event_name 
          end event_name,
	        ept.deemed_event_date est_event_date
	from dbo.trade_item ti
        join dbo.commodity c on ti.cmdty_code = c.cmdty_code    
	      join dbo.trade_formula tf on ti.trade_num = tf.trade_num and 
                                     ti.order_num = tf.order_num and 
                                     ti.item_num = tf.item_num    
        join dbo.formula f on tf.formula_num = f.formula_num
	      join dbo.event_price_term ept on f.formula_num = ept.formula_num    
        join #portfolio_recent_plasof plasof on ti.real_port_num = plasof.port_num 
        join dbo.icts_transaction it on ti.trans_id = it.trans_id    
	      left join dbo.allocation_item ai on ti.trade_num = ai.trade_num and
					                                  ti.order_num = ai.order_num and
					                                  ti.item_num = ai.item_num   
        left join dbo.allocation_item_transport ait on ai.alloc_num = ait.alloc_num and 
                                                       ai.alloc_item_num = ait.alloc_item_num    
        left join dbo.allocation al on ai.alloc_num = al.alloc_num    
        left join dbo.ai_est_actual aea on ai.alloc_num = aea.alloc_num and 
                                           ai.alloc_item_num = aea.alloc_item_num and 
                                           aea.ai_est_actual_num > 0
      	left join dbo.aud_trade_item audti on ti.trade_num = audti.trade_num and 
                                              ti.order_num = audti.order_num and 
                                              ti.item_num = audti.item_num and 
                                              audti.trans_id < plasof.nthprev_trans_id and 
                                              audti.resp_trans_id >= plasof.nthprev_trans_id    
      	left join dbo.aud_allocation_item audai on ai.alloc_num = audai.alloc_num and 
                                                   ai.alloc_item_num = audai.alloc_item_num and 
                                                   audai.trans_id < plasof.nthprev_trans_id and 
                                                   audai.resp_trans_id >= plasof.nthprev_trans_id    
   where f.formula_type = 'E' and 
         ((ept.event_include_ind = 'Y' and ept.deemed_event_date is null) or
	        (ept.event_include_ind = 'N' and ept.event_name = 'B/L' and ait.bl_date is null) or
	        (ept.event_include_ind = 'N' and ept.event_name = 'NOR' and ait.nor_date is null) or
          (ept.event_include_ind = 'N' and ept.event_name = 'COD' and ait.disch_cmnc_date is null) or    
          (ept.event_include_ind = 'N' and ept.event_name = 'CMPL' and ait.load_compl_date is null) or    
          (ept.event_include_ind = 'N' and ept.event_name = 'CMPD' and ait.disch_compl_date is null) or    
          (ept.event_include_ind = 'N' and ept.event_name = 'OTHER' and ai.title_tran_date is null) or    
          (ept.event_include_ind = 'N' and ept.event_name = 'ACTUAL' and aea.ai_est_actual_date is null))  
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while filling the #allocationitems table (trades with no deemed event dates)!'        
      goto result
   end   
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end   

   -- Query to find newly entered event dates between two pass runs    
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_changed_alloc_items - Debug 5: Finding newly entered event dates between 2 pass runs ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end
   insert into #allocationitems     
        (alloc_num, alloc_item_num, trade_num, order_num, item_num, curr_pl_trans_id,
         prev_pl_trans_id ,curr_pl_asof_date, prev_pl_asof_date, event_name, prev_event_date, 
         curr_event_date, prev_sch_qty, curr_sch_qty, prev_nomin_qty, curr_nomin_qty, 
	       prev_actual_gross_qty, curr_actual_gross_qty, 
	       change_date, change_type, alloc_status, alloc_creator, trade_price, 
         price_currency, price_uom, price_status, curr_contr_qty,
         curr_contr_qty_uom, prev_contr_qty, prev_contr_qty_uom,
         trade_totsch_qty, trade_totsch_qty_uom, trade_open_qty, trade_open_qty_uom,    
         port_num, prev_sch_uom, prev_nomin_uom, prev_actual_gross_uom, curr_sch_uom, 
         curr_nomin_uom, curr_actual_gross_uom, alloc_qty_status, cmdty_short_name, 
         alloc_last_modifier)    
   select ai.alloc_num, 
          ai.alloc_item_num, 
          ti.trade_num, 
          ti.order_num, 
          ti.item_num,      
          plasof.last_trans_id, 
          plasof.nthprev_trans_id,
          plasof.last_asof_date, 
          plasof.nthprev_asof_date,    
          case when ept.event_include_ind = 'Y' then 'DEEMED'    
               else ept.event_name    
          end event_name,    
          case when audept.event_include_ind = 'Y' then audept.deemed_event_date    
               when ept.event_name = 'B/L' then audait.bl_date    
               when ept.event_name = 'NOR' then audait.nor_date      
               when ept.event_name = 'COD' then audait.disch_cmnc_date    
               when ept.event_name = 'CMPL' then audait.load_compl_date    
               when ept.event_name = 'CMPD' then audait.disch_compl_date    
               when ept.event_name = 'OTHER' then audai.title_tran_date    
               when ept.event_name = 'ACTUAL' then audaea.ai_est_actual_date    
               else null    
          end as prev_event_date,    
          case when ept.event_include_ind = 'Y' then ept.deemed_event_date    
               when ept.event_name = 'B/L' then ait.bl_date    
               when ept.event_name = 'NOR' then ait.nor_date      
               when ept.event_name = 'COD' then ait.disch_cmnc_date    
               when ept.event_name = 'CMPL' then ait.load_compl_date    
               when ept.event_name = 'CMPD' then ait.disch_compl_date    
               when ept.event_name = 'OTHER' then ai.title_tran_date    
               when ept.event_name = 'ACTUAL' then aea.ai_est_actual_date    
               else null    
          end as curr_event_date,
          audai.sch_qty prev_sch_qty, 
          ai.sch_qty, 
          audai.nomin_qty_max prev_nomin_qty, 
          ai.nomin_qty_max, 
          audai.actual_gross_qty prev_actual_gross_qty, 
          ai.actual_gross_qty,
          case when ept.event_include_ind = 'Y' then itept.tran_date    
               when ept.event_name = 'B/L' then itait.tran_date    
               when ept.event_name = 'NOR' then itait.tran_date    
               when ept.event_name = 'COD' then itait.tran_date    
               when ept.event_name = 'CMPL' then itait.tran_date    
               when ept.event_name = 'CMPD' then itait.tran_date    
               when ept.event_name = 'OTHER' then itai.tran_date    
               when ept.event_name = 'ACTUAL' then itaea.tran_date    
               else null    
          end as change_date,    
          'New Event Date' change_type,    
          case when al.alloc_status is not null then al.alloc_status
	             else 'U'
	        end alloc_status, 
          al.sch_init, 
          ti.avg_price, 
          ti.price_curr_code, 
          ti.price_uom_code,     
          case when ti.estimate_ind = 'Y' then 'Estimated' 
               else 'Actual' 
          end price_status,    
          ti.contr_qty, 
          ti.contr_qty_uom_code, 
          audti.contr_qty, 
          audti.contr_qty_uom_code, 
          ti.total_sch_qty, 
          ti.sch_qty_uom_code, 
          ti.open_qty, 
          ti.open_qty_uom_code,    
          ti.real_port_num, 
          audai.sch_qty_uom_code, 
          audai.nomin_qty_max_uom_code, 
          audai.actual_gross_uom_code,    
          ai.sch_qty_uom_code, 
          ai.nomin_qty_max_uom_code, 
          ai.actual_gross_uom_code,    
          case when ai.fully_actualized = 'Y' then 'Actual' 
               else 'Estimated' 
          end alloc_qty_status,    
          c.cmdty_short_name,     
          case when ept.event_include_ind = 'Y' then itept.user_init    
               when ept.event_name = 'B/L' then itait.user_init    
               when ept.event_name = 'NOR' then itait.user_init    
               when ept.event_name = 'COD' then itait.user_init    
               when ept.event_name = 'CMPL' then itait.user_init    
               when ept.event_name = 'CMPD' then itait.user_init    
               when ept.event_name = 'OTHER' then itai.user_init    
               when ept.event_name = 'ACTUAL' then itaea.user_init    
               else null    
          end as user_init    
   from dbo.trade_item ti     
           join dbo.commodity c on ti.cmdty_code = c.cmdty_code    
           join dbo.trade_formula tf on ti.trade_num = tf.trade_num and 
                                        ti.order_num = tf.order_num and 
                                        ti.item_num = tf.item_num    
           join dbo.formula f on tf.formula_num = f.formula_num    
           join dbo.event_price_term ept on f.formula_num = ept.formula_num     
           join #portfolio_recent_plasof plasof on ti.real_port_num = plasof.port_num    
           left join dbo.allocation_item ai on ti.trade_num = ai.trade_num and 
                                               ti.order_num = ai.order_num and 
                                               ti.item_num = ai.item_num    
           left join dbo.allocation al on ai.alloc_num = al.alloc_num    
           left join dbo.allocation_item_transport ait on ai.alloc_num = ait.alloc_num and 
                                                          ai.alloc_item_num = ait.alloc_item_num    
           left join dbo.ai_est_actual aea on ai.alloc_num = aea.alloc_num and 
                                              ai.alloc_item_num = aea.alloc_item_num and 
                                              aea.ai_est_actual_num > 0    
           left join dbo.aud_ai_est_actual audaea on audaea.alloc_num = aea.alloc_num and 
                                                     audaea.alloc_item_num = audaea.alloc_item_num and 
                                                     audaea.ai_est_actual_num = aea.ai_est_actual_num and 
                                                     audaea.trans_id < plasof.nthprev_trans_id and 
                                                     audaea.resp_trans_id >= plasof.nthprev_trans_id     
           left join dbo.aud_trade_item audti on ti.trade_num = audti.trade_num and 
                                        		     ti.order_num = audti.order_num and 
                                        		     ti.item_num = audti.item_num and
                                                 audti.trans_id < plasof.nthprev_trans_id and 
                                                 audti.resp_trans_id >= plasof.nthprev_trans_id    
           left join dbo.aud_allocation_item audai on ai.alloc_num = audai.alloc_num and 
                                                      ai.alloc_item_num = audai.alloc_item_num and 
                                                      audai.trans_id < plasof.nthprev_trans_id and 
                                                      audai.resp_trans_id >= plasof.nthprev_trans_id    
           left join dbo.aud_allocation_item_transport audait on ait.alloc_num = audait.alloc_num and 
                                                                 ait.alloc_item_num = audait.alloc_item_num and 
                                                                 audait.trans_id < plasof.nthprev_trans_id and 
                                                                 audait.resp_trans_id >= plasof.nthprev_trans_id    
           left join dbo.aud_event_price_term audept on ept.formula_num = audept.formula_num and 
                                                        ept.price_term_num = audept.price_term_num and 
                                                        audept.trans_id < plasof.nthprev_trans_id and 
                                                        audept.resp_trans_id >= plasof.nthprev_trans_id    
           left join dbo.icts_transaction itai on ai.trans_id = itai.trans_id    
           left join dbo.icts_transaction itait on ait.trans_id = itait.trans_id    
           left join dbo.icts_transaction itept on ept.trans_id = itept.trans_id    
           left join dbo.icts_transaction itaea on aea.trans_id = itaea.trans_id        
   where f.formula_type = 'E' and     
         ( (ept.event_include_ind = 'Y' and ept.deemed_event_date is not null and audept.deemed_event_date is null) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'B/L' and ait.bl_date is not null and audait.bl_date is null) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'NOR' and ait.nor_date is not null and audait.nor_date is null) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'COD' and ait.disch_cmnc_date is not null and audait.disch_cmnc_date is null) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'CMPL' and ait.load_compl_date is not null and audait.load_compl_date is null) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'CMPD' and ait.disch_compl_date is not null and audait.disch_compl_date is null) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'OTHER' and ai.title_tran_date is not null and audai.title_tran_date is null) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'ACTUAL' and aea.ai_est_actual_date is not null and audaea.ai_est_actual_date is null)    
         ) and     
         (ai.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id or    
          ait.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id or    
          ept.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id or    
          aea.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id)    
    
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while filling the #allocationitems table (newly created)!'        
      goto result
   end   
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end   

   -- Query to find modified trade/allocation items whose event date has changed between last two pass runs    
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_changed_alloc_items - Debug 6: Finding modified trade/allocation items whose event date has changed between last 2 pass runs ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 
   insert into #allocationitems     
        (alloc_num, alloc_item_num, trade_num, order_num, item_num, curr_pl_trans_id,
         prev_pl_trans_id ,curr_pl_asof_date, prev_pl_asof_date, event_name, prev_event_date, 
         curr_event_date, change_date, change_type, alloc_status, alloc_creator, trade_price, 
         price_currency, price_uom, price_status, 
         trade_totsch_qty, trade_totsch_qty_uom, trade_open_qty, trade_open_qty_uom,    
         port_num, prev_sch_uom, prev_nomin_uom, prev_actual_gross_uom, curr_sch_uom, 
         curr_nomin_uom, curr_actual_gross_uom, alloc_qty_status, cmdty_short_name, 
         alloc_last_modifier)    
   select ai.alloc_num, 
          ai.alloc_item_num, 
          ti.trade_num, 
          ti.order_num, 
          ti.item_num,      
          plasof.last_trans_id, 
          plasof.nthprev_trans_id,
          plasof.last_asof_date, 
          plasof.nthprev_asof_date,    
          case when ept.event_include_ind = 'Y' then 'DEEMED'    
               else ept.event_name    
          end event_name,    
          case when audept.event_include_ind = 'Y' then audept.deemed_event_date    
               when ept.event_name = 'B/L' then audait.bl_date    
               when ept.event_name = 'NOR' then audait.nor_date      
               when ept.event_name = 'COD' then audait.disch_cmnc_date    
               when ept.event_name = 'CMPL' then audait.load_compl_date    
               when ept.event_name = 'CMPD' then audait.disch_compl_date    
               when ept.event_name = 'OTHER' then audai.title_tran_date    
               when ept.event_name = 'ACTUAL' then audaea.ai_est_actual_date    
               else null    
          end as prev_event_date,    
          case when ept.event_include_ind = 'Y' then ept.deemed_event_date    
               when ept.event_name = 'B/L' then ait.bl_date    
               when ept.event_name = 'NOR' then ait.nor_date      
               when ept.event_name = 'COD' then ait.disch_cmnc_date    
               when ept.event_name = 'CMPL' then ait.load_compl_date    
               when ept.event_name = 'CMPD' then ait.disch_compl_date    
               when ept.event_name = 'OTHER' then ai.title_tran_date    
               when ept.event_name = 'ACTUAL' then aea.ai_est_actual_date    
               else null    
          end as curr_event_date,    
          case when ept.event_include_ind = 'Y' then itept.tran_date    
               when ept.event_name = 'B/L' then itait.tran_date    
               when ept.event_name = 'NOR' then itait.tran_date    
               when ept.event_name = 'COD' then itait.tran_date    
               when ept.event_name = 'CMPL' then itait.tran_date    
               when ept.event_name = 'CMPD' then itait.tran_date    
               when ept.event_name = 'OTHER' then itai.tran_date    
               when ept.event_name = 'ACTUAL' then itaea.tran_date    
               else null    
          end as change_date,    
          'Event Date change' change_type,    
          case when al.alloc_status is not null then al.alloc_status
	             else 'U'
	        end alloc_status, 
          al.sch_init, 
          ti.avg_price, 
          ti.price_curr_code, 
          ti.price_uom_code,     
          case when ti.estimate_ind = 'Y' then 'Estimated' 
               else 'Actual' 
          end price_status,    
          ti.total_sch_qty, 
          ti.sch_qty_uom_code, 
          ti.open_qty, 
          ti.open_qty_uom_code,    
          ti.real_port_num, 
          null, 
          null, 
          null, 
          ai.sch_qty_uom_code, 
          ai.nomin_qty_max_uom_code, 
          ai.actual_gross_uom_code,    
          case when ai.fully_actualized = 'Y' then 'Actual' 
               else 'Estimated' 
          end alloc_qty_status,    
          c.cmdty_short_name,     
          case when ept.event_include_ind = 'Y' then itept.user_init    
               when ept.event_name = 'B/L' then itait.user_init    
               when ept.event_name = 'NOR' then itait.user_init    
               when ept.event_name = 'COD' then itait.user_init    
               when ept.event_name = 'CMPL' then itait.user_init    
               when ept.event_name = 'CMPD' then itait.user_init    
               when ept.event_name = 'OTHER' then itai.user_init    
               when ept.event_name = 'ACTUAL' then itaea.user_init    
               else null    
          end as user_init    
   from dbo.trade_item ti     
           join dbo.commodity c on ti.cmdty_code = c.cmdty_code    
           join dbo.trade_formula tf on ti.trade_num = tf.trade_num and 
                                        ti.order_num = tf.order_num and 
                                        ti.item_num = tf.item_num    
           join dbo.formula f on tf.formula_num = f.formula_num    
           join dbo.event_price_term ept on f.formula_num = ept.formula_num     
           join #portfolio_recent_plasof plasof on ti.real_port_num = plasof.port_num    
           left join dbo.allocation_item ai on ti.trade_num = ai.trade_num and 
                                               ti.order_num = ai.order_num and 
                                               ti.item_num = ai.item_num    
           left join dbo.allocation al on ai.alloc_num = al.alloc_num    
           left join dbo.allocation_item_transport ait on ai.alloc_num = ait.alloc_num and 
                                                          ai.alloc_item_num = ait.alloc_item_num    
           left join dbo.ai_est_actual aea on ai.alloc_num = aea.alloc_num and 
                                              ai.alloc_item_num = aea.alloc_item_num and 
                                              aea.ai_est_actual_num > 0    
           left join dbo.aud_ai_est_actual audaea on audaea.alloc_num = aea.alloc_num and 
                                                     audaea.alloc_item_num = audaea.alloc_item_num and 
                                                     audaea.ai_est_actual_num = aea.ai_est_actual_num and 
                                                     audaea.trans_id < plasof.nthprev_trans_id and 
                                                     audaea.resp_trans_id >= plasof.nthprev_trans_id     
           left join dbo.aud_allocation_item audai on ai.alloc_num = audai.alloc_num and 
                                                      ai.alloc_item_num = audai.alloc_item_num and 
                                                      audai.trans_id < plasof.nthprev_trans_id and 
                                                      audai.resp_trans_id >= plasof.nthprev_trans_id    
           left join dbo.aud_allocation_item_transport audait on ait.alloc_num = audait.alloc_num and 
                                                                 ait.alloc_item_num = audait.alloc_item_num and 
                                                                 audait.trans_id < plasof.nthprev_trans_id and 
                                                                 audait.resp_trans_id >= plasof.nthprev_trans_id    
           left join dbo.aud_event_price_term audept on ept.formula_num = audept.formula_num and 
                                                        ept.price_term_num = audept.price_term_num and 
                                                        audept.trans_id < plasof.nthprev_trans_id and 
                                                        audept.resp_trans_id >= plasof.nthprev_trans_id    
           left join dbo.icts_transaction itai on audai.resp_trans_id = itai.trans_id    
           left join dbo.icts_transaction itait on audait.resp_trans_id = itait.trans_id    
           left join dbo.icts_transaction itept on audept.resp_trans_id = itept.trans_id    
           left join dbo.icts_transaction itaea on audaea.resp_trans_id = itaea.trans_id        
   where f.formula_type = 'E' and     
         ( (ept.event_include_ind != audept.event_include_ind) or    
           (ept.event_include_ind = 'Y' and ept.deemed_event_date != audept.deemed_event_date) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'B/L' and ait.bl_date != audait.bl_date) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'NOR' and ait.nor_date != audait.nor_date) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'COD' and ait.disch_cmnc_date != audait.disch_cmnc_date) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'CMPL' and ait.load_compl_date != audait.load_compl_date) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'CMPD' and ait.disch_compl_date != audait.disch_compl_date) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'OTHER' and ai.title_tran_date != audai.title_tran_date) or    
           (ept.event_include_ind = 'N' and ept.event_name = 'ACTUAL' and aea.ai_est_actual_date != audaea.ai_est_actual_date)    
         ) and     
         (ai.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id or    
          ait.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id or    
          ept.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id or    
          aea.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id)    
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while filling the #allocationitems table (event date changed)!'        
      goto result
   end 
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end  
       
   -- Query to find modified trade, allocation items whose quantity has changed between last two pass runs    
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_changed_alloc_items - Debug 7: Finding modified trade, alloc items whose quantity has changed between last 2 pass runs ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end   
   insert into #allocationitems     
        (alloc_num, alloc_item_num, trade_num, order_num, item_num, curr_pl_trans_id,
         prev_pl_trans_id, curr_pl_asof_date, prev_pl_asof_date, prev_sch_qty, curr_sch_qty,
         prev_nomin_qty, curr_nomin_qty, prev_actual_gross_qty, curr_actual_gross_qty,    
         change_date, change_type, alloc_status, alloc_creator, trade_price, price_currency, 
         price_uom, price_status, prev_contr_qty,prev_contr_qty_uom,
	       curr_contr_qty,curr_contr_qty_uom,
         trade_totsch_qty, trade_totsch_qty_uom, trade_open_qty, trade_open_qty_uom,    
         port_num, prev_sch_uom, prev_nomin_uom, prev_actual_gross_uom, curr_sch_uom, curr_nomin_uom,     
         curr_actual_gross_uom, alloc_qty_status, cmdty_short_name, alloc_last_modifier)    
   select ai.alloc_num, 
          ai.alloc_item_num, 
          ti.trade_num, 
          ti.order_num, 
          ti.item_num,      
          plasof.last_trans_id, 
          plasof.nthprev_trans_id, 
          plasof.last_asof_date, 
          plasof.nthprev_asof_date,    
          case when audai.sch_qty is not null then audai.sch_qty
		           else ai.sch_qty 
		      end,
	        ai.sch_qty, 
          case when audai.nomin_qty_max is not null then audai.nomin_qty_max
		           else ai.nomin_qty_max 
		      end, 
          ai.nomin_qty_max, 
          case when audai.actual_gross_qty is not null then audai.actual_gross_qty
		           else ai.actual_gross_qty 
		      end, 
          ai.actual_gross_qty,
	        case when audti.contr_qty is not null and audti.contr_qty != ti.contr_qty then itti.tran_date
		           else itai.tran_date 
		      end change_date,    
	        case when audti.contr_qty is not null and audti.contr_qty != ti.contr_qty then 'Contract Quantity Change'  
	             else 'Allocation Quantity Change' 
	        end change_type,    
          case when al.alloc_status is not null then al.alloc_status
	             else 'U'
	        end alloc_status, 
          al.sch_init, 
          ti.avg_price, 
          ti.price_curr_code, 
          ti.price_uom_code,     
          case when ti.estimate_ind = 'Y' then 'Estimated' 
               else 'Actual' 
          end price_status,    
          case when audti.contr_qty is not null then audti.contr_qty
		           else ti.contr_qty 
		      end, 
          case when audti.contr_qty_uom_code is not null then audti.contr_qty_uom_code
		           else ti.contr_qty_uom_code 
		      end, 
          ti.contr_qty, 
          ti.contr_qty_uom_code, 
          ti.total_sch_qty, 
          ti.sch_qty_uom_code, 
          ti.open_qty, 
          ti.open_qty_uom_code,    
          ti.real_port_num, 
          case when audai.sch_qty_uom_code is not null then audai.sch_qty_uom_code
		           else ai.sch_qty_uom_code 
		      end, 
          case when audai.nomin_qty_max_uom_code is not null then audai.nomin_qty_max_uom_code
		           else ai.nomin_qty_max_uom_code 
		      end, 
          case when audai.actual_gross_uom_code is not null then audai.actual_gross_uom_code
		           else ai.actual_gross_uom_code 
		      end, 
          ai.sch_qty_uom_code, 
          ai.nomin_qty_max_uom_code, 
          ai.actual_gross_uom_code,    
          case when ai.fully_actualized = 'Y' then 'Actual' 
               else 'Estimated' 
          end alloc_qty_status,    
          c.cmdty_short_name, 
	        case when audti.contr_qty is not null and audti.contr_qty != ti.contr_qty then itti.user_init
		           else itai.user_init 
		      end user_init    
   from dbo.trade_item ti
           join dbo.commodity c on ti.cmdty_code = c.cmdty_code    
           join dbo.trade_formula tf on ti.trade_num = tf.trade_num and 
                                        ti.order_num = tf.order_num and 
                                        ti.item_num = tf.item_num    
           join dbo.formula f on tf.formula_num = f.formula_num    
           join #portfolio_recent_plasof plasof on ti.real_port_num = plasof.port_num    
	         left join dbo.allocation_item ai on ti.trade_num = ai.trade_num and
					                                     ti.order_num = ai.order_num and
					                                     ti.item_num = ai.item_num 
           left join dbo.allocation al on ai.alloc_num = al.alloc_num    
           left join dbo.aud_trade_item audti on audti.trade_num = ti.trade_num and 
                                                 audti.order_num = ti.order_num and 
                                                 audti.item_num = ti.item_num and   
                                                 audti.trans_id < plasof.nthprev_trans_id  and 
                                                 audti.resp_trans_id >= plasof.nthprev_trans_id    
           left join dbo.aud_allocation_item audai on ai.alloc_num = audai.alloc_num and 
                                                      ai.alloc_item_num = audai.alloc_item_num and 
                                                      audai.trans_id < plasof.nthprev_trans_id  and 
                                                      audai.resp_trans_id >= plasof.nthprev_trans_id    
           left join dbo.icts_transaction itai on audai.resp_trans_id = itai.trans_id
	         left join dbo.icts_transaction itti on audti.resp_trans_id = itti.trans_id    
   where f.formula_type = 'E' and 
         ( (audai.sch_qty is not null and ai.sch_qty != audai.sch_qty and 
            ai.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id) or    
           (audai.nomin_qty_max is not null and ai.nomin_qty_max != audai.nomin_qty_max and 
            ai.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id) or    
           (audai.actual_gross_qty is not null and ai.actual_gross_qty != audai.actual_gross_qty and 
            ai.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id) or
           (audti.contr_qty is not null and ti.contr_qty != audti.contr_qty and 
            ti.trans_id between plasof.nthprev_trans_id and plasof.last_trans_id) )             
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while filling the #allocationitems table (qty changed)!'        
      goto result
   end 
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end   
          
   -- Event date for modified allocation items whose quantity changed    
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_changed_alloc_items - Debug 8: Updating event_date info for modified allocation items whose quantity changeds ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 
   update #allocationitems    
   set prev_event_date = 
          case when audept.event_include_ind = 'Y' then audept.deemed_event_date    
               when ept.event_name = 'B/L' then audait.bl_date    
               when ept.event_name = 'NOR' then audait.nor_date      
               when ept.event_name = 'COD' then audait.disch_cmnc_date    
               when ept.event_name = 'CMPL' then audait.load_compl_date    
               when ept.event_name = 'CMPD' then audait.disch_compl_date    
               when ept.event_name = 'OTHER' then audai.title_tran_date    
               when ept.event_name = 'ACTUAL' then audaea.ai_est_actual_date    
               else null    
          end,    
       curr_event_date = 
          case when ept.event_include_ind = 'Y' then ept.deemed_event_date    
               when ept.event_name = 'B/L' then ait.bl_date    
               when ept.event_name = 'NOR' then ait.nor_date      
               when ept.event_name = 'COD' then ait.disch_cmnc_date    
               when ept.event_name = 'CMPL' then ait.load_compl_date    
               when ept.event_name = 'CMPD' then ait.disch_compl_date    
               when ept.event_name = 'OTHER' then ai.title_tran_date    
               when ept.event_name = 'ACTUAL' then aea.ai_est_actual_date    
               else null    
          end,    
       event_name = 
          case when ept.event_include_ind = 'Y' then 'DEEMED' 
               else ept.event_name 
          end    
   from #allocationitems tai    
           join dbo.trade_formula tf on tai.trade_num = tf.trade_num and 
                                        tai.order_num = tf.order_num and 
                                        tai.item_num = tf.item_num    
           join dbo.formula f on tf.formula_num = f.formula_num and 
                                 f.formula_type = 'E'    
           join dbo.event_price_term ept on f.formula_num = ept.formula_num     
           left join dbo.allocation_item ai on tai.alloc_num = ai.alloc_num and 
                                               tai.alloc_item_num = ai.alloc_item_num    
           left join dbo.allocation_item_transport ait on tai.alloc_num = ait.alloc_num and 
                                                          tai.alloc_item_num = ait.alloc_item_num    
           left join dbo.ai_est_actual aea on ai.alloc_num = aea.alloc_num and 
                                              ai.alloc_item_num = aea.alloc_item_num and 
                                              aea.ai_est_actual_num > 0    
           left join dbo.aud_ai_est_actual audaea on audaea.alloc_num = aea.alloc_num and 
                                                     audaea.alloc_item_num = audaea.alloc_item_num and 
                                                     audaea.ai_est_actual_num = aea.ai_est_actual_num and 
                                                     audaea.trans_id < prev_pl_trans_id  and 
                                                     audaea.resp_trans_id >= prev_pl_trans_id    
           left join dbo.aud_allocation_item audai on ai.alloc_num = audai.alloc_num and 
                                                      ai.alloc_item_num = audai.alloc_item_num and 
                                                      audai.trans_id < prev_pl_trans_id and 
                                                      audai.resp_trans_id >= prev_pl_trans_id    
           left join dbo.aud_allocation_item_transport audait on ait.alloc_num = audait.alloc_num and 
                                                                 ait.alloc_item_num = audait.alloc_item_num and 
                                                                 audait.trans_id < prev_pl_trans_id and 
                                                                 audait.resp_trans_id >= prev_pl_trans_id    
           left join dbo.aud_event_price_term audept on ept.formula_num = audept.formula_num and 
                                                        ept.price_term_num = audept.price_term_num and 
                                                        audept.trans_id < prev_pl_trans_id and 
                                                        audept.resp_trans_id >= prev_pl_trans_id    
   where tai.change_type in ('Contract Quantity Change', 'Allocation Quantity Change')
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while updating event info in the #allocationitems table (qty being changed)!'        
      goto result
   end 
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end 
           
   -- If we didn't find a matching audit record for the previous event date, 
   -- it means that the event date hasn't changed.    
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_changed_alloc_items - Debug 9: Setting prev_event_date to equal to curr_event_date ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 
   update #allocationitems    
   set prev_event_date = curr_event_date    
   where change_type in ('Contract Quantity Change', 'Allocation Quantity Change') and 
         prev_event_date is null   
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while setting prev_event_date in the #allocationitems table to be curr_event_date!'        
      goto result
   end 
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end    
        
   -- Quantities for modified allocation items whose event date changed    
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_changed_alloc_items - Debug 10: Updating Quantities for modified allocation items whose event date changed ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 
   update #allocationitems    
   set prev_sch_qty = case when audai.sch_qty is not null then audai.sch_qty 
                           else ai.sch_qty 
                      end,    
       curr_sch_qty = ai.sch_qty,    
       prev_nomin_qty = case when audai.nomin_qty_max is not null then audai.nomin_qty_max 
                             else ai.nomin_qty_max 
                        end,    
       curr_nomin_qty = ai.nomin_qty_max,    
       prev_actual_gross_qty = case when audai.actual_gross_qty is not null then audai.actual_gross_qty 
                                    else ai.actual_gross_qty
                               end,    
       curr_actual_gross_qty = ai.actual_gross_qty,    
       prev_sch_uom = case when audai.sch_qty_uom_code is not null then audai.sch_qty_uom_code 
                           else ai.sch_qty_uom_code 
                      end,     
       prev_nomin_uom = case when audai.nomin_qty_max_uom_code is not null then audai.nomin_qty_max_uom_code 
                             else ai.nomin_qty_max_uom_code 
                        end,     
       prev_actual_gross_uom = case when audai.actual_gross_uom_code is not null then audai.actual_gross_uom_code 
                                    else ai.actual_gross_uom_code 
                               end,     
       curr_sch_uom = ai.sch_qty_uom_code,     
       curr_nomin_uom = ai.nomin_qty_max_uom_code,     
       curr_actual_gross_uom = ai.actual_gross_uom_code,
       prev_contr_qty = case when audti.contr_qty is not null then audti.contr_qty 
                             else ti.contr_qty 
                        end,
       prev_contr_qty_uom = case when audti.contr_qty_uom_code is not null then audti.contr_qty_uom_code 
                                 else ti.contr_qty_uom_code 
                            end,
       curr_contr_qty = ti.contr_qty,
       curr_contr_qty_uom = ti.contr_qty_uom_code
   from #allocationitems tai    
           join dbo.trade_item ti on tai.trade_num = ti.trade_num and
					                           tai.order_num = ti.order_num and
					                           tai.item_num = ti.item_num    
           left join dbo.aud_trade_item audti on ti.trade_num = audti.trade_num and
					                                       ti.order_num = audti.order_num and
					                                       ti.item_num = audti.item_num and 
                                                 audti.trans_id < prev_pl_trans_id and 
                                                 audti.resp_trans_id >= prev_pl_trans_id    
           left join dbo.allocation_item ai on tai.alloc_num = ai.alloc_num and 
                                               tai.alloc_item_num = ai.alloc_item_num    
           left join dbo.aud_allocation_item audai on ai.alloc_num = audai.alloc_num and 
                                                      ai.alloc_item_num = audai.alloc_item_num and 
                                                      audai.trans_id < prev_pl_trans_id and 
                                                      audai.resp_trans_id >= prev_pl_trans_id    
   where tai.change_type not in ('Contract Quantity Change', 'Allocation Quantity Change')   
   select @errcode = @@error
   if @errcode > 0
   begin 
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while updating qty info in the #allocationitems table (event date being changed)!'        
      goto result
   end 
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end  
          
   -- Try finding best current pricing date     
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_changed_alloc_items - Debug 11: Try finding best current pricing date ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 
   update #allocationitems    
   set curr_pricing_date_from = a.quote_start_date,    
       curr_pricing_date_to = a.quote_end_date    
   from #allocationitems tai    
           join dbo.accumulation a on tai.trade_num = a.trade_num and 
                                      tai.order_num = a.order_num and 
                                      tai.item_num = a.item_num and    
                                      tai.alloc_num = a.alloc_num and 
                                      tai.alloc_item_num = a.alloc_item_num and 
                                      a.accum_creation_type = 'E'    
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while updating pricing date info in the #allocationitems table!'        
      goto result
   end 
   update #allocationitems    
   set curr_pricing_date_from = a.quote_start_date,    
       curr_pricing_date_to = a.quote_end_date    
   from #allocationitems tai    
           join dbo.accumulation a on tai.trade_num = a.trade_num and 
                                      tai.order_num = a.order_num and 
                                      tai.item_num = a.item_num and    
                                      a.accum_creation_type = 'E'    
   where tai.curr_pricing_date_from is null      	
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while updating pricing date info in the #allocationitems table!'        
      goto result
   end 
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end  

   -- Try finding best previous pricing date     
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_changed_alloc_items - Debug 12: Try finding best previous pricing date ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 
   update #allocationitems    
   set prev_pricing_date_from =    
          case when auda.quote_start_date is null then tai.curr_pricing_date_from 
               else auda.quote_start_date 
          end,    
       prev_pricing_date_to =    
          case when auda.quote_end_date is null then tai.curr_pricing_date_to 
               else auda.quote_end_date 
          end    
   from #allocationitems tai    
           left join dbo.aud_accumulation auda on tai.trade_num = auda.trade_num and 
                                                  tai.order_num = auda.order_num and 
                                                  tai.item_num = auda.item_num and    
                                                  auda.accum_creation_type = 'E' and 
                                                  auda.trans_id < tai.prev_pl_trans_id and 
                                                  auda.resp_trans_id >= tai.prev_pl_trans_id        
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_changed_alloc_items (DEBUG): Error occurred while updating best previous pricing date in the #allocationitems table!'        
      goto result
   end 
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end
          
result:
   drop table #allportfolio   
   drop table #children    
   drop table #portfolio_recent_plasof    

   if @errcode > 0
   begin
      select 'ERROR' as change_type, 
             NULL as change_date, 
             NULL as alloc_num, 
             NULL as alloc_item_num, 
             NULL as trade_num, 
             NULL as order_num, 
             NULL as item_num,    
             NULL as prev_pl_asof_date, 
             NULL as curr_pl_asof_date,     
             NULL as alloc_status, 
             NULL as alloc_qty_status,    
             NULL as prev_sch_qty, 
             NULL as prev_sch_uom, 
             NULL as curr_sch_qty, 
             NULL as curr_sch_uom, 
             NULL as sch_qty_difference,    
             NULL as prev_nomin_qty, 
             NULL as prev_nomin_uom, 
             NULL as curr_nomin_qty, 
             NULL as curr_nomin_uom, 
             NULL as nomin_qty_difference,    
             NULL as prev_actual_gross_qty, 
             NULL as prev_actual_gross_uom, 
             NULL as curr_actual_gross_qty, 
             NULL as curr_actual_gross_uom, 
             NULL as actual_gross_qty_difference,    
             NULL as prev_contr_qty, 
             NULL as prev_contr_qty_uom,
             NULL as curr_contr_qty, 
             NULL as curr_contr_qty_uom,
             NULL as contr_qty_difference,
             NULL as event_name, 
             NULL as prev_event_date, 
             NULL as curr_event_date,
             NULL as prev_pricing_date_from, 
             NULL as prev_pricing_date_to,     
             NULL as curr_pricing_date_from, 
             NULL as curr_pricing_date_to,      
             NULL as trade_price, 
             NULL as price_currency, 
             NULL as price_uom, 
             NULL as price_status,     
             NULL as trade_totsch_qty, 
             NULL as trade_totsch_qty_uom, 
             NULL as trade_open_qty, 
             NULL as trade_open_qty_uom, 
             NULL as port_num,     
             NULL as cmdty_short_name, 
             NULL as alloc_creator, 
             NULL as alloc_last_modifier, 
             NULL as curr_pl_trans_id, 
             NULL as prev_pl_trans_id 
   end
   else
   begin   
      -- Now, we are ready to emit the output    
      select change_type, 
             change_date, 
             alloc_num, 
             alloc_item_num, 
             trade_num, 
             order_num, 
             item_num,    
             prev_pl_asof_date, 
             curr_pl_asof_date,     
             case alloc_status when 'A' then 'Allocated' 
                               when 'C' then 'Confirmed' 
                               when 'D' then 'Completed'
			                         when 'U' then 'Unallocated' 
                               else '' 
             end as alloc_status, 
             alloc_qty_status,    
             prev_sch_qty, 
             prev_sch_uom, 
             curr_sch_qty, 
             curr_sch_uom, 
             (isnull(curr_sch_qty,0) - isnull(prev_sch_qty,0)) sch_qty_difference,    
             prev_nomin_qty, 
             prev_nomin_uom, 
             curr_nomin_qty, 
             curr_nomin_uom, 
             (isnull(curr_nomin_qty,0) - isnull(prev_nomin_qty,0)) nomin_qty_difference,    
             prev_actual_gross_qty, 
             prev_actual_gross_uom, 
             curr_actual_gross_qty, 
             curr_actual_gross_uom, 
             (isnull(curr_actual_gross_qty,0) - isnull(prev_actual_gross_qty,0)) actual_gross_qty_difference,    
             prev_contr_qty, 
             prev_contr_qty_uom,
             curr_contr_qty, 
             curr_contr_qty_uom,
             (isnull(curr_contr_qty,0) - isnull(prev_contr_qty,0)) contr_qty_difference,    
             event_name, 
             prev_event_date, 
             curr_event_date,
             prev_pricing_date_from, 
             prev_pricing_date_to,     
             curr_pricing_date_from, 
             curr_pricing_date_to,      
             trade_price, 
             price_currency, 
             price_uom, 
             price_status,     
             trade_totsch_qty, 
             trade_totsch_qty_uom, 
             trade_open_qty, 
             trade_open_qty_uom, 
             port_num,     
             cmdty_short_name, 
             alloc_creator, 
             alloc_last_modifier, 
             curr_pl_trans_id, 
             prev_pl_trans_id 
      from #allocationitems
      order by change_type, change_date     
   end
   
   drop table #allocationitems  
GO
GRANT EXECUTE ON  [dbo].[usp_changed_alloc_items] TO [next_usr]
GO
