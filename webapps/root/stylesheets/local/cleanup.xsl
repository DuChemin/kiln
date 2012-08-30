<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Sibelius MusicXML export "cleanup" for DuChemin -->
    
    <xsl:template name="start">
        <xsl:apply-templates select="/" mode="inc"/>
    </xsl:template>
    
    <!-- Pass inc: Cleanup incipit; Preserve Cut C -->
    <xsl:variable name="inc">
        <xsl:call-template name="start"/>
    </xsl:variable>    
    <!-- Pass mnum: Renumber all remaining measures (fixes duplicated measure numbers cause by middle-of-measure repeats) -->
    <xsl:variable name="mnum">
        <xsl:apply-templates select="$inc" mode="mnum"/>
    </xsl:variable>
    <!-- Output -->
    <xsl:template match="/">
        <xsl:sequence select="$mnum"/>
    </xsl:template>
    
    <!-- Templates for pass: inc -->
    <xsl:template match="*" mode="inc">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="inc"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()" mode="inc">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <!-- Preserve Cut C --> 
    <xsl:template match="time[@symbol='cut'] | measure[1][following-sibling::measure//time[@symbol='cut']]//time" mode="inc">
        <time>
            <xsl:sequence select="@*"/>
            <xsl:for-each select="*">
                <xsl:choose>
                    <xsl:when test="self::beats">
                        <beats>4</beats>
                    </xsl:when>
                    <xsl:when test="self::beat-type">
                        <beat-type>2</beat-type>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." mode="inc"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </time>
    </xsl:template>
    
    <!-- Templates for pass: mnum -->
    <xsl:template match="*" mode="mnum">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mnum"/>
            <xsl:apply-templates mode="mnum"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()" mode="mnum">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <!-- Renumber measures (for middle-of-measure repeats) -->
    <xsl:template match="@number[parent::measure]" mode="mnum">
        <xsl:variable name="part_id" select="ancestor::part[1]/@id"/>
        <xsl:attribute name="number">
            <xsl:value-of select="count(parent::measure/preceding::measure[ancestor::part[@id=$part_id]])"/>
        </xsl:attribute>
    </xsl:template>
    
</xsl:stylesheet>