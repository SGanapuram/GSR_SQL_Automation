CREATE TABLE [dbo].[fx_exposure_pl]
(
[pl_asof_date] [datetime] NOT NULL,
[exp_key_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exp_key_num] [int] NOT NULL,
[primary_open_day_pl] [numeric] (20, 8) NULL,
[primary_unlocked_day_pl] [numeric] (20, 8) NULL,
[primary_open_week_pl] [numeric] (20, 8) NULL,
[primary_unlocked_week_pl] [numeric] (20, 8) NULL,
[primary_open_month_pl] [numeric] (20, 8) NULL,
[primary_unlocked_month_pl] [numeric] (20, 8) NULL,
[primary_open_year_pl] [numeric] (20, 8) NULL,
[primary_unlocked_year_pl] [numeric] (20, 8) NULL,
[primary_open_comp_yr_pl] [numeric] (20, 8) NULL,
[primary_unlocked_comp_yr_pl] [numeric] (20, 8) NULL,
[primary_open_life_pl] [numeric] (20, 8) NULL,
[primary_unlocked_life_pl] [numeric] (20, 8) NULL,
[forex_open_day_pl] [numeric] (20, 8) NULL,
[forex_unlocked_day_pl] [numeric] (20, 8) NULL,
[forex_open_week_pl] [numeric] (20, 8) NULL,
[forex_unlocked_week_pl] [numeric] (20, 8) NULL,
[forex_open_month_pl] [numeric] (20, 8) NULL,
[forex_unlocked_month_pl] [numeric] (20, 8) NULL,
[forex_open_year_pl] [numeric] (20, 8) NULL,
[forex_unlocked_year_pl] [numeric] (20, 8) NULL,
[forex_open_comp_yr_pl] [numeric] (20, 8) NULL,
[forex_unlocked_comp_yr_pl] [numeric] (20, 8) NULL,
[forex_open_life_pl] [numeric] (20, 8) NULL,
[forex_unlocked_life_pl] [numeric] (20, 8) NULL,
[other_open_day_pl] [numeric] (20, 8) NULL,
[other_unlocked_day_pl] [numeric] (20, 8) NULL,
[other_open_week_pl] [numeric] (20, 8) NULL,
[other_unlocked_week_pl] [numeric] (20, 8) NULL,
[other_open_month_pl] [numeric] (20, 8) NULL,
[other_unlocked_month_pl] [numeric] (20, 8) NULL,
[other_open_year_pl] [numeric] (20, 8) NULL,
[other_unlocked_year_pl] [numeric] (20, 8) NULL,
[other_open_comp_yr_pl] [numeric] (20, 8) NULL,
[other_unlocked_comp_yr_pl] [numeric] (20, 8) NULL,
[other_open_life_pl] [numeric] (20, 8) NULL,
[other_unlocked_life_pl] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_exposure_pl_deltrg]
on [dbo].[fx_exposure_pl]
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
   select @errmsg = '(fx_exposure_pl) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_fx_exposure_pl
   (pl_asof_date,
    exp_key_type,
    exp_key_num,
    primary_open_day_pl,
    primary_unlocked_day_pl,
    primary_open_week_pl,
    primary_unlocked_week_pl,
    primary_open_month_pl,
    primary_unlocked_month_pl,
    primary_open_year_pl,
    primary_unlocked_year_pl,
    primary_open_comp_yr_pl,
    primary_unlocked_comp_yr_pl,
    primary_open_life_pl,
    primary_unlocked_life_pl,
    forex_open_day_pl,
    forex_unlocked_day_pl,
    forex_open_week_pl,
    forex_unlocked_week_pl,
    forex_open_month_pl,
    forex_unlocked_month_pl,
    forex_open_year_pl,
    forex_unlocked_year_pl,
    forex_open_comp_yr_pl,
    forex_unlocked_comp_yr_pl,
    forex_open_life_pl,
    forex_unlocked_life_pl,
    other_open_day_pl,
    other_unlocked_day_pl,
    other_open_week_pl,
    other_unlocked_week_pl,
    other_open_month_pl,
    other_unlocked_month_pl,
    other_open_year_pl,
    other_unlocked_year_pl,
    other_open_comp_yr_pl,
    other_unlocked_comp_yr_pl,
    other_open_life_pl,
    other_unlocked_life_pl,
    trans_id,
    resp_trans_id)
select
    d.pl_asof_date,
    d.exp_key_type,
    d.exp_key_num,
    d.primary_open_day_pl,
    d.primary_unlocked_day_pl,
    d.primary_open_week_pl,
    d.primary_unlocked_week_pl,
    d.primary_open_month_pl,
    d.primary_unlocked_month_pl,
    d.primary_open_year_pl,
    d.primary_unlocked_year_pl,
    d.primary_open_comp_yr_pl,
    d.primary_unlocked_comp_yr_pl,
    d.primary_open_life_pl,
    d.primary_unlocked_life_pl,
    d.forex_open_day_pl,
    d.forex_unlocked_day_pl,
    d.forex_open_week_pl,
    d.forex_unlocked_week_pl,
    d.forex_open_month_pl,
    d.forex_unlocked_month_pl,
    d.forex_open_year_pl,
    d.forex_unlocked_year_pl,
    d.forex_open_comp_yr_pl,
    d.forex_unlocked_comp_yr_pl,
    d.forex_open_life_pl,
    d.forex_unlocked_life_pl,
    d.other_open_day_pl,
    d.other_unlocked_day_pl,
    d.other_open_week_pl,
    d.other_unlocked_week_pl,
    d.other_open_month_pl,
    d.other_unlocked_month_pl,
    d.other_open_year_pl,
    d.other_unlocked_year_pl,
    d.other_open_comp_yr_pl,
    d.other_unlocked_comp_yr_pl,
    d.other_open_life_pl,
    d.other_unlocked_life_pl,
    d.trans_id,
    @atrans_id 
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FxExposurePl',
       'DIRECT',
       convert(varchar(40), d.pl_asof_date),
       convert(varchar(40), d.exp_key_type),
       convert(varchar(40), d.exp_key_num),
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

create trigger [dbo].[fx_exposure_pl_instrg]
on [dbo].[fx_exposure_pl]
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
       'FxExposurePl',
       'DIRECT',
       convert(varchar(40), i.pl_asof_date),
       convert(varchar(40), i.exp_key_type),
       convert(varchar(40), i.exp_key_num),
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

create trigger [dbo].[fx_exposure_pl_updtrg]
on [dbo].[fx_exposure_pl]
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
   raiserror ('(fx_exposure_pl) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(fx_exposure_pl) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pl_asof_date = d.pl_asof_date and
                 i.exp_key_type = d.exp_key_type and
                 i.exp_key_num = d.exp_key_num)
begin
   raiserror ('(fx_exposure_pl) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(pl_asof_date) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pl_asof_date = d.pl_asof_date and
                                   i.exp_key_type = d.exp_key_type and
                                   i.exp_key_num = d.exp_key_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(fx_exposure_pl) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fx_exposure_pl
      (pl_asof_date,
       exp_key_type,
       exp_key_num,
       primary_open_day_pl,
       primary_unlocked_day_pl,
       primary_open_week_pl,
       primary_unlocked_week_pl,
       primary_open_month_pl,
       primary_unlocked_month_pl,
       primary_open_year_pl,
       primary_unlocked_year_pl,
       primary_open_comp_yr_pl,
       primary_unlocked_comp_yr_pl,
       primary_open_life_pl,
       primary_unlocked_life_pl,
       forex_open_day_pl,
       forex_unlocked_day_pl,
       forex_open_week_pl,
       forex_unlocked_week_pl,
       forex_open_month_pl,
       forex_unlocked_month_pl,
       forex_open_year_pl,
       forex_unlocked_year_pl,
       forex_open_comp_yr_pl,
       forex_unlocked_comp_yr_pl,
       forex_open_life_pl,
       forex_unlocked_life_pl,
       other_open_day_pl,
       other_unlocked_day_pl,
       other_open_week_pl,
       other_unlocked_week_pl,
       other_open_month_pl,
       other_unlocked_month_pl,
       other_open_year_pl,
       other_unlocked_year_pl,
       other_open_comp_yr_pl,
       other_unlocked_comp_yr_pl,
       other_open_life_pl,
       other_unlocked_life_pl,
       trans_id,
       resp_trans_id)
   select
       d.pl_asof_date,
       d.exp_key_type,
       d.exp_key_num,
       d.primary_open_day_pl,
       d.primary_unlocked_day_pl,
       d.primary_open_week_pl,
       d.primary_unlocked_week_pl,
       d.primary_open_month_pl,
       d.primary_unlocked_month_pl,
       d.primary_open_year_pl,
       d.primary_unlocked_year_pl,
       d.primary_open_comp_yr_pl,
       d.primary_unlocked_comp_yr_pl,
       d.primary_open_life_pl,
       d.primary_unlocked_life_pl,
       d.forex_open_day_pl,
       d.forex_unlocked_day_pl,
       d.forex_open_week_pl,
       d.forex_unlocked_week_pl,
       d.forex_open_month_pl,
       d.forex_unlocked_month_pl,
       d.forex_open_year_pl,
       d.forex_unlocked_year_pl,
       d.forex_open_comp_yr_pl,
       d.forex_unlocked_comp_yr_pl,
       d.forex_open_life_pl,
       d.forex_unlocked_life_pl,
       d.other_open_day_pl,
       d.other_unlocked_day_pl,
       d.other_open_week_pl,
       d.other_unlocked_week_pl,
       d.other_open_month_pl,
       d.other_unlocked_month_pl,
       d.other_open_year_pl,
       d.other_unlocked_year_pl,
       d.other_open_comp_yr_pl,
       d.other_unlocked_comp_yr_pl,
       d.other_open_life_pl,
       d.other_unlocked_life_pl,
       d.trans_id,
       i.trans_id 
   from deleted d, inserted i
   where d.pl_asof_date = i.pl_asof_date and
         d.exp_key_type = i.exp_key_type and
         d.exp_key_num = i.exp_key_num

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FxExposurePl',
       'DIRECT',
       convert(varchar(40), i.pl_asof_date),
       convert(varchar(40), i.exp_key_type),
       convert(varchar(40), i.exp_key_num),
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
ALTER TABLE [dbo].[fx_exposure_pl] ADD CONSTRAINT [fx_exposure_pl_pk] PRIMARY KEY CLUSTERED  ([pl_asof_date], [exp_key_type], [exp_key_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fx_exposure_pl] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fx_exposure_pl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fx_exposure_pl] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fx_exposure_pl] TO [next_usr]
GO
