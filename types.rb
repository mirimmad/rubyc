
$psize = {:P_VOID => 0, :P_CHAR => 1, :P_INT => 4, :P_LONG => 8}


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
            puts "Bad type in primsize"
            exit(1)
        end
        size
    end


end

