CREATE TABLE [dbo].[aud_portfolio_tag_insp_attr]
(
[tag_name] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ref_insp_attr_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ref_insp_attr_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ref_insp_attr_value] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_tag_insp_attr] ON [dbo].[aud_portfolio_tag_insp_attr] ([tag_name], [ref_insp_attr_name], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_port_tag_insp_attr_idx1] ON [dbo].[aud_portfolio_tag_insp_attr] ([trans_id]) ON [PRIMARY]
GO
