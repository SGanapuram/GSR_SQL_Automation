CREATE TABLE [dbo].[railcar_ptp_rate]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[origin_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[destin_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rate_amount] [float] NULL,
[rate_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rec_del_ind_for_cost] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[railcar_ptp_rate_updtrg]
on [dbo].[railcar_ptp_rate]
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
   raiserror ('(railcar_ptp_rate) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(railcar_ptp_rate) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num and 
                 i.origin_loc_code = d.origin_loc_code and 
                 i.destin_loc_code = d.destin_loc_code )
begin
   raiserror ('(railcar_ptp_rate) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or  
   update(order_num) or  
   update(origin_loc_code) or  
   update(destin_loc_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and 
                                   i.origin_loc_code = d.origin_loc_code and 
                                   i.destin_loc_code = d.destin_loc_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(railcar_ptp_rate) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[railcar_ptp_rate] ADD CONSTRAINT [railcar_ptp_rate_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [origin_loc_code], [destin_loc_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[railcar_ptp_rate] ADD CONSTRAINT [railcar_ptp_rate_fk1] FOREIGN KEY ([rate_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[railcar_ptp_rate] ADD CONSTRAINT [railcar_ptp_rate_fk2] FOREIGN KEY ([origin_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[railcar_ptp_rate] ADD CONSTRAINT [railcar_ptp_rate_fk3] FOREIGN KEY ([destin_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[railcar_ptp_rate] ADD CONSTRAINT [railcar_ptp_rate_fk5] FOREIGN KEY ([rate_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[railcar_ptp_rate] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[railcar_ptp_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[railcar_ptp_rate] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[railcar_ptp_rate] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'railcar_ptp_rate', NULL, NULL
GO
