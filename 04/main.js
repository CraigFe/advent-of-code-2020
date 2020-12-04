const fs = require("fs");
const readline = require("readline");

async function* readPassports(file) {
  const fileStream = fs.createReadStream(file);
  const readLine = readline.createInterface({ input: fileStream });

  let obj = {};

  for await (const line of readLine) {
    if (line === "") {
      yield obj;
      obj = {};
    } else {
      line
        .split(" ")
        .map((x) => x.split(":"))
        .forEach(([k, v]) => (obj[k] = v));
    }
  }
  yield obj;
}

const inRange = (lower, upper, n) => n >= lower && n <= upper;

const yearInRange = (lower, upper, s) => {
  const n = parseInt(s);
  return s.length == 4 && inRange(lower, upper, n);
};

const validateHeight = (s) => {
  const cm = s.match(/^([0-9]+)cm$/);
  const inch = s.match(/^([0-9]+)in$/);

  if (cm) return inRange(150, 193, cm[1]);
  if (inch) return inRange(59, 76, inch[1]);
  return false;
};

const validate = ({ byr, iyr, eyr, hgt, hcl, ecl, pid }) => {
  const conditions = [
    yearInRange(1920, 2002, byr),
    yearInRange(2010, 2020, iyr),
    yearInRange(2020, 2030, eyr),
    validateHeight(hgt),
    !!ecl.match(/^(amb)|(blu)|(brn)|(gry)|(grn)|(hzl)|(oth)$/),
    !!hcl.match(/^#[0-9a-f]{6}$/),
    !!pid.match(/^[0-9]{9}$/),
  ];

  return conditions.every((x) => x);
};

(async () => {
  let nbRequiredFields = 0;
  let nbValid = 0;
  for await (const pp of readPassports("input.txt")) {
    let requiredFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"];

    if (requiredFields.every((field) => field in pp)) {
      nbRequiredFields++;
      if (validate(pp)) nbValid++;
    }
  }
  console.log ({
    nbRequiredFields: nbRequiredFields,
    nbValid: nbValid
  })
})();
