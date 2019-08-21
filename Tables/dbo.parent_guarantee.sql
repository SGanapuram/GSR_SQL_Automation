CREATE TABLE [dbo].[parent_guarantee]
(
[pg_num] [int] NOT NULL,
[pg_in_out_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pg_guarantor] [int] NOT NULL,
[pg_counter_ref_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_beneficiary] [int] NOT NULL,
[pg_bus_covered_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pg_subs_covered_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pg_amount_covered] [float] NOT NULL,
[pg_amt_covered_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_volume_limit] [float] NULL,
[pg_volume_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_trade_num] [int] NULL,
[pg_notify_user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_notify_days] [datetime] NOT NULL,
[pg_issue_date] [datetime] NOT NULL,
[pg_expiration_date] [datetime] NOT NULL,
[pg_office_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_cr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[parent_guarantee_deltrg]
on [dbo].[parent_guarantee]
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
   select @errmsg = '(parent_guarantee) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_parent_guarantee
   (pg_num,
    pg_in_out_ind,
    pg_guarantor,
    pg_counter_ref_code,
    pg_beneficiary,
    pg_bus_covered_code,
    pg_subs_covered_ind,
    pg_amount_covered,
    pg_amt_covered_curr_code,
    cmdty_code,
    pg_volume_limit,
    pg_volume_uom_code,
    pg_trade_num,
    pg_notify_user_init,
    pg_notify_days,
    pg_issue_date,
    pg_expiration_date,
    pg_office_loc_code,
    pg_cr_analyst_init,
    trans_id,
    resp_trans_id)
select
   d.pg_num,
   d.pg_in_out_ind,
   d.pg_guarantor,
   d.pg_counter_ref_code,
   d.pg_beneficiary,
   d.pg_bus_covered_code,
   d.pg_subs_covered_ind,
   d.pg_amount_covered,
   d.pg_amt_covered_curr_code,
   d.cmdty_code,
   d.pg_volume_limit,
   d.pg_volume_uom_code,
   d.pg_trade_num,
   d.pg_notify_user_init,
   d.pg_notify_days,
   d.pg_issue_date,
   d.pg_expiration_date,
   d.pg_office_loc_code,
   d.pg_cr_analyst_init,
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

create trigger [dbo].[parent_guarantee_updtrg]
on [dbo].[parent_guarantee]
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
   raiserror ('(parent_guarantee) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(parent_guarantee) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pg_num = d.pg_num )
begin
   raiserror ('(parent_guarantee) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(pg_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pg_num = d.pg_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(parent_guarantee) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_parent_guarantee
      (pg_num,
       pg_in_out_ind,
       pg_guarantor,
       pg_counter_ref_code,
       pg_beneficiary,
       pg_bus_covered_code,
       pg_subs_covered_ind,
       pg_amount_covered,
       pg_amt_covered_curr_code,
       cmdty_code,
       pg_volume_limit,
       pg_volume_uom_code,
       pg_trade_num,
       pg_notify_user_init,
       pg_notify_days,
       pg_issue_date,
       pg_expiration_date,
       pg_office_loc_code,
       pg_cr_analyst_init,
       trans_id,
       resp_trans_id)
   select
      d.pg_num,
      d.pg_in_out_ind,
      d.pg_guarantor,
      d.pg_counter_ref_code,
      d.pg_beneficiary,
      d.pg_bus_covered_code,
      d.pg_subs_covered_ind,
      d.pg_amount_covered,
      d.pg_amt_covered_curr_code,
      d.cmdty_code,
      d.pg_volume_limit,
      d.pg_volume_uom_code,
      d.pg_trade_num,
      d.pg_notify_user_init,
      d.pg_notify_days,
      d.pg_issue_date,
      d.pg_expiration_date,
      d.pg_office_loc_code,
      d.pg_cr_analyst_init,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.pg_num = i.pg_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[parent_guarantee] ADD CONSTRAINT [parent_guarantee_pk] PRIMARY KEY CLUSTERED  ([pg_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parent_guarantee] ADD CONSTRAINT [parent_guarantee_fk1] FOREIGN KEY ([pg_guarantor]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[parent_guarantee] ADD CONSTRAINT [parent_guarantee_fk10] FOREIGN KEY ([pg_volume_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[parent_guarantee] ADD CONSTRAINT [parent_guarantee_fk2] FOREIGN KEY ([pg_beneficiary]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[parent_guarantee] ADD CONSTRAINT [parent_guarantee_fk3] FOREIGN KEY ([pg_amt_covered_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[parent_guarantee] ADD CONSTRAINT [parent_guarantee_fk4] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[parent_guarantee] ADD CONSTRAINT [parent_guarantee_fk5] FOREIGN KEY ([pg_notify_user_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[parent_guarantee] ADD CONSTRAINT [parent_guarantee_fk6] FOREIGN KEY ([pg_cr_analyst_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[parent_guarantee] ADD CONSTRAINT [parent_guarantee_fk7] FOREIGN KEY ([pg_office_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
GRANT DELETE ON  [dbo].[parent_guarantee] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[parent_guarantee] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[parent_guarantee] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[parent_guarantee] TO [next_usr]
GO
