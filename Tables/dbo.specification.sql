CREATE TABLE [dbo].[specification]
(
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sort_ordering_value] [smallint] NULL,
[spec_group_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[spec_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__specifica__spec___43E1002F] DEFAULT ('N'),
[spec_val_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[specification_deltrg]
on [dbo].[specification]
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
   select @errmsg = '(specification) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_specification
   (spec_code,
    spec_desc,
    sort_ordering_value,
    spec_group_code,
    trans_id,
    resp_trans_id,
    spec_type,
    spec_val_uom_code)
select
   d.spec_code,
   d.spec_desc,
   d.sort_ordering_value,
   d.spec_group_code,
   d.trans_id,
   @atrans_id,
   d.spec_type,
   d.spec_val_uom_code
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[specification_updtrg]
on [dbo].[specification]
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
   raiserror ('(specification) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(specification) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.spec_code = d.spec_code )
begin
   raiserror ('(specification) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(spec_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.spec_code = d.spec_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(specification) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_specification
      (spec_code,
       spec_desc,
       sort_ordering_value,
       spec_group_code,
       trans_id,
       resp_trans_id,
       spec_type,
       spec_val_uom_code)
   select
      d.spec_code,
      d.spec_desc,
      d.sort_ordering_value,
      d.spec_group_code,
      d.trans_id,
      i.trans_id,
      d.spec_type,
      d.spec_val_uom_code
   from deleted d, inserted i
   where d.spec_code = i.spec_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[specification] ADD CONSTRAINT [chk_spec_type] CHECK (([spec_type]='S' OR [spec_type]='N' OR [spec_type]='A'))
GO
ALTER TABLE [dbo].[specification] ADD CONSTRAINT [specification_pk] PRIMARY KEY CLUSTERED  ([spec_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[specification] ADD CONSTRAINT [specification_fk1] FOREIGN KEY ([spec_group_code]) REFERENCES [dbo].[specification_group] ([spec_group_code])
GO
GRANT DELETE ON  [dbo].[specification] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[specification] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[specification] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[specification] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'specification', NULL, NULL
GO
