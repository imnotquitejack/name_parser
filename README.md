Usage
================
The name parser should be capable of handling all kinds of formats,
with all kinds of titles and suffixes (including military, legal, and
otherwise). You can optionally give it the `messy_data: true` parameter
if the data is especially messy.

Fully Namespaced
----------------
    NameParser.parse('BETTY ANN HALDEMAN')
    NameParser.parse('Adams Jr., Mr. John Quincy', messy_data: true)

On a Text object
----------------
    'Jon Collier'.parse_name
    'Collier Jon'.parse_name(messy_data: true)
    'Collier, Jon'.parse_name
