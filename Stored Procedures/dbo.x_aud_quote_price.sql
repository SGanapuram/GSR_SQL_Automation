SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[x_aud_quote_price]
(
   @daysold   smallint = 30,
   @debugon   char(1) = 'N'
)
as
set nocount on
set xact_abort on
declare @trade_num          int,
        @order_num          smallint,
        @item_num           smallint,
        @accum_num          smallint,
        @qpp_num            smallint,
        @nominal_date       datetime,
        @trans_id           int,
        @resp_trans_id      int,
        @cutoffdate         datetime,
        @rows_deleted       int,
        @errcode            int,
        @n                  smallint,
        @smsg               varchar(max),
        @total_rows_deleted int,
        @tempstr            varchar(800)
 
   set @errcode = 0
   if @daysold is null
      set @daysold = 30
 
   set @n = @daysold * -1
   set @cutoffdate = dateadd(day, @n, getdate())
   set @total_rows_deleted = 0
 
   if @debugon = 'Y'
   begin
      set @smsg = convert(varchar, @cutoffdate, 101)
      RAISERROR('aud_quote_price: Purging records before ''%s''', 0, 1, @smsg) with nowait
   end
 
   declare mycursor CURSOR FORWARD_ONLY READ_ONLY for
      select distinct trade_num, order_num, item_num, accum_num, qpp_num, nominal_date
      from dbo.aud_quote_price
      order by trade_num, order_num, item_num, accum_num, qpp_num, nominal_date
 
   open mycursor
   fetch next from mycursor into @trade_num, @order_num, @item_num, @accum_num, @qpp_num, @nominal_date
   while @@FETCH_STATUS = 0
   begin
      set @trans_id = null
      set @resp_trans_id = null
      select top 1
         @trans_id = aud.trans_id,
         @resp_trans_id = aud.resp_trans_id
      from dbo.aud_quote_price aud
      where aud.trade_num = @trade_num and
            aud.order_num = @order_num and
            aud.item_num = @item_num and
            aud.accum_num = @accum_num and
            aud.qpp_num = @qpp_num and
            aud.nominal_date = @nominal_date and
            exists (select 1
                    from dbo.icts_transaction tt
                    where tt.trans_id = aud.resp_trans_id and
                          tt.type = 'S')
      order by trans_id desc, resp_trans_id desc
 
      if @debugon = 'Y'
      begin
         RAISERROR('============================================================', 0, 1) with nowait
         set @tempstr = cast(@trade_num as varchar) + '/' + cast(@order_num as varchar) + '/' + cast(@item_num as varchar) + '/' + cast(@accum_num as varchar) + '/' + cast(@qpp_num as varchar) + '/' +
 convert(varchar, @nominal_date, 101)
         RAISERROR('Processing the primary key (%s)', 0, 1, @tempstr) with nowait
      end
 
      if @debugon = 'Y'
      begin
         RAISERROR('BEFORE:', 0, 1) with nowait
         select aud.trans_id,
                aud.resp_trans_id,
                convert(varchar, tt.tran_date, 101) 'trans date',
                tt.type
         from dbo.aud_quote_price aud
                 LEFT OUTER JOIN dbo.icts_transaction tt
                    ON aud.resp_trans_id = tt.trans_id
         where aud.trade_num = @trade_num and
               aud.order_num = @order_num and
               aud.item_num = @item_num and
               aud.accum_num = @accum_num and
               aud.qpp_num = @qpp_num and
               aud.nominal_date = @nominal_date
         order by aud.trans_id desc, aud.resp_trans_id desc
         RAISERROR(' ', 0, 1) with nowait
      end
 
      if @debugon = 'Y'
      begin
         if @trans_id is null
            RAISERROR('  Latest resp_trans_id (NULL)', 0, 1) with nowait
         else
            RAISERROR('  Latest resp_trans_id (%d)', 0, 1, @resp_trans_id) with nowait
         set @smsg = convert(varchar, getdate(), 109)
         RAISERROR('  Start time the query was executed = %s', 0, 1, @smsg) with nowait
      end
 
      /* We don't want to remove the latest system-generated record */
      if @trans_id is null or
         @resp_trans_id is null
         select @trans_id = -1, @resp_trans_id = -1
 
      set @errcode = 0
      begin tran
      begin try
        delete aud
        from dbo.aud_quote_price aud
        where aud.trade_num = @trade_num and
              aud.order_num = @order_num and
              aud.item_num = @item_num and
              aud.accum_num = @accum_num and
              aud.qpp_num = @qpp_num and
              aud.nominal_date = @nominal_date and
              trans_id <> @trans_id and
              resp_trans_id <> @resp_trans_id and
              exists (select 1
                      from dbo.icts_transaction tt
                      where aud.resp_trans_id = tt.trans_id and
                            tt.tran_date < @cutoffdate and
                            tt.type <> 'U') and
              not exists (select 1
                          from dbo.send_to_SAP sap
                          where (sap.archived_ind is null or
                                 sap.archived_ind = 'A') and
                                aud.trans_id <= sap.op_trans_id and
                                aud.resp_trans_id > sap.op_trans_id)
         set @rows_deleted = @@rowcount
       end try
       begin catch
         if @@trancount > 0
            rollback tran
         set @errcode = ERROR_NUMBER()
         set @smsg = ERROR_MESSAGE()
         RAISERROR('=> Failed to delete aud_quote_price records due to the error:', 0, 1) with nowait
         RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
       end catch
 
       if @debugon = 'Y'
       begin
          set @smsg = convert(varchar, getdate(), 109)
          RAISERROR('  Stop  time the query was executed = %s', 0, 1, @smsg) with nowait
          RAISERROR(' ', 0, 1) with nowait
          RAISERROR('AFTER:', 0, 1) with nowait
          select aud.trans_id,
                 case when aud.resp_trans_id = isnull(@resp_trans_id, -1)
                         then convert(char(25), aud.resp_trans_id) + ' <- latest'
                      else convert(char(25), aud.resp_trans_id)
                 end 'resp_trans_id',
                 convert(varchar, tt.tran_date, 101) 'trans date',
                 tt.type
          from dbo.aud_quote_price aud
                  LEFT OUTER JOIN dbo.icts_transaction tt
                     ON aud.resp_trans_id = tt.trans_id
         where aud.trade_num = @trade_num and
               aud.order_num = @order_num and
               aud.item_num = @item_num and
               aud.accum_num = @accum_num and
               aud.qpp_num = @qpp_num and
               aud.nominal_date = @nominal_date
         order by aud.trans_id desc, aud.resp_trans_id desc
         RAISERROR(' ', 0, 1) with nowait
      end
      if @errcode > 0
         break
      commit tran
      if @debugon = 'Y'
      begin
         if @rows_deleted > 0
            RAISERROR('    => %d aud_quote_price rows were deleted!', 0, 1, @rows_deleted) with nowait
         else
            RAISERROR('    => No aud_quote_price rows were deleted!', 0, 1) with nowait
      end
      set @total_rows_deleted = @total_rows_deleted + @rows_deleted
 
      fetch next from mycursor into @trade_num, @order_num, @item_num, @accum_num, @qpp_num, @nominal_date
   end /* while */
   close mycursor
   deallocate mycursor
   RAISERROR(' ', 0, 1) with nowait
   if @total_rows_deleted = 0
      RAISERROR('No rows were deleted from the ''aud_quote_price'' table!', 0, 1) with nowait
   else
   begin
      if @total_rows_deleted = 1
         RAISERROR('1 aud_quote_price record was deleted!', 0, 1) with nowait
      else
         RAISERROR('%d aud_quote_price records were deleted!', 0, 1, @total_rows_deleted) with nowait
   end
   return 0
GO
GRANT EXECUTE ON  [dbo].[x_aud_quote_price] TO [ictspurge]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'x_aud_quote_price', NULL, NULL
GO
