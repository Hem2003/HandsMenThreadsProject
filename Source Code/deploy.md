# Salesforce Trigger Deployment Instructions

## Overview
This package contains two Apex triggers for the HandsMen Threads Salesforce application:

1. **StockDeductionTrigger** - Automatically reduces inventory stock when orders are confirmed
2. **OrderTotalTrigger** - Calculates order totals based on product price and quantity

## Prerequisites
- Salesforce org with API access
- Custom objects: `HandsMen_Order__c`, `HandsMen_Product__c`, `Inventory__c`
- Custom fields: `Status__c`, `Quantity__c`, `Price__c`, `Total_Amount__c`, `Stock_Quantity__c`

## Deployment Methods

### Method 1: Salesforce CLI (Recommended)
```bash
# Install Salesforce CLI
npm install -g @salesforce/cli

# Authenticate to your org
sf org login web

# Deploy the triggers
sf project deploy start --source-dir Source\ Code

# Run tests
sf apex run test --class-names TriggerTestClass
```

### Method 2: Salesforce Developer Console
1. Open Salesforce Developer Console
2. Go to File → Open → From File System
3. Upload each trigger file (.cls)
4. Save and deploy

### Method 3: Change Set
1. Create a new Change Set in your org
2. Add the trigger components
3. Upload and deploy to target org

## Testing the Triggers

### Manual Testing
1. Create a test product with a price
2. Create test inventory with stock quantity
3. Create an order with quantity
4. Verify total amount is calculated
5. Update order status to 'Confirmed'
6. Verify inventory stock is reduced

### Automated Testing
Run the included test class `TriggerTestClass` which covers:
- Order total calculation
- Stock deduction on order confirmation
- Bulk operations
- Edge cases

## Trigger Behavior

### OrderTotalTrigger (Before Insert/Update)
- Fires before order insert/update
- Calculates `Total_Amount__c = Quantity__c × Price__c`
- Updates the order record before saving

### StockDeductionTrigger (After Insert/Update)
- Fires after order insert/update
- Only affects orders with `Status__c = 'Confirmed'`
- Reduces `Stock_Quantity__c` in related inventory records
- Handles bulk operations efficiently

## Troubleshooting
- Ensure all custom objects and fields exist
- Check field permissions and accessibility
- Verify trigger execution order if conflicts occur
- Monitor debug logs for detailed execution information

## Support
For issues or questions, check the Salesforce debug logs and ensure all prerequisites are met. 