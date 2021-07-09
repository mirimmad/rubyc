

class Cg
  def initialize(output)
    @output = output
    @freereg = Array.new(4).fill(0)
    @reglist = ["%r8","%r9", "%r10", "%r11"]
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
	  code += "\n"
	  code += "\t.globl\tmain\n"
	  code += "\t.type\tmain, @function\n"
	  code += "main:\n"
	  code += "\tpushq\t%rbp\n"
	  code += "\tmovq	%rsp, %rbp\n"
    @output.puts code
  end

  def cgpostamble
    code = "\tmovl $0, %eax\n"
    code += "\tpopq %rbp\n"
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

  def cgloadglob(identifier)
    r = allocate_register()
    code =  "\tmovq\t#{identifier}(%rip), #{@reglist[r]}\n"
    @output.puts code
    r
  end

  def cgstoreglob(r, identifier)
    code = "\tmovq\t#{@reglist[r]}, #{identifier}(%rip)\n"
    @output.puts code
    r
  end

  def cgglobsym(sym)
    code = "\t.comm\t#{sym},8,8\n"
    @output.puts code
  end

end