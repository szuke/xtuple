<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">
 <xsl:output omit-xml-declaration="yes"/>

 <xsl:param name="no-translations" as="xs:boolean" select="false()"/>

 <xsl:template match="@*|node()">
  <xsl:copy>
   <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
 </xsl:template>
 <xsl:template match="all-prerequisites">
  <xsl:apply-templates select="document('shared.xml')/shared/prerequisites/all"/>
 </xsl:template>
 <xsl:template match="postbooks-prerequisites">
  <xsl:apply-templates select="document('shared.xml')/shared/prerequisites/postbooks"/>
 </xsl:template>
 <xsl:template match="manufacturing-prerequisites">
  <xsl:apply-templates select="document('shared.xml')/shared/prerequisites/manufacturing"/>
 </xsl:template>
 <xsl:template match="distribution-prerequisites">
  <xsl:apply-templates select="document('shared.xml')/shared/prerequisites/distribution"/>
 </xsl:template>
 <xsl:template match="add-prerequisites">
  <xsl:apply-templates select="document('shared.xml')/shared/prerequisites/add"/>
 </xsl:template>

 <xsl:template match="@updater">
   <xsl:choose>
     <xsl:when test = "$no-translations">
       <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
     </xsl:when>
     <!-- xsltproc can't use fn:replace yet
     <xsl:when test = "fn:replace(../@updater, '^([0-9]+\.[0-9]+).*', '$1') >= 2.5">
       <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
     </xsl:when>
     -->
     <xsl:otherwise>
       <xsl:attribute name="updater">2.5.0Beta</xsl:attribute>
     </xsl:otherwise>
   </xsl:choose>
 </xsl:template>

 <!-- (if not not including translations) == (if including translations) -->
 <xsl:template match="loadqm">
   <!--
   <xsl:if test = "not($no-translations)" >
     <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
   </xsl:if>
   -->
   <xsl:choose>
     <xsl:when test = "$no-translations"> </xsl:when>
     <xsl:otherwise>
       <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
     </xsl:otherwise>
   </xsl:choose>
 </xsl:template>

 <xsl:template match="xTuple-translations">
  <xsl:apply-templates select="document('shared.xml')/shared/translations/xTuple"/>
 </xsl:template>
 <xsl:template match="xtcore-translations">
  <xsl:apply-templates select="document('shared.xml')/shared/translations/xtcore"/>
 </xsl:template>
 <xsl:template match="xwd-translations">
  <xsl:apply-templates select="document('shared.xml')/shared/translations/xwd"/>
 </xsl:template>
 <xsl:template match="xtmfg-translations">
  <xsl:apply-templates select="document('shared.xml')/shared/translations/xtmfg"/>
 </xsl:template>
 <xsl:template match="all">
  <xsl:apply-templates select="node()"/>
 </xsl:template>
 <xsl:template match="postbooks">
  <xsl:apply-templates select="node()"/>
 </xsl:template>
 <xsl:template match="manufacturing">
  <xsl:apply-templates select="node()"/>
 </xsl:template>
 <xsl:template match="distribution">
  <xsl:apply-templates select="node()"/>
 </xsl:template>
 <xsl:template match="add">
  <xsl:apply-templates select="node()"/>
 </xsl:template>
 <xsl:template match="xTuple">
  <xsl:apply-templates select="node()"/>
 </xsl:template>
 <xsl:template match="xtcore">
  <xsl:apply-templates select="node()"/>
 </xsl:template>
 <xsl:template match="xwd">
  <xsl:apply-templates select="node()"/>
 </xsl:template>
 <xsl:template match="xtmfg">
  <xsl:apply-templates select="node()"/>
 </xsl:template>

</xsl:stylesheet>
