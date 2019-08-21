CREATE TABLE [dbo].[spec_test]
(
[spec_test_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_test_unit] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_test_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[spec_test_updtrg]
on [dbo].[spec_test]
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
   raiserror ('(spec_test) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(spec_test) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.spec_test_code = d.spec_test_code  and 
                 i.spec_code = d.spec_code and
                 i.cmdty_code = d.cmdty_code )
begin
   raiserror ('(spec_test) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(spec_test_code) or  
   update(spec_code) or 
   update(cmdty_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.spec_test_code = d.spec_test_code  and 
                                   i.spec_code = d.spec_code and
                                   i.cmdty_code = d.cmdty_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(spec_test) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[spec_test] ADD CONSTRAINT [spec_test_pk] PRIMARY KEY CLUSTERED  ([spec_test_code], [spec_code], [cmdty_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[spec_test] ADD CONSTRAINT [spec_test_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[spec_test] ADD CONSTRAINT [spec_test_fk2] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
GRANT DELETE ON  [dbo].[spec_test] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[spec_test] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[spec_test] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[spec_test] TO [next_usr]
GO
