#!/usr/bin/env ruby

require 'set'

Rule = Struct.new(:parent, :children)
input = File.open('./input.txt', 'r')

def parse_line(line)
  parent, contain = line.match(/^(\w+ \w+) bags contain (.*)\.$/)[1..2]

  children = contain
             .split(/,\s/)
             .map { |c| c.match(/^(?<count>\d+) (?<colour>\w+ \w+) bags?$/)&.named_captures }
             .compact

  [parent, children]
end

$contains = Hash[input.map { |l| parse_line(l) }]

# --- Part 1 ------------------------------------------------------------------

contained_within = Hash.new { |hash, key| hash[key] = [] }
$contains.each do |parent, children|
  children.each { |c| contained_within[c['colour']] << parent }
end

visited = Set.new
todo = ['shiny gold']
while todo.any?
  curr = todo.shift
  visited << curr
  contained_within[curr].each { |c| todo.unshift(c) }
end

colours_containing_gold = visited.size - 1
printf("Part 1: %d\n", colours_containing_gold)

# --- Part 2 ------------------------------------------------------------------

def count_inside(colour)
  $contains[colour]
    .map { |x| (count_inside(x['colour']) + 1) * x['count'].to_i }
    .sum
end

bags_inside_gold = count_inside('shiny gold')
printf("Part 2: %d\n", bags_inside_gold)
