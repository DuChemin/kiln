<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd m"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:meifn="http://www.music-encoding.org/ns/mei/fn" 
    xmlns:xmg="http://www.cch.kcl.ac.uk/xmod/global/1.0"
    version="2.0">
    
    <xsl:import href="../defaults.xsl"/>
    <xsl:import href="id2ts.xsl"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 1, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> rviglianti</xd:p>
            <xd:p>Resolves mrpts into choice/orig/reg.</xd:p>
            <xd:p>Display measures using vexflow</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- IMPORTANT TODO: This needs to get the closest scoredef to the first measure requested, 
        otherwise it will always show tehe very first one. Example: DC0118.xml mm 28 - 34 should have
        3/1 not 4/2 -->
    
    
    <xsl:param name="startm" select="'1'"/>
    <xsl:param name="endm" select="'4'"/>
    
    <xsl:template name="getKey">
        <xsl:param name="sig"/>
        <xsl:variable name="fifths.keys" select="('C', 'G', 'D', 'A', 'E', 'B', 'F', 'D', 'A',
            'E', 'B', 'F')"/>
        <xsl:variable name="fifths.accid" select="('', '', '' ,'', '', '', 's', 'f', 'f',
            'f', 'f', '')"/>
        <xsl:choose>
            <xsl:when test="ends-with(normalize-space($sig), 's')">
                <meifn:key><xsl:value-of select="$fifths.keys[number(substring-before($sig, 's'))+1]"/></meifn:key>
                <meifn:accid><xsl:value-of select="$fifths.accid[number(substring-before($sig, 's'))+1]"/></meifn:accid>
            </xsl:when>
            <xsl:when test="ends-with(normalize-space($sig), 'f')">
                <meifn:key><xsl:value-of select="$fifths.keys[last() - (number(substring-before($sig, 'f'))-1)]"/></meifn:key>
                <meifn:accid><xsl:value-of select="$fifths.accid[last() - (number(substring-before($sig, 'f'))-1)]"/></meifn:accid>
            </xsl:when>
            <xsl:otherwise>
                <meifn:key>C</meifn:key>
                <meifn:accid/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="/">
        
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
        <xsl:variable name="height" select="max(//m:staff/@n)*100"/>
        <!--<xsl:message><xsl:value-of select="$height"/></xsl:message>-->
        
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head><title>Du Chemin Project - <xsl:value-of select="//m:filedesc/m:titlestmt/m:title"/></title>
                
                <link type="text/css" rel="stylesheet" href="{$xmg:context-path}{$xmg:assets-url}/styles/music.css"/>
                
                <script type="text/JavaScript" src="{$xmg:context-path}{$xmg:assets-url}/scripts/libs/jquery.min.js"></script>
                <script type="text/JavaScript" src="{$xmg:context-path}{$xmg:assets-url}/scripts/libs/vexflow-free.js"> </script>
                <script type="text/JavaScript" src="{$xmg:context-path}{$xmg:assets-url}/scripts/libs/meitovexflow.js"> </script>
            </head>
            <body>
                <div class="MEItoVexFlow">
                    <div id="labels">
                        <p id="firstspacer"> </p>
                        <xsl:for-each select="//m:scoredef//m:staffdef">
                            <p class="label"><xsl:value-of select="@label.full"/></p>
                            <p class="spacer"> </p>
                        </xsl:for-each>
                    </div>
                    <div id="music">
                        <span id="startm"><xsl:value-of select="$startm"/></span>
                        <span id="cv"><canvas width="{$width + 50}" height="{$height + 50}" style="border: none"/></span> 
                        <xsl:apply-templates select="//m:score" mode="meiNS"/>
                        
                        <script type="text/JavaScript">
                            <xsl:text>var MEI = $('#meiScore');var canvas = $("div#music canvas")[0];</xsl:text>
                            <xsl:text>render_notation(MEI, canvas,</xsl:text> 
                            <xsl:value-of select="$width"/>,<xsl:value-of select="$height"/>
                            <xsl:text>);</xsl:text>
                            
                            <!--<xsl:text>$(MEI).find('mei\\:staff[n="2"]').detach();</xsl:text> 
                            
                            <xsl:text>var context = canvas.getContext("2d");context.save();context.setTransform(1, 0, 0, 1, 0, 0);</xsl:text>
                            <xsl:text>context.clearRect(0, 0, canvas.width, canvas.height);context.restore();</xsl:text>
                            
                            <xsl:text>render_notation(MEI, canvas,</xsl:text>
                            <xsl:value-of select="$width"/>,<xsl:value-of select="$height"/>
                            <xsl:text>);</xsl:text>-->
                        </script>
                        
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="@*|node()[not(self::*)]" mode="meiNS">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="meiNS"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="meiNS">
        <xsl:element name="mei:{name()}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@*"/>
            <xsl:apply-templates mode="meiNS"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:score" mode="meiNS">
        <xsl:element name="mei:{name()}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@* except @xml:id"/>
            <xsl:attribute name="id">meiScore</xsl:attribute>
            <xsl:apply-templates mode="meiNS"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:score/m:scoredef" mode="meiNS">
        <!-- If there's a change in the section of the first measure, update the initial scoredef -->
        <xsl:choose>
            <xsl:when test="//m:measure[@n=$startm]/preceding::m:scoredef[parent::m:section][1]">
                <xsl:element name="mei:{name()}" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="@* except @xml:id"/>
                    <xsl:sequence select="//m:measure[@n=$startm]/preceding::m:scoredef[parent::m:section][1]/@*"/>
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="self::m:staffgrp">
                                <xsl:element name="mei:{name()}" namespace="http://www.music-encoding.org/ns/mei">
                                    <xsl:sequence select="@*"/>
                                    <xsl:for-each select="*">
                                        <xsl:choose>
                                            <xsl:when test="self::m:staffdef">
                                                <xsl:call-template name="staffdef">
                                                    <xsl:with-param name="change" select="true()"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates mode="meiNS" select="."/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </xsl:element>
                                
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates mode="meiNS" select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="mei:{name()}" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="@* except @xml:id"/>
                    <xsl:apply-templates mode="meiNS"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="m:section | m:ending" mode="meiNS">
        <xsl:choose>
            <xsl:when test="descendant::m:measure[@n=$startm or @n=$endm or (number(@n)&gt;number($startm) and number(@n)&lt;number($endm)) or (number(substring-before(@n, 'a'))&gt;number($startm) and number(substring-before(@n, 'a'))&lt;number($endm))]">
                <xsl:element name="mei:{name()}" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="@*"/>
                    <xsl:apply-templates mode="meiNS"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="m:staffdef" name="staffdef" mode="meiNS">
        <xsl:param name="change" select="false()"/>
        <!--<xsl:message><xsl:value-of select="$change"/></xsl:message>-->
        <xsl:element name="mei:{name()}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="ancestor::m:scoredef/@* except (@xml:id, @key.sig)"/>
            <xsl:sequence select="@* except @clef.shape"/>
            <xsl:if test="$change">
                <xsl:sequence select="//m:measure[@n=$startm]/preceding::m:scoredef[parent::m:section][1]/@*"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@clef.shape != 'C' or (@clef.shape='C' and @clef.line!='4')">
                    <xsl:sequence select="@clef.shape"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="clef.shape">F</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <!-- If key info is missing, determine closest major key --> 
            <xsl:if test="not(@key.pname)">
                <xsl:variable name="key">
                    <xsl:call-template name="getKey">
                        <xsl:with-param name="sig" select="@key.sig"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="key.pname">
                    <xsl:value-of select="$key/meifn:key"/>
                </xsl:attribute>
                <xsl:if test="$key/meifn:accid!=''">
                    <xsl:attribute name="key.accid">
                        <xsl:value-of select="$key/meifn:accid"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="meiNS"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:measure" mode="meiNS">
        <xsl:choose>
            <xsl:when test="@n=$startm or @n=$endm or (number(@n)&gt;number($startm) and number(@n)&lt;number($endm)) or (number(substring-before(@n, 'a'))&gt;number($startm) and number(substring-before(@n, 'a'))&lt;number($endm))">
                <xsl:element name="mei:{name()}" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="@*"/>
                    <xsl:apply-templates mode="meiNS"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!-- This template deals with several aspects within note -->
    <!-- only lyrics for now -->
    <xsl:template match="m:note" mode="meiNS">
        <xsl:element name="mei:note" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@*"/>
            <xsl:if test="not(descendant::m:syl) and preceding::m:note[ancestor::m:staff[@n=current()/ancestor::m:staff/@n]][descendant::m:syl][1]/descendant::m:syl[@wordpos='i' or @wordpos='m']">
                <xsl:element name="mei:syl" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="wordpos">m</xsl:attribute>
                    <xsl:attribute name="con">d</xsl:attribute>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates mode="meiNS"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:dir" mode="meiNS">
        <xsl:element name="mei:dir" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@*"/>
            <xsl:attribute name="startid">
                <xsl:choose>
                    <xsl:when test="@layer">
                        <xsl:value-of select="meifn:id2ts(ancestor::m:measure//m:staff[@n=current()/@staff]/m:layer[@n=current()/@layer], @tstamp)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="meifn:id2ts(ancestor::m:measure//m:staff[@n=current()/@staff]/m:layer[@n='1'], @tstamp)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates mode="meiNS"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:space" mode="meiNS">
        <!-- This should eventually be handled in MEItoVexFlow -->
    </xsl:template>
    
    <!-- SPECIFIC TO DUCHEMIN -->
    <!-- get very last note and make it longa -->
    <xsl:template match="m:note[not(following-sibling::m:note)][ancestor::m:measure[not(following::m:measure)]]" mode="meiNS" priority="1">
        <xsl:element name="mei:note" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:sequence select="@* except @dur"/>
            <xsl:attribute name="dur" select="'breve'"/>
            <xsl:if test="not(descendant::m:syl) and preceding::m:note[ancestor::m:staff[@n=current()/ancestor::m:staff/@n]][descendant::m:syl][1]/descendant::m:syl[@wordpos='i' or @wordpos='m']">
                <xsl:element name="mei:syl" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="wordpos">m</xsl:attribute>
                    <xsl:attribute name="con">d</xsl:attribute>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates mode="meiNS"/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>

