-- SO Header, Line, Fulfillment
SELECT   DHA.header_id       SO_HEADER_ID
	   , DHA.order_number
	   , (SELECT meaning 
	        FROM FND_LOOKUP_VALUES 
		   WHERE lookup_type = 'ORA_DOO_ORDER_TYPES' 
		     AND lookup_code = DHA.ORDER_TYPE_CODE
             AND language = 'US') ORDER_TYPE
	   , DHA.status_code  SO_HDR_STATUS_CODE
	   , DHA.ordered_date ORDER_DATE
       , DHA.transactional_currency_code CURR_CODE
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
  FROM   doo_headers_all DHA
       , doo_lines_all DLA
       , doo_fulfill_lines_all DFLA
       , egp_system_items ESI
 WHERE   DHA.header_id = DLA.header_id
   AND   DLA.line_id = DFLA.line_id
   AND   DLA.inventory_organization_id = esi.organization_id
   and   DLA.inventory_item_id = esi.inventory_item_id
   AND   DHA.status_code = 'OPEN'
   AND   DHA.order_type_code not in ('Sales_Return')
   AND   DHA.change_version_number = (SELECT MAX(DHA1.change_version_number)
                                        FROM doo_headers_all DHA1
                                       WHERE DHA1.header_id = DHA.header_id)
 ORDER BY DHA.header_id,DLA.line_id,DFLA.fulfill_line_id