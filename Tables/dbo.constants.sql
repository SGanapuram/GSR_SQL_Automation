CREATE TABLE [dbo].[constants]
(
[attribute_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[attribute_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[client_edit_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_constants_client_edit_ind] DEFAULT ('N'),
[attribute_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_constants_attribute_status] DEFAULT ('A'),
[attribute_note] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_constants_attribute_note] DEFAULT ('Not Available')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[constants_updtrg]
on [dbo].[constants]
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
ALTER TABLE [dbo].[constants] ADD CONSTRAINT [chk_constants_attribute_status] CHECK (([attribute_status]='I' OR [attribute_status]='A'))
GO
ALTER TABLE [dbo].[constants] ADD CONSTRAINT [chk_constants_client_edit_ind] CHECK (([client_edit_ind]='N' OR [client_edit_ind]='Y'))
GO
ALTER TABLE [dbo].[constants] ADD CONSTRAINT [constants_pk] PRIMARY KEY CLUSTERED  ([attribute_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[constants] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[constants] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[constants] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[constants] TO [next_usr]
GO
