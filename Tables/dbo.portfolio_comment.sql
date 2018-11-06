CREATE TABLE [dbo].[portfolio_comment]
(
[port_num] [int] NOT NULL,
[cmnt_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_comment_updtrg]
on [dbo].[portfolio_comment]
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
      raiserror ('(portfolio_comment) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[portfolio_comment] ADD CONSTRAINT [portfolio_comment_pk] PRIMARY KEY CLUSTERED  ([port_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_comment] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_comment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_comment] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_comment] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'portfolio_comment', NULL, NULL
GO
