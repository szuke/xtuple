<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output indent="yes" method="xml"/>

  <xsl:param name="ts"/>
  <xsl:variable name="root" select="/"/>

  <xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  <xsl:template match="label">
    <message>
      <source><xsl:value-of select="string"/></source>
      <xsl:choose>
        <xsl:when test="document($ts)/TS/context[name=$root/report/name]/message[source=current()/string]/translation!=''">
          <translation><xsl:value-of select="document($ts)/TS/context[name=$root/report/name]/message[source=current()/string]/translation"/></translation>
        </xsl:when>
        <xsl:otherwise>
          <translation type="unfinished"/>
        </xsl:otherwise>
      </xsl:choose>
    </message>
  </xsl:template>

  <xsl:template match="report">
    <context>
      <name><xsl:value-of select="name"/></name>
      <xsl:apply-templates select="*"/>
    </context>
  </xsl:template>
</xsl:stylesheet>
