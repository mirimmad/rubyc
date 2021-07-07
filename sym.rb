$NSYMBOLS = 1024


class GlobalSymTab
    def initialize
        @globs = 0
        @names = {}
    end

    def findglob(s)
        @names.each do |i, name|
            if name == s
                return i
            end
        end
        return -1
    end

    def newglob
        if (p = (@globs += 1)) > $NSYMBOLS
            puts "too many globals"
            exit(1)
        end
        p 
    end

    def addglob(s)
        if ((y = findglob(s)) != -1)
            return y
        end

        y = newglob
        @names[y] = s
        y
    end
end



