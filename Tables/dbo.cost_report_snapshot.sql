CREATE TABLE [dbo].[cost_report_snapshot]
(
[cost_num] [int] NOT NULL,
[balance_date] [datetime] NOT NULL,
[balance_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_qty] [float] NULL,
[cost_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_qty_est_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_unit_price] [float] NULL,
[cost_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_est_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_amt] [float] NULL,
[cost_amt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_comp_num] [int] NULL,
[cost_book_prd_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_report_snapshot_updtrg]
on [dbo].[cost_report_snapshot]
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
   raiserror ('(cost_report_snapshot) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(cost_report_snapshot) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_num = d.cost_num  and i.balance_date = d.balance_date  and i.balance_type = d.balance_type )
begin
   raiserror ('(cost_report_snapshot) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_num) or  
   update(balance_date) or  
   update(balance_type) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_num = d.cost_num and 
                                   i.balance_date = d.balance_date and 
                                   i.balance_type = d.balance_type )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_report_snapshot) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[cost_report_snapshot] ADD CONSTRAINT [cost_report_snapshot_pk] PRIMARY KEY CLUSTERED  ([cost_num], [balance_date], [balance_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_report_snapshot] ADD CONSTRAINT [cost_report_snapshot_fk1] FOREIGN KEY ([cost_book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cost_report_snapshot] ADD CONSTRAINT [cost_report_snapshot_fk2] FOREIGN KEY ([cost_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[cost_report_snapshot] ADD CONSTRAINT [cost_report_snapshot_fk4] FOREIGN KEY ([cost_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[cost_report_snapshot] ADD CONSTRAINT [cost_report_snapshot_fk5] FOREIGN KEY ([cost_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[cost_report_snapshot] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_report_snapshot] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_report_snapshot] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_report_snapshot] TO [next_usr]
GO
