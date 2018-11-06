CREATE TABLE [dbo].[posting_search_prec]
(
[posting_search_prec_num] [smallint] NOT NULL,
[search_company_num] [int] NULL,
[search_for_system] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[search_column_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[search_column_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[search_column_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[search_column_wild_card] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[search_precedence] [tinyint] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[posting_search_prec_updtrg]
on [dbo].[posting_search_prec]
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
   raiserror ('(posting_search_prec) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(posting_search_prec) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.posting_search_prec_num = d.posting_search_prec_num )
begin
   raiserror ('(posting_search_prec) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(posting_search_prec_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.posting_search_prec_num = d.posting_search_prec_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(posting_search_prec) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[posting_search_prec] ADD CONSTRAINT [posting_search_prec_pk] PRIMARY KEY CLUSTERED  ([posting_search_prec_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[posting_search_prec] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[posting_search_prec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[posting_search_prec] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[posting_search_prec] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'posting_search_prec', NULL, NULL
GO
