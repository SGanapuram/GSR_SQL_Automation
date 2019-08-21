CREATE TABLE [dbo].[posting_bulletin]
(
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_effective_date] [datetime] NOT NULL,
[posting_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[posting_bulletin_updtrg]
on [dbo].[posting_bulletin]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(posting_bulletin) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(posting_bulletin) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.price_source_code = d.price_source_code and 
                 i.price_effective_date = d.price_effective_date )
begin
   raiserror ('(posting_bulletin) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(price_source_code) or  
   update(price_effective_date) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.price_source_code = d.price_source_code and 
                                   i.price_effective_date = d.price_effective_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(posting_bulletin) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[posting_bulletin] ADD CONSTRAINT [posting_bulletin_pk] PRIMARY KEY CLUSTERED  ([price_source_code], [price_effective_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[posting_bulletin] ADD CONSTRAINT [posting_bulletin_fk1] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
GRANT DELETE ON  [dbo].[posting_bulletin] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[posting_bulletin] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[posting_bulletin] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[posting_bulletin] TO [next_usr]
GO
