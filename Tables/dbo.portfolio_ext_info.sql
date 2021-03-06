CREATE TABLE [dbo].[portfolio_ext_info]
(
[port_num] [int] NOT NULL,
[pl_change_limit] [numeric] (20, 8) NULL,
[pl_change_limit_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pl_new_limit] [numeric] (20, 8) NULL,
[pl_new_limit_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[outright_pos_limit] [numeric] (20, 8) NULL,
[outright_pos_limit_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spread_pos_limit] [numeric] (20, 8) NULL,
[spread_pos_limit_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[risk_neutral_stock_volume] [numeric] (20, 8) NULL,
[noise_band_min_volume] [numeric] (20, 8) NULL,
[noise_band_max_volume] [numeric] (20, 8) NULL,
[noise_band_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[var_limit] [numeric] (20, 8) NULL,
[var_limit_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_ext_info_deltrg]
on [dbo].[portfolio_ext_info]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(portfolio_ext_info) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end

insert dbo.aud_portfolio_ext_info
   (port_num,
    pl_change_limit,
    pl_change_limit_curr_code,
    pl_new_limit,
    pl_new_limit_curr_code,
    outright_pos_limit,
    outright_pos_limit_uom_code,
    spread_pos_limit,
    spread_pos_limit_uom_code,
    risk_neutral_stock_volume,
    noise_band_min_volume,
    noise_band_max_volume,
    noise_band_uom_code,
    var_limit,
    var_limit_curr_code,
    trans_id,
    resp_trans_id)
select
   d.port_num,
   d.pl_change_limit,
   d.pl_change_limit_curr_code,
   d.pl_new_limit,
   d.pl_new_limit_curr_code,
   d.outright_pos_limit,
   d.outright_pos_limit_uom_code,
   d.spread_pos_limit,
   d.spread_pos_limit_uom_code,
   d.risk_neutral_stock_volume,
   d.noise_band_min_volume,
   d.noise_band_max_volume,
   d.noise_band_uom_code,
   d.var_limit,
   d.var_limit_curr_code,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'PortfolioExtInfo',
       'DIRECT',
       convert(varchar(40), d.port_num),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_ext_info_instrg]
on [dbo].[portfolio_ext_info]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */

   insert dbo.transaction_touch
   select 'INSERT',
          'PortfolioExtInfo',
          'DIRECT',
          convert(varchar(40), i.port_num),
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          i.trans_id,
          it.sequence
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id and
         it.type != 'E'

   /* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_ext_info_updtrg]
on [dbo].[portfolio_ext_info]
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
   raiserror ('(portfolio_ext_info) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(account_ext_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.port_num = d.port_num )
begin
   raiserror ('(portfolio_ext_info) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(port_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.port_num = d.port_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(portfolio_ext_info) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_portfolio_ext_info
      (port_num,
       pl_change_limit,
       pl_change_limit_curr_code,
       pl_new_limit,
       pl_new_limit_curr_code,
       outright_pos_limit,
       outright_pos_limit_uom_code,
       spread_pos_limit,
       spread_pos_limit_uom_code,
       risk_neutral_stock_volume,
       noise_band_min_volume,
       noise_band_max_volume,
       noise_band_uom_code,
       var_limit,
       var_limit_curr_code,
       trans_id,
       resp_trans_id)
   select
      d.port_num,
      d.pl_change_limit,
      d.pl_change_limit_curr_code,
      d.pl_new_limit,
      d.pl_new_limit_curr_code,
      d.outright_pos_limit,
      d.outright_pos_limit_uom_code,
      d.spread_pos_limit,
      d.spread_pos_limit_uom_code,
      d.risk_neutral_stock_volume,
      d.noise_band_min_volume,
      d.noise_band_max_volume,
      d.noise_band_uom_code,
      d.var_limit,
      d.var_limit_curr_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.port_num = i.port_num 

/* AUDIT_CODE_END */


/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'PortfolioExtInfo',
       'DIRECT',
       convert(varchar(40), i.port_num),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */
return
GO
ALTER TABLE [dbo].[portfolio_ext_info] ADD CONSTRAINT [portfolio_ext_info_pk] PRIMARY KEY CLUSTERED  ([port_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[portfolio_ext_info] ADD CONSTRAINT [portfolio_ext_info_fk2] FOREIGN KEY ([pl_change_limit_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[portfolio_ext_info] ADD CONSTRAINT [portfolio_ext_info_fk3] FOREIGN KEY ([pl_new_limit_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[portfolio_ext_info] ADD CONSTRAINT [portfolio_ext_info_fk4] FOREIGN KEY ([outright_pos_limit_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[portfolio_ext_info] ADD CONSTRAINT [portfolio_ext_info_fk5] FOREIGN KEY ([spread_pos_limit_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[portfolio_ext_info] ADD CONSTRAINT [portfolio_ext_info_fk6] FOREIGN KEY ([noise_band_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[portfolio_ext_info] ADD CONSTRAINT [portfolio_ext_info_fk7] FOREIGN KEY ([var_limit_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[portfolio_ext_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_ext_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_ext_info] TO [next_usr]
GO
