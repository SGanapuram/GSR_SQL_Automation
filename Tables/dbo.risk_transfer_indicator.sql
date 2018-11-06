CREATE TABLE [dbo].[risk_transfer_indicator]
(
[risk_transfer_ind_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[risk_transfer_ind_desc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[risk_transfer_indicator_deltrg]
on [dbo].[risk_transfer_indicator]
for delete
as
declare @num_rows   int,
        @errmsg     varchar(255),
        @atrans_id  int

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
   select @errmsg = '(risk_transfer_indicator) Failed to obtain a valid responsible trans_id.'
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

/* AUDIT_CODE_BEGIN */
insert dbo.aud_risk_transfer_indicator
   (risk_transfer_ind_code,
    risk_transfer_ind_desc,  
    trans_id,
    resp_trans_id)
select
   d.risk_transfer_ind_code,
   d.risk_transfer_ind_desc, 
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

create trigger [dbo].[risk_transfer_indicator_updtrg]
on [dbo].[risk_transfer_indicator]
for update
as
declare @num_rows       int,
        @count_num_rows int,
        @dummy_update   int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(risk_transfer_indicator) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(risk_transfer_indicator) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end


if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.risk_transfer_ind_code = d.risk_transfer_ind_code )
begin
   raiserror ('(risk_transfer_indicator) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(risk_transfer_ind_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.risk_transfer_ind_code = d.risk_transfer_ind_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(risk_transfer_indicator) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_risk_transfer_indicator
   (risk_transfer_ind_code,
    risk_transfer_ind_desc, 
    trans_id,
    resp_trans_id)
   select
      d.risk_transfer_ind_code,
      d.risk_transfer_ind_desc, 
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.risk_transfer_ind_code = i.risk_transfer_ind_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[risk_transfer_indicator] ADD CONSTRAINT [risk_transfer_indicator_pk] PRIMARY KEY CLUSTERED  ([risk_transfer_ind_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[risk_transfer_indicator] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[risk_transfer_indicator] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[risk_transfer_indicator] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[risk_transfer_indicator] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'risk_transfer_indicator', NULL, NULL
GO
