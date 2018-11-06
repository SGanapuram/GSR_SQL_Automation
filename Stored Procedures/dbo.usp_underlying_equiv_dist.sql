SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_underlying_equiv_dist]
(
   @before_asof_date     datetime = NULL,
   @max_years_back       smallint = 0
)
as
set nocount on
declare @after_asof_date     datetime,
        @number_years_back   smallint

   if @before_asof_date is null
   begin
      print "Usage: exec dbo.usp_underlying_equiv_dist @before_asof_date = 'mm/dd/yy', [ @max_years_back = ? ]"
      print 'You must provide a date for the argument @before_asof_date!'
      return
   end

   create table #tidmtm_temp 
   (
      dist_num                int      NOT NULL,
      mtm_pl_asof_date        datetime NOT NULL
    )

   if @max_years_back > 0
   begin
      set @number_years_back = -1 * @max_years_back
      set @after_asof_date = dateadd(year, @number_years_back, convert(datetime, @before_asof_date))

      insert into #tidmtm_temp
      select tidmtm.dist_num,
             max(tidmtm.mtm_pl_asof_date)
      from dbo.tid_mark_to_market tidmtm, 
           dbo.trade_item_dist tid
      where tidmtm.dist_num = tid.dist_num and
            tid.is_equiv_ind = 'Y' and 
            tid.bus_date <= @before_asof_date and 
            tidmtm.mtm_pl_asof_date between @after_asof_date and @before_asof_date
      group by tidmtm.dist_num
   end
   else
   begin
      insert into #tidmtm_temp
      select tidmtm.dist_num,
             max(tidmtm.mtm_pl_asof_date)
      from dbo.tid_mark_to_market tidmtm, 
           dbo.trade_item_dist tid
      where tidmtm.dist_num = tid.dist_num and
            tid.is_equiv_ind = 'Y' and 
            tid.bus_date <= @before_asof_date and 
            tidmtm.mtm_pl_asof_date <= @before_asof_date
      group by tidmtm.dist_num
   end

   select distinct 
      tid.dist_num,
      tid.trade_num,
      tid.order_num,
      tid.item_num,
      tid.pos_num, 
      tid.accum_num, 
      tid.qpp_num, 
      ti.contr_qty, 
      tid.qty_uom_code, 
      tid.dist_qty, 
      tid.alloc_qty, 
      tid.qty_uom_conv_rate, 
      tid.p_s_ind, 
      tor.parent_order_num, 
      tidmtm.delta, 
      tid.priced_qty, 
      tid.discount_qty, 
      tid.real_port_num,
      tid.real_synth_ind 
   from 
      dbo.trade_item_dist tid, 
      dbo.trade_item ti, 
      dbo.trade_order tor, 
      #tidmtm_temp tidtemp,
      dbo.tid_mark_to_market tidmtm 
   where 
      tid.trade_num = ti.trade_num and 
      tid.order_num = ti.order_num and 
      tid.item_num = ti.item_num and 
      tor.trade_num = ti.trade_num and 
      tor.order_num = ti.order_num and
      tid.dist_num = tidtemp.dist_num and 
      tidmtm.dist_num = tidtemp.dist_num and 
      tidmtm.mtm_pl_asof_date = tidtemp.mtm_pl_asof_date  
   order by tid.pos_num

   drop table #tidmtm_temp
return
GO
GRANT EXECUTE ON  [dbo].[usp_underlying_equiv_dist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_underlying_equiv_dist', NULL, NULL
GO
