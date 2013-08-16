## Implementation Layer to produce SVG using SceneGraph API
package provide odfi::scenegraph::svg 1.0.0
package require odfi::scenegraph      1.0.0

namespace eval odfi::scenegraph::svg {


    ########################
    ## SVG Group
    ########################
    itcl::class Group {
        inherit odfi::scenegraph::Group

        constructor closure {odfi::scenegraph::Group::constructor ""} {
            odfi::closures::doClosure $closure
        }

        #################
        ## Adders to add SVG elements in a convinient way
        ##################
        public method addRect closure {

            ## Create Rect with closure
            set newRect [::new [namespace parent]::Rect #auto $closure]

            ## Append
            add $newRect

        }

    }

    ########################
    ## SVG base Element
    ########################
    itcl::class SVG {
        inherit Group

        constructor closure {odfi::scenegraph::svg::Group::constructor ""} {
            odfi::closures::doClosure $closure
        }

    }




    ########################
    ## SVG Rect
    ########################
    itcl::class Rect {
        inherit odfi::scenegraph::Node

        ## Width of the rect
        protected variable width 0

        ## Height of the rect
        protected variable height 0


        odfi::common::classField protected color "white"


        constructor closure {

             ## Eval closure
             if {$closure!=""} {
                odfi::closures::doClosure $closure
             }

        }

        ## Getters/Setters
        #######################
        public method setWidth w {
            set width $w
        }

        public method setHeight h {
            set height $h
        }

        ## \brief Get the non oriented Width
        public method getR0Width args {
            return $width
        }

        ## \brief Get the non oriented Height
        public method getR0Height args {
            return $height
        }

    }


}
