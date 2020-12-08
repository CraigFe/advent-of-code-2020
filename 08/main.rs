use std::collections::HashSet;
use std::convert::TryInto;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::str::FromStr;

#[derive(Debug, Copy, Clone)]
enum Opcode {
    Jmp,
    Acc,
    Nop,
}
struct Instr(Opcode, i32);

impl FromStr for Instr {
    type Err = ();

    fn from_str(s: &str) -> Result<Instr, ()> {
        let fields = s.split(" ").collect::<Vec<&str>>();
        let v = fields[1].parse::<i32>().unwrap();
        match fields[0] {
            "jmp" => Ok(Instr(Opcode::Jmp, v)),
            "acc" => Ok(Instr(Opcode::Acc, v)),
            "nop" => Ok(Instr(Opcode::Nop, v)),
            _ => Err(()),
        }
    }
}

enum ReturnCode {
    Loop,
    Terminated,
}
fn interpret(program: &Vec<Instr>) -> (i32, ReturnCode) {
    let program_length = program.len().try_into().unwrap();
    let mut acc = 0i32;
    let mut pc = 0i32;
    let mut seen = HashSet::new();

    while !seen.contains(&pc) && pc != program_length {
        seen.insert(pc);

        let Instr(opcode, data) = program[TryInto::<usize>::try_into(pc).unwrap()];
        match opcode {
            Opcode::Nop => pc += 1,
            Opcode::Jmp => pc += data,
            Opcode::Acc => {
                acc += data;
                pc += 1
            }
        }
    }

    return (
        acc,
        if pc == program_length {
            ReturnCode::Terminated
        } else {
            ReturnCode::Loop
        },
    );
}

type Program = Vec<Instr>;

fn part1(program: &Program) -> i32 {
    let (acc, _) = interpret(&program);
    return acc;
}

fn part2(program: &mut Program) -> i32 {
    // Brute force scan through all possible substitutions
    for pc in 0..(program.len()) {
        let Instr(opcode, value) = program[pc];
        match opcode {
            Opcode::Acc => continue,
            Opcode::Nop => program[pc] = Instr(Opcode::Jmp, value),
            Opcode::Jmp => program[pc] = Instr(Opcode::Nop, value),
        }

        match interpret(&program) {
            (_, ReturnCode::Loop) => program[pc] = Instr(opcode, value),
            (acc, ReturnCode::Terminated) => return acc,
        }
    }

    panic!("Didn't find a valid substitution")
}

fn main() {
    let file = File::open("input.txt").expect("blah");
    let buf = BufReader::new(file);

    let mut program = buf
        .lines()
        .map(|l| l.unwrap().parse::<Instr>().unwrap())
        .collect::<Vec<Instr>>();

    println!("Part 1: {:?}", part1(&program));
    println!("Part 2: {:?}", part2(&mut program));
}
