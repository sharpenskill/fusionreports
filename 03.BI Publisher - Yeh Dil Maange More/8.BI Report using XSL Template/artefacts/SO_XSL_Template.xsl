<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" encoding="utf-8" indent="no"/>
  <xsl:template match="/">
    <SalesOrders>
      <xsl:for-each select="DATA_DS/G_1">
        <SalesOrder>
          <OrderNum>
            <xsl:value-of select="ORDER_NUMBER" />
          </OrderNum>
		  <OrderId>
            <xsl:value-of select="SO_HEADER_ID" />
          </OrderId>
          <OrderType>
            <xsl:value-of select="''" />
          </OrderType>
          <StatusCode>
            <xsl:value-of select="SO_HDR_STATUS_CODE" />
          </StatusCode>
          <OrderDate>
            <xsl:value-of select="ORDER_DATE" />
          </OrderDate>
          <CurrencyCode>
            <xsl:value-of select="CURR_CODE" />
          </CurrencyCode>
		  <SOLines>
            <xsl:for-each select="G_2">
              <SOLine>
                <LineNumber>
                  <xsl:value-of select="LINE_NUMBER" />
                </LineNumber>
				<Item>
                  <xsl:value-of select="ITEM_CODE" />
                </Item>
                <ItemDesc>
                  <xsl:value-of select="ITEM_DESC" />
                </ItemDesc>
                <OrderUOM>
                  <xsl:value-of select="ORDERED_UOM" />
                </OrderUOM>
                <UnitListPrice>
                  <xsl:value-of select="UNIT_LIST_PRICE" />
                </UnitListPrice>
                <UnitSellingPrice>
                  <xsl:value-of select="UNIT_SELLING_PRICE" />
                </UnitSellingPrice>
				<Fulfillment>
                  <FulfillmentLineNum>
                    <xsl:value-of select="FULFILL_LINE_NUMBER" />
                  </FulfillmentLineNum>
                  <OrderQuantity>
                    <xsl:value-of select="ORDERED_QTY" />
                  </OrderQuantity>
                  <LinePrice>
                    <xsl:value-of select="LINE_PRICE" />
                  </LinePrice>
                  <FulfillStatusCode>
                    <xsl:value-of select="FULFILL_STATUS_CODE" />
                  </FulfillStatusCode>
                  <FulfilledQty>
                    <xsl:value-of select="FULFILLED_QTY" />
                  </FulfilledQty>
                </Fulfillment>
		      </SOLine>
            </xsl:for-each>
          </SOLines>
        </SalesOrder>
      </xsl:for-each>
    </SalesOrders>
  </xsl:template>
</xsl:stylesheet>