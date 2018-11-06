SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_prob_exp_loss]
(	
   @booking_comp_nums	varchar(8000),
   @exp_acct_num	    varchar(8000)
)
as
set nocount on
declare @my_booking_comp_nums	varchar(8000),
	      @my_exp_acct_num	    varchar(8000)

   select @my_booking_comp_nums = @booking_comp_nums, 
          @my_exp_acct_num = @exp_acct_num

   select (select acct_short_name 
           from dbo.account 
           where acct_num = ex.exp_booking_comp_num)as booking_name, 
          (select acct_short_name 
           from dbo.account 
           where acct_num = ex.exp_acct_num) as counter_name,
          case when aei.fld_value3 is null then 0 
               else convert(int,aei.fld_value3) 
          end as probability,
          sum(cash_exp_amt) as total_exposure 
   from dbo.exposure_detail ed 
           join dbo.exposure ex 
              on ex.exposure_num = ed.exposure_num
           left outer join dbo.account_ext_info aei 
              on aei.acct_num=ex.exp_acct_num
   where ex.exp_booking_comp_num in (select * 
                                     from dbo.udf_split(@my_booking_comp_nums, ',')) and 
         ex.exp_acct_num in (select * from dbo.udf_split(@my_exp_acct_num, ','))
   group by ex.exp_booking_comp_num, 
            ex.exp_acct_num,
            (case when aei.fld_value3 is null then 0 
                  else convert(int,aei.fld_value3)
             end)
   order by booking_name,
            counter_name,
            (case when aei.fld_value3 is null then 0 
                  else convert(int,aei.fld_value3)
             end)

return 0
GO
GRANT EXECUTE ON  [dbo].[usp_prob_exp_loss] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_prob_exp_loss', NULL, NULL
GO
