## Implementation Layer to produce SVG using SceneGraph API
package provide odfi::scenegraph::svg 1.0.0
package require odfi::scenegraph      1.0.0

namespace eval odfi::scenegraph::svg {

    ########################
    ## SVG Base graphical Element
    ########################
    itcl::class BaseGraphicalElement {
        inherit odfi::scenegraph::Node

        ## Text Title
        public variable title ""
        odfi::common::classField public title "" -noDeclaration


        ## Opacity
        public variable opacity 1.0
        odfi::common::classField protected opacity 1.0 -noDeclaration

        ## Color 
        public variable color "white"
        odfi::common::classField protected color "white" -noDeclaration

        ## Border ( Stroke)
        public variable border "black"
        odfi::common::classField protected border "black" -noDeclaration


        ## Width 
        public variable width 0
        odfi::common::classField protected width 0 -noDeclaration

        ## Height
        public variable height 0
        odfi::common::classField protected height 0 -noDeclaration


        ## \brief Get the non oriented Width
        public method getR0Width args {
            return $width
        }

        ## \brief Get the non oriented Height
        public method getR0Height args {
            return $height
        }
    }

    ########################
    ## SVG Group
    ########################
    itcl::class Group {
        inherit odfi::scenegraph::Group

        constructor closure {odfi::scenegraph::Group::constructor ""} {
            odfi::closures::doClosure $closure
        }

        #################
        ## Adders to add SVG elements in a convienient way
        ##################

        ## rect 
        ###############
        public method addRect closure {

            ## Create Rect with closure
            set newRect [::new [namespace parent]::Rect #auto $closure]

            ## Append
            add $newRect

        }

        ## text 
        public method text {text {closure {}}} {

             ## Create Text with closure
            set newText [::new [namespace parent]::Text #auto $text $closure]

            ## Append
            add $newText

        }


  

    

    }

    ########################
    ## SVG base Element
    ########################
    itcl::class SVG {
        inherit Group

        ## Width of graphic
        odfi::common::classField protected width 0

        ## height of graphic
        odfi::common::classField protected height 0

        

        constructor closure {odfi::scenegraph::svg::Group::constructor ""} {

            odfi::closures::doClosure $closure

        }


        ## Produce the SVG as XML then String
        public method toString args {

            ## XML
            ####################
            set out [odfi::common::newStringChannel]
            odfi::common::println "<?xml version=\"1.0\" ?>
            <svg width='[getWidth]' height='[getHeight]' xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\">" $out
            odfi::common::printlnIndent
            
            each {

                $it toString $out

            }


            odfi::common::printlnOutdent
            odfi::common::println "</svg>"  $out


            ## Read Result
            ###################
            flush $out
            set res [read $out]
            close $out
            return $res


        }


    }




    ########################
    ## SVG Rect
    ########################
    itcl::class Rect {
        inherit BaseGraphicalElement
        

        ## Rounded Angle degrees. If 0, no rounded angles
        odfi::common::classField protected rounded 0


        constructor closure  {

            ## Eval closure
            odfi::closures::doClosure $closure
    

        }


        ## To String : Output content of group members
        public method toString out {

            ## Prepare Parameters
            ########################
            set fill "fill=\"$color\""
            set border "stroke=\"$border\""
            set rounded "rx=\"$rounded\" ry=\"$rounded\""

            ## Output
            #################
            odfi::common::println "<rect  x=\"[getAbsoluteX]\"
                y=\"[getAbsoluteY]\"
                width=\"[width]\"
                height=\"$height\"
                opacity=\"[opacity]\"
                $rounded
                $fill
                ${border}><title>[title]</title></rect>" $out

        }

    }

    package require Tk
    

    ###############
    ## SVG Text 
    ###############
    itcl::class Text {
        inherit BaseGraphicalElement

        ## Text 
        odfi::common::classField protected text ""

        ## Font
        odfi::common::classField protected font-family  "Verdana"
        odfi::common::classField protected font-size    "12"

        ## Text size 
        odfi::common::classField protected textWidth   0
        odfi::common::classField protected textHeight  0

        constructor {cText closure} {

            ## Init 
            ############
            text   $cText 
            updateTextSize
            color  black
            border black

            ## Eval closure
            odfi::closures::doClosure $closure
        }

        ## Updates size of element based on text
        public method updateTextSize args {

            ## Try to Estimate the space required by the text under the provided font 
            ###############
            set font [font create -family [font-family] -size [font-size]]

            set textWidth [font measure $font [text]]
            set textHeight [expr [font metric $font -ascent] + [font metric $font -descent]]

            ## If base width/height is too small, adapt to text size
            if {[width]<$textWidth} {
                width $textWidth
            }
            if {[height]<$textHeight} {
                height $textHeight
            }


        }

        ## To String : Output content of group members
        public method toString out {       
          
            #puts "Text $text will take place: $textWidth x $textHeight"

            ## Output 
            ################
            odfi::common::println "<text  x=\"[getAbsoluteX]\"
                y=\"[getAbsoluteY]\"
                width=\"[width]\"
                height=\"[height]\"
                opacity=\"[opacity]\"

                font-family=\"[font-family]\"
                font-size=\"[font-size]\"
                
                dx=\"[expr ([width]-$textWidth)/2]\"
                dy=\"[expr $height - ([height]-$textHeight)/2]\"

                fill=\"[color]\"
                stroke=\"[border]\"

                >[text]</text>" $out

        }
    }


}
