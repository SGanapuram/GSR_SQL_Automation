SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_delete_portfolio]
(
   @traderInit		char(3) = null,
   @shortName		  varchar(25) = null,
   @modInit		    char(3) = null,
   @locNum		    int = null,
   @aTransId		  int = null
)
as
set nocount on
declare @parentPortNum int
declare @portNum int
declare @delPortNum int
declare @currPortNum int
declare @status int

   /* check if all the values are present */
   if (@traderInit is null) or
      (@shortName is null) or
      (@modInit is null) or
      (@locNum is null) or
      (@aTransId is null)
      return -589

   /* find out the parent trader portfolio account number */
   select @parentPortNum = null
   select @parentPortNum = port_num 
   from dbo.portfolio 
   where port_type = 'IT' and
         owner_init = @traderInit

   if (@parentPortNum is null)
      return -590

   select @currPortNum = port_num 
   from dbo.portfolio 
   where port_type = 'R' and 
         port_short_name = @shortName and 
         owner_init = @traderInit

   if (@currPortNum is null)
      return -593

   /* find out if there is a deleted portfolio account */
   select @delPortNum = null
   select @delPortNum = port_num 
   from dbo.portfolio 
   where port_short_name = 'DELETED' and 
         owner_init = null and 
         port_type = 'IT'

   if (@delPortNum is null) 
   begin
      /* get new num for portfolio */
      exec @status = dbo.update2_new_num @portNum output, 
                                         'loc_num', 
                                         @locNum, 
                                         'num_col_name',
		                                     'port_num', 
		                                     null,
		                                     null,
		                                     null,
		                                     null,
		                                     1
      if (@status != 0)
         return -591

      insert into dbo.portfolio
          (port_num, port_type, desired_pl_curr_code, port_short_name,
           port_full_name, num_history_days, trans_id)
	      values(@portNum, 'IT', 'USD', 'DELETED',
               'All Portfolios Marked For Deletion', 0, @aTransId)
      if (@@rowcount != 1)
         return -592

      select @delPortNum = @portNum
   end

   /* now delete from existing group and add to deleted group */
   delete from dbo.portfolio_group 
   where parent_port_num = @parentPortNum and 
         port_num = @currPortNum

   insert into dbo.portfolio_group 
     values (@delPortNum,@currPortNum,'N',@aTransId)

   /* 
   update dbo.portfolio_group
   set parent_port_num = @delPortNum,
       trans_id = @aTransId
   where parent_port_num = @parentPortNum and
         port_num = @currPortNum
   if (@@rowcount = 0)
      return -594
   */
return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_delete_portfolio] TO [next_usr]
GO
