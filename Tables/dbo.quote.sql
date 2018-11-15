CREATE TABLE [dbo].[quote]
(
[id] [int] NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pl_qmds_id] [int] NULL,
[product_id] [int] NOT NULL,
[report_qmds_id] [int] NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__quote__status__1CC7330E] DEFAULT ('N'),
[symbol] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_for_pl] [bit] NOT NULL CONSTRAINT [DF__quote__use_for_p__1EAF7B80] DEFAULT ((0)),
[venue_id] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[symbol_regex] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[quote_deltrg]
on [dbo].[quote]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int
 
set @num_rows = @@rowcount
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
   set @errmsg = '(quote) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
insert dbo.aud_quote
(
   id,
   loc_code,
   pl_qmds_id,
   product_id,
   report_qmds_id,
   status,
   symbol,
   use_for_pl,
   venue_id,
   symbol_regex,
   trans_id,
   resp_trans_id
)
select
   d.id,
   d.loc_code,
   d.pl_qmds_id,
   d.product_id,
   d.report_qmds_id,
   d.status,
   d.symbol,
   d.use_for_pl,
   d.venue_id,
   d.symbol_regex,
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
 
create trigger [dbo].[quote_updtrg]
on [dbo].[quote]
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
   raiserror('(quote) The change needs to be attached with a new trans_id.', 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      set @errmsg = '(quote) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg, 10, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.id = d.id)
begin
   raiserror ('(quote) new trans_id must not be older than current trans_id.', 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
/* RECORD_STAMP_END */
if update(id)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.id = d.id)
   if (@count_num_rows = @num_rows)
   begin
      set @dummy_update = 1
   end
   else
   begin
      raiserror ('(quote) primary key can not be changed.', 10, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
   insert dbo.aud_quote
 	    (id,
 	     loc_code,
 	     pl_qmds_id,
 	     product_id,
 	     report_qmds_id,
 	     status,
 	     symbol,
 	     use_for_pl,
 	     venue_id,
 	     symbol_regex,
 	     trans_id,
       resp_trans_id)
   select
 	    d.id,
 	    d.loc_code,
 	    d.pl_qmds_id,
 	    d.product_id,
 	    d.report_qmds_id,
 	    d.status,
 	    d.symbol,
 	    d.use_for_pl,
 	    d.venue_id,
 	    d.symbol_regex,
 	    d.trans_id,
 	    i.trans_id
   from deleted d, inserted i
   where d.id = i.id
return
GO
ALTER TABLE [dbo].[quote] ADD CONSTRAINT [CK__quote__status__1DBB5747] CHECK (([status]='I' OR [status]='A' OR [status]='N'))
GO
ALTER TABLE [dbo].[quote] ADD CONSTRAINT [quote_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [quote_idx1] ON [dbo].[quote] ([loc_code], [product_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[quote] ADD CONSTRAINT [quote_uk1] UNIQUE NONCLUSTERED  ([loc_code], [product_id], [venue_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[quote] ADD CONSTRAINT [quote_fk1] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[quote] ADD CONSTRAINT [quote_fk2] FOREIGN KEY ([product_id]) REFERENCES [dbo].[product] ([id])
GO
GRANT DELETE ON  [dbo].[quote] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[quote] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[quote] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[quote] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'quote', NULL, NULL
GO
