CREATE TABLE [dbo].[vessel_dist_mtm]
(
[vdist_num] [int] NOT NULL,
[mtm_asof_date] [datetime] NOT NULL,
[open_pl] [decimal] (20, 8) NULL,
[closed_pl] [decimal] (20, 8) NULL,
[trade_value] [decimal] (20, 8) NULL,
[market_value] [decimal] (20, 8) NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_price] [decimal] (20, 8) NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[vessel_dist_mtm_updtrg]
on [dbo].[vessel_dist_mtm]
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
   raiserror ('(vessel_dist_mtm) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(vessel_dist_mtm) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.vdist_num = d.vdist_num and
                 i.mtm_asof_date = d.mtm_asof_date)
begin
   select @errmsg = '(vessel_dist_mtm) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.vdist_num) + '''' + convert(varchar, i.mtm_asof_date, 101) + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(vdist_num) or
   update(mtm_asof_date) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.vdist_num = d.vdist_num and
                                   i.mtm_asof_date = d.mtm_asof_date)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(vessel_dist_mtm) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[vessel_dist_mtm] ADD CONSTRAINT [vessel_dist_mtm_pk] PRIMARY KEY CLUSTERED  ([vdist_num], [mtm_asof_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vessel_dist_mtm] ADD CONSTRAINT [vessel_dist_mtm_fk1] FOREIGN KEY ([vdist_num]) REFERENCES [dbo].[vessel_dist] ([oid])
GO
ALTER TABLE [dbo].[vessel_dist_mtm] ADD CONSTRAINT [vessel_dist_mtm_fk2] FOREIGN KEY ([curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[vessel_dist_mtm] ADD CONSTRAINT [vessel_dist_mtm_fk3] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[vessel_dist_mtm] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[vessel_dist_mtm] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[vessel_dist_mtm] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[vessel_dist_mtm] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'vessel_dist_mtm', NULL, NULL
GO
