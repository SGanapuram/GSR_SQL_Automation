CREATE TABLE [dbo].[pm_type_4_record]
(
[fdd_id] [int] NOT NULL,
[company_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[splc_code] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[record_count] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_qty_sub_total] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_qty_sub_total] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pm_type_4_record_updtrg]
on [dbo].[pm_type_4_record]
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
   raiserror ('(pm_type_4_record) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(pm_type_4_record) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fdd_id = d.fdd_id)
begin
   select @errmsg = '(pm_type_4_record) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.fdd_id) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(fdd_id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.fdd_id = d.fdd_id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(pm_type_4_record) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[pm_type_4_record] ADD CONSTRAINT [pm_type_4_record_pk] PRIMARY KEY CLUSTERED  ([fdd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pm_type_4_record_idx1] ON [dbo].[pm_type_4_record] ([company_code], [record_count], [splc_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pm_type_4_record_idx2] ON [dbo].[pm_type_4_record] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pm_type_4_record] ADD CONSTRAINT [pm_type_4_record_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[pm_type_4_record] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pm_type_4_record] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pm_type_4_record] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pm_type_4_record] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'pm_type_4_record', NULL, NULL
GO
