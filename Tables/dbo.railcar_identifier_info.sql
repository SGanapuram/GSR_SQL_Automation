CREATE TABLE [dbo].[railcar_identifier_info]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[railcar_num] [int] NOT NULL,
[railcar_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[assign_date] [datetime] NULL,
[product] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[capacity_amount] [float] NULL,
[capacity_uom] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[construction_year] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[termination_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[railcar_identifier_info_updtrg]
on [dbo].[railcar_identifier_info]
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
   raiserror ('(railcar_identifier_info) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(railcar_identifier_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num and 
                 i.railcar_num = d.railcar_num )
begin
   raiserror ('(railcar_identifier_info) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or  
   update(order_num) or  
   update(railcar_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and 
                                   i.railcar_num = d.railcar_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(railcar_identifier_info) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[railcar_identifier_info] ADD CONSTRAINT [railcar_identifier_info_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [railcar_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[railcar_identifier_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[railcar_identifier_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[railcar_identifier_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[railcar_identifier_info] TO [next_usr]
GO
