#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Copyright (C) 2008 - 2014 Computer Architecture Group @ Uni. Heidelberg <http://ra.ziti.uni-heidelberg.de>
#    

##Implementation Layer to produce SVG using SceneGraph API
package provide odfi::scenegraph::svg 1.0.0
package require odfi::scenegraph      1.0.0

namespace eval odfi::scenegraph::svg {

    ########################
    ## SVG Group
    ########################
    proc group closure {

        set newGroup [::new [namespace current]::Group #auto $closure]

        return $newGroup
    }
    itcl::class Group {
        inherit odfi::scenegraph::Group

        constructor closure {odfi::scenegraph::Group::constructor ""} {
            odfi::closures::doClosure $closure
        }

        #################
        ## Adders to add SVG elements in a convienient way
        ##################

        ## Add a <rect ../> construct 
        ###############
        public method rect closure {
            addRect $closure
        }
        public method addRect closure {

            ## Create Rect with closure
            set newRect [::new [namespace parent]::Rect #auto $closure]

            ## Append
            add $newRect

        }

        ## Add a <circle ../> construct 
        ###############
        public method addCircle closure {

            ## Create Rect with closure
            set newCircle [::new [namespace parent]::Circle #auto $closure]

            ## Append
            add $newCircle

            return $newCircle

        }

        ## Add a <text .../> construct 
        public method text {text {closure {}}} {

             ## Create Text with closure
            set newText [::new [namespace parent]::Text #auto $text $closure]

            ## Append
            add $newText

             

            return $newText

        }

        ## Add a g group 
        public method group closure {

            set newGroup [::new [namespace parent]::Group #auto $closure]

            add $newGroup

            return $newGroup
        }
  


        ## To String : Output content of group members
        ##################
        public method toString out {

         

            ## Output
            #################
            odfi::common::println "<g  x=\"[getAbsoluteX]\"
                y=\"[getAbsoluteY]\" >" $out

            each {
                $it toString $out
            }

            odfi::common::println "</g>" $out

        }

    

    }

    ########################
    ## SVG Base graphical Element
    ########################
    itcl::class BaseGraphicalElement {
        inherit Group

        ## Text Title
        odfi::common::classField public title ""


        ## Opacity
        odfi::common::classField protected opacity 1.0

        ## Color 
        odfi::common::classField protected color "white"

        ## Border ( Stroke)
        odfi::common::classField protected border "black"


        ## Width 
        odfi::common::classField protected width 0

        ## Height
        odfi::common::classField protected height 0


        ## \brief Get the non oriented Width
        public method getR0Width args {

            ## Adapt to Group size, or use local size 
            set groupSize [odfi::scenegraph::Group::getR0Width]
            if {$groupSize < [getSVGWidth]} {
                return [getSVGWidth]
            } else {
                setSVGWidth $groupSize
                return $groupSize
            }

            
        }

        ## \brief Get the non oriented Height
        public method getR0Height args {

            ## Adapt to Group size, or use local size 
            set groupSize [odfi::scenegraph::Group::getR0Height]
            if {$groupSize < [getSVGHeight]} {
                return [getSVGHeight]
            } else {
                setSVGHeight $groupSize
                return $groupSize
            }

        }

        
        public method setSVGWidth args {
            width $args
        }

 
        public method getSVGWidth args {
            return [width]
        }
        public method setSVGHeight args {
            height $args
        }

        public method getSVGHeight args {
           return [height]
        }

        ## Aliases 
        ########################

        public method fill ncolor {
            color $ncolor
        }
    }

    

    ########################
    ## SVG base Element
    ########################
    proc svg closure {
        return [::new [namespace current]::SVG #auto $closure]
    }

    ## Top SVG Factory method
    proc createSvg {varName keyword closure} {

        uplevel set $varName [::new [namespace current]::SVG #auto $closure]
        
    }

    itcl::class SVG {
        inherit Group

        ## Width of graphic
        #odfi::common::classField protected width 0

        ## height of graphic
        #odfi::common::classField protected height 0

        

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


        constructor closure  {odfi::scenegraph::svg::Group::constructor ""}  {

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

    ## Circle
    ##############
    proc circle closure {
        return [::new [namespace current]::Circle #auto $closure]
    }
    itcl::class Circle {
        inherit BaseGraphicalElement
        

        ## Rounded Angle degrees. If 0, no rounded angles
        odfi::common::classField protected radius 1


        constructor closure   {odfi::scenegraph::svg::Group::constructor ""} {

            ## Eval closure
            odfi::closures::doClosure $closure
    

        }


        ## To String : Output content of group members
        public method toString out {



            ## Prepare Parameters
            ########################
            set fill "fill=\"$color\""
            set border "stroke=\"$border\""

            ## Output
            #################
            odfi::common::println "<circle 
                cy=\"[expr [getAbsoluteY]+[radius]]\"
                cx=\"[expr [getAbsoluteX]+[radius]]\"
                r=\"[radius]\"
                opacity=\"[opacity]\"
                $fill
                ${border}><title>[title]</title></circle>" $out

            each {

                $it toString $out

            }

        }


        public method setSVGWidth args {
            radius [expr $args/2]
        }

        public method getSVGWidth args {
            return [expr [radius]*2]
        }
        public method setSVGHeight args {
            radius [expr $args/2]
        }

        public method getSVGHeight args {
           return [expr [radius]*2]
        }

        

    }

    package require Tk
    

    ###############
    ## SVG Text 
    ###############
    itcl::class Text {
        inherit BaseGraphicalElement

        ## Text 
        odfi::common::classField public text ""

        ## Font
        odfi::common::classField public font-family  "Verdana"
        public variable font-size    "12"

        public method font-size args {
            if {$args==""} {
                return ${font-size}
            } else {
                set {font-size} $args
                updateTextSize
            }
            
        }

        ## Text size 
        odfi::common::classField public textWidth   0
        odfi::common::classField public textHeight  0

        constructor {cText closure}  {odfi::scenegraph::svg::Group::constructor ""} {

            ## Init 
            ############

            ## Fix Text 
            set cText [string map {< &lt;} $cText]

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
