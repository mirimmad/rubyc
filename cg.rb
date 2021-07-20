

class Cg
  def initialize(output)
    @output = output
    @freereg = Array.new(4).fill(0)
    @reglist = ["%r8","%r9", "%r10", "%r11"].freeze
    @breglist = ["%r8b","%r9b", "%r10b", "%r11b"].freeze
  end

  def allocate_register
    r = nil
    for i in 0..3
      if @freereg[i] == 1
        r = i
        @freereg[i] = 0
        break
      end
    end
    r

  end

  def free_register(reg)
    if @freereg[reg] != 0
      puts "Error trying to free register #{reg}"
      exit(1)
    end
    @freereg[reg] = 1
  end

  def freeall_registers
    @freereg.fill(1)
  end


  def cgpreamble
    freeall_registers
    code = "\t.text\n"
    code += ".LC0:\n"
    code += "\t.string\t\"%d\\n\"\n"
    code += "printint:\n"
    code += "\tpushq\t%rbp\n"
	  code += "\tmovq\t%rsp, %rbp\n"
	  code += "\tsubq\t$16, %rsp\n"
	  code += "\tmovl\t%edi, -4(%rbp)\n"
	  code += "\tmovl\t-4(%rbp), %eax\n"
	  code += "\tmovl\t%eax, %esi\n"
	  code += "\tleaq	.LC0(%rip), %rdi\n"
	  code += "\tmovl	$0, %eax\n"
	  code += "\tcall	printf@PLT\n"
    code += "\tnop\n"
    code += "\tleave\n"
    code += "\tret\n"
    @output.puts code
  end
  
  def cgfuncpreamble(name)
    code = "\t.text\n"
    code += "\t.globl\t#{name}\n"
    code += "\t.type\t#{name}, @function\n"
    code += "#{name}:\n"
    code += "\tpushq\t%rbp\n"
    code += "\tmovq\t%rsp, %rbp\n"
    @output.puts code
  end

  def cgfuncpostamble
    code = "\tmovl\t$0, %eax\n"
    code += "\tpopq\t%rbp\n"
    code += "\tret\n"
    @output.puts code
  end

  def cgpostamble
    code = "\tmovl\t$0, %eax\n"
    code += "\tpopq\t%rbp\n"
    code += "\tret\n"
    @output.puts code
  end

  def cgload(val)
    r = allocate_register
    code = "\tmovq\t$#{val}, #{@reglist[r]}\n"
    @output.puts code
    r
  end

  def cgadd(r1, r2)
    code = "\taddq\t#{@reglist[r1]}, #{@reglist[r2]}\n"
    @output.puts code
    free_register(r1)
    r2
  end

  def cgsub(r1, r2)
    code = "\tsubq\t#{@reglist[r2]}, #{@reglist[r1]}\n"
    @output.puts code
    free_register(r2)
    r1
  end

  def cgmul(r1, r2)
    code = "\timulq\t#{@reglist[r1]}, #{@reglist[r2]}\n"
    @output.puts code
    free_register(r1)
    r2
  end

  def cgdiv(r1, r2)
    code = "\tmovq\t#{@reglist[r1]}, %rax\n"
    code += "\tcqo\n"
    code += "\tidivq\t#{@reglist[r2]}\n"
    code += "\tmovq\t%rax, #{@reglist[r1]}\n"
    @output.puts code
    free_register(r2)
    r1
  end

  def cgprintint(r)
    code = "\tmovq\t#{@reglist[r]}, %rdi\n"
    code += "\tcall\tprintint\n"
    @output.puts code
    free_register(r)
  end

  def cgloadglob(identifier, type)
    r = allocate_register()
    case type
    when :P_INT
      code =  "\tmovq\t#{identifier}(%rip), #{@reglist[r]}\n"
    else
      code = "\tmovzbq\t#{identifier}(%rip), #{@reglist[r]}\n" 
    end
    @output.puts code
    r
  end

  def cgstoreglob(r, identifier, type)
    case type
    when :P_INT
      code = "\tmovq\t#{@reglist[r]}, #{identifier}(%rip)\n"
    else
      code = "\tmovb\t#{@breglist[r]}, #{identifier}(%rip)\n"
    end
    @output.puts code
    r
  end

  def cgglobsym(sym, type)
    case type
    when :P_INT
      code = "\t.comm\t#{sym},8,8\n"
    when :P_CHAR
      code = "\t.comm\t#{sym},1,1\n"
    end
    @output.puts code
  end

  def cgcompare_and_set(op, r1, r2)
    if not [:EQ_EQ, :NE, :LT, :LE, :GT, :GE].include? op
      fatal("bad comparision op")
    end
    cmplist = {:EQ_EQ => "sete", :NE => "setne", :LT => "setl", :GT => "setg", :LE => "setle", :GE => "setge"}
    code = "\tcmpq\t#{@reglist[r2]}, #{@reglist[r1]}\n"
    code += "\t#{cmplist[op]}\t#{@breglist[r2]}\n"
    code += "\tmovzbq\t#{@breglist[r2]}, #{@reglist[r2]}"
    @output.puts code
    free_register(r1)
    r2
  end

  def cglabel(l)
    @output.puts "L#{l}:\n"
  end

  def cgjmp(l)
    @output.puts "\tjmp\tL#{l}\n"
  end

  def cgcompare_and_jump(op, r1, r2, label)
    if not [:EQ_EQ, :NE, :LT, :LE, :GT, :GE].include? op
      fatal("bad comparision op")
    end
    invcmplist = {:EQ_EQ => "jne", :NE => "je", :LT => "jge", :GT => "jle", :LE => "jg", :GE => "jl"}
    
    code = "\tcmpq\t#{@reglist[r2]}, #{@reglist[r1]}\n"
    code += "\t#{invcmplist[op]}\tL#{label}\n"
    @output.puts code
    freeall_registers()
    -1
  end

  def fatal(message)
    puts "CG: message"
    exit(1)
  end
end
