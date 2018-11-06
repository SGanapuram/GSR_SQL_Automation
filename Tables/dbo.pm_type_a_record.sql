CREATE TABLE [dbo].[pm_type_a_record]
(
[fdd_id] [int] NOT NULL,
[company_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[splc_code] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[terminal_ctrl_num] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bol_number] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bol_version] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[start_load_date] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[start_load_time] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[end_load_date] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[end_load_time] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[consignee_num] [char] (14) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dest_state_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dest_county_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dest_city_code] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[carrier_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[carrier_fein] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[vehicle_num] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vehicle_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__pm_type_a__vehic__63C3BFDC] DEFAULT ('T'),
[third_party] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[po_order_num] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[release_num] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[split_load_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[time_zone] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[shipper_info] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pm_type_a_record_updtrg]
on [dbo].[pm_type_a_record]
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
   raiserror ('(pm_type_a_record) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(pm_type_a_record) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fdd_id = d.fdd_id)
begin
   select @errmsg = '(pm_type_a_record) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.fdd_id) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(fdd_id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.fdd_id = d.fdd_id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(pm_type_a_record) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[pm_type_a_record] ADD CONSTRAINT [CK__pm_type_a__vehic__64B7E415] CHECK (([vehicle_type]='X' OR [vehicle_type]='T' OR [vehicle_type]='S' OR [vehicle_type]='R' OR [vehicle_type]='P' OR [vehicle_type]='D' OR [vehicle_type]='B'))
GO
ALTER TABLE [dbo].[pm_type_a_record] ADD CONSTRAINT [pm_type_a_record_pk] PRIMARY KEY CLUSTERED  ([fdd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pm_type_a_record_idx1] ON [dbo].[pm_type_a_record] ([company_code], [start_load_date], [splc_code], [bol_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pm_type_a_record_idx2] ON [dbo].[pm_type_a_record] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pm_type_a_record] ADD CONSTRAINT [pm_type_a_record_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[pm_type_a_record] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pm_type_a_record] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pm_type_a_record] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pm_type_a_record] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'pm_type_a_record', NULL, NULL
GO
