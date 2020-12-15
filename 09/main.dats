#include "share/atspre_staload.hats"

#define PREAMBLE 25
#define INT_MAX  0x7FFFFFFF
#define INT_MIN  0x80000000

// -----------------------------------------------------------------------------
//    UTILITIES
// -----------------------------------------------------------------------------

// Read a file into a stream of integers
fun file_to_stream (name: string) : stream int
    = loop () where
{
  val input = fileref_open_exn(name, file_mode_r)
  fun loop () = $delay(
    if fileref_isnot_eof input then
      let
        val line = fileref_get_line_string input
        val n : int = g1string2int (strptr2string line)
      in
        stream_cons(n, loop ())
      end
    else (fileref_close(input); stream_nil ())
  )
}

// Take a non-empty array and copy it, returning a new array of the same size
fun{a:t@ype} copy_array{n:nat | n > 0}
    (A: arrayref(a, n), n : int n) :<cloref1> arrayref(a, n) =
    B where
{
  val B : arrayref(a, n) = arrayref_make_elt (i2sz(n), A[0])
  fun loop{i:nat} (i: int i): void = if i < n then ((B[i] := A[i]); loop (succ i))
  val () = loop (0)
}

// In-place insertion sort on a non-empty array of known size
fun{a:t@ype} insertion_sort{n:nat | n > 0}
    (A: arrayref(a, n), A_len: int n, cmp: (a, a) -> int) :<cloref1> void =
  loop(1) where
{
  fun ins{i:int | i < n - 1} (x: a, i: int i) :<cloref1> void =
    ifcase
    | i < 0                        => A[0] := x
    | i >= 0 && cmp(x, A[i]) >= 0  => A[i+1] := x
    | _                            => (A[i+1] := A[i]; ins(x, i-1))

  fun loop{i:nat | i > 0} (i: int i) :<cloref1> void =
    if i < A_len then (ins(A[i], i-1); loop(i+1)) else ()
}

// Dependently-typed variant of integer modulus `mod`, which witnesses that
//   (n mod m = r) ⇒ r ∈ [0, m)
dataprop MOD(int,int,int) =
  | {i,j   : int | i >= 0; j > 0; i < j }  MODbas (i, j, i) of ()
  | {i,j,k : int | i >= 0; j > 0; i >= j } MODind (i, j, k) of MOD(i-j, j, k)

infixl mod dmod
fun dmod{n,m:int | n >= 0; m > 0} (n: int n, m: int m):
    [r: int | r >= 0; r < m] (MOD (n,m,r) | int r) =
  ifcase
  | n < m => (MODbas | n)
  | _     => (MODind(pf1) | r) where { val (pf1 | r) = (n - m) dmod m }

// -----------------------------------------------------------------------------

// Return [true] if there are two values in the array that sum to the goal
fun pairs_sum_to{n:nat | n > 0}
    (A: arrayref(int, n), A_len : int n, goal: int) :<cloref1> bool =
  loop(0, pred A_len) where {

  val A_tmp : arrayref(int, n) = copy_array(A, A_len)
  val () = insertion_sort(A_tmp, A_len, lam (x, y) => compare (x, y));

  fun loop{i,j:nat | j < n; i < n} (lower: int i, upper: int j) =
    let
      val sum : int = A_tmp[lower] + A_tmp[upper]
      val lower' = lower + 1
      val upper' = upper - 1
    in
      ifcase
      | sum > goal     => (upper' >= 0)    && loop (lower, upper')
      | sum < goal     => (lower' < A_len) && loop (lower', upper)
      | _ (* = goal *) => true
    end
}

fun initialise_buffer (s : stream int) : @(arrayref(int, PREAMBLE), stream int)
  = @(buf, loop (0, s)) where
{
  val buf = arrayref_make_elt (i2sz PREAMBLE, 0)

  fun loop{i:nat} (i : int i, s : stream int) : stream int =
      if i >= PREAMBLE then s else
        case- (!s) of stream_cons(c, cs) => (
          buf[i] := c;
          loop (succ i, cs)
        )
}

fun part1 (stream) = loop (0, buf) where
{
  val @(arr, buf) = initialise_buffer(stream)

  fun loop{i:nat | i < PREAMBLE} (i: int i, s : stream(int)) : int = (
    case- (!s) of stream_cons(c, cs) => (
      if pairs_sum_to(arr, PREAMBLE, c) then (
        arr[i] := c;
        let val (_ | x) = (succ i) dmod PREAMBLE in
          loop (x, cs)
        end
      ) else c
    )
  )
}

fun part2 (goal: int, stream: stream(int)) : int = loop (stream) where
{
  fun contiguous_sum_to (goal: int, stream : stream(int), smallest, largest)
    : Option_vt (@(int, int)) =
    case- (!stream) of stream_cons(c, cs) =>
      ifcase
      | c = goal => Some_vt(@(smallest, largest))
      | c > goal => None_vt()
      | _ (* c < goal *) =>
        contiguous_sum_to (goal - c, cs, min(smallest,c), max(largest,c))

  fun loop (stream: stream(int)) =
    case (contiguous_sum_to (goal, stream, INT_MAX, INT_MIN)) of
    | ~Some_vt (@(smallest, largest)) => smallest + largest
    | ~None_vt () => (case- (!stream) of stream_cons(_, cs) => loop(cs))
}

implement main0 () = {
  val not_2sum = part1(file_to_stream("input.txt"))
  val () = println! ("Part 1: ", not_2sum)
  val () = println! ("Part 2: ", part2(not_2sum, file_to_stream("input.txt")))
}
