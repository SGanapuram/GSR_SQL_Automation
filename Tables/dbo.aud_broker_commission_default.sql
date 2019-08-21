CREATE TABLE [dbo].[aud_broker_commission_default]
(
[brkr_comm_dflt_num] [int] NOT NULL,
[brkr_num] [int] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code_key] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_comm_amt] [float] NOT NULL,
[brkr_comm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[brkr_comm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_cont_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_broker_commission_default] ON [dbo].[aud_broker_commission_default] ([brkr_comm_dflt_num], [brkr_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_broker_commission_de_idx1] ON [dbo].[aud_broker_commission_default] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_broker_commission_default] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_broker_commission_default] TO [next_usr]
GO
