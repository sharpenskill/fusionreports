-- AR Invoice Query
SELECT   RCTA.customer_trx_id
       , RCTA.trx_number
	   , RCTA.trx_class
	   , RCTA.trx_date
	   , RCTA.invoice_currency_code
	   , (SELECT name 
	        FROM ra_terms_vl RTV 
		   WHERE RTV.term_id = RCTA.term_id 
		     AND rownum=1) PAYMENT_TERM
	   , RCTLA.customer_trx_line_id
	   , RCTLA.line_number
	   , RCTLA.line_type
	   , RCTLA.extended_amount  LINE_AMOUNT
	   , RCTLA_TAX.line_type    TAX_TYPE
	   , RCTLA_TAX.extended_amount  TAX_AMOUNT
  FROM   ra_customer_trx_all RCTA
       , ra_customer_trx_lines_all RCTLA
	   , ra_customer_trx_lines_all RCTLA_TAX
 WHERE   RCTA.customer_trx_id = RCTLA.customer_trx_id
   AND   RCTLA.customer_trx_line_id = RCTLA_TAX.link_to_cust_trx_line_id
   AND   RCTLA.line_type = 'LINE'
 ORDER BY RCTA.customer_trx_id, RCTLA.customer_trx_line_id