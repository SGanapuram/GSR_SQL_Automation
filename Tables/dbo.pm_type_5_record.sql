CREATE TABLE [dbo].[pm_type_5_record]
(
[fdd_id] [int] NOT NULL,
[record_count] [int] NOT NULL,
[data_company_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[grand_tot_gross_qty] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[grand_tot_net_qty] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[transmission_date] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[transmission_time] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pm_type_5_record_updtrg]
on [dbo].[pm_type_5_record]
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
   raiserror ('(pm_type_5_record) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(pm_type_5_record) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fdd_id = d.fdd_id)
begin
   select @errmsg = '(pm_type_5_record) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.fdd_id) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
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
      raiserror ('(pm_type_5_record) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[pm_type_5_record] ADD CONSTRAINT [pm_type_5_record_pk] PRIMARY KEY CLUSTERED  ([fdd_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pm_type_5_record] ADD CONSTRAINT [pm_type_5_record_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[pm_type_5_record] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pm_type_5_record] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pm_type_5_record] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pm_type_5_record] TO [next_usr]
GO
