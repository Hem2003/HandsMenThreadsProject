@isTest
public class TriggerTestClass {
    
    @TestSetup
    static void setupTestData() {
        // Create test product
        HandsMen_Product__c testProduct = new HandsMen_Product__c(
            Name = 'Test Product',
            Price__c = 100.00
        );
        insert testProduct;
        
        // Create test inventory
        Inventory__c testInventory = new Inventory__c(
            HandsMen_Product__c = testProduct.Id,
            Stock_Quantity__c = 50
        );
        insert testInventory;
    }
    
    @isTest
    static void testOrderTotalTrigger() {
        // Get test product
        HandsMen_Product__c testProduct = [SELECT Id, Price__c FROM HandsMen_Product__c LIMIT 1];
        
        Test.startTest();
        
        // Test order total calculation on insert
        HandsMen_Order__c testOrder = new HandsMen_Order__c(
            HandsMen_Product__c = testProduct.Id,
            Quantity__c = 3,
            Status__c = 'Pending'
        );
        
        insert testOrder;
        
        Test.stopTest();
        
        // Verify total amount was calculated
        HandsMen_Order__c insertedOrder = [SELECT Id, Total_Amount__c FROM HandsMen_Order__c WHERE Id = :testOrder.Id];
        System.assertEquals(300.00, insertedOrder.Total_Amount__c, 'Order total should be calculated correctly');
    }
    
    @isTest
    static void testStockDeductionTrigger() {
        // Get test data
        HandsMen_Product__c testProduct = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
        Inventory__c testInventory = [SELECT Id, Stock_Quantity__c FROM Inventory__c WHERE HandsMen_Product__c = :testProduct.Id];
        
        // Create order with pending status (should not affect stock)
        HandsMen_Order__c testOrder = new HandsMen_Order__c(
            HandsMen_Product__c = testProduct.Id,
            Quantity__c = 5,
            Status__c = 'Pending'
        );
        
        Test.startTest();
        
        insert testOrder;
        
        // Verify stock hasn't changed yet
        Inventory__c inventoryAfterInsert = [SELECT Id, Stock_Quantity__c FROM Inventory__c WHERE Id = :testInventory.Id];
        System.assertEquals(50, inventoryAfterInsert.Stock_Quantity__c, 'Stock should not change for pending orders');
        
        // Update order to confirmed status (should reduce stock)
        testOrder.Status__c = 'Confirmed';
        update testOrder;
        
        Test.stopTest();
        
        // Verify stock was reduced
        Inventory__c inventoryAfterUpdate = [SELECT Id, Stock_Quantity__c FROM Inventory__c WHERE Id = :testInventory.Id];
        System.assertEquals(45, inventoryAfterUpdate.Stock_Quantity__c, 'Stock should be reduced by order quantity');
    }
    
    @isTest
    static void testBulkOperations() {
        // Get test product
        HandsMen_Product__c testProduct = [SELECT Id, Price__c FROM HandsMen_Product__c LIMIT 1];
        
        // Create multiple orders
        List<HandsMen_Order__c> testOrders = new List<HandsMen_Order__c>();
        for (Integer i = 0; i < 10; i++) {
            testOrders.add(new HandsMen_Order__c(
                HandsMen_Product__c = testProduct.Id,
                Quantity__c = 1,
                Status__c = 'Confirmed'
            ));
        }
        
        Test.startTest();
        
        insert testOrders;
        
        Test.stopTest();
        
        // Verify all orders have correct totals
        List<HandsMen_Order__c> insertedOrders = [SELECT Id, Total_Amount__c FROM HandsMen_Order__c WHERE Id IN :testOrders];
        for (HandsMen_Order__c order : insertedOrders) {
            System.assertEquals(100.00, order.Total_Amount__c, 'Each order should have correct total');
        }
        
        // Verify stock was reduced by total quantity
        Inventory__c finalInventory = [SELECT Id, Stock_Quantity__c FROM Inventory__c WHERE HandsMen_Product__c = :testProduct.Id];
        System.assertEquals(40, finalInventory.Stock_Quantity__c, 'Stock should be reduced by total order quantity');
    }
} 