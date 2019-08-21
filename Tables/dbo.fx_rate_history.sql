CREATE TABLE [dbo].[fx_rate_history]
(
[cost_num] [int] NOT NULL,
[rate_from_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rate_to_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rate_multi_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fx_asof_date] [datetime] NOT NULL,
[real_port_num] [int] NOT NULL,
[fx_exp_num] [int] NOT NULL,
[fx_rate] [numeric] (20, 8) NULL,
[fx_spot_rate] [numeric] (20, 8) NULL,
[day_cost_amt] [numeric] (20, 8) NULL,
[prev_day_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_day_cost_amt] [numeric] (20, 8) NULL,
[day_fx_pl] [numeric] (20, 8) NULL,
[prev_week_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_week_cost_amt] [numeric] (20, 8) NULL,
[week_fx_pl] [numeric] (20, 8) NULL,
[prev_month_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_month_cost_amt] [numeric] (20, 8) NULL,
[month_fx_pl] [numeric] (20, 8) NULL,
[prev_year_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_year_cost_amt] [numeric] (20, 8) NULL,
[year_fx_pl] [numeric] (20, 8) NULL,
[prev_comp_yr_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_comp_yr_cost_amt] [numeric] (20, 8) NULL,
[comp_yr_fx_pl] [numeric] (20, 8) NULL,
[prev_life_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_life_cost_amt] [numeric] (20, 8) NULL,
[life_fx_pl] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_rate_history_deltrg]
on [dbo].[fx_rate_history]
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
   select @errmsg = '(fx_rate_history) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_fx_rate_history
   (cost_num,
    rate_from_curr_code,
    rate_to_curr_code,
    rate_multi_div_ind,
    fx_asof_date,
    real_port_num,
    fx_exp_num,
    fx_rate,
    fx_spot_rate,
    day_cost_amt,
    prev_day_initial_fx_rate,
    prev_day_cost_amt,
    day_fx_pl,
    prev_week_initial_fx_rate,
    prev_week_cost_amt,
    week_fx_pl,
    prev_month_initial_fx_rate,
    prev_month_cost_amt,
    month_fx_pl,
    prev_year_initial_fx_rate,
    prev_year_cost_amt,
    year_fx_pl,
    prev_comp_yr_initial_fx_rate,
    prev_comp_yr_cost_amt,
    comp_yr_fx_pl,
    prev_life_initial_fx_rate,
    prev_life_cost_amt,
    life_fx_pl,
    trans_id,
    resp_trans_id)
select
    d.cost_num,
    d.rate_from_curr_code,
    d.rate_to_curr_code,
    d.rate_multi_div_ind,
    d.fx_asof_date,
    d.real_port_num,
    d.fx_exp_num,
    d.fx_rate,
    d.fx_spot_rate,
    d.day_cost_amt,
    d.prev_day_initial_fx_rate,
    d.prev_day_cost_amt,
    d.day_fx_pl,
    d.prev_week_initial_fx_rate,
    d.prev_week_cost_amt,
    d.week_fx_pl,
    d.prev_month_initial_fx_rate,
    d.prev_month_cost_amt,
    d.month_fx_pl,
    d.prev_year_initial_fx_rate,
    d.prev_year_cost_amt,
    d.year_fx_pl,
    d.prev_comp_yr_initial_fx_rate,
    d.prev_comp_yr_cost_amt,
    d.comp_yr_fx_pl,
    d.prev_life_initial_fx_rate,
    d.prev_life_cost_amt,
    d.life_fx_pl,
    d.trans_id,
    @atrans_id 

from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FxRateHistory',
       'DIRECT',
       convert(varchar(40), d.cost_num),
       convert(varchar(40), d.fx_asof_date),
       convert(varchar(40), d.real_port_num),
       convert(varchar(40), d.fx_exp_num),
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

create trigger [dbo].[fx_rate_history_instrg]
on [dbo].[fx_rate_history]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'INSERT',
       'FxRateHistory',
       'DIRECT',
       convert(varchar(40), i.cost_num),
       convert(varchar(40), i.fx_asof_date),
       convert(varchar(40), i.real_port_num),
       convert(varchar(40), i.fx_exp_num),
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

create trigger [dbo].[fx_rate_history_updtrg]
on [dbo].[fx_rate_history]
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
   raiserror ('(fx_rate_history) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(fx_rate_history) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_num = d.cost_num and
                 i.fx_asof_date  = d.fx_asof_date  and
                 i.real_port_num = d.real_port_num and
                 i.fx_exp_num = d.fx_exp_num )
begin
   raiserror ('(fx_rate_history) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_num) or
   update(fx_asof_date) or
   update(real_port_num) or
   update(fx_exp_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_num = d.cost_num and
                                   i.fx_asof_date  = d.fx_asof_date  and
                                   i.real_port_num = d.real_port_num and
                                   i.fx_exp_num = d.fx_exp_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(fx_rate_history) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fx_rate_history
      (cost_num,
       rate_from_curr_code,
       rate_to_curr_code,
       rate_multi_div_ind,
       fx_asof_date,
       real_port_num,
       fx_exp_num,
       fx_rate,
       fx_spot_rate,
       day_cost_amt,
       prev_day_initial_fx_rate,
       prev_day_cost_amt,
       day_fx_pl,
       prev_week_initial_fx_rate,
       prev_week_cost_amt,
       week_fx_pl,
       prev_month_initial_fx_rate,
       prev_month_cost_amt,
       month_fx_pl,
       prev_year_initial_fx_rate,
       prev_year_cost_amt,
       year_fx_pl,
       prev_comp_yr_initial_fx_rate,
       prev_comp_yr_cost_amt,
       comp_yr_fx_pl,
       prev_life_initial_fx_rate,
       prev_life_cost_amt,
       life_fx_pl,
       trans_id,
       resp_trans_id )
   select
       d.cost_num,
       d.rate_from_curr_code,
       d.rate_to_curr_code,
       d.rate_multi_div_ind,
       d.fx_asof_date,
       d.real_port_num,
       d.fx_exp_num,
       d.fx_rate,
       d.fx_spot_rate,
       d.day_cost_amt,
       d.prev_day_initial_fx_rate,
       d.prev_day_cost_amt,
       d.day_fx_pl,
       d.prev_week_initial_fx_rate,
       d.prev_week_cost_amt,
       d.week_fx_pl,
       d.prev_month_initial_fx_rate,
       d.prev_month_cost_amt,
       d.month_fx_pl,
       d.prev_year_initial_fx_rate,
       d.prev_year_cost_amt,
       d.year_fx_pl,
       d.prev_comp_yr_initial_fx_rate,
       d.prev_comp_yr_cost_amt,
       d.comp_yr_fx_pl,
       d.prev_life_initial_fx_rate,
       d.prev_life_cost_amt,
       d.life_fx_pl,
       d.trans_id,
       i.trans_id 
   from deleted d, inserted i
   where i.cost_num = d.cost_num and
         i.fx_asof_date  = d.fx_asof_date  and
         i.real_port_num = d.real_port_num and
         i.fx_exp_num = d.fx_exp_num 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FxRateHistory',
       'DIRECT',
       convert(varchar(40), i.cost_num),
       convert(varchar(40), i.fx_asof_date),
       convert(varchar(40), i.real_port_num),
       convert(varchar(40), i.fx_exp_num),
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
ALTER TABLE [dbo].[fx_rate_history] ADD CONSTRAINT [chk_fx_rate_history_rate_multi_div_ind] CHECK (([rate_multi_div_ind]='D' OR [rate_multi_div_ind]='M'))
GO
ALTER TABLE [dbo].[fx_rate_history] ADD CONSTRAINT [fx_rate_history_pk] PRIMARY KEY CLUSTERED  ([cost_num], [fx_asof_date], [real_port_num], [fx_exp_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fx_rate_history] ADD CONSTRAINT [fx_rate_history_fk2] FOREIGN KEY ([rate_from_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[fx_rate_history] ADD CONSTRAINT [fx_rate_history_fk3] FOREIGN KEY ([rate_to_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[fx_rate_history] ADD CONSTRAINT [fx_rate_history_fk4] FOREIGN KEY ([real_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
GRANT DELETE ON  [dbo].[fx_rate_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fx_rate_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fx_rate_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fx_rate_history] TO [next_usr]
GO
