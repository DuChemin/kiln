<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd m"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:meifn="http://www.music-encoding.org/ns/mei/fn" 
    xmlns:xmg="http://www.cch.kcl.ac.uk/xmod/global/1.0"
    version="2.0">
    <xsl:import href="displayMeasures.xsl"/>
    
    <xsl:param name="analyst" select="'none'"/>
    
    <xsl:variable name="fullmei">
        <xsl:apply-templates select="//m:score" mode="meiNS"/>
    </xsl:variable>
    
    <xsl:variable name="reconStep">
        <xsl:apply-templates select="$fullmei" mode="recon"/>
    </xsl:variable>
    
    <xsl:variable name="renumber">
        <xsl:apply-templates select="$reconStep" mode="renumber"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:sequence select="$renumber"/>
    </xsl:template>
    
    <xsl:template match="@*|node()[not(self::*)]" mode="recon">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="recon"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="recon">
        <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@*"/>
            <xsl:apply-templates mode="recon"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:staffGrp[m:staffDef]" mode="recon">
        <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@*" />
            
            <analysts>
             <xsl:for-each-group select="m:staffDef[contains(lower-case(@label), 'reconstruction')]" group-by="substring-before(substring-after(@label, '_'), '_')">
                 <analyst><xsl:value-of select="current-grouping-key()"/></analyst>
             </xsl:for-each-group>
            </analysts>
            
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::m:staffDef">
                        <xsl:choose>
                            <xsl:when test="$analyst = 'none'">
                                <xsl:apply-templates select="." mode="recon"/>
                            </xsl:when>
                            <xsl:when test="contains(lower-case(@label), 'reconstruction') and substring-before(substring-after(@label, '_'), '_') = $analyst">
                                <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
                                    <xsl:sequence select="@* except @label"/>
                                    <xsl:attribute name="label" select="concat(substring-before(@label, '_'), ' (', substring-before(substring-after(@label, '_'), '_'), ')')"/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="contains(lower-case(@label), 'reconstruction') and substring-before(substring-after(@label, '_'), '_') != $analyst"/>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="recon"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="recon"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:staff" mode="recon">
        <xsl:choose>
            <xsl:when test="//m:staffDef[@n = current()/@n][contains(lower-case(@label), 'reconstruction') and substring-before(substring-after(@label, '_'), '_') != $analyst]"/>
            <xsl:otherwise>
                <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="@*" />
                    <xsl:apply-templates mode="recon"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="m:pb" mode="recon"></xsl:template>
    
    <xsl:template match="*[@staff]" mode="recon">
        <xsl:choose>
            <xsl:when test="//m:staffDef[@n = current()/@staff][contains(lower-case(@label), 'reconstruction') and substring-before(substring-after(@label, '_'), '_') != $analyst]"/>
            <xsl:otherwise>
                <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="@*" />
                    <xsl:apply-templates mode="recon"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*|node()[not(self::*)]" mode="renumber">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="renumber"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="renumber">
        <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@*"/>
            <xsl:apply-templates mode="renumber"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:staffDef" mode="renumber">
        <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@* except @n"/>
            <xsl:attribute name="n">
                <xsl:variable name="sd" select="generate-id(ancestor::m:scoreDef)"/>
                <xsl:value-of select="count(preceding::m:staffDef[ancestor::m:scoreDef[generate-id()=$sd]]) + 1"/>
            </xsl:attribute>
            <xsl:apply-templates mode="renumber"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:staff" mode="renumber">
        <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@* except @n"/>
            <xsl:attribute name="n">
                <xsl:variable name="sd" select="generate-id(ancestor::m:measure)"/>
                <xsl:value-of select="count(preceding::m:staff[ancestor::m:measure[generate-id()=$sd]]) + 1"/>
            </xsl:attribute>
            <xsl:apply-templates mode="renumber"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:measure//*[@staff]" mode="renumber">
        <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@* except @staff"/>
            <xsl:attribute name="staff">
                <xsl:variable name="sd" select="generate-id(ancestor::m:measure)"/>
                <xsl:value-of select="//m:staff[@n=current()/@staff][ancestor::m:measure[generate-id()=$sd]]/count(preceding::m:staff[ancestor::m:measure[generate-id()=$sd]]) + 1"/>
            </xsl:attribute>
            <xsl:apply-templates mode="renumber"/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>