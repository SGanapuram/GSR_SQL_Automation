CREATE TABLE [dbo].[aud_inv_build_draw_spec]
(
[inv_num] [int] NOT NULL,
[inv_b_d_num] [int] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_actual_value] [float] NULL,
[spec_actual_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_build_draw_spec] ON [dbo].[aud_inv_build_draw_spec] ([inv_num], [inv_b_d_num], [spec_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_build_draw_spec_idx1] ON [dbo].[aud_inv_build_draw_spec] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_inv_build_draw_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inv_build_draw_spec] TO [next_usr]
GO
