CREATE TABLE [dbo].[mtm_exposure]
(
[exposure_num] [int] NOT NULL,
[mtm_exp_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mtm_exp_profit_amt] [float] NULL,
[mtm_exp_loss_amt] [float] NULL,
[mtm_exp_profit_qty] [float] NULL,
[mtm_exp_loss_qty] [float] NULL,
[mtm_exp_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mtm_exp_gross_amt] [float] NULL,
[mtm_exp_num] [smallint] NOT NULL,
[exp_month] [tinyint] NOT NULL,
[exp_year] [smallint] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtm_exposure_updtrg]
on [dbo].[mtm_exposure]
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
   raiserror ('(mtm_exposure) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(mtm_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exposure_num = d.exposure_num and 
                 i.mtm_exp_num = d.mtm_exp_num )
begin
   raiserror ('(mtm_exposure) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(exposure_num) or  
   update(mtm_exp_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.exposure_num = d.exposure_num and 
                                   i.mtm_exp_num = d.mtm_exp_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(mtm_exposure) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[mtm_exposure] ADD CONSTRAINT [mtm_exposure_pk] PRIMARY KEY CLUSTERED  ([exposure_num], [mtm_exp_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mtm_exposure] ADD CONSTRAINT [mtm_exposure_fk2] FOREIGN KEY ([mtm_exp_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[mtm_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mtm_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mtm_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mtm_exposure] TO [next_usr]
GO
