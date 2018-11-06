CREATE TABLE [dbo].[inventory_balance]
(
[inv_num] [int] NOT NULL,
[inv_bal_num] [int] NOT NULL,
[inv_bal_from_date] [datetime] NOT NULL,
[inv_bal_to_date] [datetime] NOT NULL,
[inv_open_prd_proj_qty] [float] NULL,
[inv_open_prd_actual_qty] [float] NULL,
[inv_adj_qty] [float] NULL,
[inv_close_prd_proj_qty] [float] NULL,
[inv_close_prd_actual_qty] [float] NOT NULL,
[inv_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[inv_avg_cost] [float] NULL,
[inv_cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_cost_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inventory_balance_updtrg]
on [dbo].[inventory_balance]
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
   raiserror ('(inventory_balance) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(inventory_balance) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.inv_num = d.inv_num and 
                 i.inv_bal_num = d.inv_bal_num )
begin
   raiserror ('(inventory_balance) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(inv_num) or  
   update(inv_bal_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.inv_num = d.inv_num and 
                                   i.inv_bal_num = d.inv_bal_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(inventory_balance) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[inventory_balance] ADD CONSTRAINT [inventory_balance_pk] PRIMARY KEY CLUSTERED  ([inv_num], [inv_bal_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inventory_balance] ADD CONSTRAINT [inventory_balance_fk1] FOREIGN KEY ([inv_cost_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[inventory_balance] ADD CONSTRAINT [inventory_balance_fk3] FOREIGN KEY ([inv_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inventory_balance] ADD CONSTRAINT [inventory_balance_fk4] FOREIGN KEY ([inv_cost_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[inventory_balance] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inventory_balance] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inventory_balance] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inventory_balance] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'inventory_balance', NULL, NULL
GO
