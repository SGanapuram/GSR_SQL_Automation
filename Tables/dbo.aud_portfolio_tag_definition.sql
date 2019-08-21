CREATE TABLE [dbo].[aud_portfolio_tag_definition]
(
[tag_name] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tag_desc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ref_insp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_insp_formatter_key] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[value_entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[value_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[value_attribute] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tag_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tag_required_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[foreign_key_table] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[foreign_key_field] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_tag_definition] ON [dbo].[aud_portfolio_tag_definition] ([tag_name], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_tag_def_idx1] ON [dbo].[aud_portfolio_tag_definition] ([trans_id]) ON [PRIMARY]
GO
