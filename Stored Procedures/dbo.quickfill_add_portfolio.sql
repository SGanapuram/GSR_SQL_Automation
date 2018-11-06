SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_add_portfolio]
(
   @traderInit      char(3) = null,
   @shortName       varchar(25) = null,
   @longName        varchar(255) = null,
   @tpsAcct         varchar(40) = null,
   @rnAcct          varchar(40) = null,
   @portClass       char(1) = null,
   @currCode        char(8) = null,
   @locNum	        int = null,
   @aTransId	      int = null
)
as
set nocount on
set xact_abort on
declare @parentPortNum int
declare @status int
declare @portNum int
declare @result int

   /* check if all the values are present */
   if (@traderInit is null) or
      (@shortName is null) or
      (@longName is null) or 
      (@tpsAcct is null) or
      (@rnAcct is null) or
      (@portClass is null) or
      (@currCode is null)
      return -568

   /* find out the parent trader portfolio account number */
   select @parentPortNum = null
   select @parentPortNum = port_num 
   from dbo.portfolio 
   where port_type = 'IT' and
         owner_init = @traderInit
   if (@parentPortNum is null)
      return -569

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
      return -570

   begin tran
   insert into dbo.portfolio
      (port_num,
       port_type,
       desired_pl_curr_code,
       port_short_name,
       port_full_name,
       port_class,
       owner_init,
       num_history_days,
       trans_id)
     values (@portNum,
             'R',
             @currCode,
             @shortName,
             @longName,
             @portClass,
             @traderInit,
             0,
             @aTransId)
   if (@@rowcount != 1) 
   begin
      rollback tran
      return -571
   end
   
   insert into dbo.portfolio_icon
     (port_num, icon, trans_id)
    values(@portNum, null, @aTransId)
   if (@@rowcount != 1) 
   begin
      rollback tran
      return -572
   end

   insert into dbo.portfolio_comment
      (port_num, cmnt_text, trans_id)
     values(@portNum, null, @aTransId)
   if (@@rowcount != 1) 
   begin
      rollback tran
      return -573
   end

   insert into dbo.portfolio_group
       (parent_port_num, port_num, is_link_ind, trans_id)
     values(@parentPortNum, @portNum, 'N', @aTransId)
   if (@@rowcount != 1) 
   begin
      rollback tran
      return -574
   end

   insert into dbo.portfolio_alias
       (port_num,alias_source_code,port_alias_name,trans_id)
     values(@portNum,'PEI',@tpsAcct,@aTransId)
   if (@@rowcount != 1) 
   begin
      rollback tran
      return -575
   end

   insert into dbo.portfolio_alias
      (port_num,alias_source_code,port_alias_name, trans_id)
    values(@portNum,'BSI',@rnAcct,@aTransId)
   if (@@rowcount != 1) 
   begin
      rollback tran
      return -576
   end
   commit tran

   select @portNum
   return @portNum
GO
GRANT EXECUTE ON  [dbo].[quickfill_add_portfolio] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_add_portfolio', NULL, NULL
GO
