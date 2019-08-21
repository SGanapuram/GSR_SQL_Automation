SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_position_mtm_xo]
(
   @before_asof_date     datetime = NULL,
   @max_years_back       smallint = 1
)
as
set nocount on
declare @after_asof_date     datetime,
        @number_years_back   smallint

   if @before_asof_date is null
   begin
      print 'Usage: exec usp_position_mtm_xo @before_asof_date = ''mm/dd/yy'''
      print 'You must provide a date for the argument @before_asof_date!'
      return
   end

   create table #posmtm_temp 
   (
      pos_num                 int      NOT NULL,
      mtm_asof_date           datetime NOT NULL
    )


   if @max_years_back <= 1
      set @number_years_back = -1
   else
      set @number_years_back = -1 * @max_years_back
      
   set @after_asof_date = dateadd(year, @number_years_back, convert(datetime, @before_asof_date))

   insert into #posmtm_temp
   select posmtm.pos_num,
          max(posmtm.mtm_asof_date) 
   from dbo.position_mark_to_market posmtm, 
        dbo.position pos
   where posmtm.pos_num = pos.pos_num and 
         pos.pos_type in ('X', 'O') and
         posmtm.mtm_asof_date <= pos.opt_exp_date and 
	       posmtm.mtm_asof_date between @after_asof_date and @before_asof_date
   group by posmtm.pos_num
   union
   select posmtm.pos_num,
          max(posmtm.mtm_asof_date) 
   from dbo.position_mark_to_market posmtm, 
        dbo.position pos
   where posmtm.pos_num = pos.pos_num and 
         pos.pos_type = 'X' and
         pos.opt_exp_date < @before_asof_date and
         abs(pos.long_qty - pos.short_qty) > 0.1
   group by posmtm.pos_num

   select 
      posmtm.pos_num, 
      posmtm.delta, 
      posmtm.mtm_mkt_price, 
      posmtm.mtm_mkt_price_curr_code, 
      posmtm.mtm_mkt_price_uom_code, 
      posmtm.mtm_mkt_price_source_code, 
      /* the datediff() here will return 0 or a positive number */
      datediff(day, posmtm.mtm_asof_date, convert(datetime,@before_asof_date)),  
      gamma,
      theta,
      vega,
      interest_rate,
      volatility,
      convert(char(16), posmtm.mtm_asof_date, 101) 
   from #posmtm_temp posmtmtemp,
        dbo.position_mark_to_market posmtm 
   where posmtm.pos_num = posmtmtemp.pos_num and 
         posmtm.mtm_asof_date = posmtmtemp.mtm_asof_date  
   order by posmtm.pos_num

   drop table #posmtm_temp
return
GO
GRANT EXECUTE ON  [dbo].[usp_position_mtm_xo] TO [next_usr]
GO
