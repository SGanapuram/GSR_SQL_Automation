SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_purge_bulk_search_tables_data]  
    @priortomins        int = 60  
as  
set nocount on  
  
declare @rows_affected int  
  /***************************(trade_item_bulk_search)*******************************/
if exists ( select 1 from dbo.trade_item_bulk_search where datediff(mi,search_time,getdate()) > @priortomins )  
begin     
   select @rows_affected = 0       
   begin tran  
     begin try     
    delete dbo.trade_item_bulk_search  
    where datediff(mi,search_time,getdate()) > @priortomins  
    select @rows_affected = @@rowcount  
     end try  
     begin catch  
           if @@trancount > 0  
        rollback tran  
           print '=> Failed to delete records from trade_item_bulk_search table '  
    print ERROR_MESSAGE()  
     end catch  
     commit tran  
     if @rows_affected > 0  
          print '=> ' + convert(varchar(10),@rows_affected) + ' Records deleted from trade_item_bulk_search table '  
end  
else  
     print '=> No rows found to be deleted from trade_item_bulk_search table'  
 /***************************(shipment_bulk_search)*******************************/  
if exists ( select 1 from dbo.shipment_bulk_search where datediff(mi,search_time,getdate()) > @priortomins )  
begin     
   select @rows_affected = 0       
   begin tran  
     begin try     
    delete dbo.shipment_bulk_search  
    where datediff(mi,search_time,getdate()) > @priortomins  
    select @rows_affected = @@rowcount  
     end try  
     begin catch  
           if @@trancount > 0  
        rollback tran  
           print '=> Failed to delete records from shipment_bulk_search table '  
    print ERROR_MESSAGE()  
     end catch  
     commit tran  
     if @rows_affected > 0  
          print '=> ' + convert(varchar(10),@rows_affected) + ' Records deleted from shipment_bulk_search table '  
end  
else  
     print '=> No rows found to be deleted from shipment_bulk_search table'  
  /***************************(parcel_bulk_search)*******************************/  
if exists ( select 1 from dbo.parcel_bulk_search where datediff(mi,search_time,getdate()) > @priortomins )  
begin     
   select @rows_affected = 0       
   begin tran  
     begin try     
    delete dbo.parcel_bulk_search  
    where datediff(mi,search_time,getdate()) > @priortomins  
    select @rows_affected = @@rowcount  
     end try  
     begin catch  
           if @@trancount > 0  
        rollback tran  
           print '=> Failed to delete records from parcel_bulk_search table '  
    print ERROR_MESSAGE()  
     end catch  
     commit tran  
     if @rows_affected > 0  
          print '=> ' + convert(varchar(10),@rows_affected) + ' Records deleted from parcel_bulk_search table '  
end  
else  
     print '=> No rows found to be deleted from parcel_bulk_search table'  
  /***************************(inventory_bulk_search)*******************************/    
if exists ( select 1 from dbo.inventory_bulk_search where datediff(mi,search_time,getdate()) > @priortomins )  
begin     
   select @rows_affected = 0       
   begin tran  
     begin try     
    delete dbo.inventory_bulk_search  
    where datediff(mi,search_time,getdate()) > @priortomins  
    select @rows_affected = @@rowcount  
     end try  
     begin catch  
           if @@trancount > 0  
        rollback tran  
           print '=> Failed to delete records from parcel_bulk_search table '  
    print ERROR_MESSAGE()  
     end catch  
     commit tran  
     if @rows_affected > 0  
          print '=> ' + convert(varchar(10),@rows_affected) + ' Records deleted from inventory_bulk_search table '  
end  
else  
     print '=> No rows found to be deleted from inventory_bulk_search table'  
GO
GRANT EXECUTE ON  [dbo].[usp_purge_bulk_search_tables_data] TO [next_usr]
GO
