CREATE TABLE [dbo].[riskmgr_win_pivot_def]
(
[owner_win_id] [int] NOT NULL,
[piv_def_id] [int] NOT NULL,
[tab_index] [int] NOT NULL,
[tab_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[num_of_decimals] [tinyint] NOT NULL,
[show_future_equiv] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__riskmgr_w__show___729BEF18] DEFAULT ('N'),
[pivot_layout] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[show_zero] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__riskmgr_w__show___7484378A] DEFAULT ('N'),
[asof_date] [date] NULL,
[primary_uom] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__riskmgr_w__prima__75785BC3] DEFAULT ('N'),
[quantity_divisor] [float] NOT NULL CONSTRAINT [DF_quantity_divisor] DEFAULT ((1))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[riskmgr_win_pivot_def_deltrg]
on [dbo].[riskmgr_win_pivot_def]
for delete
AS
declare @num_rows           int,
        @errmsg             varchar(255),
        @atrans_id          int,
        @the_entity_name    varchar(80)

   set @num_rows = @@rowcount
   if @num_rows = 0
      return

   select @atrans_id = max(trans_id)
   from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
   where spid = @@spid and
         tran_date >= (select top 1 login_time
                       from master.dbo.sysprocesses (nolock)
                       where spid = @@spid)

   if @atrans_id is null
   begin
      set @errmsg = '(riskmgr_win_pivot_def) Failed to obtain a valid responsible trans_id.'
      if exists (select 1
                 from master.dbo.sysprocesses (nolock)
                 where spid = @@spid and
                       (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                       program_name like 'Microsoft SQL Server Management Studio%') )
         set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
      raiserror(@errmsg, 16, 1)
      rollback tran
      RETURN
   END

   set @the_entity_name = 'RiskmgrWinPivotDef'		

   /* BEGIN_TRANSACTION_TOUCH */
   insert dbo.transaction_touch
   select 'DELETE',
          @the_entity_name,
          'DIRECT',
          CONVERT(VARCHAR(40), d.piv_def_id),
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          @atrans_id,
          it.sequence
   FROM dbo.icts_transaction it WITH (NOLOCK),
        deleted d
   WHERE it.trans_id = @atrans_id AND
         it.type != 'E'

   /* END_TRANSACTION_TOUCH */

   insert into dbo.aud_riskmgr_win_pivot_def
     (
	  piv_def_id,
	  owner_win_id,
	  tab_index,
	  tab_name,
 	  uom,
	  num_of_decimals,
	  show_future_equiv,
	  pivot_layout,
	  show_zero,
	  asof_date,
	  primary_uom,
	  quantity_divisor,
	  trans_id,
	  resp_trans_id
	 )
   select
      d.piv_def_id,
	  d.owner_win_id,
	  d.tab_index,
	  d.tab_name,
 	  d.uom,
	  d.num_of_decimals,
	  d.show_future_equiv,
	  d.pivot_layout,
	  d.show_zero,
	  d.asof_date,
	  d.primary_uom,
	  d.quantity_divisor,
	  d.trans_id,
      @atrans_id	 
   from deleted d
   
return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[riskmgr_win_pivot_def_instrg]
ON [dbo].[riskmgr_win_pivot_def]
for insert  
as
   		
   /* BEGIN_TRANSACTION_TOUCH */  
   INSERT dbo.transaction_touch
   SELECT 'INSERT',
					'RiskmgrWinPivotDef',
					'DIRECT',
					convert(varchar(40), i.piv_def_id),
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					i.trans_id,
					it.sequence
   FROM inserted i, 
        dbo.icts_transaction it
   WHERE i.trans_id = it.trans_id and
         it.type != 'E'

   /* END_TRANSACTION_TOUCH */  
return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[riskmgr_win_pivot_def_updtrg]
on [dbo].[riskmgr_win_pivot_def]
for update 
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)
        
   set @num_rows = @@rowcount
   if @num_rows = 0
      return

   set @dummy_update = 0

   /* RECORD_STAMP_BEGIN */
   if not update(trans_id) 
   begin
      raiserror('(riskmgr_win_pivot_def) The change needs to be attached with a new trans_id', 16, 1)
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
         set @errmsg = '(riskmgr_win_pivot_def) New trans_id must be larger than original trans_id.'
         set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
         raiserror(@errmsg, 16, 1)
         if @@trancount > 0 rollback tran
         return
      end
   end

   if exists (select * from inserted i, deleted d
              where i.trans_id < d.trans_id and
                    i.piv_def_id = d.piv_def_id)
   begin
      raiserror('(riskmgr_win_pivot_def) new trans_id must not be older than current trans_id.',16,1)
      if @@trancount > 0 rollback tran
      return
   end

   /* RECORD_STAMP_END */
   if update(piv_def_id) 
   begin
      set @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.piv_def_id = d.piv_def_id)
      if (@count_num_rows = @num_rows)
         set @dummy_update = 1
      else
      begin
         raiserror('(riskmgr_win_pivot_def) primary key can not be changed.', 16, 1)
         if @@trancount > 0 rollback tran
         return
      end
   end

   /* BEGIN_TRANSACTION_TOUCH */

   INSERT dbo.transaction_touch
		SELECT 'UPDATE',
		       'RiskmgrWinPivotDef',
		       'DIRECT',
		       CONVERT(VARCHAR(40), i.piv_def_id),
		       NULL,
		       NULL,
		       NULL,
		       NULL,
		       NULL,
		       NULL,
		       NULL,
		       i.trans_id,
		       it.sequence
		FROM inserted i, dbo.icts_transaction it
		WHERE i.trans_id = it.trans_id AND 
		      it.type != 'E'

    /* END_TRANSACTION_TOUCH */

    INSERT INTO dbo.aud_riskmgr_win_pivot_def
      (
	   piv_def_id,
	   owner_win_id,
	   tab_index,
	   tab_name,
 	   uom,
	   num_of_decimals,
	   show_future_equiv,
	   pivot_layout,
	   show_zero,
	   asof_date,
	   primary_uom,
	   quantity_divisor,
	   trans_id,
	   resp_trans_id)
    SELECT
       d.piv_def_id,
	   d.owner_win_id,
	   d.tab_index,
	   d.tab_name,
 	   d.uom,
	   d.num_of_decimals,
	   d.show_future_equiv,
	   d.pivot_layout,
	   d.show_zero,
	   d.asof_date,
	   d.primary_uom,
	   d.quantity_divisor,
	   d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.piv_def_id = i.piv_def_id

return
GO
ALTER TABLE [dbo].[riskmgr_win_pivot_def] ADD CONSTRAINT [CK__riskmgr_w__prima__766C7FFC] CHECK (([primary_uom]='n' OR [primary_uom]='N' OR [primary_uom]='y' OR [primary_uom]='Y'))
GO
ALTER TABLE [dbo].[riskmgr_win_pivot_def] ADD CONSTRAINT [CK__riskmgr_w__show___73901351] CHECK (([show_future_equiv]='n' OR [show_future_equiv]='N' OR [show_future_equiv]='y' OR [show_future_equiv]='Y'))
GO
ALTER TABLE [dbo].[riskmgr_win_pivot_def] ADD CONSTRAINT [riskmgr_win_pivot_def_pk] PRIMARY KEY CLUSTERED  ([piv_def_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[riskmgr_win_pivot_def] ADD CONSTRAINT [riskmgr_win_pivot_def_fk1] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[riskmgr_win_pivot_def] ADD CONSTRAINT [riskmgr_win_pivot_def_fk2] FOREIGN KEY ([owner_win_id]) REFERENCES [dbo].[riskmgr_win_def] ([win_id])
GO
GRANT DELETE ON  [dbo].[riskmgr_win_pivot_def] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[riskmgr_win_pivot_def] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[riskmgr_win_pivot_def] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[riskmgr_win_pivot_def] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'riskmgr_win_pivot_def', NULL, NULL
GO
