SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[x_aud_new_num]
   @daysold   smallint = 30,
   @debugon   char(1) = 'N'
as
set nocount on
declare @num_col_name                   varchar(30),
        @loc_num                        smallint,
        @trans_id                       int,
        @resp_trans_id                  int,
        @cutoffdate                     datetime,
        @rows_deleted                   int,
        @error_occurred                 int,
        @n                              smallint,
        @smsg                           varchar(255),
        @total_rows_deleted             int

   if @daysold is null
      select @daysold = 30

   select @n = @daysold * -1
   select @cutoffdate = dateadd(day, @n, getdate())
   select @total_rows_deleted = 0

   if @debugon = 'Y'
   begin
      select @smsg = 'aud_new_num: Purging records before ' + convert(varchar, @cutoffdate, 101)
      print @smsg
   end

   declare mycursor CURSOR for
      select distinct num_col_name,loc_num 
      from dbo.aud_new_num
      order by num_col_name,loc_num 

   open mycursor
   fetch next from mycursor into @num_col_name,@loc_num 
   while @@FETCH_STATUS = 0
   begin
      select @trans_id = null,
             @resp_trans_id = null
      set rowcount 1
      select @trans_id = aud.trans_id,
             @resp_trans_id = aud.resp_trans_id
      from dbo.aud_new_num aud
      where aud.num_col_name = @num_col_name and
            aud.loc_num = @loc_num and
            exists (select 1
                    from dbo.icts_transaction tt
                    where tt.trans_id = aud.resp_trans_id and
                          tt.type = 'S')
      order by trans_id desc, resp_trans_id desc
      set rowcount 0

      if @debugon = 'Y'
      begin
         print '============================================================'
         select @smsg = 'Processing the primary key (' + rtrim(@num_col_name) + '/'
         select @smsg = @smsg + rtrim(@loc_num) + ')'
         print @smsg
      end

      if @debugon = 'Y'
      begin
         print 'BEFORE:'
         select aud.trans_id,
                aud.resp_trans_id,
                convert(varchar, tt.tran_date, 101) 'trans date',
                tt.type
         from dbo.aud_new_num aud
                 LEFT OUTER JOIN dbo.icts_transaction tt
                     ON aud.resp_trans_id = tt.trans_id
         where aud.num_col_name = @num_col_name and
               aud.loc_num = @loc_num
         order by aud.trans_id desc, aud.resp_trans_id desc
         print ' '
      end

      if @debugon = 'Y'
      begin
         if @trans_id is null
            select @smsg = '  Latest resp_trans_id (NULL)'
         else
            select @smsg = '  Latest resp_trans_id (' + convert(varchar, @resp_trans_id) + ')'
         print @smsg
         select @smsg = '  Start time the query was executed = ' + convert(varchar, getdate(), 109)
         print @smsg
      end

      /* We don't want to remove the latest system-generated record */
      if @trans_id is null or
         @resp_trans_id is null
         select @trans_id = -1, @resp_trans_id = -1

      begin tran
      delete aud
      from dbo.aud_new_num aud
      where num_col_name = @num_col_name and
            loc_num = @loc_num and
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
      select @rows_deleted = @@rowcount,
             @error_occurred = @@error
      if @debugon = 'Y'
      begin
         select @smsg = '  Stop  time the query was executed = ' + convert(varchar, getdate(), 109)
         print @smsg
         print ' '
         print 'AFTER:'
         select aud.trans_id,
                case when aud.resp_trans_id = isnull(@resp_trans_id, -1)
                        then convert(char(25), aud.resp_trans_id) + ' <- latest'
                     else convert(char(25), aud.resp_trans_id)
                end 'resp_trans_id',
                convert(varchar, tt.tran_date, 101) 'trans date',
                tt.type
         from dbo.aud_new_num aud
                 LEFT OUTER JOIN dbo.icts_transaction tt
                     ON aud.resp_trans_id = tt.trans_id
         where aud.num_col_name = @num_col_name and
               aud.loc_num = @loc_num
         order by aud.trans_id desc, aud.resp_trans_id desc
         print ' '
      end
      if @error_occurred > 0 or @rows_deleted = 0
      begin
         rollback tran
         if @error_occurred > 0
            break
      end
      else
      begin
         commit tran
         if @debugon = 'Y'
         begin
            select @smsg = '    => ' + convert(varchar, @rows_deleted) + ' rows were deleted!'
            print @smsg
         end
         select @total_rows_deleted = @total_rows_deleted + @rows_deleted
      end

      fetch mycursor into @num_col_name,@loc_num 
   end /* while */
   close mycursor
   deallocate mycursor
   print ' '
   if @total_rows_deleted = 0
      print 'No rows were deleted from the ''aud_new_num'' table!'
   else
   begin
      if @total_rows_deleted = 1
         print '1 row was deleted from the ''aud_new_num'' table!'
      else
      begin
         select @smsg = convert(varchar, @total_rows_deleted) + ' rows were deleted from ''aud_new_num'' table!'
         print @smsg
      end
   end
return 0
GO
GRANT EXECUTE ON  [dbo].[x_aud_new_num] TO [ictspurge]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'x_aud_new_num', NULL, NULL
GO
