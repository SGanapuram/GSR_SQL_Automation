CREATE TABLE [dbo].[cash_exposure]
(
[exposure_num] [int] NOT NULL,
[cash_exp_num] [smallint] NOT NULL,
[cash_exp_date] [datetime] NOT NULL,
[cash_is_due_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cash_exp_rec_amt] [float] NULL,
[cash_exp_pay_amt] [float] NULL,
[cash_exp_net_amt] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cash_exposure_deltrg]
on [dbo].[cash_exposure]
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
   select @errmsg = '(cash_exposure) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_cash_exposure
   (exposure_num,
    cash_exp_num,
    cash_exp_date,
    cash_is_due_code,
    cash_exp_rec_amt,
    cash_exp_pay_amt,
    cash_exp_net_amt,
    trans_id,
    resp_trans_id)
select
   d.exposure_num,
   d.cash_exp_num,
   d.cash_exp_date,
   d.cash_is_due_code,
   d.cash_exp_rec_amt,
   d.cash_exp_pay_amt,
   d.cash_exp_net_amt,
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

create trigger [dbo].[cash_exposure_updtrg]
on [dbo].[cash_exposure]
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
   raiserror ('(cash_exposure) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(cash_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exposure_num = d.exposure_num and 
                 i.cash_exp_num = d.cash_exp_num )
begin
   raiserror ('(cash_exposure) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(exposure_num) or  
   update(cash_exp_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.exposure_num = d.exposure_num  and 
                                   i.cash_exp_num = d.cash_exp_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cash_exposure) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cash_exposure
      (exposure_num,
       cash_exp_num,
       cash_exp_date,
       cash_is_due_code,
       cash_exp_rec_amt,
       cash_exp_pay_amt,
       cash_exp_net_amt,
       trans_id,
       resp_trans_id)
   select
      d.exposure_num,
      d.cash_exp_num,
      d.cash_exp_date,
      d.cash_is_due_code,
      d.cash_exp_rec_amt,
      d.cash_exp_pay_amt,
      d.cash_exp_net_amt,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.exposure_num = i.exposure_num and
         d.cash_exp_num = i.cash_exp_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cash_exposure] ADD CONSTRAINT [cash_exposure_pk] PRIMARY KEY CLUSTERED  ([exposure_num], [cash_exp_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cash_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cash_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cash_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cash_exposure] TO [next_usr]
GO
