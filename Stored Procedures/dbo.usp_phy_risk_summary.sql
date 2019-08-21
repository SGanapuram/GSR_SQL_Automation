SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_phy_risk_summary]
(
   @booking_comp_nums    varchar(8000),        
   @report_date	         datetime,
   @debugon              bit = 0   
)
as
set nocount on
declare @rows_affected          int, 
        @smsg                   varchar(255), 
        @status                 int, 
        @oid                    numeric(18, 0), 
        @stepid                 smallint, 
        @session_started        varchar(30), 
        @session_ended          varchar(30), 
        @my_booking_comp_nums	  varchar(8000),        
         @my_report_date	     	datetime

select @my_booking_comp_nums = @booking_comp_nums, 
       @my_report_date = @report_date


if @my_booking_comp_nums ='0'
begin
   select  
      ac1.acct_short_name 'Booking Company',
      e.exp_acct_num, 
      a.acct_short_name 'Counter Party',
      isnull(limit_amt1,0) as 'Credit Limit',
      case when cs.sector_desc is null then 'NOSECTOR' 
           else cs.sector_desc end as 'Account Group',
      sum(isnull(cash_exp_amt,0)) as 'Credit Exposure'
   from dbo.exposure e
   join dbo.exposure_detail mce 
        on mce.exposure_num=e.exposure_num
   left outer join (select acct_num, sum(isnull(limit_amt,0)) 'limit_amt1' from dbo.credit_limit cl1 where cl1.order_type_code='PHYSICAL' and limit_direction='O'group by acct_num) cl 
        on cl.acct_num=e.exp_acct_num
   join dbo.account a 
        on a.acct_num=e.exp_acct_num
   left outer join dbo.account ac1 
          on ac1.acct_num=e.exp_booking_comp_num
   left outer join dbo.account_credit_info aci 
        on a.acct_num=aci.acct_num
   left outer join dbo.credit_sector cs 
        on aci.sector_code=cs.sector_code
where exp_order_type_group='PHYSICAL' and ( cash_from_date <= @my_report_date and cash_to_date >= @my_report_date) 
   group by e.exp_acct_num,a.acct_short_name,ac1.acct_short_name,limit_amt1, cs.sector_desc
   order by e.exp_acct_num,a.acct_short_name,ac1.acct_short_name,limit_amt1, cs.sector_desc
end
else
begin
  select 
     ac1.acct_short_name 'Booking Company',
     e.exp_acct_num, 
     a.acct_short_name 'Counter Party',
     isnull(limit_amt1,0) as 'Credit Limit',
     case when cs.sector_desc is null then 'NOSECTOR' 
          else cs.sector_desc end as 'Account Group',
     sum(isnull(cash_exp_amt,0)) as 'Credit Exposure'
  from dbo.exposure e
  join dbo.exposure_detail mce 
          on mce.exposure_num=e.exposure_num
  left outer join (select acct_num, sum(isnull(limit_amt,0)) 'limit_amt1' 
                      from dbo.credit_limit cl1 
		          where  cl1.book_comp_num in (Select * from dbo.udf_split(@my_booking_comp_nums,',')) 
			         and cl1.order_type_code='PHYSICAL' and limit_direction='O' group by acct_num) cl 
          on cl.acct_num=e.exp_acct_num
  join dbo.account a 
          on a.acct_num=e.exp_acct_num
   left outer join dbo.account ac1 
          on ac1.acct_num=e.exp_booking_comp_num
  left outer join dbo.account_credit_info aci 
          on a.acct_num=aci.acct_num
  left outer join dbo.credit_sector cs on aci.sector_code=cs.sector_code
  where exp_booking_comp_num in (Select * from dbo.udf_split(@my_booking_comp_nums,',')) 
  and exp_order_type_group='PHYSICAL'  and ( cash_from_date <= @my_report_date and cash_to_date >= @my_report_date) 
  group by e.exp_acct_num,a.acct_short_name,ac1.acct_short_name,limit_amt1, cs.sector_desc
  order by e.exp_acct_num,a.acct_short_name,ac1.acct_short_name,limit_amt1, cs.sector_desc
end

endofsp: 
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_phy_risk_summary] TO [next_usr]
GO
