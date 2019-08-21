CREATE TABLE [dbo].[formula_component_ext]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[formula_comp_num] [smallint] NOT NULL,
[gravity_adj_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[deemed_gravity] [float] NULL,
[gravity_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gravity_table_name] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[posted_gravity] [float] NULL,
[estimate_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_component_ext_updtrg]
on [dbo].[formula_component_ext]
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
   raiserror ('(formula_component_ext) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(formula_component_ext) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.formula_num = d.formula_num and 
                 i.formula_body_num = d.formula_body_num and 
                 i.formula_comp_num = d.formula_comp_num )
begin
   raiserror ('(formula_component_ext) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(formula_num) or  
   update(formula_body_num) or  
   update(formula_comp_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.formula_num = d.formula_num and 
                                   i.formula_body_num = d.formula_body_num and 
                                   i.formula_comp_num = d.formula_comp_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(formula_component_ext) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[formula_component_ext] ADD CONSTRAINT [formula_component_ext_pk] PRIMARY KEY CLUSTERED  ([formula_num], [formula_body_num], [formula_comp_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula_component_ext] ADD CONSTRAINT [formula_component_ext_fk2] FOREIGN KEY ([estimate_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[formula_component_ext] ADD CONSTRAINT [formula_component_ext_fk3] FOREIGN KEY ([gravity_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
GRANT DELETE ON  [dbo].[formula_component_ext] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula_component_ext] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula_component_ext] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula_component_ext] TO [next_usr]
GO
