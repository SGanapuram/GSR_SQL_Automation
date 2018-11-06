CREATE TABLE [dbo].[ag_btt_ack_cnfrm_litem]
(
[fdd_oid] [int] NOT NULL,
[fd_oid] [int] NOT NULL,
[line_item_num] [int] NOT NULL,
[parcel_num] [int] NULL,
[event_type] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fail_desc] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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

create trigger [dbo].[ag_btt_ack_cnfrm_litem_deltrg]
on [dbo].[ag_btt_ack_cnfrm_litem]
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
   select @errmsg = '(ag_btt_ack_cnfrm_litem) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_ag_btt_ack_cnfrm_litem
(
fdd_oid,
fd_oid,
line_item_num,
parcel_num,
event_type,
status,
fail_desc,
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
d.fdd_oid,
d.fd_oid,
d.line_item_num,
d.parcel_num,
d.event_type,
d.status,
d.fail_desc,
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

create trigger [dbo].[ag_btt_ack_cnfrm_litem_updtrg]
on [dbo].[ag_btt_ack_cnfrm_litem]
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
   raiserror ('(ag_btt_ack_cnfrm_litem) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(ag_btt_ack_cnfrm_litem) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fdd_oid = d.fdd_oid )
begin
   raiserror ('(ag_btt_ack_cnfrm_litem) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(fdd_oid)  
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.fdd_oid = d.fdd_oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ag_btt_ack_cnfrm_litem) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
insert dbo.aud_ag_btt_ack_cnfrm_litem
(
fdd_oid,
fd_oid,
line_item_num,
parcel_num,
event_type,
status,
fail_desc,
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
d.fdd_oid,
d.fd_oid,
d.line_item_num,
d.parcel_num,
d.event_type,
d.status,
d.fail_desc,
d.trans_id,
i.trans_id,
d.ext_char_col1,
d.ext_char_col2,
d.ext_char_col3,
d.ext_int_col1,
d.ext_int_col2,
d.ext_int_col3
from deleted d, inserted i
where d.fdd_oid = i.fdd_oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[ag_btt_ack_cnfrm_litem] ADD CONSTRAINT [ag_btt_ack_cnfrm_litem_pk] PRIMARY KEY CLUSTERED  ([fdd_oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ag_btt_ack_cnfrm_litem] ADD CONSTRAINT [ag_btt_ack_cnfrm_litem_fk1] FOREIGN KEY ([fdd_oid]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
ALTER TABLE [dbo].[ag_btt_ack_cnfrm_litem] ADD CONSTRAINT [ag_btt_ack_cnfrm_litem_fk2] FOREIGN KEY ([fd_oid]) REFERENCES [dbo].[feed_data] ([oid])
GO
GRANT DELETE ON  [dbo].[ag_btt_ack_cnfrm_litem] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ag_btt_ack_cnfrm_litem] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ag_btt_ack_cnfrm_litem] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ag_btt_ack_cnfrm_litem] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ag_btt_ack_cnfrm_litem', NULL, NULL
GO
