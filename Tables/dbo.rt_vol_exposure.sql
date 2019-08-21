CREATE TABLE [dbo].[rt_vol_exposure]
(
[exposure_num] [int] NOT NULL,
[rt_vol_exp_num] [int] NOT NULL,
[rt_long_qty] [float] NULL,
[rt_short_qty] [float] NULL,
[rt_qty_prd] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rt_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[rt_vol_exposure_updtrg]
on [dbo].[rt_vol_exposure]
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
   raiserror ('(rt_vol_exposure) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(rt_vol_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exposure_num = d.exposure_num and 
                 i.rt_vol_exp_num = d.rt_vol_exp_num )
begin
   raiserror ('(rt_vol_exposure) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(exposure_num) or  
   update(rt_vol_exp_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.exposure_num = d.exposure_num and 
                                   i.rt_vol_exp_num = d.rt_vol_exp_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(rt_vol_exposure) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[rt_vol_exposure] ADD CONSTRAINT [rt_vol_exposure_pk] PRIMARY KEY CLUSTERED  ([exposure_num], [rt_vol_exp_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rt_vol_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[rt_vol_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[rt_vol_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[rt_vol_exposure] TO [next_usr]
GO
