CREATE TABLE [dbo].[transaction_touch]
(
[operation] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[touch_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key7] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key8] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NULL,
[sequence] [numeric] (32, 0) NOT NULL,
[touch_key] [numeric] (32, 0) NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[transaction_touch_instrg]
on [dbo].[transaction_touch]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   if @@identity > (select convert(numeric(32, 0), attribute_value)
                    from dbo.constants
                    where attribute_name = 'SequenceWaterMark')
   begin
      raiserror ('The transaction_touch table has experienced the BIG IDENTITY GAP problem..Report this problem to your DBA now.',10,1)
      if @@trancount > 0 rollback tran

      return 
   end

return
GO
ALTER TABLE [dbo].[transaction_touch] ADD CONSTRAINT [transaction_touch_pk] PRIMARY KEY CLUSTERED  ([touch_key]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [transaction_touch_idx2] ON [dbo].[transaction_touch] ([sequence], [touch_key]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [transaction_touch_idx1] ON [dbo].[transaction_touch] ([trans_id]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transaction_touch] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[transaction_touch] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[transaction_touch] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[transaction_touch] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'transaction_touch', NULL, NULL
GO
