CREATE TABLE [dbo].[glfile_td]
(
[glfile_bh_num] [int] NOT NULL,
[glfile_th_num] [int] NOT NULL,
[glfile_td_num] [int] NOT NULL,
[td_posting_acct] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[td_fiscal_year_period] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[td_ref1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[td_ref2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[td_ref3] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[td_post_currency_amt] [float] NULL,
[td_units] [float] NULL,
[td_user_int_area] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[td_corp_currency_amt] [float] NULL,
[td_other_currency_amt] [float] NULL,
[td_posted_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[glfile_td_updtrg]
on [dbo].[glfile_td]
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
   raiserror ('(glfile_td) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(glfile_td) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.glfile_bh_num = d.glfile_bh_num  and i.glfile_th_num = d.glfile_th_num  and i.glfile_td_num = d.glfile_td_num )
begin
   raiserror ('(glfile_td) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(glfile_bh_num) or  
   update(glfile_th_num) or  
   update(glfile_td_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.glfile_bh_num = d.glfile_bh_num and 
                                   i.glfile_th_num = d.glfile_th_num and 
                                   i.glfile_td_num = d.glfile_td_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(glfile_td) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[glfile_td] ADD CONSTRAINT [glfile_td_pk] PRIMARY KEY CLUSTERED  ([glfile_bh_num], [glfile_th_num], [glfile_td_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[glfile_td] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[glfile_td] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[glfile_td] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[glfile_td] TO [next_usr]
GO
