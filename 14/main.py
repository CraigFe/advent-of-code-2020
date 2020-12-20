import re


class Machine:
    WORD_SIZE = 36

    def __init__(self):
        self.__setDefaultMasks()
        self.memory = {}

    def __setDefaultMasks(self):
        self.mask_0 = 0
        self.mask_1 = 0
        self.mask_x = []

    def setMask(self, maskString):
        self.__setDefaultMasks()
        for i, bit in enumerate(reversed(maskString)):
            if bit == "0":
                self.mask_0 += 2 ** i
            elif bit == "1":
                self.mask_1 += 2 ** i
            elif bit == "X":
                self.mask_x.append(2 ** i)
            else:
                raise RuntimeError("Invalid bitstring")

    def setValue(self, k, v, floating=False):
        if not floating:
            v |= self.mask_1
            v &= ~self.mask_0
            self.memory[k] = v

        else:
            k |= self.mask_1
            ks = [k]
            for x in self.mask_x:
                ks = [k & ~x for k in ks] + [k | x for k in ks]

            for k in ks:
                self.memory[k] = v


pat_mask = re.compile(r"mask = (?P<mask>[X01]{36})")
pat_mem = re.compile(r"mem\[(?P<addr>[0-9]+)\] = (?P<val>[0-9]+)")


def runProgram(program, floating):
    machine = Machine()

    for instr in program:
        match = pat_mask.match(instr)
        if match:
            mask = match.group("mask")
            machine.setMask(mask)
            continue

        match = pat_mem.match(instr)
        if match:
            addr = int(match.group("addr"))
            val = int(match.group("val"))
            machine.setValue(addr, val, floating)
            continue

        raise RuntimeError("Couldn't parse instruction: " + instr)

    print(sum(machine.memory.values()))


if __name__ == "__main__":
    prog = open("./input.txt").read().splitlines()
    runProgram(prog, floating=False)
    runProgram(prog, floating=True)
