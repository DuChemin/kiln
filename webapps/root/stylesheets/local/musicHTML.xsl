<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd m"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:meifn="http://www.music-encoding.org/ns/mei/fn" 
    xmlns:xmg="http://www.cch.kcl.ac.uk/xmod/global/1.0"
    version="2.0">
    <xsl:import href="displayMeasures.xsl"/>
    
    <xsl:template match="/">
        
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
                        </script>
                        
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>