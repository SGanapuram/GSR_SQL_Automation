SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[pl_records]  
( 
   @top_portfolio         int,    
   @asofdate              datetime,    
   @includephysicals      char(1) = 'Y',  
   @includefutures        char(1) = 'Y',  
   @includeswaps          char(1) = 'Y',  
   @includebookingcompany char(1) = 'Y',  
   @includedesk           char(1) = 'Y',  
   @includegroup          char(1) = 'Y',     
   @altpricefutures       char(1) = 'N' 
)    
as    
set nocount on
declare @deskETid          int,
        @bookCompETid      int,
        @groupETid         int,
        @futPlTypeToIgnore char(1)
	  
   create table #children (port_num int, port_type char(2))    
   create table #children2 
   (
      port_num             int, 
      port_type            char(2),
      desk                 char(20), 
      booking_company      char(20),
      booking_acct_num     int, 
      tcgroup              char(20),
      acct_short_name      char(30) null,
      desired_pl_curr_code char(8) null
   )      

   create nonclustered index xx1014_child_idx1 on #children2 (port_num)
   create nonclustered index xx1014_child_idx2 on #children2 (booking_acct_num)

	 select @deskETid = oid 
	 from dbo.entity_tag_definition with (nolock)
	 where entity_tag_name = 'DESK'

	 select @bookCompETid = oid
	 from dbo.entity_tag_definition with (nolock)
	 where entity_tag_name = 'BOOKCOMP'

	 select @groupETid = oid
	 from dbo.entity_tag_definition with (nolock)
	 where entity_tag_name = 'GROUP'

   exec dbo.port_children @top_portfolio, 'R', 0    
   insert into #children2     
   select port_num,  
          port_type,  
          isnull(desk.target_key1, 'N/A'),   
          isnull(booking_company.target_key1, 'N/A'),   
          case when booking_company.target_key1 is null then 0
               else convert(int, booking_company.target_key1) 
          end,  
          isnull(tcgroup.target_key1, 'N/A'),
          null,
          null
/* OLD SYNTAX
   from #children po,  
        dbo.entity_tag desk with (nolock),  
        dbo.entity_tag booking_company with (nolock),  
        dbo.entity_tag tcgroup with (nolock)
   where desk.entity_tag_id = @deskETid and  
         convert(int,desk.key1) =* po.port_num and  
         booking_company.entity_tag_id = @bookCompETid and  
         convert(int,booking_company.key1) =* po.port_num and  
         tcgroup.entity_tag_id = @groupETid and  
         convert(int, tcgroup.key1) =* po.port_num    
*/
   from #children po    
            LEFT OUTER JOIN dbo.entity_tag desk
               ON cast(po.port_num as varchar) = desk.key1 and
                  desk.entity_tag_id = @deskETid
            LEFT OUTER JOIN dbo.entity_tag booking_company
               ON cast(po.port_num as varchar) = booking_company.key1 and
                  booking_company.entity_tag_id = @bookCompETid 
            LEFT OUTER JOIN dbo.entity_tag tcgroup   
               ON cast(po.port_num as varchar) = tcgroup.key1 and
                  tcgroup.entity_tag_id = @groupETid
    
   if @includebookingcompany = 'N'    
      update #children2    
      set booking_company = 'ALL', 
          acct_short_name = 'ALL'  
   else
      update #children2 
      set acct_short_name = (select a.acct_short_name 
                             from dbo.account a with (nolock)
                             where a.acct_num = #children2.booking_acct_num)                              

   if @includedesk = 'N'    
      update #children2    
      set desk = 'ALL'    
          
   if @includegroup = 'N'    
      update #children2    
      set tcgroup = 'ALL'    

   update #children2 
   set desired_pl_curr_code = rp.desired_pl_curr_code           
   from dbo.portfolio rp
   where #children2.port_num = rp.port_num                        

   select @futPlTypeToIgnore = 'W'
   if @altpricefutures = 'Y'
      select @futPlTypeToIgnore = 'U'

   select     
      po.desk,    
      po.booking_company,    
      po.tcgroup,    
      p.cmdty_code,    
      p.mkt_code,    
      'Physical' as pos_type,    
      pl_type,    
      sum(pl.pl_amt) as amount,    
      po.desired_pl_curr_code,
      po.acct_short_name,
      c.cmdty_short_name,
      m.mkt_short_name
   from (select     
            real_port_num,    
            pos_num,    
            pl_asof_date,    
            case when pl_type = 'C' 
                    then 'Closed' 
                 else 'Open' 
            end as pl_type,    
            pl_amt    
         from	dbo.pl_history
	       where pl_asof_date = @asofdate and    
		           pl_type not in ('W')) pl,     
        dbo.position p
           LEFT OUTER JOIN dbo.commodity c with (nolock)
              on c.cmdty_code = p.cmdty_code
           LEFT OUTER JOIN dbo.market m with (nolock) 
              on m.mkt_code = p.mkt_code, 
        #children2 po
   where pl.pos_num = p.pos_num and    
         pos_type in ('P', 'I') and    
         po.port_num = pl.real_port_num and    
	       @includephysicals != 'N'
   group by p.cmdty_code,    
            p.mkt_code,    
            pl_type,    
            desk,    
            booking_company,    
            tcgroup,    
            po.desired_pl_curr_code,
	          po.acct_short_name,
	          c.cmdty_short_name,
	          m.mkt_short_name 
   union        
   select     
      po.desk,    
      po.booking_company,    
      po.tcgroup,    
      pl.cmdty_code,    
      pl.mkt_code,    
      'Future' as pos_type,    
      pl_type,    
      sum(pl.pl_amt) as amount,    
      po.desired_pl_curr_code,
	    po.acct_short_name,
      c.cmdty_short_name,
      m.mkt_short_name
   from (select     
		        pl.real_port_num,    
		        pos_type,    
		        cmdty_code,    
		        mkt_code,              
            case when datediff(day, @asofdate, last_trade_date) <= 0 
                    then 'Closed' 
                 else 'Open' 
            end as pl_type,    
            pl_amt    
         from dbo.pl_history pl,    
              dbo.trading_period tp,    
              dbo.position p    
         where pl.pos_num = p.pos_num and    
               pl.pl_asof_date = @asofdate and    
               pl_type not in (@futPlTypeToIgnore) and    
               pos_type = 'F' and    
               p.commkt_key = tp.commkt_key and    
               p.trading_prd = tp.trading_prd and 
		           not (pl.pl_owner_code = 'C' and 
		                pl.pl_owner_sub_code = 'FBC')) pl  /* need to skip broker costs */
           LEFT OUTER JOIN dbo.commodity c with (nolock)
              on c.cmdty_code = pl.cmdty_code
           LEFT OUTER JOIN dbo.market m with (nolock) 
              on m.mkt_code = pl.mkt_code, 
        #children2 po   
   where po.port_num = pl.real_port_num and    
	       @includefutures != 'N'
   group by pl.cmdty_code,    
            pl.mkt_code,    
            pos_type,    
            pl_type,    
            desk,    
            booking_company,    
            tcgroup,    
            po.desired_pl_curr_code,
	          po.acct_short_name,
	          c.cmdty_short_name,
	          m.mkt_short_name
   union        
   select     
      po.desk,    
      po.booking_company,    
	    po.tcgroup,    
      p.cmdty_code,    
      p.mkt_code,    
      'Swap' as pos_type,    
      pl_type,    
      sum(pl.pl_amt) as amount,    
      po.desired_pl_curr_code,
	    po.acct_short_name,
      c.cmdty_short_name,
      m.mkt_short_name
   from (select    
            real_port_num,    
            pos_num,    
            pl_asof_date,    
            case when pl_category_type = 'R' 
                    then 'Closed' 
                 else 'Open' 
            end as pl_type,    
            pl_amt    
         from dbo.pl_history 
	       where not (pl_owner_code = 'C' and 
	                  pl_owner_sub_code = 'SWBC') and /* need to skip broker costs */
	             pl_asof_date = @asofdate and    
		           pl_type not in ('W')) pl,     
        dbo.position p
           LEFT OUTER JOIN dbo.commodity c with (nolock)
              on c.cmdty_code = p.cmdty_code
           LEFT OUTER JOIN dbo.market m with (nolock) 
              on m.mkt_code = p.mkt_code, 
        #children2 po  
   where pl.pos_num = p.pos_num and    
         pos_type = 'W' and    
         po.port_num = pl.real_port_num and    
	       @includeswaps != 'N'
   group by desk,    
            booking_company,    
            tcgroup,    
            pos_type,    
            p.cmdty_code,    
            p.mkt_code,    
            pl_type,    
            po.desired_pl_curr_code,
	          po.acct_short_name,
	          c.cmdty_short_name,
	          m.mkt_short_name
   order by desk,    
            booking_company,    
            tcgroup,    
            pos_type,    
            p.cmdty_code,    
            p.mkt_code    
    
   drop table #children    
   drop table #children2       
   return    
GO
GRANT EXECUTE ON  [dbo].[pl_records] TO [next_usr]
GO
