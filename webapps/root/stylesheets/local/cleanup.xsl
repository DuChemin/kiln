<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://http://duchemin.haverford.edu/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs dc"
    version="2.0">
    
    <!-- Sibelius MusicXML export "cleanup" for DuChemin -->
    
    <xsl:template name="start">
        <xsl:apply-templates select="/" mode="cut"/>
    </xsl:template>
    
    <!-- Pass cut: Cleanup incipit; Preserve Cut C -->
    <xsl:variable name="cut">
        <xsl:call-template name="start"/>
    </xsl:variable>    
    <!-- Pass inc: Renumber all measures -->
    <xsl:variable name="inc">
        <xsl:apply-templates select="$cut" mode="inc"/>
    </xsl:variable>
    <!-- Pass mnum: Renumber all measures -->
    <xsl:variable name="mnum">
        <xsl:apply-templates select="$inc" mode="mnum"/>
    </xsl:variable>
    <!-- Pass rpt: Finds "middle of measure" repeats and sets the same numer for two measures -->
    <!--<xsl:variable name="rpt">
        <xsl:apply-templates select="$mnum" mode="rpt"/>
    </xsl:variable>-->
    <!-- Output -->
    <xsl:template match="/">
        <xsl:sequence select="$mnum"/>
    </xsl:template>
    
    <!-- Functions -->
    <xsl:function name="dc:is_rpt">
        <!-- 
             This function determines if the current measure is the second half
             of a "middle-of-measure" repeat sign
        -->
        <xsl:param name="m"/>
        <!-- does the preceding measure have a repeat sign? -->
        <xsl:choose>
            <xsl:when test="$m/preceding-sibling::measure[1]/descendant::repeat[@direction='backward']">
                <!-- get closest time signature -->
                <xsl:variable name="beats">
                    <xsl:choose>
                        <xsl:when test="$m/attributes/time">
                            <xsl:value-of select="$m/attributes/time/beats"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$m/preceding::measure[attributes/time][1]/attributes/time/beats"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="beat-type">
                    <xsl:choose>
                        <xsl:when test="$m/attributes/time">
                            <xsl:value-of select="$m/attributes/time/beat-type"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$m/preceding::measure[attributes/time][1]/attributes/time/beat-type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="divisions">
                    <xsl:choose>
                        <xsl:when test="$m/attributes/divisions">
                            <xsl:value-of select="$m/attributes/divisions"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$m/preceding::measure[attributes/divisions][1]/attributes/divisions"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <!-- Get total, assuming that $divisions always equals 1/4 (0.25) as it seems to be -->
                <xsl:variable name="mtot" select="($divisions * ($beats div $beat-type)) div 0.25"/>
                <!-- sum up event values in this measure. Do they add up correctly? -->
                <xsl:choose>
                    <xsl:when test="sum($m/descendant::*[duration]/duration) &lt; $mtot">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <!-- Is this a second volta? Is the previous measure 2/2? -->
                    <xsl:when test="$m/descendant::ending[@type=('discontinue','test') and @number='2']">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Templates for pass: cut -->
    <xsl:template match="*" mode="cut">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="cut"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()" mode="cut">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <!-- Preserve Cut C --> 
    <xsl:template match="time[@symbol='cut'] | measure[1][following-sibling::measure//time[@symbol='cut']]//time" mode="cut">
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
                        <xsl:apply-templates select="." mode="cut"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </time>
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
    
    <xsl:template match="measure[@number='1']" mode="inc">
        <xsl:variable name="part_id" select="ancestor::part[1]/@id"/>
        <xsl:choose>
            <xsl:when test="following::measure[@number='1'][ancestor::part[@id=$part_id]]"></xsl:when>
            <xsl:when test="preceding::measure[@number='1'][ancestor::part[@id=$part_id]]"></xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates mode="inc"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="inc"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Templates for pass: mnum, rpt -->
    <xsl:template match="*" mode="mnum">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mnum"/>
            <xsl:apply-templates mode="mnum"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()" mode="mnum">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <!-- Renumber measures -->
    <xsl:template match="@number[parent::measure]" mode="mnum">
        <xsl:variable name="part_id" select="ancestor::part[1]/@id"/>
        <xsl:attribute name="number">
            <xsl:choose>
                <xsl:when test="dc:is_rpt(parent::measure) = true()">
                    <xsl:value-of select="count(parent::measure/preceding::measure[ancestor::part[@id=$part_id]][dc:is_rpt(.) = false()])-1"/>
                    <xsl:text>a</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count(parent::measure/preceding::measure[ancestor::part[@id=$part_id]][dc:is_rpt(.) = false()])"/>
                </xsl:otherwise>
                </xsl:choose>
            <!--<xsl:value-of select="count(parent::measure/preceding::measure[ancestor::part[@id=$part_id]])"/>-->
        </xsl:attribute>
    </xsl:template>
    
    <!-- Templates for pass: rpt -->
   <!-- <xsl:template match="*" mode="rpt">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="rpt"/>
            <xsl:apply-templates mode="rpt"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|text()|comment()|processing-instruction()" mode="rpt">
        <xsl:sequence select="."/>
    </xsl:template>-->
    
    <!-- Renumber measures -->
    <!--<xsl:template match="@number[parent::measure/preceding-sibling::measure[1]/descendant::repeat[@direction='backward']]" mode="rpt">
        <xsl:attribute name="number">
            <xsl:value-of select="parent::measure/preceding-sibling::measure[1]/@number"/><xsl:text>a</xsl:text>
        </xsl:attribute>
    </xsl:template>-->
    
</xsl:stylesheet>