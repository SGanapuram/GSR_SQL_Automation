CREATE TABLE [dbo].[aud_ai_est_act_inv_pricing]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [int] NOT NULL,
[ai_est_actual_num] [int] NOT NULL,
[insert_val_amt] [numeric] (20, 8) NULL,
[insert_val_override_transid] [int] NULL,
[mac_actual_value] [numeric] (20, 8) NULL,
[mac_r_actual_value] [numeric] (20, 8) NULL,
[mac_unr_actual_value] [numeric] (20, 8) NULL,
[fifo_actual_value] [numeric] (20, 8) NULL,
[fifo_r_actual_value] [numeric] (20, 8) NULL,
[fifo_unr_actual_value] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ai_est_act_inv_pricing] ON [dbo].[aud_ai_est_act_inv_pricing] ([alloc_num], [alloc_item_num], [ai_est_actual_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ai_est_act_inv_pricing_idx1] ON [dbo].[aud_ai_est_act_inv_pricing] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ai_est_act_inv_pricing] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_act_inv_pricing] TO [next_usr]
GO
