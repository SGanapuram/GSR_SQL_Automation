CREATE TABLE [dbo].[tid_mtm_volatility]
(
[dist_num] [int] NOT NULL,
[mtm_pl_asof_date] [datetime] NOT NULL,
[vol_num] [int] NOT NULL,
[strike_price] [numeric] (20, 8) NULL,
[skew_price] [numeric] (20, 8) NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volatility] [numeric] (20, 8) NULL,
[use_option_skew] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_tid_mtm_volatility_use_option_skew] DEFAULT ('N'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[tid_mtm_volatility_deltrg]
on [dbo].[tid_mtm_volatility]
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
                    from master.dbo.sysprocesses with (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(tid_mtm_volatility) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses with (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_tid_mtm_volatility
   (dist_num,
    mtm_pl_asof_date,
    vol_num,
    strike_price,
    skew_price,
    curr_code,
    uom_code,
    volatility,
    use_option_skew,
    trans_id,
    resp_trans_id)
select
   d.dist_num,
   d.mtm_pl_asof_date,
   d.vol_num,
   d.strike_price,
   d.skew_price,
   d.curr_code,
   d.uom_code,
   d.volatility,
   d.use_option_skew,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[tid_mtm_volatility_updtrg]
on [dbo].[tid_mtm_volatility]
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
   raiserror ('(tid_mtm_volatility) The change needs to be attached with a new trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses with (nolock)
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(tid_mtm_volatility) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.dist_num = d.dist_num and
                 i.mtm_pl_asof_date = d.mtm_pl_asof_date and
                 i.vol_num = d.vol_num )
begin
   raiserror ('(tid_mtm_volatility) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(dist_num) or
   update(mtm_pl_asof_date) or
   update(vol_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.dist_num = d.dist_num and
                                   i.mtm_pl_asof_date = d.mtm_pl_asof_date and
                                   i.vol_num = d.vol_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(tid_mtm_volatility) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_tid_mtm_volatility
      (dist_num,
       mtm_pl_asof_date,
       vol_num,
       strike_price,
       skew_price,
       curr_code,
       uom_code,
       volatility,
       use_option_skew,
       trans_id,
       resp_trans_id)
   select
      d.dist_num,
      d.mtm_pl_asof_date,
      d.vol_num,
      d.strike_price,
      d.skew_price,
      d.curr_code,
      d.uom_code,
      d.volatility,
      d.use_option_skew,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.dist_num = i.dist_num and
         d.mtm_pl_asof_date = i.mtm_pl_asof_date and
         d.vol_num = i.vol_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[tid_mtm_volatility] ADD CONSTRAINT [chk_tid_mtm_volatility_use_option_skew] CHECK (([use_option_skew]='N' OR [use_option_skew]='Y'))
GO
ALTER TABLE [dbo].[tid_mtm_volatility] ADD CONSTRAINT [tid_mtm_volatility_pk] PRIMARY KEY CLUSTERED  ([dist_num], [mtm_pl_asof_date], [vol_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tid_mtm_volatility_idx1] ON [dbo].[tid_mtm_volatility] ([mtm_pl_asof_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tid_mtm_volatility] ADD CONSTRAINT [tid_mtm_volatility_fk2] FOREIGN KEY ([curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[tid_mtm_volatility] ADD CONSTRAINT [tid_mtm_volatility_fk3] FOREIGN KEY ([uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[tid_mtm_volatility] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tid_mtm_volatility] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tid_mtm_volatility] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tid_mtm_volatility] TO [next_usr]
GO
