CREATE TABLE [dbo].[temp_value_adjust]
(
[acct_num] [int] NOT NULL,
[tva_seqno] [smallint] NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[begin_date] [datetime] NOT NULL,
[end_date] [datetime] NOT NULL,
[price_delta] [float] NOT NULL,
[price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[temp_value_adjust_updtrg]
on [dbo].[temp_value_adjust]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(temp_value_adjust) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(temp_value_adjust) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and 
                 i.tva_seqno = d.tva_seqno )
begin
   raiserror ('(temp_value_adjust) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) or 
   update(tva_seqno) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and 
                                   i.tva_seqno = d.tva_seqno )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(temp_value_adjust) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[temp_value_adjust] ADD CONSTRAINT [temp_value_adjust_pk] PRIMARY KEY CLUSTERED  ([acct_num], [tva_seqno]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[temp_value_adjust] ADD CONSTRAINT [temp_value_adjust_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[temp_value_adjust] ADD CONSTRAINT [temp_value_adjust_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[temp_value_adjust] ADD CONSTRAINT [temp_value_adjust_fk3] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
GRANT DELETE ON  [dbo].[temp_value_adjust] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[temp_value_adjust] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[temp_value_adjust] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[temp_value_adjust] TO [next_usr]
GO
