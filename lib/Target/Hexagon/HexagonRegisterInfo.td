//===-- HexagonRegisterInfo.td - Hexagon Register defs -----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the Hexagon register file.
//===----------------------------------------------------------------------===//

let Namespace = "Hexagon" in {

  class HexagonReg<bits<5> num, string n, list<string> alt = [], 
                   list<Register> alias = []> : Register<n> {
    field bits<5> Num;
    let Aliases = alias;
    let HWEncoding{4-0} = num;
  }

  class HexagonDoubleReg<bits<5> num, string n, list<Register> subregs,
                         list<string> alt = []> :
        RegisterWithSubRegs<n, subregs> {
    field bits<5> Num;

    let AltNames = alt;
    let HWEncoding{4-0} = num;
  }

  // Registers are identified with 5-bit ID numbers.
  // Ri - 32-bit integer registers.
  class Ri<bits<5> num, string n, list<string> alt = []> : HexagonReg<num, n, alt> {
    let Num = num;
  }

  // Rf - 32-bit floating-point registers.
  class Rf<bits<5> num, string n> : HexagonReg<num, n> {
    let Num = num;
  }


  // Rd - 64-bit registers.
  class Rd<bits<5> num, string n, list<Register> subregs> :
        HexagonDoubleReg<num, n, subregs> {
    let Num = num;
    let SubRegs = subregs;
  }

  // Rp - predicate registers
  class Rp<bits<5> num, string n> : HexagonReg<num, n> {
    let Num = num;
  }

  // Rc - control registers
  class Rc<bits<5> num, string n,
           list<string> alt = [], list<Register> alias = []> : 
        HexagonReg<num, n, alt, alias> {
    let Num = num;
  }

  // Rcc - 64-bit control registers.
  class Rcc<bits<5> num, string n, list<Register> subregs,
            list<string> alt = []> :
        HexagonDoubleReg<num, n, subregs, alt> {
    let Num = num;
    let SubRegs = subregs;
  }

  // Mx - address modifier registers
  class Mx<bits<1> num, string n> : HexagonReg<{0b0000, num}, n> {
    let Num = !cast<bits<5>>(num);
  }

  def subreg_loreg  : SubRegIndex<32>;
  def subreg_hireg  : SubRegIndex<32, 32>;
  def subreg_overflow : SubRegIndex<1, 0>;

  // Integer registers.
  foreach i = 0-28 in {
    def R#i  : Ri<i, "r"#i>,  DwarfRegNum<[i]>;
  }

  def R29 : Ri<29, "r29", ["sp"]>, DwarfRegNum<[29]>;
  def R30 : Ri<30, "r30", ["fp"]>, DwarfRegNum<[30]>;
  def R31 : Ri<31, "r31", ["lr"]>, DwarfRegNum<[31]>;

  // Aliases of the R* registers used to hold 64-bit int values (doubles).
  let SubRegIndices = [subreg_loreg, subreg_hireg], CoveredBySubRegs = 1 in {
  def D0  : Rd< 0,  "r1:0",  [R0,  R1]>, DwarfRegNum<[32]>;
  def D1  : Rd< 2,  "r3:2",  [R2,  R3]>, DwarfRegNum<[34]>;
  def D2  : Rd< 4,  "r5:4",  [R4,  R5]>, DwarfRegNum<[36]>;
  def D3  : Rd< 6,  "r7:6",  [R6,  R7]>, DwarfRegNum<[38]>;
  def D4  : Rd< 8,  "r9:8",  [R8,  R9]>, DwarfRegNum<[40]>;
  def D5  : Rd<10, "r11:10", [R10, R11]>, DwarfRegNum<[42]>;
  def D6  : Rd<12, "r13:12", [R12, R13]>, DwarfRegNum<[44]>;
  def D7  : Rd<14, "r15:14", [R14, R15]>, DwarfRegNum<[46]>;
  def D8  : Rd<16, "r17:16", [R16, R17]>, DwarfRegNum<[48]>;
  def D9  : Rd<18, "r19:18", [R18, R19]>, DwarfRegNum<[50]>;
  def D10 : Rd<20, "r21:20", [R20, R21]>, DwarfRegNum<[52]>;
  def D11 : Rd<22, "r23:22", [R22, R23]>, DwarfRegNum<[54]>;
  def D12 : Rd<24, "r25:24", [R24, R25]>, DwarfRegNum<[56]>;
  def D13 : Rd<26, "r27:26", [R26, R27]>, DwarfRegNum<[58]>;
  def D14 : Rd<28, "r29:28", [R28, R29]>, DwarfRegNum<[60]>;
  def D15 : Rd<30, "r31:30", [R30, R31]>, DwarfRegNum<[62]>;
  }

  // Predicate registers.
  def P0 : Rp<0, "p0">, DwarfRegNum<[63]>;
  def P1 : Rp<1, "p1">, DwarfRegNum<[64]>;
  def P2 : Rp<2, "p2">, DwarfRegNum<[65]>;
  def P3 : Rp<3, "p3">, DwarfRegNum<[66]>;

  // Modifier registers.
  // C6 and C7 can also be M0 and M1, but register names must be unique, even
  // if belonging to different register classes.
  def M0 : Mx<0, "m0">, DwarfRegNum<[72]>;
  def M1 : Mx<1, "m1">, DwarfRegNum<[73]>;

  // Fake register to represent USR.OVF bit. Artihmetic/saturating instruc-
  // tions modify this bit, and multiple such instructions are allowed in the
  // same packet. We need to ignore output dependencies on this bit, but not
  // on the entire USR.
  def USR_OVF : Rc<?, "usr.ovf">;

  // Control registers.
  def SA0  : Rc<0,  "sa0",       ["c0"]>,   DwarfRegNum<[67]>;
  def LC0  : Rc<1,  "lc0",       ["c1"]>,   DwarfRegNum<[68]>;
  def SA1  : Rc<2,  "sa1",       ["c2"]>,   DwarfRegNum<[69]>;
  def LC1  : Rc<3,  "lc1",       ["c3"]>,   DwarfRegNum<[70]>;
  def P3_0 : Rc<4,  "p3:0",      ["c4"], [P0, P1, P2, P3]>,
                                            DwarfRegNum<[71]>;
  def C6   : Rc<6,  "c6",        [], [M0]>, DwarfRegNum<[72]>;
  def C7   : Rc<7,  "c7",        [], [M1]>, DwarfRegNum<[73]>;

  def USR  : Rc<8,  "usr",       ["c8"]>,   DwarfRegNum<[74]> {
    let SubRegIndices = [subreg_overflow];
    let SubRegs = [USR_OVF];
  }
  def PC   : Rc<9,  "pc">,                  DwarfRegNum<[75]>;
  def UGP  : Rc<10, "ugp",       ["c10"]>,  DwarfRegNum<[76]>;
  def GP   : Rc<11, "gp">,                  DwarfRegNum<[77]>;
  def CS0  : Rc<12, "cs0",       ["c12"]>,  DwarfRegNum<[78]>;
  def CS1  : Rc<13, "cs1",       ["c13"]>,  DwarfRegNum<[79]>;
  def UPCL : Rc<14, "upcyclelo", ["c14"]>,  DwarfRegNum<[80]>;
  def UPCH : Rc<15, "upcyclehi", ["c15"]>,  DwarfRegNum<[81]>;
}

  // Control registers pairs.
  let SubRegIndices = [subreg_loreg, subreg_hireg], CoveredBySubRegs = 1 in {
    def C1_0   : Rcc<0,   "c1:0",  [SA0, LC0], ["lc0:sa0"]>, DwarfRegNum<[67]>;
    def C3_2   : Rcc<2,   "c3:2",  [SA1, LC1], ["lc1:sa1"]>, DwarfRegNum<[69]>;
    def C7_6   : Rcc<6,   "c7:6",  [C6, C7],   ["m1:0"]>,    DwarfRegNum<[72]>;
    def C9_8   : Rcc<8,   "c9:8",  [USR, PC]>,               DwarfRegNum<[74]>;
    def C11_10 : Rcc<10, "c11:10", [UGP, GP]>,               DwarfRegNum<[76]>;
    def CS     : Rcc<12, "c13:12", [CS0, CS1], ["cs1:0"]>,   DwarfRegNum<[78]>;
    def UPC    : Rcc<14, "c15:14", [UPCL, UPCH]>,            DwarfRegNum<[80]>;
  }

// Register classes.
//
// FIXME: the register order should be defined in terms of the preferred
// allocation order...
//
def IntRegs : RegisterClass<"Hexagon", [i32,f32], 32,
                            (add (sequence "R%u", 0, 9),
                                 (sequence "R%u", 12, 28),
                                 R10, R11, R29, R30, R31)> {
}

def DoubleRegs : RegisterClass<"Hexagon", [i64,f64], 64,
                               (add (sequence "D%u", 0, 4),
                                    (sequence "D%u", 6, 13), D5, D14, D15)>;


def PredRegs : RegisterClass<"Hexagon", [i1], 32, (add (sequence "P%u", 0, 3))>
{
  let Size = 32;
}

let Size = 32, isAllocatable = 0 in
def CtrRegs : RegisterClass<"Hexagon", [i32], 32,
                           (add LC0, SA0, LC1, SA1,
                                P3_0,
                                 M0, M1, C6, C7, CS0, CS1, UPCL, UPCH,
                                 USR, USR_OVF, UGP, GP, PC)>;

let Size = 64, isAllocatable = 0 in
def CtrRegs64 : RegisterClass<"Hexagon", [i64], 64,
                              (add C1_0, C3_2, C7_6, C9_8, C11_10, CS, UPC)>;

def VolatileV3 {
  list<Register> Regs = [D0, D1, D2, D3, D4, D5, D6, D7,
                         R28, R31,
                         P0, P1, P2, P3,
                         M0, M1,
                         LC0, LC1, SA0, SA1, USR, USR_OVF];
}

def PositiveHalfWord : PatLeaf<(i32 IntRegs:$a),
[{
  return isPositiveHalfWord(N);
}]>;
