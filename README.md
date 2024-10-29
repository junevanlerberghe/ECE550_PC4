# ECE 550 Semester Project: Simple Processor
- June Vanlerberghe, Diya Manna
- netid: jlv46, sm1091
  
## Overview
This project is a simple processor that implements add, sub, addi, sll, sra, lw, sw, and, or operations. 
The skeleton is a wrapper that instantiates our modules: imem, dmem, processor and regfile. Each of these has
its own clock. 

## Modules
### Given Modules
The ALU and regfile were given to us since we previously implemented them. The dmem and imem are instantiated using 
the test case mif files. The dffe is also from a previous project checkpoint. 

### Processor
#### Control Signals
In order to implement the control signals, we used the three-step method to come up with a control circuit for the following
signals: wren, ctrl_writeEnable, ALUinB, Rdst, Rwd, ALUop. The first two are outputs of the processor.

#### PC
We used a 12-bit register to create the program counter (PC), which is similar to the previous project checkpoint. 
The PC gets incrememented by 1 every clock cycle using the ALU.

#### Overflow
Since $rstatus needs to be updated whenever an overflow occurs for add, addi or sub, we need to check the overflow of ALU. 
We used the 3-step method to figure out when we need to check the overflow (if its an add, addi or sub operation) and 
which value rstatus would be. This is what the check_overflow module does. If overflow happened and we need to check_overflow, 
then we set the write register to $rstatus and the write data to the corresponding value (1 if add, 2 if addi, 3 if sub).

### Clocks
In the skeleton module, we created 4 different clocks for the imem, dmem, processor and regfile. The processor and regfile 
clocks are the same and are the given clock divided by 4. To do this, we created a clk_div4 module which uses two DFFEs linked 
together to divide the clock frequency by 4. The imem and dmem clocks have the same frequency as the given clock, but dmem is 
inverted. 
