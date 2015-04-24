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
package provide odfi::scenegraph::svg 2.0.0
package require odfi::scenegraph      2.0.0

namespace eval odfi::scenegraph::svg {

    namespace import -force ::odfi::nx::* 
    
    ## Languages
    ######################
    nx::Class create RectLanguage {

        #::odfi::scenegraph::svg::Group configure -mixins RectLanguage
        #Group configure -help
        #Group configure -mixins RectLanguage
        #Group mixins add RectLanguage

        ## Add a <rect ../> construct
        ###############
        :public method rect closure {


            ## Create Rect with closure
           set newRect [Rect new]
            :add $newRect
           $newRect apply $closure

            return $newRect 
        }

        #:public method addRect closure {


        #}

    }
    
    nx::Class create TextLanguage {
        
        
        ## Add a <text .../> construct
        :public method text {text {closure {}}} {
            
            ## Create Text with closure
            set newText [[namespace current]::Text new -text $text]
            
            
            ## Append
            :add $newText
            
            
            $newText apply $closure            
            
            
            return $newText
            
        }        
        
    }    

    nx::Class create SVGGroupBuilder {

        :public method group {name closure} {

            ## Create
            set newGroup [Group new]
            :add $newGroup
            ## Apply Closure
            #puts "NEw G: [Group info mixins classes] "
            #puts "NEw G: [Group info superclass] "
            $newGroup apply $closure



            return $newGroup

        }
    }

    nx::Class create SVGBuilder {

        :mixins add SVGGroupBuilder
        :mixins add RectLanguage
        :mixins add TextLanguage        

        :public method svg {name closure} {

            ## Create
            set newSvg [SVG new]
            :addChild $newSvg

            ## Apply Closure
            #puts "NEw G: [Group info mixins classes] "
            #puts "NEw G: [Group info superclass] "
            $newSvg apply $closure



            return $newSvg

        }

    }

    ########################
    ## SVG Group
    ########################
    proc group closure {

        ## Create
        set newGroup [Group new]

        ## Apply Closure
        puts "NEw G: [Group info mixins classes] "
        puts "NEw G: [Group info superclass] "
        $newGroup apply $closure

        return $newGroup
    }

    nx::Class create SVGNode -superclass odfi::scenegraph::Node {

    }

    nx::Class create Group -superclass odfi::scenegraph::Group -mixins SVGNode {

        :mixins add SVGBuilder

        #################
        ## Adders to add SVG elements in a convienient way
        ##################



        ## Add a <circle ../> construct
        ###############
        :public method addCircle closure {

            ## Create Rect with closure
            set newCircle [::new [namespace parent]::Circle #auto $closure]

            ## Append
            add $newCircle

            return $newCircle

        }

        



        ## To String : Output content of group members
        ##################
        :public method reduceProduce args {

            set out [odfi::common::newStringChannel]

            odfi::common::println "<g  x=\"[:getAbsoluteX]\"
            y=\"[:getAbsoluteY]\" >" $out

            odfi::common::printlnIndent

            odfi::common::println [join [join $args]] $out

            odfi::common::printlnOutdent
            odfi::common::println "</g>"  $out

            ## Read Result
            ###################
            flush $out
            set res [read $out]
            #close $out
            return $res
        }



        :public method toString out {



            ## Output
            #################
            odfi::common::println "<g  x=\"[:getAbsoluteX]\"
                y=\"[:getAbsoluteY]\" >" $out

            :each {
                $it toString $out
            }

            odfi::common::println "</g>" $out

        }



    }

    ########################
    ## SVG Base graphical Element
    ########################
    odfi::nx::Class create BaseGraphicalElement -superclass Group {

    
        
        
        ## Text Title
        :property -accessor public {title ""}


        ## Opacity
        :property -accessor public {opacity 1.0}

        ## Color
        #:var color "white"
        :property -accessor public {color "white"}
        

        ## Border ( Stroke)
        :property -accessor public {border "none"}

        ## Index
        :property -accessor public {z-index 0}


        ## \brief Get the non oriented Width
        :public method getR0Width args {

            ## Adapt to Group size, or use local size
            set groupSize [next]
            if {$groupSize < [:getSVGWidth]} {
                return [:getSVGWidth]
            } else {
                :setSVGWidth $groupSize
                return $groupSize
            }


        }

        ## \brief Get the non oriented Height
        :public method getR0Height args {

            ## Adapt to Group size, or use local size
            set groupSize [next]
            if {$groupSize < [:getSVGHeight]} {
                return [:getSVGHeight]
            } else {
                :setSVGHeight $groupSize
                return $groupSize
            }

        }


        :public method setSVGWidth args {
            :width  $args
        }


        :public method getSVGWidth args {
            return [:width]
        }
        :public method setSVGHeight args {
            :height $args
        }

        :public method getSVGHeight args {
           return [:height]
        }

        ## Aliases
        ########################

        :public method fill ncolor {
            :color $ncolor
        }
    }

    ########################
    ## SVG base Element
    ########################
    proc svg closure {
        set svg [SVG new]
        $svg apply $closure
        return $svg
    }
    
    proc svg2 args {
        
        ## Test input arguments
        ##############
        if {[llength $args]>1} {
            set vartarget [lindex $args 0]
            set closure [lindex $args 1]
        } elseif {[llength $args]==1} {
            set closure $args
        } else {
            error "svg format: svg name closure or svg closure"
        }
        
        ## Create SVG
        ###########
        set svg [SVG new]
        $svg apply $closure
           
        ## Set Var if necessary
        ################
        if {[info exists vartarget]} {
            uplevel set $vartarget $svg
        }
        ## Return
        ############
        return $svg
    }    
    

    ## Top SVG Factory method
    proc createSvg {varName keyword closure} {

        uplevel set $varName [svg $closure]

    }

    nx::Class create SVG -superclass Group {


        ## Width of graphic
        #odfi::common::classField protected width 0

        ## height of graphic
        #odfi::common::classField protected height 0


        :public method reduceProduce args {

            set out [odfi::common::newStringChannel]

            odfi::common::println "<?xml version=\"1.0\" ?>
            <svg width='[:getWidth]' height='[:getHeight]' xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\">" $out
            odfi::common::printlnIndent

            odfi::common::println [join [join $args]] $out

            odfi::common::printlnOutdent
            odfi::common::println "</svg>"  $out

            ## Read Result
            ###################
            flush $out
            set res [read $out]
            #close $out
            return $res
        }

        ## Produce the SVG as XML then String
        :public method toString args {

            ## XML
            ####################
            if {[llength $args]==1} {
                set out [lindex $args 0]
            } else {
                set out [odfi::common::newStringChannel]
            }

            odfi::common::println "<?xml version=\"1.0\" ?>
            <svg width='[:getWidth]' height='[:getHeight]' xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\">" $out
            odfi::common::printlnIndent

            :each {


                $it toString $out

            }


            odfi::common::printlnOutdent
            odfi::common::println "</svg>"  $out


            ## Read Result
            ###################
            flush $out
            set res [read $out]
            #close $out
            return $res


        }




    }

    ########################
    ## SVG Rect
    ########################
    nx::Class create Rect -superclass BaseGraphicalElement {

        ## Rounded Angle degrees. If 0, no rounded angles
        :property -accessor public {rounded 0}

        ## Depth for 3D operations. Not supported in standard SVG
        #:property -accessor public {depth 0}

        #:public method getR0Depth args {
        #    return [:depth]
        #}

        :public method reduceProduce args {


            set out [odfi::common::newStringChannel]


            ## Prepare Parameters
            ########################
            set fill "fill=\"[:color get]\""
            set border "stroke=\"[:border get]\""
            set rounded "rx=\"[:rounded get]\" ry=\"[:rounded get]\""

            ## Output
            #################
            odfi::common::println "<rect  x=\"[:getAbsoluteX]\"
                y=\"[:getAbsoluteY]\"
                width=\"[:getR0Width]\"
                height=\"[:getR0Height]\"
                opacity=\"[:opacity get]\"
                z-index=\"[:z-index get]\"
                $rounded
                $fill
                ${border}><title>[:title get]</title></rect>" $out

                

            odfi::common::println $out
            
            odfi::common::println [join $args]       $out     

            ## Read Result
            ###################
            flush $out
            set res [read $out]
            #itcl::delete object $out            
            close $out
            return $res

        }

        ## To String : Output content of group members
        :public method toString out {

            ## Prepare Parameters
            ########################
            set fill "fill=\"[:color]\""
            set border "stroke=\"[:border]\""
            set rounded "rx=\"[:rounded]\" ry=\"[:rounded]\""

            ## Output
            #################
            odfi::common::println "<rect  x=\"[:getAbsoluteX]\"
                y=\"[:getAbsoluteY]\"
                width=\"[:width]\"
                height=\"[:height]\"
                opacity=\"[:opacity]\"
                z-index=\"[:z-index]\"
                $rounded
                $fill
                ${border}><title>[:title]</title></rect>" $out

            ## Write Out Content
            #######################
            :each {
                $it toString $out
            }

        }

    }

    nx::Class create CircleLanguage {

        #Group configure -mixins {CircleLanguage RectLanguage}

        Group mixins add CircleLanguage

        #puts "[Group info superclass]"
    }

    ## Circle
    ##############
    proc circle closure {
        return [Circle apply $closure]
    }

    nx::Class create Circle -superclass BaseGraphicalElement {


        ## Rounded Angle degrees. If 0, no rounded angles
        :property -accessor public {radius 1}

        ## @return a new Circle created with provided closure
        :public object method apply closure {

            set c [Circle new]
            $c apply $closure
            return $c
        }


        ## To String : Output content of group members
        :public method toString out {



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


        :public method setSVGWidth args {
            :radius [expr $args/2]
        }

        :public method getSVGWidth args {
            return [expr [:radius]*2]
        }
        :public method setSVGHeight args {
            :radius [expr $args/2]
        }

        :public method getSVGHeight args {
           return [expr [:radius]*2]
        }



    }

    #package require Tk

    ###############
    ## SVG Text
    ###############
    nx::Class create Text -superclass BaseGraphicalElement {


        ## Text
        :property -accessor public text

        ## Font
        :property -accessor public {font-family  "Verdana"}
        :property -accessor public {font-size    "12"}

        :public method font-size args {
            if {$args==""} {
                return ${:font-size}
            } else {
                set :font-size $args
                :updateTextSize
            }

        }

        ## Text size

        :property -accessor public {textWidth   0}
        :property -accessor public {textHeight  0}

        :method init {} {

            ## Fix Text
            set :text [string map {< &lt;} ${:text}]

            :updateTextSize
            :color  set black
            :border set black
            
            next
        }


        :public method reduceProduce args {
            
            
            set out [odfi::common::newStringChannel]
            
            ## Output
            ################
            odfi::common::println "<text  x=\"[:getAbsoluteX]\"
            y=\"[:getAbsoluteY]\"
            width=\"[:width]\"
            height=\"[:height]\"
            opacity=\"[:opacity get]\"
            
            font-family=\"[:font-family get]\"
            font-size=\"[:font-size]\"
            
            dx=\"0\"
            dy=\"[expr [:height] - ([:height]-${:textHeight})/2]\"
            
            fill=\"[:color get]\"
            stroke=\"[:border get]\" 
            
            >${:text}</text>" $out            
            
         #[expr ([:width]-${:textWidth})/2]
            
            #odfi::common::println [join $args]       $out     
            
            ## Read Result
            ###################
            flush $out
            set res [read $out]
            #itcl::delete object $out            
            close $out
            return $res
            
        }        
        

        ## Updates size of element based on text
        :public method updateTextSize args {

            ## Try to Estimate the space required by the text under the provided font
            ###############
            set font [font create -family [:font-family get] -size [:font-size]]

            set :textWidth [font measure $font ${:text}]
            set :textHeight [expr [font metric $font -ascent] + [font metric $font -descent]]

            ## If base width/height is too small, adapt to text size
            if {[:width]<${:textWidth}} {
                :width ${:textWidth}
            }
            if {[:height]<${:textHeight}} {
                :height ${:textHeight}
            }


        }



        ## To String : Output content of group members
        :public method toString out {

            #puts "Text $text will take place: $textWidth x $textHeight"

            ## Output
            ################
            odfi::common::println "<text  x=\"[:getAbsoluteX]\"
                y=\"[:getAbsoluteY]\"
                width=\"[:width]\"
                height=\"[:height]\"
                opacity=\"[:opacity]\"

                font-family=\"[:font-family]\"
                font-size=\"[:font-size]\"

                dx=\"[expr ([width]-$textWidth)/2]\"
                dy=\"[expr $height - ([:height]-$textHeight)/2]\"

                fill=\"[:color]\"
                stroke=\"[:border]\"

                >[:text]</text>" $out

        }
    }

}
