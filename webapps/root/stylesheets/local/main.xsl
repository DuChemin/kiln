<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:import href="../defaults.xsl"/>
    
    <xsl:template match="/">
        <xsl:apply-imports/>
    </xsl:template>
    
    <xsl:template match="tei:teiHeader"/>
    
</xsl:stylesheet>
