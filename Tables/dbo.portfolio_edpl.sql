CREATE TABLE [dbo].[portfolio_edpl]
(
[port_num] [int] NOT NULL,
[latest_pl] [numeric] (20, 8) NULL,
[day_pl] [numeric] (20, 8) NULL,
[week_pl] [numeric] (20, 8) NULL,
[month_pl] [numeric] (20, 8) NULL,
[year_pl] [numeric] (20, 8) NULL,
[comp_yr_pl] [numeric] (20, 8) NULL,
[asof_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_edpl_deltrg]
on [dbo].[portfolio_edpl]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

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
   select @errmsg = '(portfolio_edpl) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_portfolio_edpl
(  
    port_num,
    latest_pl,
    day_pl,
    week_pl,
    month_pl,
    year_pl,
    comp_yr_pl,
    asof_date,
    trans_id,
    resp_trans_id
)
select
    d.port_num,
    d.latest_pl,
    d.day_pl,
    d.week_pl,
    d.month_pl,
    d.year_pl,
    d.comp_yr_pl,
    d.asof_date,
    d.trans_id,
    @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),  
        @the_tran_type      char(1),  
        @the_entity_name    varchar(30)  
  
   select @the_entity_name = 'PortfolioEdpl'  
  
   if @num_rows = 1  
   begin  
      select @the_tran_type = it.type,  
             @the_sequence = it.sequence  
      from dbo.icts_transaction it WITH (NOLOCK)  
      where it.trans_id = @atrans_id       
  
      if @the_tran_type != 'E'  
      begin  
         /* BEGIN_TRANSACTION_TOUCH */  
  
         insert dbo.transaction_touch  
         select 'DELETE',  
                @the_entity_name,  
                'DIRECT',  
                convert(varchar(40), d.port_num),  
                null,  
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
   end  
   else  
   begin  /* if @num_rows > 1 */  
  
      /* BEGIN_TRANSACTION_TOUCH */  
  
      insert dbo.transaction_touch  
      select 'DELETE',  
             @the_entity_name,  
             'DIRECT',  
             convert(varchar(40), d.port_num),  
             null,  
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
      where it.trans_id = @atrans_id and  
            it.type != 'E'  
  
      /* END_TRANSACTION_TOUCH */  
   end  
  
  return  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_edpl_instrg]
on [dbo].[portfolio_edpl]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'PortfolioEdpl'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it,
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_TRANSACTION_TOUCH */
       if @the_tran_type <> 'E'
       begin
          insert dbo.transaction_touch
          select 'INSERT',
                 @the_entity_name,
                 'DIRECT',
                 convert(varchar(40), port_num),
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 i.trans_id,
                 @the_sequence
          from inserted i
       end

       /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), port_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it,
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

create trigger [dbo].[portfolio_edpl_updtrg]
on [dbo].[portfolio_edpl]
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
   raiserror ('(portfolio_edpl) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(portfolio_edpl) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.port_num = d.port_num)
begin
   select @errmsg = '(portfolio_edpl) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.port_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(port_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.port_num = d.port_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(portfolio_edpl) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_portfolio_edpl
   (port_num,
    latest_pl,
    day_pl,
    week_pl,
    month_pl,
    year_pl,
    comp_yr_pl,
    asof_date,
    trans_id,	
    resp_trans_id)
  select
    d.port_num,
    d.latest_pl,
    d.day_pl,
    d.week_pl,
    d.month_pl,
    d.year_pl,
    d.comp_yr_pl,
    d.asof_date,
    d.trans_id,
    i.trans_id
   from deleted d, inserted i
   where d.port_num = i.port_num 

declare @the_sequence       numeric(32,0),  
        @the_tran_type      char(1),  
        @the_entity_name    varchar(30)  
  
   select @the_entity_name = 'PortfolioEdpl'  
  
   if @num_rows = 1  
   begin  
      select @the_tran_type = it.type,  
             @the_sequence = it.sequence  
      from dbo.icts_transaction it WITH (NOLOCK),  
           inserted i  
      where it.trans_id = i.trans_id  
  
      if @the_tran_type != 'E'  
      begin  
         /* BEGIN_TRANSACTION_TOUCH */  
  
         insert dbo.transaction_touch  
         select 'UPDATE',  
                @the_entity_name,  
                'DIRECT',  
                convert(varchar(40), i.port_num),  
                null,  
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
      /* BEGIN_TRANSACTION_TOUCH */  
  
      insert dbo.transaction_touch  
      select 'UPDATE',  
             @the_entity_name,  
             'DIRECT',  
             convert(varchar(40), i.port_num),  
             null,  
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
ALTER TABLE [dbo].[portfolio_edpl] ADD CONSTRAINT [portfolio_edpl_pk] PRIMARY KEY CLUSTERED  ([port_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_edpl] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_edpl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_edpl] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_edpl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'portfolio_edpl', NULL, NULL
GO
