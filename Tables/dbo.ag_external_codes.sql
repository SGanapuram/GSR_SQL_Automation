CREATE TABLE [dbo].[ag_external_codes]
(
[oid] [int] NOT NULL,
[code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_type] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[source] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[ext_char_col1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col3] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_int_col1] [int] NULL,
[ext_int_col2] [int] NULL,
[ext_int_col3] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ag_external_codes_deltrg]
on [dbo].[ag_external_codes]
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
   select @errmsg = '(ag_external_codes) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_ag_external_codes
(
oid,
code,
description,
entity_type,
source,
trans_id,
resp_trans_id,
ext_char_col1,
ext_char_col2,
ext_char_col3,
ext_int_col1,
ext_int_col2,
ext_int_col3
)
select
d.oid,
d.code,
d.description,
d.entity_type,
d.source,
d.trans_id,
@atrans_id,
d.ext_char_col1,
d.ext_char_col2,
d.ext_char_col3,
d.ext_int_col1,
d.ext_int_col2,
d.ext_int_col3
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ag_external_codes_updtrg]
on [dbo].[ag_external_codes]
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
   raiserror ('(ag_external_codes) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(ag_external_codes) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(ag_external_codes) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid)  
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ag_external_codes) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
insert dbo.aud_ag_external_codes
(
oid,
code,
description,
entity_type,
source,
trans_id,
resp_trans_id,
ext_char_col1,
ext_char_col2,
ext_char_col3,
ext_int_col1,
ext_int_col2,
ext_int_col3
)
select
d.oid,
d.code,
d.description,
d.entity_type,
d.source,
d.trans_id,
i.trans_id,
d.ext_char_col1,
d.ext_char_col2,
d.ext_char_col3,
d.ext_int_col1,
d.ext_int_col2,
d.ext_int_col3
from deleted d, inserted i
where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[ag_external_codes] ADD CONSTRAINT [ag_external_codes_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ag_external_codes] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ag_external_codes] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ag_external_codes] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ag_external_codes] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ag_external_codes', NULL, NULL
GO
