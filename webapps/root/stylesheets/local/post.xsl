<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    version="2.0">
   
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[normalize-space(.)='&#xE501;' or normalize-space(.)='&#xE502;']"/>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="m:layer[descendant::text()[.='&#xE501;']]">
        <layer xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@*"/>
            
            <xsl:for-each-group select="node()" group-starting-with="text()[normalize-space(.)='&#xE501;']">
                <xsl:choose>
                    <xsl:when test="current-group()[descendant-or-self::text()[normalize-space(.)='&#xE501;']]">
                        <beam xmlns="http://www.music-encoding.org/ns/mei">
                            <xsl:for-each select="current-group()">
                                <xsl:if test="following-sibling::text()[normalize-space(.)='&#xE502;']">
                                    <xsl:apply-templates select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </beam>
                        <xsl:for-each select="current-group()">
                            <xsl:if test="preceding-sibling::text()[normalize-space(.)='&#xE502;']">
                                <xsl:apply-templates select="."/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </layer>
    </xsl:template>
   
</xsl:stylesheet>
