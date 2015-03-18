#
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
package provide odfi::scenegraph 2.0.0
package require odfi::list 3.0.0
package require nx 2.0.0

package require odfi::flextree 1.0.0
package require odfi::flist 1.0.0

package require odfi::nx::domainmixin 1.0.0

namespace eval odfi::scenegraph {

    odfi::common::resetNamespaceClasses [namespace current]


    #####################################################
    ## Factories
    #####################################################

    ## \brief Creates a new Group.
    proc newGroup {name closure} {

        ## Create Group
        return [uplevel :[list ::new [namespace current]::Group $name $closure]]

    }

    #####################################################
    ## Layouting Stuff
    #####################################################
    array set supportedLayouts {}


    ## Represents Constraints for layouting
    odfi::nx::Class create  Constraints {

        ## The simple named parameters constraints
        :variable   parameters {}

        ## \brief Records some constraints provided in pList using "name value" pairs
        :public method addConstraints pList {

            foreach {name value} $pList {

                ## Overwrite if existing
                set index [lsearch -exact ${:parameters} $name]
                if {$index!=-1} {
                    set valueIndex [expr $index+1]
                    set :parameters [lreplace ${:parameters} $valueIndex $valueIndex $value]
                } else {

                    #puts "Adding constraints: /$name/ with value $value"
                    lappend :parameters $name
                    lappend :parameters $value
                }



            }
        }

        ## \brief Mergin the values of otherConstraints into those constraints
        ##        Already existing constraints are overwritten
        ## @param otherConstraints A list of constraints, or an object
        ## @return This object to allow stream interface
        :public method merge otherConstraints {

            if {[odfi::common::isClass $otherConstraints [namespace current]::Constraints]} {
                addConstraints [$otherConstraints cget -parameters]
            } else {
                addConstraints $otherConstraints
            }

            return [current object]

        }


        ## \brief Returns the named constraint as an int, or the provided #default parameter value
        :public method getInt {name {default 0}} {

            ## Search
            set res [lsearch -exact ${:parameters} $name]

            #puts "Searching constraint: $name, res: $res"

            ## Return default if nothing
            if {$res==-1} {
                return $default
            } else {
                set vname [lindex ${:parameters} [expr $res+1] ]
               # puts "Searching for variable: $vname"
                return [expr int([odfi::common::resolveVariable $vname ])]
            }

        }
        
        ## \brief Returns the named constraint as an int, or the provided #default parameter value
        :public method getFloat {name {default 0}} {
            
            ## Search
            set res [lsearch -exact ${:parameters} $name]
            
            #puts "Searching constraint: $name, res: $res"
            
            ## Return default if nothing
            if {$res==-1} {
                return $default
            } else {
                set vname [lindex ${:parameters} [expr $res+1] ]
                # puts "Searching for variable: $vname"
                return [expr double([odfi::common::resolveVariable $vname ])]
            }
            
        }        

        ## \brief Returns the named constraint as a "true"/"false" string, or the provided #default parameter value
        # The default value is false
        :public method getTrueFalse {name {default false}} {

            ## Search
            set res [lsearch -exact ${:parameters} $name]

            ## Return default if nothing
            if {$res==-1} {
                return $default
            } else {
                return [odfi::common::resolveVariable [lindex ${:parameters} [expr $res+1]]]
            }

        }
    }

    ## Describes a layout. Scripts provided in #newLayout will be added to such an object
    odfi::nx::Class create  Layout {

        :property -accessor public  id:required
        :property -accessor public  script:required

        ## The group variable will be filled when layouting is called, before evaluating script
        :variable   group

        ## This variable will be filled with constraints provided by user, or an empty set
        :variable -accessor protected  constraints

        :variable   emptyConstraints [Constraints new]

        :method init {} {
           # set id $cId
            #set script $cScript
            #set emptyConstraints [[namespace parent]::Constraints new]
        }

        ## \brief Layout the given set of objects using this layout script function. objects is copied to class objects variable
        # @return nothing, the layout function updates the nodes positions
        :public method layout {fgroup {cstr ""} } {

        
            set :group $fgroup
            eval ${:script}
            return            
        

            if {$cstr==""} {
                set :constraints ${:emptyConstraints}
            } else {

                ## Adapt constraints if necessary
                ##########

                #puts "PRovided constraints: $cstr"

                ## IF object is already a constraints set, keep like this, if not, create constraints set
                if {![odfi::common::isClass $cstr [namespace current]::Constraints]} {
                    #puts "Creating constraints object"

                    set :constraints [[namespace current]::Constraints new]
                    ${:constraints} addConstraints $cstr

                } else {
                    set :constraints $cstr
                }

            }
            set :group $fgroup
            eval ${:script}
            #odfi::closures::applyLambda ${:script}

        }

        ## Group The members node togetehr, and return a new Group object
#        :public method group {members {cstr ""}} {
#
#            ## Create group
#            set group [Group new ${members}]
#
#            ## Layout
#            :layout $group $cstr
#
#            ## Return
#            return $group
#        }


    }
    
    
    
    ## Describes a layout. Scripts provided in #newLayout will be added to such an object
    odfi::nx::Class create  Layout2 {
        
        :property -accessor public  id:required
        :property -accessor public  script:required
        :variable   emptyConstraints [Constraints new]
        
        :method init {} {
            # set id $cId
            #set script $cScript
            #set emptyConstraints [[namespace parent]::Constraints new]
        }
        
        ## \brief Layout the given set of objects using this layout script function. objects is copied to class objects variable
        # @return nothing, the layout function updates the nodes positions
        :public method layout {fgroup {cstr ""} } {
            
            
            #odfi::closures::applyLambda ${:script} [list group $fgroup]         
            
            #return                        
            
            ## Set constraints
            if {$cstr==""} {
                set constraints ${:emptyConstraints}
            } else {
                
                ## Adapt constraints if necessary
                ##########
                
                #puts "PRovided constraints: $cstr"
                
                ## IF object is already a constraints set, keep like this, if not, create constraints set
                if {![odfi::common::isClass $cstr [namespace current]::Constraints]} {
                    #puts "Creating constraints object"
                    
                    set constraints [[namespace current]::Constraints new]
                    $constraints     addConstraints $cstr
                    
                } else {
                    set constraints $cstr
                }
                
            }
            
            ## Call
            odfi::closures::applyLambda ${:script} [list group $fgroup] [list constraints $constraints]            
            
            if {$constraints!=${:emptyConstraints}} {
                $constraints destroy
            }
            
            return 
                        
            #set :group $fgroup
            #eval ${:script}
            #odfi::closures::applyLambda ${:script}
            
        }
        
       
        
    }    

    

    ## \brief Registers a new layout object und provided id, and given implementation script
    # @return the object representing the layout
    proc newLayout {id script} {

        ## Create Object and Register
        ##################
        set obj [Layout create ::layout.$id -id $id -script $script]

        #puts "Registered layout $obj under $id name"
        set [namespace current]::supportedLayouts($id) $obj

        return $obj

    }
    
    ## \brief Registers a new layout object und provided id, and given implementation script
    # @return the object representing the layout
    proc newLayout2 {id script} {
        
        ## Create Object and Register
        ##################
        set obj [Layout2 create ::layout.$id -id $id -script $script]
        
        #puts "Registered layout $obj under $id name"
        set [namespace current]::supportedLayouts($id) $obj
        
        return $obj
        
    }    


    proc newConstraints values {

        ## Create Constraints
        set constraints [namespace current]::[Constraints #auto]
        $constraints addConstraints $values

        return $constraints



    }




    #####################################################
    ## Scene Graph like interface for floorplaning
    #####################################################
    odfi::nx::Class create Node -superclass odfi::flextree::FlexNode {

        ## The parent node of this node
        #:variable -accessor public parent ""
        
        ## Name of a node 
        :property -accessor public {name ""}

        :variable -accessor public x 0
        :variable -accessor public y 0
        :variable -accessor public z 0

        ## The orientation of this node R0 R90 R180... encounter rotation placement
        :variable orientation R0

        ## \brief Executes the provided closure into this object
        #:public method apply closure {
        #    ::odfi::closures::run $closure
        #}

        ## Returns an ID string for this object
        :public method getId args {
            return ${:this}
        }


        ## \brief Set the parent of this node to the provided obj
        :public method setParent obj {
            [current object] detach
            :addParent $obj
        }

        ## \brief returns the parent object of this node. "" if not defined
        :public method getParent args {
            return [:parent]
        }

        ## \brief Invalidates the parent's size cache if there is a parent, and it is a group
        :public method invalidateParentSize args {
            if {[:parent]!="" && "[[:parent] info class]" == "[namespace parent]::Group"} {
                [:parent] invalidateSize
            }
        }

        ## \brief Changes the orientation of node to get a mirrored on X Axe
        :public method mirrorX args {

            if {${:orientation} == "R0" || ${:orientation} == "R180"} {
               set :orientation "MX"
            } elseif {${:orientation} == "MX"} {
                set :orientation "R90"
            } elseif {${:orientation} == "R90" || ${:orientation} == "R270"} {
                set :orientation "MY90"
            } elseif {${:orientation} == "MY90"} {
                set :orientation "R90"
            }

        }

        ## \brief Changes the orientation of node to get a mirrored on Y Axe
        :public method mirrorY args {

            if {${:orientation} == "R0" || ${:orientation} == "R180"} {
                set :orientation "MY"
            } elseif {${:orientation} == "MY"} {
                set :orientation "R0"
            } elseif {${:orientation} == "R90" || ${:orientation} == "R270"} {
                set :orientation "MX90"
            } elseif {${:orientation} == "MX90"} {
                set :orientation "R90"
            }

        }

        ## Accessors 
        ##########################

        ## \brief Return orientation
        :public method getOrientation args {
            return ${:orientation}
        }

        ## \brief Set orientation
        :public method setOrientation orient {
            set :orientation $orient
        }

        ## \brief return X position relative to parent
        :public method getX args {
            return ${:x}
        }

        ## \brief Set X position relative to parent
        :public method setX fX {
            #set :x [expr $fX < 0 ? 0 : $fX]
            set :x $fX
            :invalidateParentSize
        }
        
        :public method x args {
            if {[string is double $args]} {
                :setX $args
            }
            :getX
        }

        ## \brief return Y position relative to parent
        :public method getY args {
            return ${:y}
        }

        ## \brief Set Y position relative to parent
        :public method setY fY {
            #set :y [expr $fY < 0 ? 0 : $fY]
            set :y $fY
            :invalidateParentSize
        }
        
        :public method y args {
            if {[string is double $args]} {
                :setY $args
            }
            :getY
        }

        ## \brief return Y position relative to parent
        :public method getZ args {
            return ${:z}
        }

        ## \brief Set Y position relative to parent
        :public method setZ fz {
            #set :y [expr $fY < 0 ? 0 : $fY]
            set :z $fz
            :invalidateParentSize
        }
        
        :public method z args {
            if {[string is double $args]} {
                :setZ $args
            }
            :getZ
        }

        ## \brief Set position as: x y z 
        :public method position args {
            set argsLength [llength $args]
            if {$argsLength>0} { setX [lindex $args 0]; }
            if {$argsLength>1} { setY [lindex $args 1]; }
            if {$argsLength>2} { setZ [lindex $args 2]; }
           
        }

        ## \brief Increments the Y position by fy
        :public method up fy {
            :setY [expr [:getY] + $fy]

        }

        ## \brief Decrements the X position by x
        :public method down fy {
            :setY [expr [:getY] - $fy]

        }

        ## \brief Increments the X position by fx
        :public method right fx {
            :setX [expr [:getX] + $fx]

        }

        ## \brief Decrements the X position by fx
        :public method left fx {
            :setX [expr [:getX] - $fx]

        }

        ## \brief Increments the Z positin by dz 
        :public method higher dz {
            :setZ [expr [:getZ] + $dz]
        }

        ## \brief Decrements the Z positin by dz 
        :public method lower dz {
            :setZ [expr [:getZ] - $dz]
        }

        ## \brief Place at #fx from the most right position in parent group, wit
        # @warning Does nothing if no parent
        :public method fromRight fx {
            if {[:parent]==""} {
                return
            }
            #invalidateSize
            puts "From right with size: [getWidth]"
            setX [expr [[:parent] getWidth] - [getWidth] - $fx]
        }

        ## \brief Place at #fx from the most left position in parent group, equivalent to "right function"
        # @warning Does nothing if no parent
        :public method fromLeft fx {
            :right $fx
        }

        ## \brief Returns absolute X position
        :public method getAbsoluteX args {

            ## If no Parent, only return this position, otherwise, it is the parents absolute + our x
            if {[:parent]==""} {
                return [:getX]
            } else {
                return [expr [[:parent] getAbsoluteX]+[:getX]]
            }

        }

        ## \brief Returns absolute Y position
        :public method getAbsoluteY args {

            ## If no Parent, only return this position, otherwise, it is the parents absolute + our y
            if {[:parent]==""} {
                return [:getY]
            } else {
                return [expr [[:parent] getAbsoluteY]+[:getY]]
            }

        }

        ## \brief Returns absolute Z position
        :public method getAbsoluteZ args {

            ## If no Parent, only return this position, otherwise, it is the parents absolute + our y
            if {[:parent]==""} {
                return [:getZ]
            } else {
                return [expr [[:parent] getAbsoluteZ]+[:getZ]]
            }

        }

        ## \brief Returns absolute position list {x y z}
        :public method getAbsolutePosition args {

           return [list [:getAbsoluteX] [:getAbsoluteY] [:getAbsoluteZ]]

        }

        ## \brief Returns the actual Width, meaning that width/height are switched if the orientation defines a R90 R270 MX/Y90 orientation
        :public method getWidth args {

            if {${:orientation}=="R90" || ${:orientation}=="R270" || ${:orientation}=="MX90" || ${:orientation}=="MY90"} {
                return [:getR0Height]
            }
            return [:getR0Width]

        }

        ## \brief Returns the actual Height, meaning that width/height are switched if the orientation defines a R90 R270 MX/Y90 orientation
        :public method getHeight args {

            if {${:orientation}=="R90" || ${:orientation}=="R270" || ${:orientation}=="MX90" || ${:orientation}=="MY90"} {
                return [:getR0Width]
            }

            return [:getR0Height]
        }

        ## \brief Returns the actual Depth, Not support for orientation
        :public method getDepth args {

            return [:getR0Depth]
        }
        

        ## \brief Returns a list with {width,height,depth} for this node
        :public method getSize args {
            return [list [:getWidth] [:getHeight] [:getDepth]]
        }


        ## \brief Get the non oriented Width
        # @warning User must implement this
        :public method getR0Width args {
            error "getR0Width Undefined on object"
        }

        ## \brief Get the non oriented Height
        # @warning User must implement this
        :public method getR0Height args {
            error "getR0Height Undefined"
        }

        ## \brief Get the non oriented Height
        # @warning User must implement this
        :public method getR0Depth args {
            error "getR0Depth Undefined"
        }

    }

    ###################
    ## \brief Group in a SG tree
    ##################
    odfi::nx::Class create  Group -superclass Node {
       

        ## This is a list containing the member nodes of the group
        ##:property -accessor public  {members ""}

        ## The last layout used on this group. Used by relayout function
        :property -accessor public   {lastLayout      ""}
        :property -accessor public   {lastConstraints ""}

        ## \brief R0 Width cache
        :property -accessor public   {r0Width -1}

        ## \brief R0 Height cache
        :property -accessor public   {r0Height -1}

        ## \brief R0 Depth cache
        :property -accessor public   {r0Depth -1}
        :property -accessor public   {r0DepthLock false}

        :method init args {

            #set :members [odfi::flist::MutableList new]
            next
        }

        ## \brief Add obj to members list in last position, and set its parent to this group
        # If Some new objects are Tech macro, a hard macro is created
        # @return The added objects, for streaming interface
        :public method add obj {

            set obj [:prepareObjectsForAdd $obj]
            next
            #${:members} += $newMembers
            return $obj

        }

        ## \brief Add obj to members in first position
        # @return The added objects, for streaming interface
        :public method addFirst obj {
            set newMembers [:prepareObjectsForAdd $obj]
            :prepend $newMembers
            return $newMembers
        }

        ## \brief add A new Group to this group
        ## Creates the group using default type
        :public method addGroup {name closure} {

            ## Create
            set newGroup [[namespace current]::Group new]
            $newGroup apply $closure
            :add $newGroup
            
            ## add
            return $newGroup

        }

        ## \brief Prepares the obj objects list for adding, by instanciating HardMacros for Macros, and making names fully namespaced
        # @return the prepared list
        :protected method prepareObjectsForAdd obj {

            ::set res {}
            foreach o $obj {

                ## Remove from existing parent
                if {[$o getParent]!=""} {

                    #puts "Object $o had a parent [$o getParent], remove it"
                    [$o getParent] remove $o
                }

                ## Set parent
                $o setParent ::nsf::[:info name]
                lappend res $o
            }

            return $res

        }

        ## \brief Switches the two indexed members of group with each other
        :public method switch {first second} {

            ## Get Objects
            set firstMember [member $first]
            set secondMember [member $second]

            ## Replace
            set members [lreplace ${:members} $first $first $secondMember]
            set members [lreplace ${:members} $second $second $firstMember]
        }

        ## \brief Reverses the order of the members list.
        # @warning Doest not use lreverse because of TCL 8.4 compatibility
        :public method reverse args {

            set newMembers {}
            foreach m ${:members} {
                set newMembers [concat $m $newMembers]
            }
            set members $newMembers

        }

        ## \brief Remove Given Element
        #:public method remove obj {
        #    set objIndex [lsearch -exact ${:members} $obj]
        #    if {$objIndex!=-1} {
        #        set members [lreplace ${:members} $objIndex $objIndex]
        #    }
#
        #}

        ## \brief Remove all empty groups
        :public method removeEmptyGroups args {

            each {
                if {[odfi::common::isClass $it [namespace current]] && [$it size]==0} {
                    remove $it
                }
            }

        }

        ## \brief returns a copy of the internal members list
        :public method members args {
            return [:children]
        }

        ## \brief Returns the group member at specified index
        :public method member index {
            return [[:children] at $index]
        }

        ## \brief Search of a member having the given name in its object name
        #   If the name if hierarchical, separated by '/', then each component of the path defines a subgroup, making a sub tree search
        :public method memberByName hierName {

            set result ""

            #puts "Searching by name: $hierName"

            ## Split name and init search
            set nameComponents [split $hierName /]
            set groupsToSearch [list [list [current object] $nameComponents]]
            while {[llength $groupsToSearch]>0} {

                ## Take current Group to search
                set currentGroup [lindex [lindex $groupsToSearch 0] 0]
                set pathToSearch [lindex [lindex $groupsToSearch 0] 1]
                set groupsToSearch [lreplace $groupsToSearch 0 0]

                ## Take first path component
                set firstComponentPath [lindex $pathToSearch 0]

                #puts "---> Exploring $currentGroup for $firstComponentPath, with members ${:members}"

                ## - If path starts with "@", then it is an absolute index
                ## - Otherwise make a name search
                ####################
                if {[string match "@*" $firstComponentPath]} {

                    ## Get Member by index
                    set member [$currentGroup member [string range $firstComponentPath 1 end]]

                    ## Remainining path length == 1, end
                    ## Remainining path length > 1, continue on this member
                    if {[llength $pathToSearch]>1} {
                        lappend groupsToSearch [list $member [lrange $pathToSearch 1 end]]
                    } else {
                        set result $member
                        break
                    }

                } else {

                    ## Is  there a member with a name ending with the provided first path component ?
                    foreach member [[$currentGroup members] asTCLList] {

                        puts "-------->is $member [$member info class] matching ? *$firstComponentPath "                    
                        set match [string match "*$firstComponentPath" [$member name get]]

                        #

                        if {$match} {

                            ## Match:
                            ## Remainining path length == 1, end
                            ## Remainining path length > 1, continue on this member
                            if {[llength $pathToSearch]>1} {
                                lappend groupsToSearch [list $member [lrange $pathToSearch 1 end]]
                            } else {
                                set result $member
                                break
                            }

                        }

                    }
                    ## End of members search

                }

                if {$result!=""} {
                    break
                }

            }
            ## EOF Recursive loop

            if {$result==""} {
                odfi::common::logWarn "memberByName result empty for $hierName"
            }

            return $result


        }

        ##\brief Returns the number of members of this group
        :public method size args {
            return [:childCount]
        }

        ## \brief execute script closure on each element.
        # Available variable: $i for index, $it for actual element
        :public method each script {
            
      
            #${:members} foreach { it}
            set callerNS [uplevel 1 {namespace current}]

           #set membersCopy [:members]
            for {set i 0} {$i < [:size]} {incr i} {
                uplevel [list odfi::closures::applyLambda $script [list elt  [:member $i]] [list it  [:member $i]] [list i  $i]]
                #eval "uplevel 1 {" "set elt [${:members} at $i];" "set it [${:members} at $i];" "$script}"

            }
        }

        ## \brief execute script closure on each element starting at element with index #startIndex.
        # Available variable: $i for index, $it for actual element
        :public method eachFrom {startIndex script} {

            set callerNS [uplevel 1 {namespace current}]

            for {set i $startIndex} {$i < [:size]} {incr i} {
                uplevel [list odfi::closures::applyLambda $script [list elt  [:member $i]] [list it  [:member $i]] [list i  $i]]
            }

        }

        ## \brief Calls script once on each groups of #number of elements. an elts variable provides the group content, the i index provides the group index
        :public method eachInGroupsOf {number script} {

            set numberofGroups [expr ceil(double([size])/double($number))]
            set membersCopy [members]
            for {set i 0} {$i < $numberofGroups} {incr i} {

               # puts "eachInGroupsOf index $i of $numberofGroups (num: $number and size: [size])"

                ## Calculate range
                set first [expr $i*$number]
                set last  [expr ($first+($number-1))>=[llength ${:members}Copy]? [llength ${:members}Copy]-1 : $first+($number-1)]


                ## create group
                set elts [lrange ${:members}Copy $first $last]

                ## call script
                eval "uplevel 1 {" "set elts {$elts};" "$script}"
            }


        }

        

        ## \brief Works like regroup, with regroups all the members by grouping togeteher the provided #count number
        :public method regroupBy {count {layoutName ""} {cstr ""}} {

            eachInGroupsOf $count {

                regroup $elts $layoutName $cstr

            }


        }


        ## Takes the members of this group provided in the members list, group them in a new subgroup, then layout using layoutName
        # @param cstr Can be a constraints object, or a list or paired constraints, in which case an object will be build
        :public method regroup {gmembers {-layoutName ""} {-groupClass Group} {cstr ""}} {

            ## Get normal list from members if necessary
            if {[odfi::common::isClass $gmembers odfi::flist::MutableList]} {
                set gmembers [$gmembers toTCLList]
            }  
            

            ## Resolved list between real objects and string names
            set realMembers {}

            ## Remove group members that are specified in the new group
            ##############
            puts "Regrouping togeteher $gmembers"
            foreach gmember $gmembers {

                ## If element is not an object, try a byName search
                ###########
                if {[::odfi::common::isClass $gmember ::odfi::flextree::FlexNode]} {
                    lappend realMembers $gmember
                } else {

                    set found [:memberByName $gmember]
                    if {$found!=""} {
                        lappend realMembers $found
                    }

                }

                ## Find element and remove if found
                #set gmemberIndex [lsearch -exact ${:members} $gmember]
                #if {$gmemberIndex!=-1} {
                #    remove [lindex ${:members} $gmemberIndex]
                #}

            }


            ## Create Group
            #####################
            set newGroup [$groupClass new]
            foreach m $realMembers {
                $m detach
                $newGroup add $m
            }
            :add $newGroup
            #$newGroup setParent $this

            ## Layout
            ##############
            if {$layoutName!=""} {
                $newGroup layout $layoutName $cstr
            }

            return $newGroup


        }

        ## \brief Adds all gmembers to this group. Each group present in #gmembers will be removed, and their members merged into this group (first lelvel ungrouping)
        :public method merge {gmembers} {

            foreach gmember $gmembers {

                ## IF gmember is in the current group, remove it
                ########
                remove $gmember

                ## If Group, merge members into this group
                ##############
                if {[odfi::common::isClass $gmember [namespace current]]} {
                    add [$gmember members]
                } else {
                    add $gmember
                }


            }

        }

        ## \brief Merges all children of this group's subgroup's into this group
        :public method ungroupFirstLevel args {


            merge [members]

        }

        ## \brief Layouts the group given the provided layout Name
        :public method layout {layoutName {cstr ""}} {

            ## Get The Layout Object
           # set layoutObject $edid::prototyping::fp::supportedLayouts($layoutName)
           set layoutObject ::layout.$layoutName



            ## If group is empty -> don't do anything
            ############
            if {[:size]==0} {
                ::odfi::common::logWarn "Tried to layout [[current object] info class] with $layoutName, but group is empty, not doing anything"
                return
            }


            ## Layout
            if {$layoutObject!=""} {

                 ## Save last used layout
                set :lastLayout $layoutName

                $layoutObject layout [current object] $cstr

                 ## Save last used layout
                set :lastLayout $layoutName
                set :lastConstraints $cstr

                ## Update R0Width and R0Height
                :invalidateSize

            } else {
                ::odfi::common::logWarn "Tried to layoutusing $layoutName, which was not found"
                return
            }


        }

        ## \brief Layouts the group using the last used layout, and a new set of constraints
        ##  If layout has not been called once before, this does nothing
        :public method relayout {{cstr ""}} {

            ## Check
            if {$lastLayout==""} {
                return
            }

            ## Merge Constraints
            if {[llength $lastConstraints]>0} {
                set cstr [concat $lastConstraints $cstr]
            }

            ## We can re-layout
            :layout $lastLayout $cstr

        }

        ## \brief Invalidates Width/height cache to force recalculation
        :public method invalidateSize args {
            set :r0Width  -1
            set :r0Height -1
            if {!${:r0DepthLock}} {
                set :r0Depth -1
            }
            :invalidateParentSize
        }

        ## \brief Returns Width of the group, which is the most right member+width - most left member
        :public method getR0Width args {

            

            ## If Width already calculated, return
            if {${:r0Width}>=0} {
                return ${:r0Width}
            }
            
            ## IF empty -> 0
            if {[:size]==0} {
                return 0
            }

            set mostLeft [:member 0]
            set mostRight [:member 0]

            #puts "Most right: [$mostRight info class]"

            #::puts "[lrepeat [:getPrimaryTreeDepth] **] prepare start width"            
            ::set mlx 0
            ::set mrx 0

            #::puts "[lrepeat [:getPrimaryTreeDepth] **]  start width"
            :each {
                
                
                
                set actualX         [$it getX]                
                set actualEndX      [expr [$it getX]+[$it getWidth]]   
                
                
                #::puts "Element $actualX <-> $actualEndX  ($mlx <-> $mrx)"                              
                
                if {$actualEndX > $mrx} {
                        ::set mrx $actualEndX
                }
                if {$actualX < $mlx} {
                        ::set mlx $actualX
                }  
                
                                
                
                #::puts "---- ($mlx <-> $mrx)"
                                                    

#                set mostRightendX   [expr [$mostRight getX]+[$mostRight getWidth]]
#                set actualEndX      [expr [$it getX]+[$it getWidth]]
#
#                set mostLeftX       [$mostLeft getX]
#                set actualX         [$it getX]
#
#                ## If actual X+Width is > mostRight, this is the new mostRight
#                ## If actual X is < mostLeft, this is the new most left
#                if {  $actualEndX > $mostRightendX} {
#                    set mostRight $it
#                }
#                if {$actualX < $mostLeftX} {
#                    set mostLeft $it
#                }



            }
            #::puts "[lrepeat [:getPrimaryTreeDepth] **]  ** end width ($mlx <-> $mrx)"            
            
            set :r0Width [expr $mrx-$mlx]            
            return ${:r0Width}            

#            set mostRightendX   [expr [$mostRight getX]+[$mostRight getWidth]]
#            set mostLeftX       [$mostLeft getX]
#
#           # puts "End of R0 return, most right end X $mostRightendX"
#            set :r0Width [expr ([$mostRight getX]+[$mostRight getWidth])-([$mostLeft getX])]
#            return ${:r0Width}

        }

        ## \brief Returns Height of the group, which is the bottom most member+height - top most member
        :public method getR0Height args {

            ## If Height already calculated, return
            if {${:r0Height}>=0} {
                return ${:r0Height}
            }
            
            ## IF empty -> 0
            if {[:size]==0} {
                return 0
            }

            
        
            ::set mby 0
            ::set mty 0
            
  
            :each {
                  
                set actualY         [$it getY]                
                set actualEndY     [expr [$it getY]+[$it getHeight]]   
                                               
                
                if {$actualEndY > $mty} {
                    ::set mty $actualEndY
                }
                if {$actualY < $mby} {
                    ::set mby $actualY
                }  
       
               
            }

            set :r0Height [expr $mty-$mby]            
            return ${:r0Height}

        }

        ## \brief Returns Height of the group, which is the bottom most member+height - top most member
        :public method getR0Depth args {

            ## If Depth already calculated, return
            if {${:r0Depth}>=0} {
                return ${:r0Depth}
            }
            
            ## IF empty -> 0
            if {[:size]==0} {
                return 0
            }

            

            ::set mbz 0
            ::set mtz 0
            
            
            :each {
                
                set actualZ         [$it getZ]                
                set actualEndZ     [expr [$it getZ]+[$it getDepth]]   
                
                
                if {$actualEndZ > $mtz} {
                    ::set mtz $actualEndZ
                }
                if {$actualZ < $mbz} {
                    ::set mbz $actualZ
                }  
                
                
            }
            
            set :r0Depth [expr $mtz-$mbz]            
            return ${:r0Depth} 

        }
        
        
        ## Get/Set utilities
        ###################
        
        :public method width args {
            if {[string is double $args]} {
                
                set :r0Width $args
            }
            return ${:r0Width}
            
        }
        
        :public method height args {
            
            if {[string is double $args]} {
                            
                set :r0Height $args
            }
            return ${:r0Height}
          
        }
        
        :public method depth args {
            
            if {[string is double $args]} {
                set :r0DepthLock true           
                set :r0Depth $args
            }
            return ${:r0Depth}
           
        }
        

    }


   


    ## Source layout Functions
    ###################
    #source [file dirname [info script]]/layout-functions-1.0.0.tm


}

namespace eval odfi::scenegraph::utilities {

    ## Coordinates Utils 
    ################
    nx::Class create GroupCoordinatesTrait {

        ::odfi::scenegraph::Group mixins add GroupCoordinatesTrait
    
        ## Translate to origin: Find most negative X and Y elements. Translate them to 0
        :public method translateToOrigin args {

            ## X 
            ######################

            ## Search the most negative X
            set mostLeftX  0
            ${:members} foreach { m =>
       
                if { [$m getX] < $mostLeftX} {
                    set mostLeftX  [$m getX]
                }

            }

            # If Found a most left X, add -$mostLeftX to all 
            if {$mostLeftX<0} {
                ${:members} foreach { $it right [expr -$mostLeftX] }
            }

            ## Y
            #########################

            ## Search the most negative Y
            set mostDownY  0
            ${:members} foreach { m =>
       
                if { [$m getY] < $mostDownY} {
                    set mostDownY  [$m getY]
                }

            }

            # If Found a most down Y, add -$mostDownY to all 
            if {$mostDownY<0} {
                ${:members} foreach { $it up [expr -$mostDownY] }
            }

        }
    }

}
