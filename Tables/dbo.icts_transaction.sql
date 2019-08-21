CREATE TABLE [dbo].[icts_transaction]
(
[trans_id] [int] NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tran_date] [datetime] NOT NULL,
[app_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[app_revision] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spid] [smallint] NULL,
[workstation_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sequence] [numeric] (32, 0) NOT NULL IDENTITY(1, 1),
[parent_trans_id] [int] NULL,
[executor_id] [tinyint] NOT NULL CONSTRAINT [df_icts_transaction_executor_id] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[icts_transaction_instrg]
on [dbo].[icts_transaction]    
instead of insert    
as    
declare @num_rows    int        
    
select @num_rows = @@rowcount    
if @num_rows = 0    
   return    
    
insert into icts_transaction
( trans_id,
  type,
  user_init,
  tran_date,
  app_name,
  app_revision,
  spid,
  workstation_id,  
  parent_trans_id,
  executor_id)
select 
  trans_id,
  type,
  user_init,
  tran_date,
  app_name,
  app_revision,
  @@spid,
  workstation_id,  
  parent_trans_id,
  executor_id
from inserted  
  
return  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[icts_transaction_updtrg]
on [dbo].[icts_transaction]
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

if @@identity > (select convert(numeric(32, 0), attribute_value)
                 from dbo.constants
                 where attribute_name = 'SequenceWaterMark')
begin
   raiserror ('The icts_transaction table has experienced the BIG IDENTITY GAP problem..Report this problem to your DBA now.',16,1)
   if @@trancount > 0 rollback tran

   return 
end

if update(trans_id) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trans_id = d.trans_id )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(icts_transaction) trans_id can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[icts_transaction] ADD CONSTRAINT [icts_transaction_pk] PRIMARY KEY CLUSTERED  ([sequence]) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE NONCLUSTERED INDEX [icts_transaction_idx5] ON [dbo].[icts_transaction] ([parent_trans_id]) INCLUDE ([trans_id]) WHERE ([parent_trans_id] IS NOT NULL) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [icts_transaction_idx4] ON [dbo].[icts_transaction] ([spid], [tran_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [icts_transaction_idx3] ON [dbo].[icts_transaction] ([tran_date], [trans_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [icts_transaction_idx1] ON [dbo].[icts_transaction] ([trans_id], [tran_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [icts_transaction_idx2] ON [dbo].[icts_transaction] ([type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[icts_transaction] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[icts_transaction] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[icts_transaction] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[icts_transaction] TO [next_usr]
GO
