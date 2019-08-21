CREATE TABLE [dbo].[portfolio]
(
[port_num] [int] NOT NULL,
[port_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[desired_pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_short_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_full_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_class] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_ref_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[num_history_days] [int] NULL,
[trading_entity_num] [int] NULL,
[port_locked] [smallint] NULL CONSTRAINT [df_portfolio_port_locked] DEFAULT ((0)),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_deltrg]
on [dbo].[portfolio]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(portfolio) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'Portfolio',
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
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */

/* AUDIT_CODE_BEGIN */

insert dbo.aud_portfolio
   (port_num,
    port_type,
    desired_pl_curr_code,
    port_short_name,
    port_full_name,
    port_class,
    port_ref_key,
    owner_init,
    cmnt_num,
    num_history_days,
    trading_entity_num,
    port_locked,
    trans_id,
    resp_trans_id)
select
   d.port_num,
   d.port_type,
   d.desired_pl_curr_code,
   d.port_short_name,
   d.port_full_name,
   d.port_class,
   d.port_ref_key,
   d.owner_init,
   d.cmnt_num,
   d.num_history_days,
   d.trading_entity_num,
   d.port_locked,
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

create trigger [dbo].[portfolio_instrg]
on [dbo].[portfolio]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'Portfolio',
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
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id and
         it.type != 'E'
 
   /* END_TRANSACTION_TOUCH */

   -- The following code block added specifically for Mercuria
   -- Subu's explanation bout why he needs to add the following query block  (10/22/2013)
   --    We are a 24/7 business.  We create new portfolios and add new trades/costs/inventories.
   --    In the meantime the Middle Officers are trying to close their day and they want to update 
   --    their hierarchy P/L by running Rollup P/L.
   --
   --    This should sum up all the portfolios with existing P/L and add that value to rollup to hierarchy.

   --    BUT what Rollup P/L task does, instead, is that it will also check for portfolios for which P/L 
   --    data does not exists and run Compute P/L on those automatically and then rollup.
   --    That P/L on new portfolios are not meant to be for previous day and PASS does not understand that.
   --    So, when you are creating a REAL portfolio (which where all the real P/L data is) if we create a 
   --    P/L record of ZERO – the system assumes that PASS was run for that portfolio and P/L is Zero and 
   --    rolls that up to the hierarchy instead of recalculating and skewing up P/L.
   --
   --    This is something I already explained to Davinder and everybody and it seems like a huge architectural 
   --    PASS change. So here is a fix that works.
 
   if (select attribute_value from dbo.constants where attribute_name = 'AmphoraClientID') = 'MERCURIA'
   begin   
      declare @asof_date   datetime
	  
	    if exists (select 1 from inserted i where port_type = 'R')
	    begin
		     select @asof_date = max(pl_asof_date) 
		     from dbo.portfolio_profit_loss with (nolock)
		     where port_num in (17, 18, 52421, 5587, 103111, 102836, 318076, 13121, 144507, 47048, 93612)   
		     group by port_num        

		     insert into dbo.portfolio_profit_loss 
		         (port_num,
				      pl_asof_date,
				      pl_calc_date,
				      pl_curr_code,
				      open_phys_pl,
				      open_hedge_pl,
				      closed_phys_pl,
				      closed_hedge_pl,
				      other_pl,
				      liq_open_phys_pl,
				      liq_open_hedge_pl,
				      liq_closed_phys_pl,
			    	  liq_closed_hedge_pl,
				      trans_id,
				      pass_run_detail_id,
				      is_official_run_ind,
				      total_pl_no_sec_cost)
		     select	i.port_num,
				        @asof_date,
				        @asof_date,
				        i.desired_pl_curr_code,
				        0,
				        0,
				        0,
				        0,
				        NULL,
				        NULL,
				        NULL,
				        0,
				        0,
				        1,
				        1,
				        'N',
				        0
		     from inserted i	
		     where i.port_type = 'R'				
	    end		
   end		

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_updtrg]
on [dbo].[portfolio]
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
   raiserror ('(portfolio) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(portfolio) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.port_num = d.port_num )
begin
   raiserror ('(portfolio) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

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
      raiserror ('(portfolio) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'Portfolio',
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
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
  
/* END_TRANSACTION_TOUCH */


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_portfolio
      (port_num,
       port_type,
       desired_pl_curr_code,
       port_short_name,
       port_full_name,
       port_class,
       port_ref_key,
       owner_init,
       cmnt_num,
       num_history_days,
       trading_entity_num,
       port_locked,
       trans_id,
       resp_trans_id)
   select
      d.port_num,
      d.port_type,
      d.desired_pl_curr_code,
      d.port_short_name,
      d.port_full_name,
      d.port_class,
      d.port_ref_key,
      d.owner_init,
      d.cmnt_num,
      d.num_history_days,
      d.trading_entity_num,
      d.port_locked,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.port_num = i.port_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[portfolio] ADD CONSTRAINT [portfolio_pk] PRIMARY KEY CLUSTERED  ([port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_idx3] ON [dbo].[portfolio] ([port_num]) INCLUDE ([desired_pl_curr_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_POSGRID_idx1] ON [dbo].[portfolio] ([port_num]) INCLUDE ([trading_entity_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_idx1] ON [dbo].[portfolio] ([port_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_idx2] ON [dbo].[portfolio] ([trading_entity_num]) INCLUDE ([port_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[portfolio] ADD CONSTRAINT [portfolio_fk1] FOREIGN KEY ([trading_entity_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[portfolio] ADD CONSTRAINT [portfolio_fk3] FOREIGN KEY ([desired_pl_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[portfolio] ADD CONSTRAINT [portfolio_fk4] FOREIGN KEY ([owner_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[portfolio] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio] TO [next_usr]
GO
