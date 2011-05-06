<?xml version="1.0"?>
<!-- This style sheet can be used to transform the dataoneTypes.xsd document to
a reStructuredText representation that can be rendered using Sphinx. It is by 
no means a tool for general transform of XML Schema to rst, but should work OK
for the pattern of type structures being used by DataONE.

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:str="http://exslt.org/strings"
 extension-element-prefixes="str"
 exclude-result-prefixes="str">
<xsl:import href="exslt/str/functions/replace/str.replace.xsl" />
<xsl:output omit-xml-declaration="yes" indent="yes" method="xml"/>
<xsl:variable name="MODULE">STypes.</xsl:variable>

<xsl:template match="/">
  <!-- Add a warning notice to the generated output to discourage edits there. -->
  <xsl:text>.. WARNING: This file is generated. Any edits will be lost upon regeneration.
  
  </xsl:text>
  <!-- Process the schema -->
  <xsl:call-template name="t1"/>
</xsl:template>


<xsl:template name="t1">
  <!-- Render the simple types first -->
  <xsl:for-each select="//xs:simpleType">
    <xsl:call-template name="simpleType"></xsl:call-template>
  </xsl:for-each>
  <!-- Then the complex types. -->
  <xsl:for-each select="//xs:complexType">
    <xsl:call-template name="complexType"></xsl:call-template>
  </xsl:for-each>
</xsl:template>


<!-- simple type documentation -->
<xsl:template name="simpleType">
  <xsl:param name="prefix" select="''" />
  <xsl:param name="sprefix" select="concat($prefix,'   ')" />
  <xsl:value-of select="$prefix"/><xsl:text>.. py:class:: </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>(</xsl:text>
      <xsl:choose>
      <xsl:when test="'xs' = substring-before(xs:restriction/@base,':')">
        <xsl:value-of select="xs:restriction/@base"></xsl:value-of>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($MODULE, substring-after(xs:restriction/@base,':'))"></xsl:value-of>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>)</xsl:text>
  <xsl:value-of select="'&#xa;&#xa;'"></xsl:value-of>
  <xsl:for-each select="xs:annotation/xs:documentation">
    <xsl:call-template name="formatBlock">
      <xsl:with-param name="outputString" select="."/>
      <xsl:with-param name="prefix" select="$sprefix" />
    </xsl:call-template>
    <xsl:value-of select="'&#xa;&#xa;'"></xsl:value-of>
  </xsl:for-each>
  <xsl:if test="count(xs:restriction/xs:enumeration) &gt; 0">
    <xsl:value-of select="concat($sprefix,'Enumerated values::&#xa;&#xa;')" />
    <xsl:value-of select="concat($sprefix,'  ')"/><xsl:text>( </xsl:text>
    <xsl:call-template name="join">
      <xsl:with-param name="valueList" select="xs:restriction/xs:enumeration/@value" />
      <xsl:with-param name="separator" select="concat(' |&#xa;', $sprefix, '    ')" />
      <xsl:with-param name="quote"><xsl:text>&apos;</xsl:text></xsl:with-param>
    </xsl:call-template>
    <xsl:text> )</xsl:text>
  </xsl:if>
  <xsl:text>&#xa;&#xa;</xsl:text>
  <!-- Show the source of this type definition -->
  <xsl:call-template name="showsource">
    <xsl:with-param name="prefix" select="$sprefix" />
  </xsl:call-template>
  <xsl:text>&#xa;&#xa;</xsl:text>
</xsl:template>


<!-- renders an attribute -->
<xsl:template name="attribute">
  <xsl:param name="sprefix" select="''" />
  <xsl:value-of select="concat($sprefix, ':param ',@name,': ')" />
  <xsl:choose>
    <xsl:when test="count(@use) &gt; 0">
      <xsl:text> (</xsl:text><xsl:value-of select="@use"></xsl:value-of><xsl:text>) </xsl:text>
    </xsl:when>
    <xsl:otherwise><xsl:text> (optional) </xsl:text></xsl:otherwise>
  </xsl:choose>
  <xsl:for-each select="xs:annotation/xs:documentation">
    <xsl:call-template name="formatBlock">
      <xsl:with-param name="outputString" select="."/>
      <xsl:with-param name="prefix" select="$sprefix" />
    </xsl:call-template>        
  </xsl:for-each>
  <xsl:text>&#xa;</xsl:text>
  <xsl:choose>
    <xsl:when test="'xs' = substring-before(@type,':')">
      <xsl:value-of select="concat($sprefix, ':type ',@name,': ', @type)"></xsl:value-of>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat($sprefix, ':type ',@name,': ',$MODULE, substring-after(@type,':'))"></xsl:value-of>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#xa;</xsl:text>  
</xsl:template>


<!-- Renders an element in a complex type -->
<xsl:template name="complexTypeElement">
  <xsl:param name="sprefix" select="''" />
  <xsl:variable name="minocc">
    <xsl:choose>
      <xsl:when test="count(@minOccurs) &gt; 0"><xsl:value-of select="@minOccurs" /></xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="maxocc">
    <xsl:choose>
      <xsl:when test="count(@maxOccurs) &gt; 0">
      <xsl:choose>
        <xsl:when test="@maxOccurs = 1">1</xsl:when>
        <xsl:when test="@maxOccurs = 'unbounded'">*</xsl:when>
      </xsl:choose>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="concat($sprefix, ':param ',@name,': ')" />
  <xsl:value-of select="concat('``',$minocc,'..',$maxocc,'`` ')" />
  <xsl:for-each select="xs:annotation/xs:documentation">
    <xsl:call-template name="formatBlock">
      <xsl:with-param name="outputString" select="."/>
      <xsl:with-param name="prefix" select="$sprefix" />
    </xsl:call-template>        
  </xsl:for-each>
  <xsl:text>&#xa;</xsl:text>
  <xsl:choose>
    <xsl:when test="'xs' = substring-before(@type,':')">
      <xsl:value-of select="concat($sprefix, ':type ',@name,': ', @type)"></xsl:value-of>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat($sprefix, ':type ',@name,': ',$MODULE, substring-after(@type,':'))"></xsl:value-of>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#xa;</xsl:text>
</xsl:template>

<!-- Render a type name -->
<xsl:template name="renderTypeName">
  <xsl:param name="typename" select="''"/>
  <xsl:choose>
    <xsl:when test="'xs' = substring-before($typename,':')">
      <xsl:value-of select="$typename"></xsl:value-of>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat($MODULE, substring-after($typename,':'))"></xsl:value-of>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Document complex types -->
<xsl:template name="complexType">
  <xsl:param name="prefix" select="''" />
  <xsl:param name="sprefix" select="concat($prefix,'   ')" />
  
  <!-- figure the parent class, if any -->
  <xsl:variable name="parent">
    <xsl:choose>
      <xsl:when test="count(xs:simpleContent/xs:extension) &gt; 0">
        <xsl:text>(</xsl:text><xsl:call-template name="renderTypeName">
        <xsl:with-param name="typename" select="xs:simpleContent/xs:extension/@base" /></xsl:call-template> 
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="count(xs:complexContent/xs:extension) &gt; 0">
        <xsl:text>(</xsl:text><xsl:call-template name="renderTypeName">
        <xsl:with-param name="typename" select="xs:complexContent/xs:extension/@base" /></xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise><xsl:text>()</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$prefix"/><xsl:text>.. py:class:: </xsl:text>
  <xsl:value-of select="concat(@name,$parent)"/>
  <xsl:text>&#xa;&#xa;</xsl:text>
  <xsl:if test="count(xs:annotation/xs:documentation) &gt; 0">
    <xsl:for-each select="xs:annotation/xs:documentation">
      <xsl:call-template name="formatBlock">
        <xsl:with-param name="outputString" select="."/>
        <xsl:with-param name="prefix" select="$sprefix" />
      </xsl:call-template>        
    </xsl:for-each>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:if>
  
  <!-- Attributes of type -->
  <xsl:if test="count(xs:attribute) &gt; 0 or count(xs:simpleContent/xs:extension/xs:attribute) &gt; 0">
    <xsl:value-of select="$sprefix" /> 
    <xsl:text>**Attributes**&#xa;&#xa;</xsl:text>
    <xsl:for-each select=".//xs:attribute">
      <xsl:call-template name="attribute">
        <xsl:with-param name="sprefix" select="$sprefix" />
     </xsl:call-template>
    </xsl:for-each>
    <xsl:text>&#xa;</xsl:text>
  </xsl:if>

  <xsl:choose>  
    <!-- sequence of elements -->
    <xsl:when test="count(xs:sequence) &gt; 0">
      <xsl:value-of select="$sprefix" /> 
      <xsl:text>**Sequence Elements**&#xa;&#xa;</xsl:text>
      <xsl:for-each select="xs:sequence/xs:element">
        <xsl:call-template name="complexTypeElement">
          <xsl:with-param name="sprefix" select="$sprefix" />
        </xsl:call-template>
      </xsl:for-each>
    </xsl:when>

    <!-- choice of elements -->
    <xsl:when test="count(xs:choice) &gt; 0">
      <xsl:value-of select="$sprefix" /> 
      <xsl:text>**One Of**&#xa;&#xa;</xsl:text>
      <xsl:for-each select="xs:choice/xs:element">
        <xsl:call-template name="complexTypeElement">
          <xsl:with-param name="sprefix" select="$sprefix" />
        </xsl:call-template>
      </xsl:for-each>
    </xsl:when>
    
    <!-- simpleContent of a complex type-->
    <xsl:when test="count(xs:simpleContent) &gt; 0">
      <!--  TODO -->
    </xsl:when> 
  </xsl:choose>
  <xsl:text>&#xa;</xsl:text>
  <xsl:call-template name="showsource">
    <xsl:with-param name="prefix" select="$sprefix" />
  </xsl:call-template>
  <xsl:text>&#xa;</xsl:text>
</xsl:template>

<!-- Generate an XML source block -->
<xsl:template name="showsource">
  <xsl:param name="prefix" select="''" />
  <xsl:param name="sprefix" select="concat($prefix,'   ')" />
  <xsl:value-of select="$prefix"/><xsl:text>Schema Source:&#xa;&#xa;</xsl:text>
  <xsl:value-of select="$prefix" /><xsl:text>.. code-block:: xml&#xa;&#xa;</xsl:text>
  <xsl:value-of select="$sprefix" />
  <xsl:apply-templates name="docopy" select="."></xsl:apply-templates>
  <xsl:text>&#xa;&#xa;</xsl:text>  
</xsl:template>


<!-- template 'join' accepts valueList and separator -->
<xsl:template name="join" >
  <xsl:param name="valueList" select="''"/>
  <xsl:param name="separator" select="','"/>
  <xsl:param name="quote" select="''"/>
  <xsl:for-each select="$valueList">
    <xsl:choose>
      <xsl:when test="position() = 1">
        <xsl:value-of select="concat($quote, ., $quote)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($separator, $quote, ., $quote) "/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>


<!-- convert text to a single line -->
<xsl:template name="formatBlock">
  <xsl:param name="outputString"/>
  <xsl:param name="prefix" />
  <xsl:value-of select="$prefix"></xsl:value-of><xsl:value-of select="str:replace($outputString,'&#xa;',' ')"></xsl:value-of>
</xsl:template>

<!--  Copy template -->
<xsl:template name="docopy" match="node() | @*">
  <xsl:choose>
  <xsl:when test="name(.) != 'xs:annotation'">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:when>
  <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
