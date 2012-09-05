<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd m"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:meifn="http://www.music-encoding.org/ns/mei/fn" 
    xmlns:xmg="http://www.cch.kcl.ac.uk/xmod/global/1.0"
    version="2.0">
    <xsl:import href="displayMeasures.xsl"/>
    <xsl:import href="xml-to-string.xsl"/>
    
    <xsl:output encoding="UTF-8" method="text"/>
    
    <xsl:template match="/">
    <xsl:variable name="data">
        <div id="music">
            <span id="startm"><xsl:value-of select="$startm"/></span>
            <span id="cv"><canvas width="{$width + 50}" height="{$height + 50}" style="border: none"/></span> 
            <xsl:apply-templates select="//m:score" mode="meiNS"/>
        </div>
    </xsl:variable>

<xsl:text xml:space="preserve">
{
    'music': '</xsl:text><xsl:for-each select="$data"><xsl:call-template name="xml-to-string"/></xsl:for-each><xsl:text xml:space="preserve">',
    'dimensions': [</xsl:text><xsl:value-of select="$width"/>, <xsl:value-of select="$height"/><xsl:text>],
}
</xsl:text>
        
    </xsl:template>
    
    
    
</xsl:stylesheet>