Developer
=================


# SVG Implementation

The SVG implementation is located under tcl/svg/

## Class Hierarchy

(TODO: Create a picture here)

- scenegraph::Node
    - BaseGraphicalElement (common properties like title, opacity etc...)
        - svg::Rect
        - svg::Text
- scenegraph::Group
    - svg::Group
        - svg::SVG (top level)
    
    

## SVG Top level

To create an SVG structure, the user must start by creating an ``odfi::scenegraph::svg::SVG`` object

## Object creation methods

To add support for a new object type, the creator function must be located in the class that can support the new type as child.

For example, a text or rectangle element can be contained in a ``svg::Group``, so the ``text`` or ``rect`` creator functions are located in the ``svg::Group`` class


# Creating a custom implementation layer


# Creating a layout function

TBD
