-- Query for Open Standard PO with Suppliers
SELECT   POH.po_header_id     PO_HDR_ID
       , POH.segment1         PO_NUMBER
	   , POH.document_status  PO_STATUS
	   , POH.type_lookup_code PO_TYPE
	   , PS.segment1          SUPPLIER_NUMBER
	   , HP.party_name        SUPPLIER_NAME
  FROM   po_headers_all POH
       , poz_suppliers  PS
	   , hz_parties     HP
 WHERE   POH.vendor_id = PS.vendor_id
   AND   PS.party_id   = HP.party_id
   AND   POH.type_lookup_code = 'STANDARD'
   AND   POH.document_status = 'OPEN'
   AND   PS.segment1 = 1255
   
-- Query to find PO Lines against a PO Header
SELECT   POL.po_header_id     PO_HEADER_ID
       , POL.po_line_id       PO_LINE_ID
	   , POL.line_num         PO_LINE_NUM
	   , POL.line_status      PO_LINE_STATUS
	   , POL.item_description PO_ITEM
	   , POL.uom_code         ITEM_UOM
	   , POL.unit_price       ITEM_UNIT_PRICE
	   , POL.quantity         ITEM_QUANTITY
  FROM   po_lines_all POL
 WHERE   POL.po_header_id = :po_hdr_id