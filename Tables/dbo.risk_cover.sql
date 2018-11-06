CREATE TABLE [dbo].[risk_cover]
(
[risk_cover_num] [int] NOT NULL,
[instr_type_code] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rc_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[guarantee_acct_num] [int] NULL,
[covered_percent] [decimal] (20, 8) NULL,
[max_covered_amt] [decimal] (20, 8) NULL,
[guarantee_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[guarantee_start_date] [datetime] NULL,
[guarantee_end_date] [datetime] NULL,
[min_num_of_days] [int] NULL,
[analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[office_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[disc_date] [datetime] NULL,
[disc_rec_amt] [decimal] (20, 8) NULL,
[disc_rec_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[risk_cover_deltrg]
on [dbo].[risk_cover]
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
   select @errmsg = '(risk_cover) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_risk_cover
   (risk_cover_num,
    instr_type_code,
    rc_status_code,
    guarantee_acct_num,
    covered_percent,
    max_covered_amt,
    guarantee_ref_num,
    guarantee_start_date,
    guarantee_end_date,
    min_num_of_days,
    analyst_init,
    office_loc_code,
    disc_date,
    disc_rec_amt,
    disc_rec_curr_code,
    cmnt_num,
    trans_id,
    resp_trans_id)
select
    d.risk_cover_num,
    d.instr_type_code,
    d.rc_status_code,
    d.guarantee_acct_num,
    d.covered_percent,
    d.max_covered_amt,
    d.guarantee_ref_num,
    d.guarantee_start_date,
    d.guarantee_end_date,
    d.min_num_of_days,
    d.analyst_init,
    d.office_loc_code,
    d.disc_date,
    d.disc_rec_amt,
    d.disc_rec_curr_code,
    d.cmnt_num,
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

create trigger [dbo].[risk_cover_updtrg]
on [dbo].[risk_cover]
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
   raiserror ('(risk_cover) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(risk_cover) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.risk_cover_num = d.risk_cover_num)
begin
   raiserror ('(risk_cover) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(risk_cover_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.risk_cover_num = d.risk_cover_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(risk_cover) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_risk_cover
   (risk_cover_num,
    instr_type_code,
    rc_status_code,
    guarantee_acct_num,
    covered_percent,
    max_covered_amt,
    guarantee_ref_num,
    guarantee_start_date,
    guarantee_end_date,
    min_num_of_days,
    analyst_init,
    office_loc_code,
    disc_date,
    disc_rec_amt,
    disc_rec_curr_code,
    cmnt_num,
    trans_id,
    resp_trans_id)
 select
    d.risk_cover_num,
    d.instr_type_code,
    d.rc_status_code,
    d.guarantee_acct_num,
    d.covered_percent,
    d.max_covered_amt,
    d.guarantee_ref_num,
    d.guarantee_start_date,
    d.guarantee_end_date,
    d.min_num_of_days,
    d.analyst_init,
    d.office_loc_code,
    d.disc_date,
    d.disc_rec_amt,
    d.disc_rec_curr_code,
    d.cmnt_num,
    d.trans_id,
    i.trans_id
 from deleted d, inserted i
 where d.risk_cover_num = i.risk_cover_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[risk_cover] ADD CONSTRAINT [risk_cover_pk] PRIMARY KEY CLUSTERED  ([risk_cover_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[risk_cover] ADD CONSTRAINT [risk_cover_fk1] FOREIGN KEY ([instr_type_code]) REFERENCES [dbo].[rc_instr_type] ([instr_type_code])
GO
ALTER TABLE [dbo].[risk_cover] ADD CONSTRAINT [risk_cover_fk2] FOREIGN KEY ([rc_status_code]) REFERENCES [dbo].[rc_status] ([rc_status_code])
GO
ALTER TABLE [dbo].[risk_cover] ADD CONSTRAINT [risk_cover_fk3] FOREIGN KEY ([guarantee_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[risk_cover] ADD CONSTRAINT [risk_cover_fk4] FOREIGN KEY ([analyst_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[risk_cover] ADD CONSTRAINT [risk_cover_fk5] FOREIGN KEY ([office_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[risk_cover] ADD CONSTRAINT [risk_cover_fk6] FOREIGN KEY ([disc_rec_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[risk_cover] ADD CONSTRAINT [risk_cover_fk7] FOREIGN KEY ([cmnt_num]) REFERENCES [dbo].[comment] ([cmnt_num])
GO
GRANT DELETE ON  [dbo].[risk_cover] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[risk_cover] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[risk_cover] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[risk_cover] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'risk_cover', NULL, NULL
GO
