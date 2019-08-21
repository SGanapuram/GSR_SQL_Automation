CREATE TABLE [dbo].[autopool_criteria]
(
[autopool_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pooling_port_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[book_comp_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[autopool_criteria_updtrg]
on [dbo].[autopool_criteria]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

GO
ALTER TABLE [dbo].[autopool_criteria] ADD CONSTRAINT [autopool_criteria_pk] PRIMARY KEY CLUSTERED  ([autopool_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[autopool_criteria] ADD CONSTRAINT [autopool_criteria_fk1] FOREIGN KEY ([mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[autopool_criteria] ADD CONSTRAINT [autopool_criteria_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[autopool_criteria] ADD CONSTRAINT [autopool_criteria_fk4] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[autopool_criteria] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[autopool_criteria] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[autopool_criteria] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[autopool_criteria] TO [next_usr]
GO
