$NSYMBOLS = 1024


class GlobalSymTab
    attr_reader :names
    def initialize
        @globs = 0
        @names = {}
    end

    def findglob(s)
        @names.each do |i, props|
            if props["name"] == s
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

    def addglob(name, type=nil, s_type=nil, endlabel=nil)
        if ((y = findglob(name)) != -1)
            return y
        end

        y = newglob
        @names[y] = {"name" => name, "type" => type, "s_type" => s_type, "endlabel" => endlabel}
        y
    end
end



