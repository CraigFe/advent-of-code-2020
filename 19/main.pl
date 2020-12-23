#!/usr/bin/perl
use strict;
use warnings;

my @rules;
$rules[$1] = $2 while (<> =~ /^(\d+): (.*)$/);

my @messages = <>;

# Regex evaluator in open recursive style
sub compute_regex {
    my ($self, $i) = @_;
    if ($rules[$i] =~ /"(.*)"/) { return $1; }
    else {
        my @subrules   = split / \| /, $rules[$i];
        my @subregexes = map {join '', map {$self->($_)} split} @subrules;
        return "(?:" . join('|', @subregexes) . ")";
    }
}

# Memoised form of `compute_regex`
my @regexes;
sub regex { $regexes[$_[0]] ||= compute_regex(\&regex, $_[0]) }

# Part 1
# ------

my $count = grep /^${\regex(0)}$/, @messages;
printf "Part 1: $count\n";

# Part 2
# ------
#  Do everything again but with the following alterations:
#
#   >   8: 42 | 42 8
#   >  11: 42 31 | 42 11 31

@regexes = ();
$regexes[8]  = "(?:${\regex(42)}+)";
$regexes[11] = "(${\regex(42)}(?1)?${\regex(31)})";
$count = grep /^${\regex(0)}$/, @messages;
print "Part 2: $count\n";
