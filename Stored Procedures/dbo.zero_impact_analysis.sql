SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[zero_impact_analysis]  
  @resp_trans_id_NEW     int,      
  @resp_trans_id_OLD     int,      
  @mode                  int = null,      
  @portnum               int = null,      
  @digits_for_scale4     tinyint = 4,      
  @digits_for_scale7     tinyint = 7        
as      
set nocount on      
declare @smsg     varchar(255)      
      
   if @mode is not null      
   begin      
       if @mode > 18 or @mode < 1      
       begin      
          print '=> The value for the argument ''mode'' must be a NULL, or a value between 1 and 18!'      
          return      
       end      
   end      
         
   print ' '      
   print '******************************************************************'      
   print ' ZERO IMPACT ANALYSIS REPORT'      
   select @smsg = '     Reporting Date       : ' + cast(getdate() as varchar)      
   print @smsg      
   select @smsg = '     resp_trans_id (NEW) : ' + cast(@resp_trans_id_NEW as varchar)      
   print @smsg      
   select @smsg = '     resp_trans_id (OLD)   : ' + cast(@resp_trans_id_OLD as varchar)      
   print @smsg      
   select @smsg = '     portnum              : ' + cast(@portnum as varchar)      
   print @smsg         
   print '******************************************************************'      
   print ' '      
         
   if @mode is null OR @mode = 1      
      exec dbo.usp_compare_pl_history_nonExpFutSumSwap  @resp_trans_id_NEW,       
							@resp_trans_id_OLD,       
							@portnum,       
							@digits_for_scale4,       
							@digits_for_scale7      
         
   if @mode is null OR @mode = 2      
      exec dbo.usp_compare_tid_mtm @resp_trans_id_NEW,       
                                   @resp_trans_id_OLD,       
                                   @portnum,       
                                   @digits_for_scale4,       
                                   @digits_for_scale7      
         
   if @mode is null OR @mode = 3      
      exec dbo.usp_compare_portfolio_pl @resp_trans_id_NEW,       
                                        @resp_trans_id_OLD,       
                                        @portnum,       
                                        @digits_for_scale4,       
                                        @digits_for_scale7      
         
   if @mode is null OR @mode = 4      
      exec dbo.usp_compare_pos_mtm @resp_trans_id_NEW,       
                                   @resp_trans_id_OLD,       
                                   @portnum,       
                                   @digits_for_scale4,       
                                   @digits_for_scale7      
        
   if @mode is null OR @mode = 5      
      exec dbo.usp_compare_tid_mtm_vol @resp_trans_id_NEW,       
                                       @resp_trans_id_OLD,       
                                       @portnum,       
                                       @digits_for_scale4,       
                                       @digits_for_scale7      
      
   if @mode is null OR @mode = 6      
      exec dbo.usp_compare_ti_mtm @resp_trans_id_NEW,       
                                  @resp_trans_id_OLD,       
                                  @portnum,       
                                  @digits_for_scale4,       
                                  @digits_for_scale7      
      
   if @mode is null OR @mode = 7      
      exec dbo.usp_compare_tid_pl @resp_trans_id_NEW,       
                                  @resp_trans_id_OLD,       
                                  @portnum,       
                                  @digits_for_scale4,       
                                  @digits_for_scale7      
      
   if @mode is null OR @mode = 8      
      exec dbo.usp_compare_trade_item_pl @resp_trans_id_NEW,       
                                         @resp_trans_id_OLD,       
                                         @portnum,       
                       @digits_for_scale4,       
                                         @digits_for_scale7      
    
   if @mode is null OR @mode = 9    
      exec dbo.usp_compare_cost_ext_info @resp_trans_id_NEW,    
                                         @resp_trans_id_OLD,    
                                         @portnum,    
                                         @digits_for_scale4,    
                                         @digits_for_scale7    
    
   if @mode is null OR @mode = 10    
      exec dbo.usp_compare_fx_exposure   @resp_trans_id_NEW,    
                                         @resp_trans_id_OLD,    
                                         @portnum,    
                                         @digits_for_scale4,    
                                         @digits_for_scale7    
    
   if @mode is null OR @mode = 11    
      exec dbo.usp_compare_fx_exposure_dist @resp_trans_id_NEW,    
					    @resp_trans_id_OLD,    
                                            @portnum,    
                                            @digits_for_scale4,    
                                            @digits_for_scale7    
    
   if @mode is null OR @mode = 12      
      exec dbo.usp_compare_pl_history_expiredFutures @resp_trans_id_NEW,       
						     @resp_trans_id_OLD,       
						     @portnum,       
                                                     @digits_for_scale4,       
                                                     @digits_for_scale7  
   if @mode is null OR @mode = 13      
      exec dbo.usp_compare_pl_history_summarySwaps @resp_trans_id_NEW,       
                                                   @resp_trans_id_OLD,       
                                                   @portnum,       
                                                   @digits_for_scale4,       
                                                   @digits_for_scale7  									  
   if @mode is null OR @mode = 14      
      exec dbo.usp_compare_inventory_history @resp_trans_id_NEW,       
                                                   @resp_trans_id_OLD,       
                                                   @portnum,       
                                                   @digits_for_scale4,       
                                                   @digits_for_scale7  
												   
   if @mode is null OR @mode = 15    
      exec dbo.usp_compare_position_history @resp_trans_id_NEW,       
                                                   @resp_trans_id_OLD,       
                                                   @portnum,       
                                                   @digits_for_scale4,       
                                                   @digits_for_scale7  
   if @mode is null OR @mode = 16   
      exec dbo.usp_compare_portfolio_eod @resp_trans_id_NEW,       
                                                   @resp_trans_id_OLD,       
                                                   @portnum,       
                                                   @digits_for_scale4,       
                                                   @digits_for_scale7 
   if @mode is null OR @mode = 17   
      exec dbo.usp_compare_position_group_eod @resp_trans_id_NEW,       
                                                   @resp_trans_id_OLD,       
                                                   @portnum,       
                                                   @digits_for_scale4,       
                                                   @digits_for_scale7 
   if @mode is null OR @mode = 18   
      exec dbo.usp_compare_portfolio_group_eod @resp_trans_id_NEW,       
                                                   @resp_trans_id_OLD,       
                                                   @portnum,       
                                                   @digits_for_scale4,       
                                                   @digits_for_scale7 
SET QUOTED_IDENTIFIER OFF
GO
GRANT EXECUTE ON  [dbo].[zero_impact_analysis] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'zero_impact_analysis', NULL, NULL
GO
