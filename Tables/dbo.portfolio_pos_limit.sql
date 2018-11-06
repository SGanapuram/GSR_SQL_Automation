CREATE TABLE [dbo].[portfolio_pos_limit]
(
[port_num] [int] NOT NULL,
[pos_limit_id] [int] NOT NULL,
[long_limit_qty] [decimal] (20, 8) NULL,
[short_limit_qty] [decimal] (20, 8) NULL,
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tolerance_pct] [decimal] (18, 3) NULL,
[pos_qty] [decimal] (20, 8) NULL,
[pos_asof_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_pos_limit_deltrg]
on [dbo].[portfolio_pos_limit]
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
   select @errmsg = '(portfolio_pos_limit) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_portfolio_pos_limit
(  
   port_num,
   pos_limit_id,
   long_limit_qty,	
   short_limit_qty,	
   uom_code,
   tolerance_pct,
   pos_qty,
   pos_asof_date,
   trans_id,
   resp_trans_id
)
select
   d.port_num,
   d.pos_limit_id,
   d.long_limit_qty,	
   d.short_limit_qty,	
   d.uom_code,
   d.tolerance_pct,
   d.pos_qty,
   d.pos_asof_date,
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

create trigger [dbo].[portfolio_pos_limit_updtrg]
on [dbo].[portfolio_pos_limit]
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
   raiserror ('(portfolio_pos_limit) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(portfolio_pos_limit) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.port_num = d.port_num and
                 i.pos_limit_id = d.pos_limit_id)
begin
   raiserror ('(portfolio_pos_limit) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(port_num) or
   update(pos_limit_id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.port_num = d.port_num and
                                   i.pos_limit_id = d.pos_limit_id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(portfolio_pos_limit) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_portfolio_pos_limit
 	    (port_num, 
 	     pos_limit_id,
       long_limit_qty,	
       short_limit_qty,	
       uom_code,
       tolerance_pct,
       pos_qty,
       pos_asof_date,
       trans_id,
       resp_trans_id)
   select
 	    d.port_num, 
 	    d.pos_limit_id,
      d.long_limit_qty,	
      d.short_limit_qty,	
      d.uom_code,
      d.tolerance_pct,
      d.pos_qty,
      d.pos_asof_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.port_num = i.port_num and
         d.pos_limit_id = i.pos_limit_id

return
GO
ALTER TABLE [dbo].[portfolio_pos_limit] ADD CONSTRAINT [portfolio_pos_limit_pk] PRIMARY KEY CLUSTERED  ([port_num], [pos_limit_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[portfolio_pos_limit] ADD CONSTRAINT [portfolio_pos_limit_fk1] FOREIGN KEY ([port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[portfolio_pos_limit] ADD CONSTRAINT [portfolio_pos_limit_fk3] FOREIGN KEY ([uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[portfolio_pos_limit] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_pos_limit] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_pos_limit] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_pos_limit] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'portfolio_pos_limit', NULL, NULL
GO
