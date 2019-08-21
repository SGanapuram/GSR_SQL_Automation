CREATE TABLE [dbo].[inv_pricing_period]
(
[inv_num] [int] NOT NULL,
[inv_price_start_date] [datetime] NULL,
[inv_price_end_date] [datetime] NULL,
[num_of_pricing_days] [smallint] NULL,
[inv_price_excl_sat] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_price_excl_sun] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_price_excl_hol] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inv_pricing_period_deltrg]
on [dbo].[inv_pricing_period]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(inv_pricing_period) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_inv_pricing_period
(  
 	 inv_num,
 	 inv_price_start_date,
   inv_price_end_date,
   num_of_pricing_days,
   inv_price_excl_sat, 
   inv_price_excl_sun, 
   inv_price_excl_hol, 
   trans_id,
   resp_trans_id
)
select
 	 d.inv_num,
 	 d.inv_price_start_date,
   d.inv_price_end_date,
   d.num_of_pricing_days,
   d.inv_price_excl_sat, 
   d.inv_price_excl_sun, 
   d.inv_price_excl_hol, 
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

create trigger [dbo].[inv_pricing_period_updtrg]
on [dbo].[inv_pricing_period]
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
   raiserror ('(inv_pricing_period) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(inv_pricing_period) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.inv_num = d.inv_num)
begin
   select @errmsg = '(inv_pricing_period) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.inv_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(inv_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.inv_num = d.inv_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(inv_pricing_period) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_inv_pricing_period
 	    (inv_num,
 	     inv_price_start_date,
       inv_price_end_date,
       num_of_pricing_days,
       inv_price_excl_sat, 
       inv_price_excl_sun, 
       inv_price_excl_hol, 
       trans_id,
       resp_trans_id)
   select
 	    d.inv_num,
 	    d.inv_price_start_date,
      d.inv_price_end_date,
      d.num_of_pricing_days,
      d.inv_price_excl_sat, 
      d.inv_price_excl_sun, 
      d.inv_price_excl_hol, 
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.inv_num = i.inv_num 

return
GO
ALTER TABLE [dbo].[inv_pricing_period] ADD CONSTRAINT [inv_pricing_period_pk] PRIMARY KEY CLUSTERED  ([inv_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inv_pricing_period] ADD CONSTRAINT [inv_pricing_period_fk1] FOREIGN KEY ([inv_num]) REFERENCES [dbo].[inventory] ([inv_num])
GO
GRANT DELETE ON  [dbo].[inv_pricing_period] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inv_pricing_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inv_pricing_period] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inv_pricing_period] TO [next_usr]
GO
