CREATE TABLE [dbo].[als_run_touch]
(
[als_module_group_id] [int] NOT NULL,
[operation] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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

create trigger [dbo].[als_run_touch_instrg]
on [dbo].[als_run_touch]
for insert
as
declare @num_rows    int

select @num_rows = @@rowcount
if @num_rows = 0
   return

   insert into dbo.als_run 
      (sequence, als_module_group_id, trans_id)
   select distinct
      sequence,
      als_module_group_id,
      trans_id
   from inserted i
   where not exists (select 1
                     from dbo.als_run b WITH (NOLOCK)
                     where i.sequence = b.sequence and
                           i.als_module_group_id = b.als_module_group_id)

return
GO
ALTER TABLE [dbo].[als_run_touch] ADD CONSTRAINT [als_run_touch_pk] PRIMARY KEY CLUSTERED  ([touch_key]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [als_run_touch_idx2] ON [dbo].[als_run_touch] ([entity_name]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [als_run_touch_idx1] ON [dbo].[als_run_touch] ([sequence], [als_module_group_id]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[als_run_touch] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[als_run_touch] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[als_run_touch] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[als_run_touch] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'als_run_touch', NULL, NULL
GO
