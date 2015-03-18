

set dir [file dirname [file normalize [info script]]]



## Main scenegraph module
package ifneeded odfi::scenegraph       1.0.0 [list source [file join $dir scenegraph/scenegraph-1.0.0.tm]]

package ifneeded odfi::scenegraph               2.0.0 [list source [file join $dir scenegraph/scenegraph-2.0.tm]]
package ifneeded odfi::scenegraph::layouts      2.0.0 [list source [file join $dir scenegraph/layout-functions-2.0.tm]]

## SVG Output
package ifneeded odfi::scenegraph::svg  1.0.0 [list source [file join $dir svg/svg-1.0.0.tm]]
package ifneeded odfi::scenegraph::svg  2.0.0 [list source [file join $dir svg/svg-2.0.tm]]
