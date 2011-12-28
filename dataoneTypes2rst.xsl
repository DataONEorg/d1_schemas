<?xml version="1.0" encoding="UTF-8"?>
<!-- 
This style sheet can be used to transform the dataoneTypes.xsd document to
a reStructuredText representation that can be rendered using Sphinx. 

Sphinx classes are generated for each defined type, and plantuml diagrams 
generated for each type.

An overall UML diagram is also generated.

This is by no means a tool for general transform of XML Schema to RST, but 
should work OK for the pattern of type structures being used by DataONE.

- Dave V.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="1.0">
    <!-- Transform DataONE Types to plantuml text output. -->

    <xsl:output omit-xml-declaration="yes" indent="no" method="text"/>
    <xsl:strip-space elements="*" />
    <xsl:variable name="MODULE">Types.</xsl:variable>

    <!-- Pretty print XML fragment -->
    <xsl:param name="indent-increment" select="'   '"/>
    <xsl:template name="newline">
        <xsl:text disable-output-escaping="yes">
</xsl:text>
    </xsl:template>
    <xsl:template match="comment() | processing-instruction()">
        <!-- <xsl:param name="indent" select="''"/>
            <xsl:call-template name="newline"/>    
            <xsl:value-of select="$indent"/>
            <xsl:copy /> -->
    </xsl:template>
    <xsl:template match="text()">
        <xsl:param name="indent" select="''"/>
        <xsl:call-template name="newline"/>    
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="text()[normalize-space(.)='']"/>
    <xsl:template match="*" name="xcopy" mode="xcopy">
        <xsl:param name="indent" select="''"/>
        <xsl:call-template name="newline"/>    
        <xsl:value-of select="$indent"/>
        <xsl:choose>
            <xsl:when test="count(child::*) > 0">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates select="* [not(local-name() = 'annotation')] |text()" mode="xcopy">
                        <xsl:with-param name="indent" select="concat ($indent, $indent-increment)"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="newline"/>
                    <xsl:value-of select="$indent"/>
                </xsl:copy>
            </xsl:when>       
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <xsl:template name="d1type">
        <xsl:param name="v" />
        <xsl:choose>
            <xsl:when test="'xs' = substring-before($v,':')">
                <xsl:text>xs.</xsl:text><xsl:value-of select="substring-after($v,':')"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring-after($v,':')"></xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="render_enum">
        <xsl:param name="enode" />
        <xsl:param name="indent" />
        <xsl:value-of select="$indent"/>
        <xsl:text>enum </xsl:text><xsl:value-of select="$enode/@name"/><xsl:text>&#xa;</xsl:text>
        <xsl:for-each select="$enode/xs:restriction/xs:enumeration">
            <xsl:value-of select="$indent"/><xsl:text>  </xsl:text>
            <xsl:value-of select="$enode/@name"/><xsl:text> : </xsl:text><xsl:value-of select="@value"/>
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="render_simple">
        <xsl:param name="snode" />
        <xsl:param name="indent"/>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="$snode/@name"/>
        <xsl:text disable-output-escaping="yes"> --|> </xsl:text>
        <xsl:call-template name="d1type">
            <xsl:with-param name="v" select="$snode/xs:restriction/@base"></xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template name="render_simplecontent">
        <xsl:param name="snode" />
        <xsl:param name="indent"/>
        <xsl:value-of select="$indent"/>
        <xsl:text>class </xsl:text><xsl:value-of select="$snode/@name"/><xsl:text> {&#xa;</xsl:text>
        <xsl:for-each select="$snode/xs:simpleContent/xs:extension/xs:attribute">
            <xsl:value-of select="$indent"/>
            <xsl:text>  + </xsl:text><xsl:value-of select="@name"/>
            <xsl:text> : </xsl:text>
            <xsl:call-template name="d1type"><xsl:with-param name="v" select="@type"/></xsl:call-template>
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
        <xsl:value-of select="$indent"/><xsl:text>}&#xa;</xsl:text>
        <xsl:for-each select="$snode/xs:simpleContent/xs:extension/xs:attribute">
            <xsl:value-of select="$indent"/>
            <xsl:value-of select="$snode/@name"/>
            <xsl:text> .. </xsl:text>
            <xsl:call-template name="d1type"><xsl:with-param name="v" select="@type"/></xsl:call-template>
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="$snode/@name"/>
        <xsl:text disable-output-escaping="yes"> --|> </xsl:text>
        <xsl:call-template name="d1type"><xsl:with-param name="v" select="$snode/xs:simpleContent/xs:extension/@base" /></xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template name="render_complexseq">
        <!-- TODO: add in attributes outside of the sequence -->
        <xsl:param name="snode" />
        <xsl:param name="indent"/>
        <xsl:value-of select="$indent"/>
        <xsl:text>class </xsl:text><xsl:value-of select="$snode/@name"/><xsl:text> {&#xa;</xsl:text>
        <xsl:for-each select="$snode/xs:sequence/xs:element">
            <xsl:value-of select="$indent"/>
            <xsl:text>  + </xsl:text><xsl:value-of select="@name"/>
            <xsl:text> : </xsl:text>
            <xsl:call-template name="d1type">
                <xsl:with-param name="v" select="@type" />
            </xsl:call-template>
            <xsl:text>[</xsl:text>
            <xsl:choose>
                <xsl:when test="@minOccurs"><xsl:value-of select="@minOccurs"/></xsl:when>
                <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:text>..</xsl:text>
            <xsl:choose>
                <xsl:when test="@maxOccurs = 'unbounded'"><xsl:text>*</xsl:text></xsl:when>
                <xsl:when test="@maxOccurs != 'unbounded'"><xsl:value-of select="@maxOccurs"/></xsl:when>
                <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:text>]&#xa;</xsl:text>                    
        </xsl:for-each>
        <xsl:for-each select="$snode/xs:attribute">
            <xsl:value-of select="$indent"/>
            <xsl:text>  + </xsl:text><xsl:value-of select="@name"/>
            <xsl:text> : </xsl:text>
            <xsl:call-template name="d1type">
                <xsl:with-param name="v" select="@type" />
            </xsl:call-template>
            <xsl:text>[</xsl:text>
            <xsl:choose>
                <xsl:when test="@use = 'required'">1</xsl:when>
                <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:text>.. 1]&#xa;</xsl:text>
        </xsl:for-each>
        <xsl:value-of select="$indent"/>
        <xsl:text>}&#xa;</xsl:text>
        <xsl:for-each select="$snode/xs:sequence/xs:element[not(@type=preceding-sibling::xs:element/@type)]">
            <xsl:value-of select="$indent"/>
            <xsl:value-of select="$snode/@name" />
            <xsl:text> .. </xsl:text>
            <xsl:call-template name="d1type">
                <xsl:with-param name="v" select="@type" />
            </xsl:call-template>
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="$snode/xs:attribute[not(@type=preceding-sibling::xs:attribute/@type)]">
            <xsl:value-of select="$indent"/>
            <xsl:value-of select="$snode/@name" />
            <xsl:text> .. </xsl:text>
            <xsl:call-template name="d1type">
                <xsl:with-param name="v" select="@type" />
            </xsl:call-template>
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template name="render_complexattrs_only">
        <xsl:param name="snode" />
        <xsl:param name="indent"/>
        <xsl:value-of select="$indent"/>
        <xsl:text>class </xsl:text><xsl:value-of select="$snode/@name"/><xsl:text> {&#xa;</xsl:text>
        <xsl:for-each select="$snode/xs:attribute">
            <xsl:value-of select="$indent"/>
            <xsl:text>  + </xsl:text><xsl:value-of select="@name"/>
            <xsl:text> : </xsl:text>
            <xsl:call-template name="d1type">
                <xsl:with-param name="v" select="@type" />
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="@use='required'"><xsl:text>[1..1]</xsl:text></xsl:when>
                <xsl:otherwise><xsl:text>[0..1]</xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xa;</xsl:text>                    
        </xsl:for-each>
        <xsl:value-of select="$indent"/>
        <xsl:text>}&#xa;</xsl:text>
        <xsl:for-each select="$snode/xs:attribute[not(@type=preceding-sibling::xs:attribute/@type)]">
            <xsl:value-of select="$indent"/>
            <xsl:value-of select="$snode/@name" />
            <xsl:text> .. </xsl:text>
            <xsl:call-template name="d1type">
                <xsl:with-param name="v" select="@type" />
            </xsl:call-template>
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>


    <xsl:template name="render_complexContent">
        <xsl:param name="snode" />
        <xsl:param name="indent" />
        <xsl:value-of select="$indent"/>
        <xsl:text>class </xsl:text><xsl:value-of select="$snode/@name"/><xsl:text> {&#xa;</xsl:text>
        <xsl:for-each select="$snode/xs:complexContent/xs:extension/xs:sequence/xs:element">
            <xsl:value-of select="$indent"/>
            <xsl:text>  + </xsl:text><xsl:value-of select="@name"/>
            <xsl:text> : </xsl:text>
            <xsl:call-template name="d1type">
                <xsl:with-param name="v" select="@type" />
            </xsl:call-template>
            <xsl:text>[</xsl:text>
            <xsl:choose>
                <xsl:when test="@minOccurs"><xsl:value-of select="@minOccurs"/></xsl:when>
                <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:text>..</xsl:text>
            <xsl:choose>
                <xsl:when test="@maxOccurs = 'unbounded'"><xsl:text>*</xsl:text></xsl:when>
                <xsl:when test="@maxOccurs != 'unbounded'"><xsl:value-of select="@maxOccurs"/></xsl:when>
                <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:text>]&#xa;</xsl:text>                                
        </xsl:for-each>
        <xsl:value-of select="$indent"/>
        <xsl:text>}&#xa;</xsl:text>

        <!-- Associations -->
        <xsl:for-each select="$snode/xs:complexContent/xs:extension/xs:sequence/xs:element[not(@type=preceding-sibling::xs:element/@type)]">
            <xsl:value-of select="$indent"/>
            <xsl:value-of select="$snode/@name" />
            <xsl:text> .. </xsl:text>
            <xsl:call-template name="d1type">
                <xsl:with-param name="v" select="@type" />
            </xsl:call-template>
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
        
        <!-- Inheritance -->
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="$snode/@name"/>
        <xsl:text disable-output-escaping="yes"> --|> </xsl:text>
        <xsl:call-template name="d1type">
            <xsl:with-param name="v" select="$snode/xs:complexContent/xs:extension/@base" />
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>


    <!-- Handle processing of simple types -->
    <xsl:template match="xs:simpleType" mode="plantuml">
        <xsl:param name="indent" select="'  '"/>
        <xsl:choose>
        <xsl:when test="count(xs:restriction/xs:enumeration) &gt; 0">
            <xsl:call-template name="render_enum">
                <xsl:with-param name="enode" select="." />
                <xsl:with-param name="indent" select="$indent" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="render_simple">
                <xsl:with-param name="snode" select="." />
                <xsl:with-param name="indent" select="$indent" />
            </xsl:call-template>
        </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>
    
    
    <!-- Handle processing of complex types -->
    <xsl:template match="xs:complexType" mode="plantuml">
        <xsl:param name="indent" select="'  '"/>
        <xsl:choose>
            <xsl:when test="xs:simpleContent">
                <xsl:call-template name="render_simplecontent">
                    <xsl:with-param name="snode" select="." />
                    <xsl:with-param name="indent" select="$indent" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="xs:sequence">
                <xsl:call-template name="render_complexseq">
                    <xsl:with-param name="snode" select="."/>
                    <xsl:with-param name="indent" select="$indent" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="xs:attribute">
                <xsl:call-template name="render_complexattrs_only">
                    <xsl:with-param name="snode" select="."/>
                    <xsl:with-param name="indent" select="$indent" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="xs:complexContent">
                <xsl:call-template name="render_complexContent">
                    <xsl:with-param name="snode" select="."/>
                    <xsl:with-param name="indent" select="$indent" />
                </xsl:call-template>                
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Generate an index to the document -->
    <xsl:template match="/" mode="index">
        <xsl:for-each select="//xs:simpleType | //xs:complexType">
            <xsl:sort select="@name" />
            <xsl:text>- :class:</xsl:text><xsl:value-of select="concat('`',$MODULE,@name,'`')"/><xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>



    <!-- Class descriptions -->
    <xsl:template match="/" mode="detail">
        <xsl:text>&#xa;.. include:: Types_include.txt&#xa;&#xa;</xsl:text>
        <xsl:for-each select="//xs:simpleType | //xs:complexType">
            <xsl:text>&#xa;..                                    ######&#xa;</xsl:text>
            <xsl:text>.. class:: </xsl:text><xsl:value-of select="@name"/><xsl:text>&#xa;&#xa;</xsl:text>
            <xsl:for-each select="xs:annotation/xs:documentation">
                <xsl:text>    </xsl:text>
                <xsl:value-of select="concat(normalize-space(.), '&#xA;')"/>
                <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
            
            <!-- attrs drawn from attributes and elements of complex types -->
            <xsl:for-each select="xs:sequence/xs:element | xs:attribute">
                <xsl:text>    .. attribute:: </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>&#xa;</xsl:text><xsl:text>&#xa;</xsl:text>
                <xsl:text>      Type: :class:`Types.</xsl:text>
                <xsl:call-template name="d1type">
                    <xsl:with-param name="v" select="@type" />
                </xsl:call-template>
                <xsl:text>`&#xa;</xsl:text>
                <xsl:text>&#xa;</xsl:text>
                <xsl:for-each select="xs:annotation/xs:documentation">
                    <xsl:text>      </xsl:text>
                    <xsl:value-of select="concat(normalize-space(.), '&#xA;')"/>
                    <xsl:text>&#xa;</xsl:text><xsl:text>&#xa;</xsl:text>
                </xsl:for-each>
            </xsl:for-each>
            
            <!-- Show the schema source -->
            <xsl:text>    .. code-block:: xml&#xa;&#xa;</xsl:text>
            <xsl:call-template name="xcopy">
                <xsl:with-param name="indent" select="'      '" />
            </xsl:call-template>
            <xsl:text>&#xa;</xsl:text>
            
            <!-- Render a UML fragment for the structure -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;    .. image:: images/class_</xsl:text><xsl:value-of select="@name"/><xsl:text>.png&#xa;&#xa;</xsl:text>
            <xsl:text>    ..&#xa;</xsl:text>
            <xsl:text>      @startuml images/class_</xsl:text><xsl:value-of select="@name"/><xsl:text>.png&#xa;&#xa;</xsl:text>
            <xsl:apply-templates select="." mode="plantuml">
                <xsl:with-param name="indent" select="'      '"></xsl:with-param>
            </xsl:apply-templates>
            <xsl:text>      @enduml&#xa;</xsl:text>
            
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="/">
        <xsl:text>..&#xa;</xsl:text>
        <xsl:text>   WARNING! This file is automatically generated. Edits will be lost.&#xa;&#xa;</xsl:text>
        <xsl:text>Data Types in CICore&#xa;</xsl:text>
        <xsl:text>--------------------&#xa;&#xa;</xsl:text>
        <xsl:text>.. module:: Types&#xa;</xsl:text>
        <xsl:text>   :synopsis: Catalog of data types (structures) used by the DataONE cicore.&#xa;&#xa;</xsl:text>
        <xsl:text>**Quick Reference**&#xa;&#xa;</xsl:text>
        <!-- Generate class index --> 
        <xsl:apply-templates select="/" mode="index"></xsl:apply-templates>

        <!-- Generate overall UML diagram -->
        <xsl:text>&#xa;.. image:: images/classes_combined.png&#xa;&#xa;</xsl:text>
        <xsl:text>&#xa;..&#xa;</xsl:text>
        <xsl:text>  @startuml images/classes_combined.png&#xa;</xsl:text>
        <xsl:apply-templates select="//xs:simpleType" mode="plantuml"></xsl:apply-templates>
        <xsl:apply-templates select="//xs:complexType" mode="plantuml"></xsl:apply-templates>
        <xsl:text>  @enduml&#xa;&#xa;&#xa;</xsl:text>
        
        <!-- detail for each class -->
        <xsl:apply-templates select="/" mode="detail"></xsl:apply-templates>
    </xsl:template>

</xsl:stylesheet>