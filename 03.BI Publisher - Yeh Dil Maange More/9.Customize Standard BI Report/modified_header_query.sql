SELECT 
trx.customer_trx_id || '_' || ps.payment_schedule_id SPLIT_KEY_ATTR ,     
trx.customer_trx_id     customer_trx_id,
( select 'Y' from dual 
  where exists (Select 'X' from ra_customer_trx_lines_all lines
		 Where lines.billing_period_start_date is not null 
		 and lines.customer_trx_id = trx.customer_trx_id )) Billing_Period_Exist ,
(SELECT Count(DISTINCT(sales_order)) 
 FROM ra_customer_trx_lines_all lines  
 WHERE lines.customer_trx_id= trx.customer_trx_id ) total_Sales_Order,
(SELECT  lines.sales_order
FROM ra_customer_trx_lines_all lines
WHERE  lines.customer_trx_id  = trx.customer_trx_id
AND lines.sales_order IS NOT NULL 
AND rownum =1
) Header_Sales_Order ,
nvl(ps.terms_sequence_number,1)  term_sequence_number,
trx.trx_number      trx_number,
to_char(trx.trx_date,'YYYY-MM-DD')        trx_date,
trx.invoice_currency_code  invoice_currency_code,  
t.name                  term_name,
t.description			term_desc,
trx.waybill_number                      waybill_number,
        trx.ship_via                            ship_via,       
        to_char(trx.ship_date_actual,'YYYY-MM-DD')                    ship_date_actual,
        trx.purchase_order                      purchase_order_number,
        to_char(trx.purchase_order_date,'YYYY-MM-DD')                  purchase_order_date,
        to_char(ps.due_date,'YYYY-MM-DD')                             term_due_date_from_ps,
        b_bill.account_number                   bill_to_customer_number,
        b_bill_party.party_name   bill_to_customer_name,
         a_bill_loc.address1            bill_to_address1,
        a_bill_loc.address2            bill_to_address2,
        a_bill_loc.address3            bill_to_address3,
        a_bill_loc.address4            bill_to_address4,
        a_bill_loc.city                            bill_to_city,
        a_bill_loc.state            bill_to_state,
        a_bill_loc.province            bill_to_province,
        a_bill_loc.postal_code                     bill_to_postal_code,
        a_bill_loc.country                         bill_to_country,
    b_ship_party.party_name   ship_to_customer_name,        
    u_ship.party_site_id                   ship_to_site_number,
    a_ship_loc.address1            ship_to_address1,        
    a_ship_loc.address2            ship_to_address2,     
    a_ship_loc.address3            ship_to_address3,        
    a_ship_loc.address4            ship_to_address4,        
    a_ship_loc.city             ship_to_city,        
    a_ship_loc.postal_code             ship_to_postal_code,        
    a_ship_loc.country            ship_to_country,
      a_ship_loc.state            ship_to_state,
       a_ship_loc.province            ship_to_province,
     a_remit_loc.address1                       remit_to_address1,
        a_remit_loc.address2                       remit_to_address2,
        a_remit_loc.address3                       remit_to_address3,
        a_remit_loc.address4                       remit_to_address4,
        a_remit_loc.city                           remit_to_city,
        a_remit_loc.state                          remit_to_state,
        a_remit_loc.postal_code                    remit_to_postal_code,
        a_remit_loc.country                        remit_to_country ,
        u_bill.location bill_to_location,
        (SELECT  party.party_name 
         FROM   JTF_RS_SALESREPS  sales,
         Hz_parties     party
         WHERE sales.RESOURCE_SALESREP_ID    =  trx.PRIMARY_RESOURCE_SALESREP_ID
         AND sales.RESOURCE_ID = party.party_id) primary_salesrep_name,   
		 
(SELECT max(cp.URL) 
FROM hz_contact_points       cp, 
     hz_cust_account_roles   acct_role 
  WHERE acct_role.cust_account_role_id = trx.bill_to_contact_id 
    and acct_role.relationship_id = cp.relationship_id 
    and cp.owner_table_name = 'HZ_PARTIES' 
    and cp.contact_point_type='WEB'
    and cp.status ='A'
    and cp.primary_flag = 'Y') contact_web_url,  --Bug: 18705899

(SELECT max(cp.raw_phone_number) 
FROM hz_contact_points       cp, 
     hz_cust_account_roles   acct_role 
  WHERE acct_role.cust_account_role_id = trx.bill_to_contact_id 
    and acct_role.relationship_id = cp.relationship_id 
    and cp.owner_table_name = 'HZ_PARTIES' 
    and cp.contact_point_type='PHONE' 
    and cp.phone_line_type='MOBILE'
    and cp.status ='A'
    and cp.primary_flag = 'Y') contact_mobile_ph_number,  --Bug: 18705899


 (SELECT max(cp.email_address) 
   FROM hz_contact_points       cp, 
        hz_cust_account_roles   acct_role 
  WHERE acct_role.cust_account_role_id = trx.bill_to_contact_id 
    and acct_role.relationship_id = cp.relationship_id 
    and cp.owner_table_name = 'HZ_PARTIES' 
    and cp.contact_point_type='EMAIL'
    and cp.status ='A'
    and cp.primary_flag = 'Y') contact_email,  --Bug: 18705899

         (SELECT  party.PRIMARY_PHONE_NUMBER 
         FROM   JTF_RS_SALESREPS  sales,
         Hz_parties     party
         WHERE sales.RESOURCE_SALESREP_ID    =  trx.PRIMARY_RESOURCE_SALESREP_ID
         AND sales.RESOURCE_ID = party.party_id) primary_salesrep_phone,        
	(SELECT  party.PRIMARY_PHONE_AREA_CODE 
         FROM   JTF_RS_SALESREPS  sales,
         Hz_parties     party
         WHERE sales.RESOURCE_SALESREP_ID    =  trx.PRIMARY_RESOURCE_SALESREP_ID
         AND sales.RESOURCE_ID = party.party_id) salesrep_phone_areacode,
	(SELECT  party.PRIMARY_PHONE_COUNTRY_CODE 
         FROM   JTF_RS_SALESREPS  sales,
         Hz_parties     party
         WHERE sales.RESOURCE_SALESREP_ID    =  trx.PRIMARY_RESOURCE_SALESREP_ID
         AND sales.RESOURCE_ID = party.party_id) salesrep_phone_countrycode,		 
    TO_CHAR(NVL( DECODE(types.accounting_affect_flag, 'Y', ps.amount_line_items_original, 'N',
  (SELECT SUM(extended_amount)
     FROM ra_customer_trx_lines_all lines
    WHERE lines.customer_trx_id = trx.customer_trx_id
  AND lines.line_type           ='LINE'
  ) ),to_number(0)),fnd_currency.get_format_mask(trx.invoice_currency_code, 40 ) ) line_amount,
  TO_CHAR(NVL( DECODE(types.accounting_affect_flag, 'Y', ps.tax_original, 'N',
  (SELECT SUM(extended_amount)
     FROM ra_customer_trx_lines_all lines
    WHERE lines.customer_trx_id = trx.customer_trx_id
  AND lines.line_type           ='TAX'
  ) ),to_number(0)),fnd_currency.get_format_mask(trx.invoice_currency_code, 40 ) ) tax_amount,
  TO_CHAR(NVL( DECODE(types.accounting_affect_flag, 'Y', ps.freight_original, 'N',
  (SELECT SUM(extended_amount)
     FROM ra_customer_trx_lines_all lines
    WHERE lines.customer_trx_id = trx.customer_trx_id
  AND lines.line_type           ='FREIGHT'
  ) ),to_number(0)),fnd_currency.get_format_mask(trx.invoice_currency_code, 40 ) ) freight_amount,
  TO_CHAR(NVL( DECODE(types.accounting_affect_flag, 'Y', ps.amount_due_original, 'N',
  (SELECT SUM(extended_amount)
     FROM ra_customer_trx_lines_all lines
    WHERE lines.customer_trx_id = trx.customer_trx_id
  ) ) + nvl(ps.amount_adjusted,to_number(0)) ,to_number(0)),fnd_currency.get_format_mask(trx.invoice_currency_code, 40 ) ) total_amount,
  (SELECT NVL(SUM(NVL(adj.receivables_charges_adjusted, 0)), 0)
	FROM   ar_adjustments_all adj
	WHERE  adj.customer_trx_id = trx.customer_trx_id
	  AND  adj.status = 'A'
	  AND  adj.receivables_trx_id <> -15) finance_charges,
AR_BPA_UTILS_PKG.fn_get_contact_name(trx.bill_to_contact_id) customer_contact_name,        
AR_BPA_UTILS_PKG.fn_get_phone(trx.bill_to_contact_id) customer_phone,
AR_BPA_UTILS_PKG.fn_get_fax(trx.bill_to_contact_id) customer_fax,
AR_BPA_UTILS_PKG.fn_get_header_level_so(trx.customer_trx_id) sales_order,
AR_BPA_UTILS_PKG.fn_trx_has_groups(trx.customer_trx_id) trx_has_groups,
AR_BPA_UTILS_PKG.fn_get_billing_line_level(trx.customer_trx_id) billing_line_level,
    HZ_FORMAT_PUB.format_address(a_bill_loc.location_id) formatted_bill_to_address,
    HZ_FORMAT_PUB.format_address(a_ship_loc.location_id) formatted_ship_to_address,
    HZ_FORMAT_PUB.format_address(a_remit_loc.location_id) formatted_remit_to_address,
    HZ_FORMAT_PUB.format_address(a_bill_loc.location_id,null,null,CHR(13)) formatted_bill_to_address1,
    HZ_FORMAT_PUB.format_address(a_ship_loc.location_id,null,null,CHR(13)) formatted_ship_to_address1,
    HZ_FORMAT_PUB.format_address(a_remit_loc.location_id,null,null,CHR(13)) formatted_remit_to_address1,
to_char(trunc(sysdate),'YYYY-MM-DD') current_date,
AR_BPA_UTILS_PKG.fn_get_header_level_co(trx.customer_trx_id) contract_number,
AR_BPA_UTILS_PKG.fn_get_profile_class_name(trx.customer_trx_id) profile_class_name,
trx.interface_header_context,
AR_BPA_UTILS_PKG.fn_get_tax_printing_option(trx.bill_to_site_use_id, trx.bill_to_customer_id) tax_printing_option,
trx.interface_header_attribute1,
trx.interface_header_attribute2,
trx.interface_header_attribute3,
trx.interface_header_attribute4,
trx.interface_header_attribute5,
trx.interface_header_attribute6,
trx.interface_header_attribute7,
trx.interface_header_attribute8,
trx.interface_header_attribute9,
trx.interface_header_attribute10,
trx.interface_header_attribute11,
trx.interface_header_attribute12,
trx.interface_header_attribute13,
trx.interface_header_attribute14,
trx.interface_header_attribute15,
a_ship_ps.PARTY_SITE_NUMBER  ship_to_location,
t_count.number_of_terms                 number_of_terms,
ps.terms_sequence_number        terms_sequence_number,
trx.org_id,
to_char(trunc(trx.creation_date),'YYYY-MM-DD')  creation_date,
trx.internal_notes,
to_char(nvl(ps.amount_due_original,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_due_original,
          to_char(nvl(ps.amount_applied,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_applied,
          nvl(ps.amount_due_remaining,to_number(0)) outstanding_balance,                        
          to_char(nvl(ps.amount_due_remaining,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_due_remaining,
          to_char(nvl(ps.amount_applied,to_number(0)) - nvl(ps.amount_credited,to_number(0)) +
          nvl(ps.discount_taken_earned,to_number(0)) + nvl(ps.discount_taken_unearned,to_number(0)) + 
           nvl(ps.receivables_charges_charged,to_number(0)) ,    
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                                payments_and_credits,
          to_char(- nvl(ps.amount_applied,to_number(0)),    
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                                payments,
          to_char(nvl(ps.amount_credited,to_number(0)),    
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                                credits,
          to_char(nvl(ps.receivables_charges_charged,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_charges,
          to_char(nvl(ps.amount_adjusted,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_adjusted,
        ps.amount_due_original  total_amounts,
        ps.class trx_type,
        t.term_id,
        ps.payment_schedule_id,
        trx.comments,
        to_char(trunc(trx.START_DATE_COMMITMENT),'YYYY-MM-DD') START_DATE_COMMITMENT,
        to_char(trunc(trx.END_DATE_COMMITMENT),'YYYY-MM-DD') END_DATE_COMMITMENT,
        reason_lookup.meaning Credit_memo_reason,
        trx.previous_customer_trx_id,
        decode(trx.trx_class,'CM',
		              (SELECT applied_trx.trx_number FROM   ra_customer_trx_all applied_trx  WHERE  applied_trx.customer_trx_id = trx.previous_customer_trx_id) ,
		              'CB',
		              (select ct.trx_number  from ra_customer_trx_all ct, ar_adjustments_all adj  where adj.chargeback_customer_trx_id  =  trx.customer_trx_id and ct.customer_trx_id = adj.customer_trx_id and trx.trx_class = 'CB'), null)   AS    previous_trx_number,
--FND_ACCESS_CONTROL_UTIL.Get_Org_Name(trx.org_id) org_name,
null org_name,
trx.legal_entity_id,
(select xle.name from  XLE_FIRSTPARTY_INFORMATION_V xle
where xle.legal_entity_id = trx.legal_entity_id) as legal_entity_name,
trx.ct_reference,
trx.cust_trx_type_seq_id,
types.name cust_trx_type_name,
trx.batch_source_seq_id,
batch.name batch_source_name,
trx.attribute1,
trx.attribute2,
trx.attribute3,
trx.attribute4,
trx.attribute5,
trx.attribute6,
trx.attribute7,
trx.attribute8,
trx.attribute9,
trx.attribute10,
trx.attribute11,
trx.attribute12,
trx.attribute13,
trx.attribute14,
trx.attribute15,
trx.SET_OF_BOOKS_ID,
trx.REASON_CODE,
trx.PURCHASE_ORDER_REVISION,
trx.CUSTOMER_REFERENCE,
to_char(trx.CUSTOMER_REFERENCE_DATE,'YYYY-MM-DD') ,
trx.EXCHANGE_RATE_TYPE,
to_char(trx.EXCHANGE_DATE,'YYYY-MM-DD'),
trx.EXCHANGE_RATE,
trx.ATTRIBUTE_CATEGORY,
trx.ORIG_SYSTEM_BATCH_NAME,
trx.FINANCE_CHARGES as Finance_Charge_Indicator,
trx.CREDIT_METHOD_FOR_RULES,
trx.CREDIT_METHOD_FOR_INSTALLMENTS,
trx.FOB_POINT,
trx.DEFAULT_USSGL_TRX_CODE_CONTEXT,
trx.DEFAULT_USSGL_TRANSACTION_CODE,
trx.RECURRED_FROM_TRX_NUMBER,
trx.STATUS_TRX,
trx.DOC_SEQUENCE_VALUE,
trx.GLOBAL_ATTRIBUTE1,
trx.GLOBAL_ATTRIBUTE2,
trx.GLOBAL_ATTRIBUTE3,
trx.GLOBAL_ATTRIBUTE4,
trx.GLOBAL_ATTRIBUTE5,
trx.GLOBAL_ATTRIBUTE6,
trx.GLOBAL_ATTRIBUTE7,
trx.GLOBAL_ATTRIBUTE8,
trx.GLOBAL_ATTRIBUTE9,
trx.GLOBAL_ATTRIBUTE10,
trx.GLOBAL_ATTRIBUTE11,
trx.GLOBAL_ATTRIBUTE12,
trx.GLOBAL_ATTRIBUTE13,
trx.GLOBAL_ATTRIBUTE14,
trx.GLOBAL_ATTRIBUTE15,
trx.GLOBAL_ATTRIBUTE16,
trx.GLOBAL_ATTRIBUTE17,
trx.GLOBAL_ATTRIBUTE18,
trx.GLOBAL_ATTRIBUTE19,
trx.GLOBAL_ATTRIBUTE20,
trx.GLOBAL_ATTRIBUTE_CATEGORY,
trx.EDI_PROCESSED_FLAG,
trx.EDI_PROCESSED_STATUS,
trx.MRC_EXCHANGE_RATE_TYPE,
trx.MRC_EXCHANGE_DATE,
trx.MRC_EXCHANGE_RATE,
trx.PAYMENT_SERVER_ORDER_NUM,
trx.APPROVAL_CODE,
trx.ADDRESS_VERIFICATION_CODE,
ps.NUMBER_OF_DUE_DATES,
ps.STATUS,
to_char(ps.GL_DATE_CLOSED,'YYYY-MM-DD'),
to_char(ps.ACTUAL_DATE_CLOSED,'YYYY-MM-DD'),
ps.AMOUNT_LINE_ITEMS_REMAINING,
ps.AMOUNT_IN_DISPUTE,
ps.AMOUNT_CREDITED,
ps.RECEIVABLES_CHARGES_REMAINING,
ps.FREIGHT_REMAINING,
ps.TAX_REMAINING,
ps.DISCOUNT_TAKEN_EARNED,
ps.DISCOUNT_TAKEN_UNEARNED,
ps.ACCTD_AMOUNT_DUE_REMAINING,
trx.SPECIAL_INSTRUCTIONS,
a_bill_loc.county                         bill_to_county,
a_ship_loc.county                         ship_to_county,
a_remit_loc.county                         remit_to_county,
(SELECT territory_short_name FROM fnd_territories_vl WHERE territory_code=a_bill_loc.country)
AS bill_to_country_name,
(SELECT territory_short_name FROM fnd_territories_vl WHERE territory_code=a_ship_loc.country)
AS ship_to_country_name,
rep_registration_number   cust_tax_regn_no,
(CASE
WHEN exists
(SELECT 1
  FROM
  ra_customer_trx_lines_all lines,
         ZX_RATES_B       rates,
         ZX_REPORTING_TYPES_B  reporting_types,        
         ZX_REPORT_CODES_ASSOC assoc
   WHERE
          customer_trx_id=trx.customer_trx_id
          and lines.vat_tax_id=rates.tax_rate_id                                       
          AND reporting_types.tax_regime_code = rates.tax_regime_code       
          AND  assoc.entity_id   =  rates.tax_rate_id
          AND  assoc.entity_code = 'ZX_RATES'   
          and reporting_types.reporting_type_code = 'REVERSE_CHARGE_VAT'
          and assoc.reporting_type_id = reporting_types.reporting_type_id
 )         
THEN 'Y'
ELSE 'N'
END ) reverse_charge_vat_invoice,
AR_BPA_UTILS_PKG.fn_get_contact_name_party(trx.ship_to_party_contact_id) ship_to_contact_name,        
AR_BPA_UTILS_PKG.fn_get_phone_party(trx.ship_to_party_contact_id) ship_to_phone,
AR_BPA_UTILS_PKG.fn_get_fax_party(trx.ship_to_party_contact_id) ship_to_fax ,
(SELECT  
  to_char(sum( NVL( adj.line_adjusted, 0) + NVL( adj.tax_adjusted, 0)  )
  ,fnd_currency.get_format_mask(trx.invoice_currency_code,40))

        FROM ar_adjustments_all adj
WHERE  PS.PAYMENT_SCHEDULE_ID =ADJ.PAYMENT_SCHEDULE_ID 
AND      adj.status = 'A'
AND     adj.receivables_trx_id  <> -15  ) AS   line_tax_adjustment  ,      
(SELECT  
  to_char(sum( NVL( adj.freight_adjusted, 0) )
  ,fnd_currency.get_format_mask(trx.invoice_currency_code,40))

        FROM ar_adjustments_all adj
WHERE  PS.PAYMENT_SCHEDULE_ID =ADJ.PAYMENT_SCHEDULE_ID 
AND      adj.status = 'A'
AND     adj.receivables_trx_id  <> -15  ) AS   freight_adjustment ,
trx.STRUCTURED_PAYMENT_REFERENCE     

FROM
        ar_invoice_count_terms_v                t_count,
        ar_payment_schedules_all                ps,
        ra_terms_lines                          tl,
        ra_terms                                t,

        ra_cust_trx_types_all                   types,
        ra_batch_sources_all                    batch,
        ra_customer_trx_all                     trx,
        hz_cust_accounts                        b_bill,
        hz_parties                              b_bill_party,
        hz_cust_acct_sites_all                  a_bill,
        hz_party_sites                          a_bill_ps,
        hz_locations                            a_bill_loc,

        hz_parties                              b_ship_party,        

        hz_party_sites                          a_ship_ps,
        hz_locations                            a_ship_loc,

        ar_remit_to_locs_all                    a_remit,
        hz_locations                            a_remit_loc,        
        hz_cust_site_uses_all                   u_bill,
        hz_party_site_uses                      u_ship,
        ar_lookups                              reason_lookup,
        zx_party_tax_profilE                    tax
        &P_DYNAMIC_FROM_CLAUSE        

WHERE   &P_DYNAMIC_WHERE_CLAUSE
        trx.cust_trx_type_seq_id            = types.cust_trx_type_seq_id

        AND trx.batch_source_seq_id                    = batch.batch_source_seq_id

        AND trx.term_id                         = tl.term_id(+)
        AND trx.term_id                         = t.term_id(+)
        AND trx.customer_trx_id =  PS.CUSTOMER_TRX_ID 
       
        /*AND NVL(ps.terms_sequence_number,
            NVL(tl.sequence_num,0))             = NVL(tl.sequence_num,
                                                  NVL(ps.terms_sequence_number,0))*/
           AND reason_lookup.lookup_type(+) = 'CREDIT_MEMO_REASON'
           AND reason_lookup.lookup_code(+) = trx.reason_code             
        AND nvl(trx.term_id, -1)                = t_count.term_id
        AND trx.bill_to_customer_id             = b_bill.cust_account_id
        ANd b_bill.party_id                     = b_bill_party.party_id
        AND trx.ship_to_party_id             = b_ship_party.party_id(+) 

        AND trx.bill_to_site_use_id             = u_bill.site_use_id

        AND trx.ship_to_party_site_use_id       = u_ship.party_site_use_id(+)
      
        AND u_bill.cust_acct_site_id            = a_bill.cust_acct_site_id(+)

        AND a_bill.party_site_id                = a_bill_ps.party_site_id(+)
        AND a_bill_loc.location_id(+)           = a_bill_ps.location_id
        AND u_ship.party_site_id            = a_ship_ps.party_site_id(+) 

        AND a_ship_loc.location_id(+)           = a_ship_ps.location_id              
        AND trx.remit_to_address_seq_id         = a_remit.address_loc_seq_id(+)
        AND a_remit.location_id                 = a_remit_loc.location_id(+)

        AND tax.party_id(+)                     = b_bill_party.party_id
        AND tax.party_type_code(+)              = 'THIRD_PARTY'
	

UNION

SELECT      
trx.customer_trx_id || '_' ||  ps.payment_schedule_id SPLIT_KEY_ATTR ,
trx.customer_trx_id     customer_trx_id,
( select 'Y' from dual 
  where exists (Select 'X' from ra_customer_trx_lines_all lines
		Where lines.billing_period_start_date is not null 
		and lines.customer_trx_id = trx.customer_trx_id )) Billing_Period_Exist ,
(SELECT Count(DISTINCT(sales_order)) 
 FROM ra_customer_trx_lines_all lines  
 WHERE lines.customer_trx_id= trx.customer_trx_id ) total_Sales_Order,
(SELECT  lines.sales_order
FROM ra_customer_trx_lines_all lines
WHERE  lines.customer_trx_id  = trx.customer_trx_id
AND lines.sales_order IS NOT NULL 
AND rownum =1
) Header_Sales_Order 	,
1  term_sequence_number,
trx.trx_number      trx_number,
to_char(trx.trx_date,'YYYY-MM-DD')        trx_date,
trx.invoice_currency_code  invoice_currency_code,  
t.name                  term_name,
t.description			term_desc,
trx.waybill_number                      waybill_number,
        trx.ship_via                            ship_via,       
        to_char(trx.ship_date_actual,'YYYY-MM-DD')                    ship_date_actual,
        trx.purchase_order                      purchase_order_number,
        to_char(trx.purchase_order_date,'YYYY-MM-DD')                 purchase_order_date,
        to_char(ps.due_date,'YYYY-MM-DD')                             term_due_date_from_ps,
        b_bill.account_number                   bill_to_customer_number,
        b_bill_party.party_name   bill_to_customer_name,
         a_bill_loc.address1            bill_to_address1,
        a_bill_loc.address2            bill_to_address2,
        a_bill_loc.address3            bill_to_address3,
        a_bill_loc.address4            bill_to_address4,
        a_bill_loc.city                            bill_to_city,
        a_bill_loc.state            bill_to_state,
        a_bill_loc.province            bill_to_province,
        a_bill_loc.postal_code                     bill_to_postal_code,
        a_bill_loc.country                         bill_to_country,
    b_ship_party.party_name   ship_to_customer_name,        
    u_ship.party_site_id                   ship_to_site_number,	
    a_ship_loc.address1            ship_to_address1,        
    a_ship_loc.address2            ship_to_address2,     
    a_ship_loc.address3            ship_to_address3,        
    a_ship_loc.address4            ship_to_address4,        
    a_ship_loc.city             ship_to_city,        
    a_ship_loc.postal_code             ship_to_postal_code,        
    a_ship_loc.country            ship_to_country,
      a_ship_loc.state            ship_to_state,
       a_ship_loc.province            ship_to_province,
     a_remit_loc.address1                       remit_to_address1,
        a_remit_loc.address2                       remit_to_address2,
        a_remit_loc.address3                       remit_to_address3,
        a_remit_loc.address4                       remit_to_address4,
        a_remit_loc.city                           remit_to_city,
        a_remit_loc.state                          remit_to_state,
        a_remit_loc.postal_code                    remit_to_postal_code,
        a_remit_loc.country                        remit_to_country ,
        u_bill.location bill_to_location,
        (SELECT  party.party_name 
         FROM   JTF_RS_SALESREPS  sales,
         Hz_parties     party
         WHERE sales.RESOURCE_SALESREP_ID    =  trx.PRIMARY_RESOURCE_SALESREP_ID
         AND sales.RESOURCE_ID = party.party_id) primary_salesrep_name,   

(SELECT max(cp.URL) 
FROM hz_contact_points       cp, 
     hz_cust_account_roles   acct_role 
  WHERE acct_role.cust_account_role_id = trx.bill_to_contact_id 
    and acct_role.relationship_id = cp.relationship_id 
    and cp.owner_table_name = 'HZ_PARTIES' 
    and cp.contact_point_type='WEB'
    and cp.status ='A'
    and cp.primary_flag = 'Y') contact_web_url,  --Bug: 18705899

(SELECT max(cp.raw_phone_number) 
FROM hz_contact_points       cp, 
     hz_cust_account_roles   acct_role 
  WHERE acct_role.cust_account_role_id = trx.bill_to_contact_id 
    and acct_role.relationship_id = cp.relationship_id 
    and cp.owner_table_name = 'HZ_PARTIES' 
    and cp.contact_point_type='PHONE' 
    and cp.phone_line_type='MOBILE'
    and cp.status ='A'
    and cp.primary_flag = 'Y') contact_mobile_ph_number,  --Bug: 18705899


 (SELECT max(cp.email_address) 
   FROM hz_contact_points       cp, 
        hz_cust_account_roles   acct_role 
  WHERE acct_role.cust_account_role_id = trx.bill_to_contact_id 
    and acct_role.relationship_id = cp.relationship_id 
    and cp.owner_table_name = 'HZ_PARTIES' 
    and cp.contact_point_type='EMAIL'
    and cp.status ='A'
    and cp.primary_flag = 'Y') contact_email,  --Bug: 18705899

         (SELECT  party.PRIMARY_PHONE_NUMBER 
         FROM   JTF_RS_SALESREPS  sales,
         Hz_parties     party
         WHERE sales.RESOURCE_SALESREP_ID    =  trx.PRIMARY_RESOURCE_SALESREP_ID
         AND sales.RESOURCE_ID = party.party_id) primary_salesrep_phone,       		 
	(SELECT  party.PRIMARY_PHONE_AREA_CODE 
         FROM   JTF_RS_SALESREPS  sales,
         Hz_parties     party
         WHERE sales.RESOURCE_SALESREP_ID    =  trx.PRIMARY_RESOURCE_SALESREP_ID
         AND sales.RESOURCE_ID = party.party_id) salesrep_phone_areacode,
	(SELECT  party.PRIMARY_PHONE_COUNTRY_CODE 
         FROM   JTF_RS_SALESREPS  sales,
         Hz_parties     party
         WHERE sales.RESOURCE_SALESREP_ID    =  trx.PRIMARY_RESOURCE_SALESREP_ID
         AND sales.RESOURCE_ID = party.party_id) salesrep_phone_countrycode,		 
    TO_CHAR(NVL( DECODE(types.accounting_affect_flag, 'Y', ps.amount_line_items_original, 'N',
  (SELECT SUM(extended_amount)
     FROM ra_customer_trx_lines_all lines
    WHERE lines.customer_trx_id = trx.customer_trx_id
  AND lines.line_type           ='LINE'
  ) ),to_number(0)),fnd_currency.get_format_mask(trx.invoice_currency_code, 40 ) ) line_amount,
  TO_CHAR(NVL( DECODE(types.accounting_affect_flag, 'Y', ps.tax_original, 'N',
  (SELECT SUM(extended_amount)
     FROM ra_customer_trx_lines_all lines
    WHERE lines.customer_trx_id = trx.customer_trx_id
  AND lines.line_type           ='TAX'
  ) ),to_number(0)),fnd_currency.get_format_mask(trx.invoice_currency_code, 40 ) ) tax_amount,
  TO_CHAR(NVL( DECODE(types.accounting_affect_flag, 'Y', ps.freight_original, 'N',
  (SELECT SUM(extended_amount)
     FROM ra_customer_trx_lines_all lines
    WHERE lines.customer_trx_id = trx.customer_trx_id
  AND lines.line_type           ='FREIGHT'
  ) ),to_number(0)),fnd_currency.get_format_mask(trx.invoice_currency_code, 40 ) ) freight_amount,
  TO_CHAR(NVL( DECODE(types.accounting_affect_flag, 'Y', ps.amount_due_original, 'N',
  (SELECT SUM(extended_amount)
     FROM ra_customer_trx_lines_all lines
    WHERE lines.customer_trx_id = trx.customer_trx_id
  ) ) + nvl(ps.amount_adjusted,to_number(0)),to_number(0)),fnd_currency.get_format_mask(trx.invoice_currency_code, 40 ) ) total_amount,
  (SELECT NVL(SUM(NVL(adj.receivables_charges_adjusted, 0)), 0)
	FROM   ar_adjustments_all adj
	WHERE  adj.customer_trx_id = trx.customer_trx_id
	  AND  adj.status = 'A'
	  AND  adj.receivables_trx_id <> -15) finance_charges,
AR_BPA_UTILS_PKG.fn_get_contact_name(trx.bill_to_contact_id) customer_contact_name,        
AR_BPA_UTILS_PKG.fn_get_phone(trx.bill_to_contact_id) customer_phone,
AR_BPA_UTILS_PKG.fn_get_fax(trx.bill_to_contact_id) customer_fax,
AR_BPA_UTILS_PKG.fn_get_header_level_so(trx.customer_trx_id) sales_order,
AR_BPA_UTILS_PKG.fn_trx_has_groups(trx.customer_trx_id) trx_has_groups,
AR_BPA_UTILS_PKG.fn_get_billing_line_level(trx.customer_trx_id) billing_line_level,
    HZ_FORMAT_PUB.format_address(a_bill_loc.location_id) formatted_bill_to_address,
    HZ_FORMAT_PUB.format_address(a_ship_loc.location_id) formatted_ship_to_address,
    HZ_FORMAT_PUB.format_address(a_remit_loc.location_id) formatted_remit_to_address,
    HZ_FORMAT_PUB.format_address(a_bill_loc.location_id,null,null,CHR(13)) formatted_bill_to_address1,
    HZ_FORMAT_PUB.format_address(a_ship_loc.location_id,null,null,CHR(13)) formatted_ship_to_address1,
    HZ_FORMAT_PUB.format_address(a_remit_loc.location_id,null,null,CHR(13)) formatted_remit_to_address1,
to_char(trunc(sysdate),'YYYY-MM-DD') current_date,
AR_BPA_UTILS_PKG.fn_get_header_level_co(trx.customer_trx_id) contract_number,
AR_BPA_UTILS_PKG.fn_get_profile_class_name(trx.customer_trx_id) profile_class_name,
trx.interface_header_context,
AR_BPA_UTILS_PKG.fn_get_tax_printing_option(trx.bill_to_site_use_id, trx.bill_to_customer_id) tax_printing_option,
trx.interface_header_attribute1,
trx.interface_header_attribute2,
trx.interface_header_attribute3,
trx.interface_header_attribute4,
trx.interface_header_attribute5,
trx.interface_header_attribute6,
trx.interface_header_attribute7,
trx.interface_header_attribute8,
trx.interface_header_attribute9,
trx.interface_header_attribute10,
trx.interface_header_attribute11,
trx.interface_header_attribute12,
trx.interface_header_attribute13,
trx.interface_header_attribute14,
trx.interface_header_attribute15,
a_ship_ps.PARTY_SITE_NUMBER ship_to_location,
t_count.number_of_terms                 number_of_terms,
ps.terms_sequence_number        terms_sequence_number,
trx.org_id,
to_char(trunc(trx.creation_date),'YYYY-MM-DD') creation_date,
trx.internal_notes,
to_char(nvl(ps.amount_due_original,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_due_original,
          to_char(nvl(ps.amount_applied,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_applied,
          nvl(ps.amount_due_remaining,to_number(0)) outstanding_balance,                        
          to_char(nvl(ps.amount_due_remaining,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_due_remaining,
          to_char(nvl(ps.amount_applied,to_number(0)) - nvl(ps.amount_credited,to_number(0)) +
          nvl(ps.discount_taken_earned,to_number(0)) + nvl(ps.discount_taken_unearned,to_number(0)) + 
           nvl(ps.receivables_charges_charged,to_number(0)) ,    
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                                payments_and_credits,
          to_char(- nvl(ps.amount_applied,to_number(0)),    
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                                payments,
          to_char(nvl(ps.amount_credited,to_number(0)),    
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                                credits,
          to_char(nvl(ps.receivables_charges_charged,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_charges,
          to_char(nvl(ps.amount_adjusted,to_number(0)) ,
                fnd_currency.get_format_mask(trx.invoice_currency_code,40))
                        amount_adjusted,
        ps.amount_due_original  total_amounts,
        ps.class trx_type,
        t.term_id,
        ps.payment_schedule_id,
        trx.comments,
        to_char(trunc(trx.START_DATE_COMMITMENT),'YYYY-MM-DD') START_DATE_COMMITMENT,
        to_char(trunc(trx.END_DATE_COMMITMENT),'YYYY-MM-DD') END_DATE_COMMITMENT,
        reason_lookup.meaning Credit_memo_reason,
        trx.previous_customer_trx_id,
        decode(trx.trx_class,'CM',
		              (SELECT applied_trx.trx_number FROM   ra_customer_trx_all applied_trx WHERE  applied_trx.customer_trx_id = trx.previous_customer_trx_id) ,
		              'CB',
		               (select ct.trx_number  from ra_customer_trx_all ct, ar_adjustments_all adj  where adj.chargeback_customer_trx_id  =  trx.customer_trx_id and ct.customer_trx_id = adj.customer_trx_id and trx.trx_class = 'CB'),null)   AS    previous_trx_number,
--FND_ACCESS_CONTROL_UTIL.Get_Org_Name(trx.org_id) org_name,
null org_name,
trx.legal_entity_id,
(select xle.name from  XLE_FIRSTPARTY_INFORMATION_V xle
where xle.legal_entity_id = trx.legal_entity_id) as legal_entity_name,
trx.ct_reference,
trx.cust_trx_type_seq_id,
types.name cust_trx_type_name,
trx.batch_source_seq_id,
batch.name batch_source_name,
trx.attribute1,
trx.attribute2,
trx.attribute3,
trx.attribute4,
trx.attribute5,
trx.attribute6,
trx.attribute7,
trx.attribute8,
trx.attribute9,
trx.attribute10,
trx.attribute11,
trx.attribute12,
trx.attribute13,
trx.attribute14,
trx.attribute15,
trx.SET_OF_BOOKS_ID,
trx.REASON_CODE,
trx.PURCHASE_ORDER_REVISION,
trx.CUSTOMER_REFERENCE,
to_char(trx.CUSTOMER_REFERENCE_DATE,'YYYY-MM-DD'),
trx.EXCHANGE_RATE_TYPE,
to_char(trx.EXCHANGE_DATE,'YYYY-MM-DD'),
trx.EXCHANGE_RATE,
trx.ATTRIBUTE_CATEGORY,
trx.ORIG_SYSTEM_BATCH_NAME,
trx.FINANCE_CHARGES as Finance_Charge_Indicator,
trx.CREDIT_METHOD_FOR_RULES,
trx.CREDIT_METHOD_FOR_INSTALLMENTS,
trx.FOB_POINT,
trx.DEFAULT_USSGL_TRX_CODE_CONTEXT,
trx.DEFAULT_USSGL_TRANSACTION_CODE,
trx.RECURRED_FROM_TRX_NUMBER,
trx.STATUS_TRX,
trx.DOC_SEQUENCE_VALUE,
trx.GLOBAL_ATTRIBUTE1,
trx.GLOBAL_ATTRIBUTE2,
trx.GLOBAL_ATTRIBUTE3,
trx.GLOBAL_ATTRIBUTE4,
trx.GLOBAL_ATTRIBUTE5,
trx.GLOBAL_ATTRIBUTE6,
trx.GLOBAL_ATTRIBUTE7,
trx.GLOBAL_ATTRIBUTE8,
trx.GLOBAL_ATTRIBUTE9,
trx.GLOBAL_ATTRIBUTE10,
trx.GLOBAL_ATTRIBUTE11,
trx.GLOBAL_ATTRIBUTE12,
trx.GLOBAL_ATTRIBUTE13,
trx.GLOBAL_ATTRIBUTE14,
trx.GLOBAL_ATTRIBUTE15,
trx.GLOBAL_ATTRIBUTE16,
trx.GLOBAL_ATTRIBUTE17,
trx.GLOBAL_ATTRIBUTE18,
trx.GLOBAL_ATTRIBUTE19,
trx.GLOBAL_ATTRIBUTE20,
trx.GLOBAL_ATTRIBUTE_CATEGORY,
trx.EDI_PROCESSED_FLAG,
trx.EDI_PROCESSED_STATUS,
trx.MRC_EXCHANGE_RATE_TYPE,
trx.MRC_EXCHANGE_DATE,
trx.MRC_EXCHANGE_RATE,
trx.PAYMENT_SERVER_ORDER_NUM,
trx.APPROVAL_CODE,
trx.ADDRESS_VERIFICATION_CODE,
ps.NUMBER_OF_DUE_DATES,
ps.STATUS,
to_char(ps.GL_DATE_CLOSED,'YYYY-MM-DD'),
to_char(ps.ACTUAL_DATE_CLOSED,'YYYY-MM-DD'),
ps.AMOUNT_LINE_ITEMS_REMAINING,
ps.AMOUNT_IN_DISPUTE,
ps.AMOUNT_CREDITED,
ps.RECEIVABLES_CHARGES_REMAINING,
ps.FREIGHT_REMAINING,
ps.TAX_REMAINING,
ps.DISCOUNT_TAKEN_EARNED,
ps.DISCOUNT_TAKEN_UNEARNED,
ps.ACCTD_AMOUNT_DUE_REMAINING,
trx.SPECIAL_INSTRUCTIONS,
a_bill_loc.county                         bill_to_county,
a_ship_loc.county                         ship_to_county,
a_remit_loc.county                         remit_to_county,
(SELECT territory_short_name FROM fnd_territories_vl WHERE territory_code=a_bill_loc.country)
AS bill_to_country_name,
(SELECT territory_short_name FROM fnd_territories_vl WHERE territory_code=a_ship_loc.country)
AS ship_to_country_name,
rep_registration_number   cust_tax_regn_no,
(CASE
WHEN exists
(SELECT 1
  FROM
  ra_customer_trx_lines_all lines,
         ZX_RATES_B       rates,
         ZX_REPORTING_TYPES_B  reporting_types,        
         ZX_REPORT_CODES_ASSOC assoc
   WHERE
          customer_trx_id=trx.customer_trx_id
          and lines.vat_tax_id=rates.tax_rate_id                                       
          AND reporting_types.tax_regime_code = rates.tax_regime_code       
          AND  assoc.entity_id   =  rates.tax_rate_id
          AND  assoc.entity_code = 'ZX_RATES'   
          and reporting_types.reporting_type_code = 'REVERSE_CHARGE_VAT'
          and assoc.reporting_type_id = reporting_types.reporting_type_id
 )         
THEN 'Y'
ELSE 'N'
END ) reverse_charge_vat_invoice ,
AR_BPA_UTILS_PKG.fn_get_contact_name_party(trx.ship_to_party_contact_id) ship_to_contact_name,        
AR_BPA_UTILS_PKG.fn_get_phone_party(trx.ship_to_party_contact_id) ship_to_phone,
AR_BPA_UTILS_PKG.fn_get_fax_party(trx.ship_to_party_contact_id) ship_to_fax ,
to_char(to_number(0) ,fnd_currency.get_format_mask(trx.invoice_currency_code,40))
 AS   line_tax_adjustment  ,       
to_char(to_number(0) ,fnd_currency.get_format_mask(trx.invoice_currency_code,40))
 AS   freight_adjustment ,
trx.STRUCTURED_PAYMENT_REFERENCE     

FROM
        ar_invoice_count_terms_v                t_count,
        ar_payment_schedules_all                ps,
        ra_terms                                t,

        ra_cust_trx_types_all                   types,
        ra_batch_sources_all                    batch,
        ra_customer_trx_all                     trx,
        hz_cust_accounts                        b_bill,
        hz_parties                              b_bill_party,
        hz_cust_acct_sites_all                  a_bill,
        hz_party_sites                          a_bill_ps,
        hz_locations                            a_bill_loc,

        hz_parties                              b_ship_party,        

        hz_party_sites                          a_ship_ps,
        hz_locations                            a_ship_loc,

        ar_remit_to_locs_all                    a_remit,
        hz_locations                            a_remit_loc,        
        hz_cust_site_uses_all                   u_bill,
        hz_party_site_uses                   u_ship,
        ar_lookups                              reason_lookup,
        zx_party_tax_profilE                    tax
        &P_DYNAMIC_FROM_CLAUSE        

WHERE   &P_DYNAMIC_WHERE_CLAUSE1
        trx.cust_trx_type_seq_id                = types.cust_trx_type_seq_id
        AND trx.batch_source_seq_id             = batch.batch_source_seq_id
        AND trx.term_id                         = t.term_id(+)
        AND reason_lookup.lookup_type(+)        = 'CREDIT_MEMO_REASON'
        AND reason_lookup.lookup_code(+)        = trx.reason_code             
        AND nvl(trx.term_id, -1)                = t_count.term_id
        AND trx.bill_to_customer_id             = b_bill.cust_account_id
        ANd b_bill.party_id                     = b_bill_party.party_id
        AND trx.ship_to_party_id                = b_ship_party.party_id(+)
        AND trx.bill_to_site_use_id             = u_bill.site_use_id
        AND trx.ship_to_party_site_use_id       = u_ship.party_site_use_id(+)
        AND u_bill.cust_acct_site_id            = a_bill.cust_acct_site_id(+)
        AND a_bill.party_site_id                = a_bill_ps.party_site_id(+)
        AND a_bill_loc.location_id(+)           = a_bill_ps.location_id
        
        AND u_ship.party_site_id                = a_ship_ps.party_site_id(+)   
        AND a_ship_loc.location_id(+)           = a_ship_ps.location_id              
        AND trx.remit_to_address_seq_id         = a_remit.address_loc_seq_id(+)
        AND a_remit.location_id                 = a_remit_loc.location_id(+)
        AND tax.party_id(+)                     = b_bill_party.party_id
        AND tax.party_type_code(+)              = 'THIRD_PARTY'
	&P_DYNAMIC_ORDER_BY_CLAUSE