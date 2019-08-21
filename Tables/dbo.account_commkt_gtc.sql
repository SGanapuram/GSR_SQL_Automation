CREATE TABLE [dbo].[account_commkt_gtc]
(
[acct_num] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[booking_company_num] [int] NOT NULL,
[gtc_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[netting_forwards_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_account_commkt_gtc_netting_forwards_ind] DEFAULT ('N'),
[netting_vouchers_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_account_commkt_gtc_netting_vouchers_ind] DEFAULT ('N'),
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL CONSTRAINT [df_account_commkt_gtc_creation_date] DEFAULT (getdate()),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_commkt_gtc_deltrg]
on [dbo].[account_commkt_gtc]
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
   select @errmsg = '(account_commkt_gtc) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_account_commkt_gtc
(   
   acct_num,
   commkt_key,
   booking_company_num,
   gtc_code,
   netting_forwards_ind,
   netting_vouchers_ind,
   creator_init,
   creation_date,
   trans_id,
   resp_trans_id
)
select
   d.acct_num,
   d.commkt_key,
   d.booking_company_num,
   d.gtc_code,
   d.netting_forwards_ind,
   d.netting_vouchers_ind,
   d.creator_init,
   d.creation_date,
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

create trigger [dbo].[account_commkt_gtc_updtrg]
on [dbo].[account_commkt_gtc]
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
   raiserror ('(account_commkt_gtc) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(account_commkt_gtc) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and
                 i.commkt_key = d.commkt_key and
                 i.booking_company_num = d.booking_company_num)
begin
   raiserror ('(account_commkt_gtc) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) or
   update(commkt_key) or
   update(booking_company_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and
                                   i.commkt_key = d.commkt_key and
                                   i.booking_company_num = d.booking_company_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_commkt_gtc) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_account_commkt_gtc
      (acct_num,
       commkt_key,
       booking_company_num,
       gtc_code,
       netting_forwards_ind,
       netting_vouchers_ind,
       creator_init,
       creation_date,
       trans_id,
       resp_trans_id)
   select
      d.acct_num,
      d.commkt_key,
      d.booking_company_num,
      d.gtc_code,
      d.netting_forwards_ind,
      d.netting_vouchers_ind,
      d.creator_init,
      d.creation_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_num = i.acct_num and
         d.commkt_key = i.commkt_key and
         d.booking_company_num = i.booking_company_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[account_commkt_gtc] ADD CONSTRAINT [chk_account_commkt_gtc_netting_forwards_ind] CHECK (([netting_forwards_ind]='N' OR [netting_forwards_ind]='Y'))
GO
ALTER TABLE [dbo].[account_commkt_gtc] ADD CONSTRAINT [chk_account_commkt_gtc_netting_vouchers_ind] CHECK (([netting_vouchers_ind]='N' OR [netting_vouchers_ind]='Y'))
GO
ALTER TABLE [dbo].[account_commkt_gtc] ADD CONSTRAINT [account_commkt_gtc_pk] PRIMARY KEY CLUSTERED  ([acct_num], [commkt_key], [booking_company_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_commkt_gtc] ADD CONSTRAINT [account_commkt_gtc_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_commkt_gtc] ADD CONSTRAINT [account_commkt_gtc_fk2] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
ALTER TABLE [dbo].[account_commkt_gtc] ADD CONSTRAINT [account_commkt_gtc_fk3] FOREIGN KEY ([booking_company_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_commkt_gtc] ADD CONSTRAINT [account_commkt_gtc_fk4] FOREIGN KEY ([gtc_code]) REFERENCES [dbo].[gtc] ([gtc_code])
GO
ALTER TABLE [dbo].[account_commkt_gtc] ADD CONSTRAINT [account_commkt_gtc_fk5] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[account_commkt_gtc] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_commkt_gtc] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_commkt_gtc] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_commkt_gtc] TO [next_usr]
GO
