-- SO Header
SELECT   DHA.header_id       SO_HEADER_ID
	   , DHA.order_number
	   , DHA.ORDER_TYPE_CODE ORDER_TYPE
	   , DHA.status_code  SO_HDR_STATUS_CODE
	   , DHA.ordered_date ORDER_DATE
       , DHA.transactional_currency_code CURR_CODE
  FROM   doo_headers_all DHA
 WHERE   DHA.status_code = 'OPEN'
   AND   DHA.order_type_code not in ('Sales_Return')
   AND   DHA.change_version_number = (SELECT MAX(DHA1.change_version_number)
                                        FROM doo_headers_all DHA1
                                       WHERE DHA1.header_id = DHA.header_id)

-- SO Line, Fulfillment details
SELECT   DLA.header_id
       , DLA.line_number
       , ESI.item_number ITEM_CODE
       , ESI.description ITEM_DESC
       , DLA.ordered_uom
       , DFLA.ordered_qty
       , DLA.unit_list_price
       , DLA.unit_selling_price
       , (DFLA.ORDERED_QTY * DLA.unit_selling_price) LINE_PRICE
	   , DFLA.fulfill_line_number
	   , DFLA.status_code FULFILL_STATUS_CODE
	   , DFLA.fulfilled_qty
  FROM   doo_lines_all DLA
       , doo_fulfill_lines_all DFLA
       , egp_system_items ESI
 WHERE   DLA.line_id = DFLA.line_id
   AND   DLA.inventory_organization_id = esi.organization_id
   and   DLA.inventory_item_id = esi.inventory_item_id
 ORDER BY DLA.line_id,DFLA.fulfill_line_id
 
-- Test Data
-- (9315),(60007),4153, 6202, 6203, 6204 order number
