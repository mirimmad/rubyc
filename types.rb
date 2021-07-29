
#types = [:P_VOID, :P_CHAR, :P_INT, :P_LONG, :P_VOIDPTR, :P_CHARPTR, :PINTPTR, :P_LONGPTR]

$psize = {:P_VOID => 0, :P_CHAR => 1, :P_INT => 4, :P_LONG => 8, :P_VOIDPTR => 8, :P_CHARPTR => 8, :P_INTPTR => 8, :P_LONGPTR => 8}


class Types

    def self.compatibleTypes(t1, t2, onlyright=false)
        if t1 == t2
            return :COMPATIBLE
        end

        leftsize = Types::primsize(t1)
        rightsize = Types::primsize(t2)

        if leftsize == 0 or rightsize == 0
            return :INCOMPATIBLE
        end

        if leftsize < rightsize
            return :WIDEN_LEFT
        end

        if rightsize < leftsize
            if onlyright
                return :INCOMPATIBLE
            end
            return :WIDEN_RIGHT
        end
        
        return :COMPATIBLE
    end

    def self.primsize(type)
        size = $psize[type]
        if size == nil
            Types::fatal("Bad type in primsize #{type}")
        end
        size
    end

    def self.pointerTo(type)
        pt = {:P_VOID => :P_VOIDPTR, :P_INT => :P_INTPTR, :P_CHAR => :P_CHARPTR, :P_LONG => :P_LONGPTR}
        
        return (if pt[type] != nil then pt[type] else Types::fatal("unknown type in pointer_to #{type}") end)
    end

    def self.valueAt(type)
        pt = {:P_VOIDPTR => :P_VOID, :P_INTPTR => :P_INT, :P_CHARPTR => :P_CHAR, :P_LONGPTR => :P_LONG}
        return (if pt[type] != nil then pt[type] else Types::fatal("unknown type in value_at") end)
    end

    def self.fatal(msg)
        puts "Types: #{msg}"
        exit(1)
    end
    

end



