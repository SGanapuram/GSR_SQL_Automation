CREATE TABLE [dbo].[ag_consignee_tankage]
(
[oid] [int] NOT NULL,
[entity_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[source] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_type] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[carrier_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[location_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ag_consignee_tankage_updtrg]
on [dbo].[ag_consignee_tankage]
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
   raiserror ('(ag_consignee_tankage) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(ag_consignee_tankage) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(ag_consignee_tankage) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ag_consignee_tankage) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[ag_consignee_tankage] ADD CONSTRAINT [ag_consignee_tankage_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ag_consignee_tankage] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ag_consignee_tankage] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ag_consignee_tankage] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ag_consignee_tankage] TO [next_usr]
GO
