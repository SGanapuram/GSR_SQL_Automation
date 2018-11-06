SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_undelete_portfolio]
(
   @traderInit	char(3) = null,
   @shortName	  varchar(25) = null,
   @aTransId	  int = null
)
as
set nocount on
declare @parentPortNum int
declare @portNum int
declare @delPortNum int
declare @currPortNum int
declare @status int
declare @portClass char(1)

   /* check if all the values are present */
   if (@traderInit is null) or
      (@shortName is null) or
      (@aTransId is null)
      return -595

   /* find out the parent trader portfolio account number */
   select @parentPortNum = null
   select @parentPortNum = port_num 
   from dbo.portfolio 
   where port_type = 'IT' and
         owner_init = @traderInit

   if (@parentPortNum is null)
      return -590

   select @currPortNum = port_num, 
          @portClass = port_class 
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
      return -596

   /* now delete from delete group and add to active group */
   delete from dbo.portfolio_group 
   where parent_port_num = @delPortNum and 
         port_num = @currPortNum

   insert into dbo.portfolio_group 
      values (@parentPortNum,@currPortNum,'N',@aTransId)

   /* 
   update dbo.portfolio_group
   set parent_port_num = @parentPortNum,
       trans_id = @aTransId
   where parent_port_num = @delPortNum and
         port_num = @currPortNum
   if (@@rowcount = 0)
      return -597
   */
   if (@portClass = 'O')
      return 1
   else if (@portClass = 'P')
      return 2
   else if (@portClass = 'D')
      return 3
   else 
      return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_undelete_portfolio] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_undelete_portfolio', NULL, NULL
GO
