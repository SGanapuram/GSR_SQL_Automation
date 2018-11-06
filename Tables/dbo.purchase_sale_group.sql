CREATE TABLE [dbo].[purchase_sale_group]
(
[oid] [int] NOT NULL,
[purchase_sale_group_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[booking_comp_num] [int] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__purchase___p_s_i__35C7EB02] DEFAULT ('P'),
[cmdty_group_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[purchase_sale_group_deltrg]
on [dbo].[purchase_sale_group]
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
   select @errmsg = '(purchase_sale_group) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_purchase_sale_group
   (oid,
    purchase_sale_group_code,
    booking_comp_num,
    p_s_ind,
    cmdty_group_code,
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.purchase_sale_group_code,
   d.booking_comp_num,
   d.p_s_ind,
   d.cmdty_group_code,
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

create trigger [dbo].[purchase_sale_group_updtrg]
on [dbo].[purchase_sale_group]
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
   raiserror ('(purchase_sale_group) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(purchase_sale_group) New trans_id must be larger than original trans_id.'
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
   raiserror ('(purchase_sale_group) new trans_id must not be older than current trans_id.',10,1)
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
      raiserror ('(purchase_sale_group) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_purchase_sale_group
      (oid,
       purchase_sale_group_code,
       booking_comp_num,
       p_s_ind,
       cmdty_group_code,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.purchase_sale_group_code,
      d.booking_comp_num,
      d.p_s_ind,
      d.cmdty_group_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid
 
/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[purchase_sale_group] ADD CONSTRAINT [CK__purchase___p_s_i__36BC0F3B] CHECK (([p_s_ind]='S' OR [p_s_ind]='P'))
GO
ALTER TABLE [dbo].[purchase_sale_group] ADD CONSTRAINT [purchase_sale_group_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [purchase_sale_group_idx1] ON [dbo].[purchase_sale_group] ([booking_comp_num], [p_s_ind], [cmdty_group_code], [purchase_sale_group_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[purchase_sale_group] ADD CONSTRAINT [purchase_sale_group_fk1] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[purchase_sale_group] ADD CONSTRAINT [purchase_sale_group_fk2] FOREIGN KEY ([cmdty_group_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[purchase_sale_group] ADD CONSTRAINT [purchase_sale_group_fk3] FOREIGN KEY ([purchase_sale_group_code]) REFERENCES [dbo].[ps_group_code_ref] ([purchase_sale_group_code])
GO
GRANT DELETE ON  [dbo].[purchase_sale_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[purchase_sale_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[purchase_sale_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[purchase_sale_group] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'purchase_sale_group', NULL, NULL
GO
