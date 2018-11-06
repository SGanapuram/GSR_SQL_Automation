CREATE TABLE [dbo].[recap_item]
(
[recap_item_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trader_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_inv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_qty] [float] NULL,
[alloc_qty] [float] NULL,
[actual_qty] [float] NULL,
[recap_qty] [float] NULL,
[recap_item_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[recap_item_updtrg]
on [dbo].[recap_item]
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
   raiserror ('(recap_item) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(recap_item) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.recap_item_num = d.recap_item_num )
begin
   raiserror ('(recap_item) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(recap_item_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.recap_item_num = d.recap_item_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(recap_item) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[recap_item] ADD CONSTRAINT [recap_item_pk] PRIMARY KEY CLUSTERED  ([recap_item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [recap_item_idx3] ON [dbo].[recap_item] ([mot_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [recap_item_idx2] ON [dbo].[recap_item] ([trader_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[recap_item] ADD CONSTRAINT [recap_item_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[recap_item] ADD CONSTRAINT [recap_item_fk2] FOREIGN KEY ([trader_id]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[recap_item] ADD CONSTRAINT [recap_item_fk3] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[recap_item] ADD CONSTRAINT [recap_item_fk4] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[recap_item] ADD CONSTRAINT [recap_item_fk6] FOREIGN KEY ([recap_item_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[recap_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[recap_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[recap_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[recap_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'recap_item', NULL, NULL
GO
