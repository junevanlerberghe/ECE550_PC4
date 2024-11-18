# ECE 550 Semester Project: Full Processor
- June Vanlerberghe, Diya Manna
- netid: jlv46, sm1091
  
## Overview
This project is a full processor that implements the following operations:
  - add, sub, addi, sll, sra, lw, sw, and, or, j, bne, jal, jr, blt, bex, setx 

The skeleton is a wrapper that instantiates our modules: imem, dmem, processor and regfile. Each of these has
its own clock. 

## Modules
### Given Modules
The ALU and regfile were given to us since we previously implemented them. The dmem and imem are instantiated using 
the test case mif files. The dffe is also from a previous project checkpoint. 

### Control Signals
We created a separate control module to set all of our control signals. We used the three-step method to come up with a control circuit for the following signals: wren, ctrl_writeEnable, ALUinB, Rdst, Rwd, ALUop. For the full processor we also added the following signals: jal, jp, jr, bne, blt, bex, setx. The first two are outputs of the processor.

### Clocks
In the skeleton module, we created 4 different clocks for the imem, dmem, processor and regfile. The processor and regfile 
clocks are the same and are the given clock divided by 4. To do this, we created a clk_div4 module which uses two DFFEs linked 
together to divide the clock frequency by 4. The imem and dmem clocks have the same frequency as the given clock, but imem is 
inverted. 

### Next PC
To accomodate for the new jump and branch instructions, we created a new module to calculate the next PC. The module will pick either PC + 1, PC + 1 + N, T or $rd based on which instruction is being performed (based on the controls).

### Processor
#### PC
We used a 12-bit register to create the program counter (PC), which is similar to the previous project checkpoint. 
The PC gets incrememented according to the next PC module.

#### Overflow
Since $rstatus needs to be updated whenever an overflow occurs for add, addi or sub, we need to check the overflow of ALU. 
We used the 3-step method to figure out when we need to check the overflow (if its an add, addi or sub operation) and 
which value rstatus would be. This is what the check_overflow module does. If overflow happened and we need to check_overflow, 
then we set the write register to $rstatus and the write data to the corresponding value (1 if add, 2 if addi, 3 if sub).
