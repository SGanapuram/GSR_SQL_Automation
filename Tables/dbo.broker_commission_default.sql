CREATE TABLE [dbo].[broker_commission_default]
(
[brkr_comm_dflt_num] [int] NOT NULL,
[brkr_num] [int] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code_key] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_comm_amt] [float] NOT NULL,
[brkr_comm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[brkr_comm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_cont_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[broker_commission_defau_deltrg]
on [dbo].[broker_commission_default]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(broker_commission_default) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_broker_commission_default
   (brkr_comm_dflt_num,
    brkr_num,
    p_s_ind,
    acct_num,
    cmdty_code,
    del_loc_code_key,
    order_type_code,
    brkr_comm_amt,
    brkr_comm_curr_code,
    brkr_comm_uom_code,
    brkr_cont_num,
    trans_id,
    resp_trans_id)
select
   d.brkr_comm_dflt_num,
   d.brkr_num,
   d.p_s_ind,
   d.acct_num,
   d.cmdty_code,
   d.del_loc_code_key,
   d.order_type_code,
   d.brkr_comm_amt,
   d.brkr_comm_curr_code,
   d.brkr_comm_uom_code,
   d.brkr_cont_num,
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

create trigger [dbo].[broker_commission_defau_updtrg]
on [dbo].[broker_commission_default]
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
   raiserror ('(broker_commission_default) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(broker_commission_default) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.brkr_comm_dflt_num = d.brkr_comm_dflt_num )
begin
   raiserror ('(broker_commission_default) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(brkr_comm_dflt_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.brkr_comm_dflt_num = d.brkr_comm_dflt_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(broker_commission_default) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_broker_commission_default
      (brkr_comm_dflt_num,
       brkr_num,
       p_s_ind,
       acct_num,
       cmdty_code,
       del_loc_code_key,
       order_type_code,
       brkr_comm_amt,
       brkr_comm_curr_code,
       brkr_comm_uom_code,
       brkr_cont_num,
       trans_id,
       resp_trans_id)
   select
      d.brkr_comm_dflt_num,
      d.brkr_num,
      d.p_s_ind,
      d.acct_num,
      d.cmdty_code,
      d.del_loc_code_key,
      d.order_type_code,
      d.brkr_comm_amt,
      d.brkr_comm_curr_code,
      d.brkr_comm_uom_code,
      d.brkr_cont_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.brkr_comm_dflt_num = i.brkr_comm_dflt_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[broker_commission_default] ADD CONSTRAINT [broker_commission_default_pk] PRIMARY KEY CLUSTERED  ([brkr_comm_dflt_num]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [broker_commission_default_idx2] ON [dbo].[broker_commission_default] ([brkr_num], [p_s_ind], [acct_num], [cmdty_code], [del_loc_code_key], [order_type_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[broker_commission_default] ADD CONSTRAINT [broker_commission_default_fk1] FOREIGN KEY ([brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[broker_commission_default] ADD CONSTRAINT [broker_commission_default_fk2] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[broker_commission_default] ADD CONSTRAINT [broker_commission_default_fk3] FOREIGN KEY ([brkr_num], [brkr_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[broker_commission_default] ADD CONSTRAINT [broker_commission_default_fk4] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[broker_commission_default] ADD CONSTRAINT [broker_commission_default_fk5] FOREIGN KEY ([brkr_comm_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[broker_commission_default] ADD CONSTRAINT [broker_commission_default_fk6] FOREIGN KEY ([del_loc_code_key]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[broker_commission_default] ADD CONSTRAINT [broker_commission_default_fk7] FOREIGN KEY ([order_type_code]) REFERENCES [dbo].[order_type] ([order_type_code])
GO
ALTER TABLE [dbo].[broker_commission_default] ADD CONSTRAINT [broker_commission_default_fk8] FOREIGN KEY ([brkr_comm_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[broker_commission_default] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[broker_commission_default] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[broker_commission_default] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[broker_commission_default] TO [next_usr]
GO
