Schematron validation
=====================

Kiln comes with pipelines and XSLT to perform `Schematron`_ validation
of XML files.

The base transformation is the ``validate/*/*/**.xml`` match in
``kiln/sitemaps/schematron.xmap``. The first parameter is the schema
filename (with no extension), expected to exist as
``assets/schematron/<schema>.sch``. The second parameter is the phase,
which is a named subset of rules within the schema. If all phases
should be run, use ``#ALL`` as the value. The third parameter is the
path to the XML file to be validated, relative to ``content/xml/``.

``sitemaps/private.xmap#local-schematron`` contains an example match
that is meant to automatically extract the schema from the project's
encoding guidelines embedded in an ODD file. This functionality is not
currently available.


.. _Schematron: http://www.schematron.com/
