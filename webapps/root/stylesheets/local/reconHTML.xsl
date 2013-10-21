<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd m"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:meifn="http://www.music-encoding.org/ns/mei/fn" 
    xmlns:xmg="http://www.cch.kcl.ac.uk/xmod/global/1.0"
    version="2.0">
    
    <xsl:param name="startm"/>
    <xsl:param name="endm"/>
    
    <xsl:variable name="width">
        <xsl:choose>
            <xsl:when test="1+(number($endm)-number($startm)) &lt; 4">
                <xsl:value-of select="1+(number($endm)-number($startm))*100 + 600"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="1+(number($endm)-number($startm))*300"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable> 
    <xsl:variable name="height" select="max(//m:staffDef/@n)*100"/>
    
    <xsl:template match="/">
        
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head><title>Du Chemin Project - <xsl:value-of select="//m:filedesc/m:titlestmt/m:title"/></title>
                
                <link type="text/css" rel="stylesheet" href="/assets/styles/music.css"/>
                <link type="text/css" rel="stylesheet" href="/assets/styles/bootstrap.min.css"/>
                
                <script type="text/JavaScript" src="/assets/scripts/libs/jquery.min.js"></script>
                <script type="text/JavaScript" src="/assets/scripts/libs/bootstrap.min.js"></script>
                <script type="text/JavaScript" src="/assets/scripts/libs/vexflow-min.js"> </script>
                <script type="text/JavaScript" src="/assets/scripts/libs/meitovexflow-min.js"> </script>
            </head>
            <body>
                <div class="well">Choose a reconstruction: 
                    <div class="btn-group" data-toggle="buttons" id="recons">
                        <xsl:for-each select="//m:analyst">
                            <label class="btn btn-primary">
                                <input type="radio" name="options" id="{.}"/> <xsl:value-of select="."/>
                            </label>
                        </xsl:for-each>
                    </div>
                </div>
                <div class="MEItoVexFlow row">
                    <div class="col-sm-1 well" id="labels">
                        <div class="well" style="border:none;"/>
                        <xsl:for-each select="//m:scoreDef//m:staffDef">
                            <xsl:variable name="analyst">
                                <xsl:choose>
                                    <xsl:when test="contains(lower-case(@label), 'reconstruction')">
                                        <xsl:value-of select="substring-before(substring-after(@label, '_'), '_')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>source</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="label">
                                <xsl:choose>
                                    <xsl:when test="contains(@label, '_')">
                                        <xsl:value-of select="substring-before(@label,'_')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@label"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="recon">
                                <xsl:choose>
                                    <xsl:when test="contains(lower-case(@label), 'reconstruction')">
                                        <xsl:text>recon</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <div class="well {$analyst} lab" style="border:none;"><xsl:value-of select="@label"/></div>
                        </xsl:for-each>
                    </div>
                    <div class="col-sm-11 well" id="music">
                        <span id="startm"><xsl:value-of select="$startm"/></span>
                        <span id="cv"><canvas width="{$width + 50}" height="{$height + 50}" style="border: none"/></span> 
                    </div>
                    <!--<div id="labels">
                        <p id="firstspacer"> </p>
                        <xsl:for-each select="//m:scoreDef//m:staffDef">
                            <xsl:variable name="label">
                                <xsl:choose>
                                    <xsl:when test="contains(@label, '_')">
                                        <xsl:value-of select="substring-before(@label,'_')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@label"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="recon">
                                <xsl:choose>
                                    <xsl:when test="contains(lower-case(@label), 'reconstruction')">
                                        <xsl:text>recon</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <p class="label {$recon} {$label}" id="{$label}"><xsl:value-of select="@label"/></p>
                            <p class="spacer {$label}"> </p>
                        </xsl:for-each>
                    </div>
                    <div id="music">
                        <span id="startm"><xsl:value-of select="$startm"/></span>
                        <span id="cv"><canvas width="{$width + 50}" height="{$height + 50}" style="border: none"/></span> 
                        <!-\-<xsl:sequence select="//m:score"/>-\->
                    </div>-->
                </div>
                
                <script type="text/JavaScript" src="/assets/scripts/recon.js"></script>
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>