CREATE TABLE [dbo].[noise_band_exposure]
(
[port_num] [int] NOT NULL,
[asof_date] [datetime] NOT NULL,
[rnsv_exposure] [numeric] (20, 4) NULL,
[rnsv_exposure_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rnsv_mtm_value] [numeric] (20, 4) NULL,
[weighted_trade_value] [numeric] (20, 4) NULL,
[weighted_trade_price] [numeric] (20, 4) NULL,
[rnsv_mtm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_exposure_volume] [numeric] (20, 4) NULL,
[trans_id] [int] NOT NULL,
[market_value] [numeric] (20, 4) NULL,
[weighted_market_price] [numeric] (20, 4) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[noise_band_exposure_deltrg]
on [dbo].[noise_band_exposure]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(noise_band_exposure) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end

insert dbo.aud_noise_band_exposure
(  
   port_num,
   asof_date,
   rnsv_exposure,
   rnsv_exposure_uom_code,
   rnsv_mtm_value,
   weighted_trade_value,
   weighted_trade_price,
   rnsv_mtm_curr_code,
   net_exposure_volume,
   trans_id,
   resp_trans_id
)
select
   d.port_num,
   d.asof_date,
   d.rnsv_exposure,
   d.rnsv_exposure_uom_code,
   d.rnsv_mtm_value,
   d.weighted_trade_value,
   d.weighted_trade_price,
   d.rnsv_mtm_curr_code,
   d.net_exposure_volume,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[noise_band_exposure_updtrg]
on [dbo].[noise_band_exposure]
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
   raiserror ('(noise_band_exposure) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(noise_band_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.port_num = d.port_num and
                 i.asof_date = d.asof_date)
begin
   select @errmsg = '(noise_band_exposure) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.port_num) + ',' +
                             convert(varchar, i.asof_date, 101) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(port_num) or
   update(asof_date)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.port_num = d.port_num and
                                   i.asof_date = d.asof_date)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(noise_band_exposure) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_noise_band_exposure
 	    (port_num,
       asof_date,
       rnsv_exposure,
       rnsv_exposure_uom_code,
       rnsv_mtm_value,
       weighted_trade_value,
       weighted_trade_price,
       rnsv_mtm_curr_code,
       net_exposure_volume,
       trans_id,
       resp_trans_id)
   select
 	    d.port_num,
      d.asof_date,
      d.rnsv_exposure,
      d.rnsv_exposure_uom_code,
      d.rnsv_mtm_value,
      d.weighted_trade_value,
      d.weighted_trade_price,
      d.rnsv_mtm_curr_code,
      d.net_exposure_volume,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.port_num = i.port_num and
         d.asof_date = i.asof_date

return
GO
ALTER TABLE [dbo].[noise_band_exposure] ADD CONSTRAINT [noise_band_exposure_pk] PRIMARY KEY CLUSTERED  ([port_num], [asof_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[noise_band_exposure] ADD CONSTRAINT [noise_band_exposure_fk1] FOREIGN KEY ([port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[noise_band_exposure] ADD CONSTRAINT [noise_band_exposure_fk2] FOREIGN KEY ([rnsv_exposure_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[noise_band_exposure] ADD CONSTRAINT [noise_band_exposure_fk3] FOREIGN KEY ([rnsv_mtm_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[noise_band_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[noise_band_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[noise_band_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[noise_band_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'noise_band_exposure', NULL, NULL
GO
