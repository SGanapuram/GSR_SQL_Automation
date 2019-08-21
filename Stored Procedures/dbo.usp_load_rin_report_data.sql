SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_load_rin_report_data] 
(    
   @mode           tinyint,      
   @port_num       int,  
   @impact_year    smallint 
)  
as  
set nocount on  
declare @prev_impact_year    smallint  
  
   set @prev_impact_year = @impact_year - 1  
  
   if @mode not in (1, 2, 3, 4, 5, 6, 7)  
   begin  
      print '=> You must provide a valid value (1-7) for the argument @mode!'  
      return 2  
   end  
     
   if not exists (select 1  
                  from dbo.portfolio  
                  where port_num = @port_num)  
   begin  
      print '=> You must provide a valid port # for the argument @port_num!'  
      return 2  
   end  
  
   if @impact_year < 1990  
   begin  
      print '=> You must provide a 4-digit number for the argument @impact_year!'  
      return 2  
   end  
        
   -- ### set up action lists.  
   create table #actions   
   (  
      mode         tinyint not null,   
      action_code  char(2) not null,  
      CONSTRAINT [xx1329597_action_pk] PRIMARY KEY CLUSTERED   
            (mode, action_code)        
   )  
     
   -- ### set up children table  
   create table #portnums   
   (  
      port_num     int primary key   
   )   
     
   -- ### set up rin definitions (prior year and cur year cmdty codes and d codes)  
   create table #rin_codes   
   (  
      rin_dcode          char(8) not null,   
      rin_year           smallint not null,   
      rin_cmdty_code     char(8) not null,   
      rin_cmdty_code0    char(8) not null  
   )  
  
   create table #rin_ti_data   
   (  
      real_port_num        int,   
      contr_date           datetime,   
      trade_num            int,   
      order_num            smallint,   
      item_num             smallint,  
     contract_num         varchar(10),   
     acct_num             int,   
     acct_short_name      nvarchar(15),   
     cmdty_code           char(8),   
     del_date_from        datetime,   
     del_date_to          datetime,   
     p_s_ind              char(1),   
     contr_qty            float,   
     contr_qty_uom_code   char(8),   
     actual_qty           float,   
     actual_qty_uom_code  char(8),   
     rvo_qty              float,   
     rvo_qty_uom_code     char(8),   
     rin_action_code      char(1),  
     rin_impact_date      datetime,   
     rin_cmdty_code       char(8),   
     rin_dcode            char(8),  
     cur_y_rin_qty        float,   
     pre_y_rin_qty        float,   
     rin_price            float,   
     rin_year             int,   
     rin_delivery_date    datetime  
  )  
  
   create table #dist_data   
   (  
      cmdty_code        char(8),   
      trade_num         int,   
      order_num         smallint,   
      item_num          smallint,   
      dist_num          int,  
     rin_action_code   char(8),   
     dist_type         char(8),   
     dist_qty          float,   
     qty_uom_code      char(8),   
     pl_amt            float   
   )  
  
  
   insert into #portnums  
   select port_num  
   from dbo.udf_portfolio_list(@port_num)  
   where port_type = 'R'  
  
   insert into #actions values(1, 'I')  
   insert into #actions values(1, 'E')  
   insert into #actions values(1, 'P')   
   insert into #actions values(1, 'C')  
   insert into #actions values(1, 'L')   
   insert into #actions values(1, 'R')   
   insert into #actions values(1, 'O')   
   insert into #actions values(1, 'M')  
  
   insert into #actions values(2, 'I')  
   insert into #actions values(2, 'E')  
   insert into #actions values(2, 'P')   
   insert into #actions values(2, 'C')  
   insert into #actions values(2, 'L')   
   insert into #actions values(2, 'X')   
  
   insert into #actions values(3, 'R')   
  
   insert into #actions values(4, 'I')  
   insert into #actions values(4, 'E')  
   insert into #actions values(4, 'P')   
   insert into #actions values(4, 'C')  
   insert into #actions values(4, 'L')   
   insert into #actions values(4, 'R')   
   insert into #actions values(4, 'X')   
  
   insert into #actions values(5, 'E')   
  
   insert into #actions values(6, 'O')   
   insert into #actions values(6, 'M')   
   insert into #actions values(6, 'N')   
  
   insert into #actions values(7, 'O')   
   insert into #actions values(7, 'M')   
     
   insert into #rin_codes  
  select a.rin_dcode,   
         a.rin_year,   
         a.rin_cmdty_code,   
         b.rin_cmdty_code   
  from (select rin_dcode, rin_year, rin_cmdty_code  
        from dbo.rin_definition   
        where rin_year = @impact_year and   
              status = 'A') a,  
      (select rin_dcode, rin_cmdty_code   
        from dbo.rin_definition   
        where rin_year = @prev_impact_year and   
              status = 'A') b  
  where a.rin_dcode = b.rin_dcode  
  
  
   -- ##------------------------------##  
   -- ##  Gather RIN Related TI data  ##  
   -- ##------------------------------##  
  
   -- #### biofuel report atributes (except out-of-country)  
   insert into #rin_ti_data  
   select tr.rin_port_num,   
          t.contr_date,   
          ti.trade_num,   
          ti.order_num,   
          ti.item_num,  
         t.special_contract_num,   
         t.acct_num,   
         cp.acct_short_name,   
         ti.cmdty_code,  
         ph.del_date_from,   
         ph.del_date_to,  
         ti.p_s_ind,   
         ti.contr_qty,   
         ti.contr_qty_uom_code,   
         0.0 as actual_qty,   
         null as actual_qty_uom_code,   
         0.0 as rvo_qty,   
         null as rvo_qty_uom_code,   
         tr.rin_action_code,   
         tr.rin_impact_date,   
         tr.rin_cmdty_code,   
         rc.rin_dcode,  
         tr.settled_cur_y_sqty,   
         tr.settled_pre_y_sqty,   
         0.0 as rin_price,   
         tr.impact_current_year,   
         null as rin_delivery_date  
   from dbo.trade_item ti  
         join dbo.trade_item_rin tr  
            on ti.trade_num = tr.trade_num and   
               ti.order_num = tr.order_num and   
               ti.item_num = tr.item_num  
         join #actions a  
            on tr.rin_action_code = a.action_code and  
               a.mode = @mode  
         join #rin_codes rc  
            on tr.rin_cmdty_code = rc.rin_cmdty_code  
         join #portnums c  
            on tr.rin_port_num = c.port_num   
         join dbo.trade_item_wet_phy ph  
            on ti.trade_num = ph.trade_num and   
               ti.order_num = ph.order_num and   
               ti.item_num = ph.item_num  
         join dbo.trade t  
            on ti.trade_num = t.trade_num  
         join dbo.account cp  
            on t.acct_num = cp.acct_num  
   where tr.rin_action_code in ('I', 'E', 'P', 'C', 'L') and   
         tr.impact_current_year = @impact_year  
  
   -- ### RIN Only Trades  
   insert into #rin_ti_data  
   select ti.real_port_num,   
          t.contr_date,   
          ti.trade_num,   
          ti.order_num,   
          ti.item_num,  
         t.special_contract_num,   
         t.acct_num,   
         cp.acct_short_name,   
         ti.cmdty_code,  
         null as del_date_from,   
         null as del_date_to,  
         ti.p_s_ind,   
         ti.contr_qty,   
         ti.contr_qty_uom_code,   
         0.0 as actual_qty,   
         null as actual_qty_uom_code,   
         0.0 as rvo_qty,   
         null as rvo_qty_uom_code,   
         tr.rin_action_code,   
         tr.rin_impact_date,   
         tr.rin_cmdty_code,   
         rc.rin_dcode,  
         tr.settled_cur_y_sqty,   
         tr.settled_pre_y_sqty,   
         ti.avg_price as rin_price,   
         tr.impact_current_year,    
         tr.rin_impact_date  
   from dbo.trade_item ti  
          join dbo.trade_item_rin tr  
             on ti.trade_num = tr.trade_num and   
                ti.order_num = tr.order_num and   
                ti.item_num = tr.item_num  
          join dbo.rin_definition rc  
             on tr.rin_cmdty_code = rc.rin_cmdty_code and   
                rc.status = 'A'  
          join #actions a  
             on tr.rin_action_code = a.action_code and  
                a.mode = @mode  
          join #portnums c  
             on tr.rin_port_num = c.port_num   
          join dbo.trade t  
             on ti.trade_num = t.trade_num  
          join dbo.account cp  
             on t.acct_num = cp.acct_num  
   where tr.rin_action_code in ('R') and   
         tr.impact_current_year = @impact_year  
  
  
   -- #### motor fuel obligations  
   insert into #rin_ti_data  
   select tr.rin_port_num,    
          t.contr_date,   
          ti.trade_num,   
          ti.order_num,   
          ti.item_num,  
         t.special_contract_num,   
         t.acct_num,   
         cp.acct_short_name,   
         ti.cmdty_code,  
         ph.del_date_from,   
         ph.del_date_to,  
         ti.p_s_ind,   
         ti.contr_qty,   
         ti.contr_qty_uom_code,   
         0.0 as actual_qty,   
         null as actual_qty_uom_code,   
         tr.rvo_mf_qty as rvo_qty,   
         tr.rvo_mf_qty_uom_code as rvo_qty_uom_code,   
         tr.rin_action_code,    
         tr.rin_impact_date,  
         null as rin_cmdty_code,   
         null as rin_dcode,  
         0 as cur_y_rin_qty,   
         0 as pre_y_rin_qty,   
         0.0 as rin_price,   
         tr.impact_current_year,   
         null as rin_delivery_date  
   from dbo.trade_item ti  
          join dbo.trade_item_rin tr  
             on ti.trade_num = tr.trade_num and   
                ti.order_num = tr.order_num and   
                ti.item_num = tr.item_num  
          join #actions a  
             on tr.rin_action_code = a.action_code and  
                a.mode = @mode  
          join #portnums c  
             on tr.rin_port_num = c.port_num   
          join dbo.trade_item_wet_phy ph  
             on ti.trade_num = ph.trade_num and   
                ti.order_num = ph.order_num and   
                ti.item_num = ph.item_num  
          join dbo.trade t  
             on ti.trade_num = t.trade_num  
          join dbo.account cp  
             on t.acct_num = cp.acct_num  
   where tr.rin_action_code in ('O', 'M') and   
         tr.impact_current_year = @impact_year  
  
   -- #### biofuel report atributes (out-of-country)  
   -- #### motor report atributes (non-rvo)  
   insert into #rin_ti_data  
   select ti.real_port_num,   
          t.contr_date,   
          ti.trade_num,   
          ti.order_num,   
          ti.item_num,  
         t.special_contract_num,   
         t.acct_num,   
         cp.acct_short_name,   
         ti.cmdty_code,  
         ph.del_date_from,   
         ph.del_date_to,  
         ti.p_s_ind,   
         ti.contr_qty,   
         ti.contr_qty_uom_code,   
         0.0 as actual_qty,   
         null as actual_qty_uom_code,   
         0.0 as rvo_qty,   
         null as rvo_qty_uom_code,   
         tr.rin_action_code,   
         null as rin_impact_date,   
         null as rin_cmdty_code,   
         null as rin_dcode,  
         0 as cur_y_rin_qty,   
         0 as pre_y_rin_qty,   
         0 as rin_price,   
         tr.impact_current_year,   
         null as rin_delivery_date  
   from dbo.trade_item ti  
          join dbo.trade_item_rin tr  
             on ti.trade_num = tr.trade_num and   
                ti.order_num = tr.order_num and   
                ti.item_num = tr.item_num  
          join #actions a  
             on tr.rin_action_code = a.action_code and  
                a.mode = @mode  
          join #portnums c  
             on tr.rin_port_num = c.port_num   
          join dbo.trade_item_wet_phy ph  
             on ti.trade_num = ph.trade_num and   
                ti.order_num = ph.order_num and   
                ti.item_num = ph.item_num  
          join dbo.trade t  
             on ti.trade_num = t.trade_num  
          join dbo.account cp  
             on t.acct_num = cp.acct_num  
   where tr.rin_action_code in ('X', 'N') and   
         tr.impact_current_year = @impact_year  
  
   -- ##------------------------------##  
   -- ##    find actual qty data      ##  
   -- ##------------------------------##  
  
   -- (all except RIN only)  
   update tr  
  set actual_qty = td.dist_qty,  
  actual_qty_uom_code = td.qty_uom_code  
   from #rin_ti_data tr  
          join dbo.trade_item_dist td  
     on tr.trade_num = td.trade_num and   
                tr.order_num = td.order_num and   
                tr.item_num = td.item_num and   
                dist_type = 'D'  
         join dbo.position p  
            on td.pos_num = p.pos_num and   
               tr.cmdty_code = p.cmdty_code  
   where tr.rin_action_code in ('I', 'E', 'P', 'C', 'L', 'X', 'O', 'M', 'N')   
  
  
   -- ##------------------------------##  
   -- ##  Find RIN Distribution data  ##  
   -- ##------------------------------##  
  
   -- load distribution data  
   insert into #dist_data  
  select p.cmdty_code,  
        tid.trade_num,   
        tid.order_num,   
        tid.item_num,   
        dist_num,   
        rin_action_code,   
        dist_type,   
        dist_qty,   
        tid.qty_uom_code,   
        0  
  from dbo.trade_item_rin tr  
         join #actions a  
            on tr.rin_action_code = a.action_code and  
               a.mode = @mode  
         join #portnums c  
           on tr.rin_port_num = c.port_num  
        join dbo.trade_item_dist tid   
           on tid.trade_num = tr.trade_num and   
              tid.order_num = tr.order_num and   
              tid.item_num = tr.item_num  
        join dbo.position p  
           on tid.pos_num = p.pos_num  
  where dist_type in ('L', 'E', 'N')  
  
  
   -- ##------------------------------##  
   -- ##   Find Active RIN P/L data   ##  
   -- ##------------------------------##  
  
   -- ### find PL history for active RIN distributions.  
   declare @pl_asof_date     datetime  
   
  select @pl_asof_date = max(pl_asof_date) from dbo.pl_history  
  
   update dd  
  set pl_amt = ISNULL(pl.pl_amt, 0)  
   from #dist_data dd  
          join dbo.pl_history pl  
             on pl.pl_asof_date = @pl_asof_date and   
                pl.pl_record_key = dist_num and   
                pl.pl_owner_code = 'T' and   
                pl.pl_type = 'U'  
   where dd.dist_type = 'L'  
  
  
   -- ##------------------------------##  
   -- ##    produce report data       ##  
   -- ##------------------------------##  
  
   -- return the following as result of the stored proc.  
   select tr.real_port_num,   
          tr.contr_date,   
          tr.trade_num,   
          tr.order_num,   
          tr.item_num,   
         tr.contract_num,    
         tr.acct_num,   
         tr.acct_short_name,   
         tr.cmdty_code,   
         tr.del_date_from,   
         tr.del_date_to,   
         tr.p_s_ind,   
         tr.contr_qty,   
         tr.contr_qty_uom_code,   
         tr.actual_qty,   
         tr.actual_qty_uom_code,   
         tr.rvo_qty,   
         tr.rvo_qty_uom_code,   
         tr.rin_action_code,   
         tr.rin_impact_date,   
         rc.rin_cmdty_code,   
         rc.rin_dcode,   
         tr.cur_y_rin_qty,   
         tr.pre_y_rin_qty,   
         tr.rin_price,   
         tr.rin_year,   
         tr.rin_delivery_date,   
         ISNULL(dc.dist_qty, 0.0) as cur_y_committed,   
         ISNULL(dc0.dist_qty, 0.0) as pre_y_committed,  
         ISNULL(dn.dist_qty, 0.0) as cur_y_obligated,  
         ISNULL(dn0.dist_qty, 0.0) as pre_y_obligated,  
         ISNULL(da.dist_qty, 0.0) as cur_y_active,  
         ISNULL(da0.dist_qty, 0.0) as pre_y_active,  
         ISNULL(da.pl_amt, 0.0) as cur_y_active_pl,  
         ISNULL(da0.pl_amt, 0.0) as pre_y_active_pl,  
         ISNULL(da.pl_amt, 0.0) + ISNULL(da0.pl_amt, 0.0) as total_active_pl  
   from #rin_ti_data tr  
          join #actions a  
             on tr.rin_action_code = a.action_code and  
                a.mode = @mode  
          join #rin_codes rc  
             on tr.rin_year = rc.rin_year   
          left join #dist_data dc  
             on tr.trade_num = dc.trade_num and   
                tr.order_num = dc.order_num and   
                tr.item_num = dc.item_num and   
                dc.dist_type = 'E' and   
                dc.cmdty_code = rc.rin_cmdty_code  
          left join #dist_data dc0  
             on tr.trade_num = dc0.trade_num and   
                tr.order_num = dc0.order_num and   
                tr.item_num = dc0.item_num and   
                dc0.dist_type = 'E' and   
                dc0.cmdty_code = rc.rin_cmdty_code0  
          left join #dist_data dn  
             on tr.trade_num = dn.trade_num and   
                tr.order_num = dn.order_num and   
                tr.item_num = dn.item_num and   
                dn.dist_type = 'N' and   
                dn.cmdty_code = rc.rin_cmdty_code  
          left join #dist_data dn0  
             on tr.trade_num = dn0.trade_num and   
                tr.order_num = dn0.order_num and   
                tr.item_num = dn0.item_num and   
                dn0.dist_type = 'N' and   
                dn0.cmdty_code = rc.rin_cmdty_code0  
          left join #dist_data da  
             on tr.trade_num = da.trade_num and   
                tr.order_num = da.order_num and   
                tr.item_num = da.item_num and   
                da.dist_type = 'L' and   
                da.cmdty_code = rc.rin_cmdty_code  
          left join #dist_data da0  
             on tr.trade_num = da0.trade_num and   
                tr.order_num = da0.order_num and   
                tr.item_num = da0.item_num and   
                da0.dist_type = 'L' and   
                da0.cmdty_code = rc.rin_cmdty_code0  
   where tr.rin_action_code in ('I', 'E', 'P', 'C', 'L', 'R', 'O', 'M') and   
        not (dc.dist_qty is null and   
             dc0.dist_qty is null and   
             dn.dist_qty is null and   
             dn0.dist_qty is null and   
             da.dist_qty is null and   
             da0.dist_qty is null)  
   union  
   select tr.real_port_num,   
          tr.contr_date,   
          tr.trade_num,   
          tr.order_num,   
          tr.item_num,   
         tr.contract_num,    
         tr.acct_num,   
         tr.acct_short_name,   
         tr.cmdty_code,   
         tr.del_date_from,   
         tr.del_date_to,   
         tr.p_s_ind,   
         tr.contr_qty,   
         tr.contr_qty_uom_code,   
         tr.actual_qty,   
         tr.actual_qty_uom_code,   
         tr.rvo_qty,   
         tr.rvo_qty_uom_code,   
         tr.rin_action_code,   
         tr.rin_impact_date,   
         tr.rin_cmdty_code,   
         tr.rin_dcode,   
         tr.cur_y_rin_qty,  
         tr.pre_y_rin_qty,   
         tr.rin_price,   
         tr.rin_year,   
         tr.rin_delivery_date,   
         0.0 as cur_y_committed,   
         0.0 as pre_y_committed,  
         0.0 as cur_y_obligated,  
         0.0 as pre_y_obligated,  
         0.0 as cur_y_active,  
         0.0 as pre_y_active,  
         0.0 as cur_y_active_pl,  
         0.0 as pre_y_active_pl,  
         0.0 as total_active_pl  
   from #rin_ti_data tr  
          join #actions a  
             on tr.rin_action_code = a.action_code and  
                a.mode = @mode  
   where tr.rin_action_code in ('X', 'N')  
   order by tr.real_port_num,   
            tr.p_s_ind,   
            tr.trade_num,   
            tr.order_num,   
            tr.item_num  
   return 0  
     
endofsp:  
GO
GRANT EXECUTE ON  [dbo].[usp_load_rin_report_data] TO [next_usr]
GO
