#!/usr/bin/env tclsh


##################################
## Unit Tests for SVG Scenegraph API
#####################################

package require odfi::scenegraph::svg 1.0.0


odfi::tests::test "4 Squares in grid" {


    ####################################################################
    ## Test 1: Simple SVG with rectangles
    ####################################################################

    ::new odfi::scenegraph::svg::SVG "::svg" {


        ## Add 4 rectangles
        ##########
        ::repeat 4 {

            addRect {

                setWidth  20
                setHeight 20
                color "red"

            }

        }

        ## Make a flow grid over two lines
        layout "flowGrid" {
            columns 2
        }
    }

    ## Check Results
    #############

    expectMap {

        @.llength(::svg.members) 4
        @::svg.member(0).getX 0
        #::svg.member(0).getY 0

        #::svg.member(1).getX 20
        #::svg.member(1).getY 0

        #::svg.member(2).getX 0
        #::svg.member(2).getY 20

        #::svg.member(3).getX 20
        #::svg.member(3).getY 20

    }





}


