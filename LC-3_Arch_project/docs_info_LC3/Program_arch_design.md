## Project Goal  
Simulate an LC-3 CPU using a hardware description language (Verilog) on the Vivado IDE. The CPU should meet the following requirements:  
1. Successfully execute up to 15 instructions (excluding interrupt handling).  
2. Display register contents on four 7-segment displays.  
3. Allow switching the displayed register by pressing a button (triggered by a high-voltage signal).  
4. Indicate the currently displayed register using four LEDs.  
5. Execute complex programs.  

## Feasibility Analysis  

### Hardware Resources  
The project will use the **ZNYQ 7020z** development board, provided by my dad's colleague. It includes:  
- An FPGA with a **50 MHz crystal oscillator**  
- A powerful ARM chip (though only the FPGA portion will be utilized due to the complexity of ARM's ISA)  

The simulation will focus on the LC-3 CPU itself, excluding I/O interactions and interrupt handling.  

### Reference Materials  
1. **Yale Patt's Book**:  
   *Introduction to Computing Systems: From Bits & Gates to C/C++ and Beyond* provides a detailed description of LC-3 implementation.  
2. **University of Texas Teaching Materials**:  
   The [LC-3 State Machine PDF](https://users.ece.utexas.edu/~patt/19f.306/Handouts/LC3_State_Machine.pdf) complements Patt's book by explaining the state machine design.  
3. **Existing Implementations**:  
   The [LC3-CPU GitHub project](https://github.com/MatthewKing2/LC3-CPU/blob/main/docs/LC3_State_Machine.pdf) serves as a reference, though some corrections may be needed in its code.  

### Conclusion  
This project is **feasible and challenging**, with ample reference materials available. It provides an excellent platform for learning CPU architecture and Verilog design.





由于ARM处理器架构过于复杂，我们这里暂时不使用，只使用FPGA的部分。
我们的目标是实现LC-3架构，其拥有16种指令。
对于vivado的synthesis过程来说，中断处理开发难度较大不在计划之内，2^16位内存需要大量综合的时间。因此最终采取2^8*2^16的内存，也就是2MB的存储空间，



关于LC-3的编译器
感谢laser/src/label.c at testing · PaperFanz/laser · GitHub开发的laser库使得LC-3转机器码成为可能。具体实现细节我们就按黑箱操作就行，不过此类编译器的基本原理都是刚开始创造一个变量名和地址的mapping，称为symbol table。第二遍再进行assemble，遇到变量就用symbol table上对应的值替换。




2.任务目标

通过FPGA实现LC-3架构
Input
一个按钮负责切换显示哪个寄存器
一个按钮复位所有寄存器
Output
10条线控制一组（4个）七段数码管，显示当前寄存器的值
四个LED显示当前查看的是哪个寄存器，9个GPR和PC还有MDR和MAR，一共12个寄存器

因此，经过长时间的研究，这个项目的难度已经被降到了最低，接下来的任务和最大难点就是如何简化并实现这个LC-3结构。
3.Architecture的规划
指令集分析：
Operate ADD/AND/NOT
Control BR/JMP/JSR
Data transfer LD/LDR/LEA/ST/STR
接下来应该研究在原本的LC-3架构上我们要保留哪些，删除哪些
开发流程将分为三个部分—我们先实现三种最简单的操作指令，然后再是数据搬运指令，最后是控制指令，符合先易后难的原则。
有一个概念很重要：微指令
微指令序列相当于一个虚拟的状态机，一个指令（如ADD）由多个微指令组成。
微指令储存在ROM中，读取速度非常快（每条都要单周期内完成），由COE文件进行memory的预设。
微指令具有易于扩展的优点，同时其逻辑清楚适合初学者编写。
在我们的设计中，微指令将以此类格式出现：
0-1: alu_ctrl
2-11: reg_ctrl 
12-xx: mem_ctrl
xx-xx+2: COND
xx+3-xx+6: next address（j-field）
微指令拥有自己的内存条和地址系统，有一个专门的微指令计数器，保证指令每周期更新一位。
J-field是满足COND后会跳转的位置。
但是对于有些需要等待的COND类型，就有可能把J-field改为其他的地址入口。内存等待微指令（R）就令地址不变，使得程序一直等待直到内存更新完毕。
条件跳转微指令（IR11）就通过NZP寄存器和当前IR的要求进行跳转。
这个微指令运行的架构参考的是
LC3-CPU/ControlSignals/ControlStore.csv at main · MatthewKing2/LC3-CPU · GitHub
他的结构很清楚，还留下了极大的扩展空间。