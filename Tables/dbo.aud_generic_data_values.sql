CREATE TABLE [dbo].[aud_generic_data_values]
(
[gdv_num] [int] NOT NULL,
[gdd_num] [int] NOT NULL,
[int_value] [int] NULL,
[double_value] [float] NULL,
[datetime_value] [datetime] NULL,
[string_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_generic_data_values] ON [dbo].[aud_generic_data_values] ([gdv_num], [gdd_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_generic_data_values_idx1] ON [dbo].[aud_generic_data_values] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_generic_data_values] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_generic_data_values] TO [next_usr]
GO
