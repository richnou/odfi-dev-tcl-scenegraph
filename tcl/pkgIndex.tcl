

set dir [file dirname [file normalize [info script]]]



## Main scenegraph module
package ifneeded odfi::scenegraph       1.0.0 [list source [file join $dir scenegraph/scenegraph-1.0.0.tm]]

## SVG Output
package ifneeded odfi::scenegraph::svg  1.0.0 [list source [file join $dir svg/svg-1.0.0.tm]]
