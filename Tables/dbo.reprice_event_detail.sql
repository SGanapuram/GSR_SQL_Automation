CREATE TABLE [dbo].[reprice_event_detail]
(
[reprice_event_oid] [int] NOT NULL,
[reprice_event_detail_num] [smallint] NOT NULL,
[entity_id] [int] NOT NULL,
[key1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[reprice_event_detail_deltrg]
on [dbo].[reprice_event_detail]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

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
   select @errmsg = '(reprice_event_detail) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_reprice_event_detail
   (reprice_event_oid,
    reprice_event_detail_num,
    entity_id,
    key1,
    key2,
    key3,
    key4,
    status,
    trans_id,
    resp_trans_id)
select
   d.reprice_event_oid,
   d.reprice_event_detail_num,
   d.entity_id,
   d.key1,
   d.key2,
   d.key3,
   d.key4,
   d.status,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'RepriceEventDetail'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK)
      where it.trans_id = @atrans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.reprice_event_oid),
             convert(varchar(40), d.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           deleted d
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 4) = 4 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), d.reprice_event_oid),
             convert(varchar(40), d.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from deleted d

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.reprice_event_oid),
             convert(varchar(40), d.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           deleted d,
           dbo.icts_transaction it WITH (NOLOCK)
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 4) = 4 AND
            a.entity_name = @the_entity_name AND
            it.trans_id = @atrans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), d.reprice_event_oid),
             convert(varchar(40), d.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           deleted d
      where it.trans_id = @atrans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[reprice_event_detail_instrg]
on [dbo].[reprice_event_detail]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'RepriceEventDetail'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40), i.reprice_event_oid),
             convert(varchar(40), i.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 1) = 1 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'INSERT',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40), i.reprice_event_oid),
                convert(varchar(40), i.reprice_event_detail_num),
                null,
                null,
                null,
                null,
                null,
                null,
                i.trans_id,
                @the_sequence
         from inserted i

         /* END_TRANSACTION_TOUCH */
      end
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40), i.reprice_event_oid),
             convert(varchar(40), i.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 1) = 1 AND
            a.entity_name = @the_entity_name AND
            i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), i.reprice_event_oid),
             convert(varchar(40), i.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[reprice_event_detail_updtrg]
on [dbo].[reprice_event_detail]
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
   raiserror ('(reprice_event_detail) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(reprice_event_detail) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.reprice_event_oid = d.reprice_event_oid and
                 i.reprice_event_detail_num = d.reprice_event_detail_num )
begin
   select @errmsg = '(reprice_event_detail) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.reprice_event_oid) + ',' + 
                                        convert(varchar, i.reprice_event_detail_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end


/* RECORD_STAMP_END */

if  update(reprice_event_oid) or
    update(reprice_event_detail_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.reprice_event_oid = d.reprice_event_oid and
                                   i.reprice_event_detail_num = d.reprice_event_detail_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(reprice_event_detail) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */
if @dummy_update = 0
   insert dbo.aud_reprice_event_detail
      (reprice_event_oid,
       reprice_event_detail_num,
       entity_id,
       key1,
       key2,
       key3,
       key4,
       status,
       trans_id,
       resp_trans_id)
   select
      d.reprice_event_oid,
      d.reprice_event_detail_num,
      d.entity_id,
      d.key1,
      d.key2,
      d.key3,
      d.key4,
      d.status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.reprice_event_oid = i.reprice_event_oid and
         d.reprice_event_detail_num = i.reprice_event_detail_num

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'RepriceEventDetail'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40), i.reprice_event_oid),
             convert(varchar(40), i.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,            
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 2) = 2 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), i.reprice_event_oid),
             convert(varchar(40), i.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,            
             i.trans_id,
             @the_sequence
      from inserted i

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40), i.reprice_event_oid),
             convert(varchar(40), i.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,            
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 2) = 2 AND
            a.entity_name = @the_entity_name AND
            i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), i.reprice_event_oid),
             convert(varchar(40), i.reprice_event_detail_num),
             null,
             null,
             null,
             null,
             null,
             null,            
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
ALTER TABLE [dbo].[reprice_event_detail] ADD CONSTRAINT [reprice_event_detail_pk] PRIMARY KEY CLUSTERED  ([reprice_event_oid], [reprice_event_detail_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reprice_event_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[reprice_event_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[reprice_event_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[reprice_event_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'reprice_event_detail', NULL, NULL
GO
