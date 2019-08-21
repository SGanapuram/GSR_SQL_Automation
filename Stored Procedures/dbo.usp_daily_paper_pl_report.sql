SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_daily_paper_pl_report]
(  
   @pl_asof_date      datetime = null,   
   @port_nums         varchar(max) = null,  
   @dept_code         varchar(50) = null,  
   @desk_code         varchar(50) = null,  
   @debugon           bit = 0    
)  
as    
set nocount on 
declare @rows_affected    int,    
        @smsg             varchar(255),    
        @status           int,    
        @oid              numeric(18, 0),    
        @stepid           smallint,    
        @session_started  varchar(30),    
        @session_ended    varchar(30),  
        @my_pl_asof_date  datetime,  
        @my_dept_code     varchar(50),  
        @my_desk_code     varchar(50),
        @my_port_nums     varchar(8000)

   select @my_pl_asof_date = @pl_asof_date,
          @my_port_nums	= @port_nums,
          @my_dept_code = @dept_code,
          @my_desk_code = @desk_code

   create table #TIs  
   (  
      trade_num int,  
      order_num int,  
      item_num int,  
      item_type char(1),  
      d_dist_num int null,  
      asof_date datetime,  
      dept_code char(8),   
      open_pl  decimal(20,8),  
      closed_pl decimal(20,8),  
      total_pl decimal(20,8),  
      curr_code char(8)  
   )  
  
   create table #Trade  
   (  
      trade_num int,  
      dept_code char(8)  
   )  
  
   create table #Pos  
   (  
      pos_num  int,  
      trade_num int,  
      asof_date datetime,  
      curr_code char(8),  
      unr_amt  decimal(20, 8),  
      rel_amt  decimal(20, 8),  
      total_amt decimal(20, 8),  
      mkt_val  decimal(20, 8)  
   )  
  
   -- Get all trades here except Invventories  
   insert into #TIs  
     (trade_num,  
      order_num,  
      item_num,  
      d_dist_num,  
      asof_date,  
      item_type)  
   select distinct   
      pl_secondary_owner_key1,  
      pl_secondary_owner_key2,  
      pl_secondary_owner_key3,  
      pl_record_owner_key,  
      pl_asof_date,  
      'T'  
   from dbo.pl_history pl  
        -- join #children c on c.port_num=pl.real_port_num --use this when portfolio's are selected as input.  
   where pl_asof_date = @my_pl_asof_date and   
         pl_owner_code in ('C', 'T') and  
         pl_secondary_owner_key1 > 0 and   
         pl_type not in ('I', 'W') and
         1 = (case when @my_port_nums is null then 1   
                   when pl.real_port_num in (Select * from dbo.udf_split(@my_port_nums,',')) then 1 
              end)
  
   -- Get all Inventory Draws  
   insert into #TIs  
     (trade_num,  
      order_num,  
      item_num,  
      closed_pl,  
      asof_date,  
      curr_code,  
      item_type)  
   select   
      pl_secondary_owner_key1,  
      pl_secondary_owner_key2,  
      pl_secondary_owner_key3,  
      sum(pl_amt),  
      pl_asof_date,  
      p.desired_pl_curr_code,  
      'I'  
   from dbo.pl_history pl  
      --join #children c on c.port_num=pl.real_port_num --use this when portfolio's are selected as input.  
           join dbo.portfolio p   
              on pl.real_port_num = p.port_num  
   where pl_asof_date = @my_pl_asof_date and   
         pl_owner_code in ('I') and  
         pl_secondary_owner_key1 > 0 and   
         pl_type not in ('I', 'W') and   
         1 = (case when @my_port_nums is null then 1   
                   when pl.real_port_num in (Select * from dbo.udf_split(@my_port_nums,',')) then 1 
              end)  
   group by pl_secondary_owner_key1,  
            pl_secondary_owner_key2,  
            pl_secondary_owner_key3,  
            pl_asof_date,  
            p.desired_pl_curr_code  
      
   -- Get all inventory Positions  
   insert into #Pos  
     (pos_num,  
      curr_code,  
      asof_date)  
   select distinct   
      pl_record_key,  
      p.desired_pl_curr_code,  
      pl_asof_date  
   from dbo.pl_history pl  
        -- join #children c on c.port_num=pl.real_port_num --use this when portfolio's are selected as input.  
          join dbo.portfolio p   
             on pl.real_port_num = p.port_num  
   where pl_asof_date = @my_pl_asof_date and   
         pl_owner_code in ('P') and  
         pl_secondary_owner_key1 > 0 and   
         pl_type not in ('I', 'W') and   
         1 = (case when @my_port_nums is null then 1   
                   when pl.real_port_num in (Select * from dbo.udf_split(@my_port_nums,',')) then 1 
              end)
  
   --Calculate Realized and Unrealized Inventory PL  
   update p  
   set unr_amt = isnull(pl1.pl_amt, 0),  
       rel_amt = isnull(pl2.pl_amt, 0),  
       total_amt = isnull(pl1.pl_amt, 0) + isnull(pl2.pl_amt, 0),  
       mkt_val = isnull(pl3.pl_amt, 0)  
   from #Pos p  
          left outer join dbo.pl_history pl1   
             on pl1.pl_record_key = p.pos_num and   
                pl1.pl_asof_date = p.asof_date and   
                pl1.pl_owner_code = 'P' and   
                pl1.pl_type = 'U'  
          left outer join dbo.pl_history pl2   
             on pl2.pl_record_key = p.pos_num and   
                pl2.pl_asof_date = p.asof_date and   
                pl2.pl_owner_code = 'P' and   
                pl2.pl_type = 'R'  
          left outer join dbo.pl_history pl3   
             on pl3.pl_record_key = p.pos_num and   
                pl3.pl_asof_date = p.asof_date and   
                pl3.pl_owner_code = 'P' and   
                pl3.pl_type = 'M'  
  
  
   update #Pos  
   set unr_amt = unr_amt +(case when (total_amt) <> 0   
                                   then (mkt_val * unr_amt / total_amt)   
                                else 0.0   
                           end),  
      rel_amt = rel_amt +(case when (total_amt) <> 0   
                                  then (mkt_val * rel_amt / total_amt)   
                               else 0.0   
                          end),  
      total_amt = total_amt + mkt_val  
  
   -- Get minimum Storage/Transport trade_num for getting depart code  
   update p  
   set trade_num = i.trade_num  
   from #Pos p  
            join (select pos_num,   
                         min(trade_num) as trade_num   
                  from dbo.inventory   
                  group by pos_num) i   
              on i.pos_num=p.pos_num  
  
   -- Consolidate Inventory Position data to main table  
   insert into #TIs  
   (   
      trade_num,   
      item_type,  
      asof_date,  
      open_pl,  
      closed_pl,  
      total_pl,  
      curr_code  
   )  
   select   
      trade_num,  
      'P',  
      asof_date,  
      unr_amt,  
      rel_amt,  
      total_amt,  
      curr_code  
   from #Pos  
  
   -- Filter trades by user criteria of required  
   insert into #Trade  
   select t.trade_num,  
          d1.dept_code   
   from dbo.trade t   
           join #TIs ti   
              on t.trade_num = ti.trade_num  
           join dbo.icts_user iu   
              on iu.user_init = t.trader_init  
           join dbo.desk d on d.desk_code=iu.desk_code  
           join dbo.department d1 on   
              d.dept_code = d1.dept_code and  
              d1.dept_code in (select *   
                               from dbo.fnToSplit(@my_dept_code, ','))  
  
   --Eliminate trades that are no required  
   delete ti  
   from #TIs ti  
   where not exists (select 1   
                     from #Trade t   
                     where t.trade_num = ti.trade_num)  
  
  
   --Set the correct dept code on records  
   update ti  
   set dept_code = t.dept_code  
   from #TIs ti  
          join #Trade t   
             on t.trade_num = ti.trade_num  
  
   -- For non inventory trades get Unrealized and realized PL  
   update ti  
   set d_dist_num = tid.dist_num  
   from #TIs ti  
         join dbo.trade_item_dist tid   
            on tid.trade_num = ti.trade_num and   
               tid.order_num = ti.order_num and   
               tid.item_num = ti.item_num and   
               dist_type = 'D'  
   where d_dist_num is null or   
         d_dist_num <= 0 and   
         ti.item_type = 'T'  
  
   update ti  
   set open_pl = isnull(tmtm.open_pl, 0),  
      closed_pl = isnull(tmtm.closed_pl, 0) + isnull(tmtm.addl_cost_sum, 0),  
      total_pl = isnull(tmtm.open_pl, 0) + isnull(tmtm.closed_pl, 0) + isnull(tmtm.addl_cost_sum, 0),  
      curr_code = tmtm.curr_code  
   from #TIs ti  
          join dbo.tid_mark_to_market tmtm   
             on tmtm.dist_num = ti.d_dist_num and   
                tmtm.mtm_pl_asof_date = ti.asof_date  
   where ti.item_type = 'T'  
  
  
   -- Return the amount  
   if (@my_desk_code is null)  
   begin  
     select dept_code,   
            curr_code,   
            sum(isnull(open_pl,0)) as 'Unrealized Amt',   
            sum(isnull(closed_pl,0)) as 'Realized Amt',   
            sum(isnull(total_pl,0)) as 'Total Amt'  
     from #TIs  
     group by dept_code, curr_code  
   end  
   else   
   begin  
     select o.dept_code,   
            curr_code,   
            sum(isnull(open_pl,0)) as 'Unrealized Amt',   
            sum(isnull(closed_pl,0)) as 'Realized Amt',   
            sum(isnull(total_pl,0)) as 'Total Amt'  
     from #TIs o   
            join dbo.desk d   
               on (d.dept_code = o.dept_code)   
     where d.desk_code in (select * from dbo.fnToSplit(@my_desk_code, ','))  
     group by o.dept_code, curr_code  
End  
drop table #TIs  
drop table #Trade  
drop table #Pos  
 
endofsp:    
return 0    
GO
GRANT EXECUTE ON  [dbo].[usp_daily_paper_pl_report] TO [next_usr]
GO
