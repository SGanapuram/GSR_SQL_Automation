CREATE TABLE [dbo].[uic_rpt_criteria]
(
[oid] [int] NOT NULL,
[report_type_id] [int] NOT NULL,
[criteria_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[display_entity_id] [int] NULL,
[display_value_selector] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[report_value_selector] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[uic_rpt_criteria_deltrg]
on [dbo].[uic_rpt_criteria]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(uic_rpt_criteria) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_uic_rpt_criteria
   (oid,
    report_type_id,
    criteria_desc,
    display_entity_id, 
    display_value_selector,  
    report_value_selector,  
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.report_type_id,
   d.criteria_desc,
   d.display_entity_id, 
   d.display_value_selector,  
   d.report_value_selector,  
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[uic_rpt_criteria_updtrg]
on [dbo].[uic_rpt_criteria]
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
    raiserror ('(uic_rpt_criteria) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(uic_rpt_criteria) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   raiserror ('(uic_rpt_criteria) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

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
      raiserror ('(uic_rpt_criteria) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_uic_rpt_criteria
      (oid,
       report_type_id,
       criteria_desc,
       display_entity_id, 
       display_value_selector,  
       report_value_selector,  
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.report_type_id,
      d.criteria_desc,
      d.display_entity_id, 
      d.display_value_selector,  
      d.report_value_selector,  
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[uic_rpt_criteria] ADD CONSTRAINT [uic_rpt_criteria_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uic_rpt_criteria_idx1] ON [dbo].[uic_rpt_criteria] ([report_type_id], [criteria_desc]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[uic_rpt_criteria] ADD CONSTRAINT [uic_rpt_criteria_fk1] FOREIGN KEY ([report_type_id]) REFERENCES [dbo].[uic_report_type] ([oid])
GO
ALTER TABLE [dbo].[uic_rpt_criteria] ADD CONSTRAINT [uic_rpt_criteria_fk2] FOREIGN KEY ([display_entity_id]) REFERENCES [dbo].[icts_entity_name] ([oid])
GO
GRANT DELETE ON  [dbo].[uic_rpt_criteria] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[uic_rpt_criteria] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[uic_rpt_criteria] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[uic_rpt_criteria] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'uic_rpt_criteria', NULL, NULL
GO
