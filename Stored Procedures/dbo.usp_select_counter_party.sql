SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_select_counter_party]
(
   @booking_comp_nums		varchar(8000)
)
as
set nocount on
declare @my_booking_comp_nums	varchar(8000)

   set @my_booking_comp_nums = @booking_comp_nums

   select distinct 
      a.acct_num,
      a.acct_short_name 
   from dbo.exposure e  
           join dbo.account a 
              on e.exp_acct_num = a.acct_num
   where e.exp_booking_comp_num in (select * 
                                    from dbo.udf_split(@my_booking_comp_nums, ','))

return 0
GO
GRANT EXECUTE ON  [dbo].[usp_select_counter_party] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_select_counter_party', NULL, NULL
GO
