CREATE TABLE [dbo].[mca_payment_term]
(
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pay_term_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [smallint] NULL,
[pay_term_contr_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_event1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_event2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_event3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_ba_ind1] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_ba_ind2] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_ba_ind3] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_days1] [smallint] NULL,
[pay_term_days2] [smallint] NULL,
[pay_term_days3] [smallint] NULL,
[accounting_pay_term] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_trans_cat1] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_trans_cat2] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mca_payment_term_updtrg]
on [dbo].[mca_payment_term]
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
   raiserror ('(mca_payment_term) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(mca_payment_term) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pay_term_code = d.pay_term_code )
begin
   raiserror ('(mca_payment_term) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(pay_term_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pay_term_code = d.pay_term_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(mca_payment_term) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[mca_payment_term] ADD CONSTRAINT [mca_payment_term_pk] PRIMARY KEY CLUSTERED  ([pay_term_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mca_payment_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mca_payment_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mca_payment_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mca_payment_term] TO [next_usr]
GO
