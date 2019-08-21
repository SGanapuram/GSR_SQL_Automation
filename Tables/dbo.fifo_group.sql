CREATE TABLE [dbo].[fifo_group]
(
[fifo_group_num] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[clr_brkr_num] [int] NULL,
[item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[strike_price] [numeric] (20, 8) NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fifo_group_deltrg]
on [dbo].[fifo_group]
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
   select @errmsg = '(fifo_group) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_fifo_group
(  
   fifo_group_num,		
   commkt_key,
   trading_prd,
   clr_brkr_num,
   item_type,
   strike_price,
   put_call_ind,
   trans_id,
   resp_trans_id
)
select
   d.fifo_group_num,		
   d.commkt_key,
   d.trading_prd,
   d.clr_brkr_num,
   d.item_type,
   d.strike_price,
   d.put_call_ind,
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

create trigger [dbo].[fifo_group_updtrg]
on [dbo].[fifo_group]
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
   raiserror ('(fifo_group) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fifo_group_num = d.fifo_group_num) 
begin
   raiserror ('(fifo_group) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(fifo_group_num)
begin
   select @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.fifo_group_num = d.fifo_group_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      select @errmsg = '(fifo_group) primary key can not be changed.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fifo_group
   (
      fifo_group_num,		
      commkt_key,
      trading_prd,
      clr_brkr_num,
      item_type,
      strike_price,
      put_call_ind,
      trans_id,
      resp_trans_id
   )
   select
      d.fifo_group_num,		
      d.commkt_key,
      d.trading_prd,
      d.clr_brkr_num,
      d.item_type,
      d.strike_price,
      d.put_call_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.fifo_group_num = i.fifo_group_num

/* AUDIT_CODE_END */  
return
GO
ALTER TABLE [dbo].[fifo_group] ADD CONSTRAINT [chk_fifo_group_item_type] CHECK (([item_type]='E' OR [item_type]='F'))
GO
ALTER TABLE [dbo].[fifo_group] ADD CONSTRAINT [fifo_group_pk] PRIMARY KEY CLUSTERED  ([fifo_group_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fifo_group] ADD CONSTRAINT [fifo_group_fk1] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[fifo_group] ADD CONSTRAINT [fifo_group_fk2] FOREIGN KEY ([clr_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[fifo_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fifo_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fifo_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fifo_group] TO [next_usr]
GO
