CREATE TABLE [dbo].[booking_company_info]
(
[acct_num] [int] NOT NULL,
[dept_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_comp_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_ar_acct_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_ap_acct_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_gl_journal_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_data_class_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_book_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[division_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[writeoff_tolerance] [float] NOT NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inventory_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[liquidation_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mvmt_costs_inv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[non_mvmt_costs_inv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pur_grp_mandatory_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_booking_company_info_pur_grp_mandatory_ind] DEFAULT ('N'),
[trans_id] [int] NOT NULL,
[dflt_fut_clr_brkr] [int] NULL,
[dflt_lopt_clr_brkr] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[booking_company_info_updtrg]
on [dbo].[booking_company_info]
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
   raiserror ('(booking_company_info) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(booking_company_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num )
begin
   raiserror ('(booking_company_info) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(booking_company_info) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[booking_company_info] ADD CONSTRAINT [chk_booking_company_info_pur_grp_mandatory_ind] CHECK (([pur_grp_mandatory_ind]='N' OR [pur_grp_mandatory_ind]='Y'))
GO
ALTER TABLE [dbo].[booking_company_info] ADD CONSTRAINT [booking_company_info_pk] PRIMARY KEY CLUSTERED  ([acct_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[booking_company_info] ADD CONSTRAINT [booking_company_info_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[booking_company_info] ADD CONSTRAINT [booking_company_info_fk2] FOREIGN KEY ([calendar_code]) REFERENCES [dbo].[calendar] ([calendar_code])
GO
ALTER TABLE [dbo].[booking_company_info] ADD CONSTRAINT [booking_company_info_fk3] FOREIGN KEY ([dflt_book_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[booking_company_info] ADD CONSTRAINT [booking_company_info_fk4] FOREIGN KEY ([dflt_fut_clr_brkr]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[booking_company_info] ADD CONSTRAINT [booking_company_info_fk5] FOREIGN KEY ([dflt_lopt_clr_brkr]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[booking_company_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[booking_company_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[booking_company_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[booking_company_info] TO [next_usr]
GO
