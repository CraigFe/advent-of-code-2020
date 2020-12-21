import java.io.File typealias Ticket = List<Int>
data class Rule(val name: String, val valid: List<IntRange>) {
  fun isConsistentWith (field : Int) = valid.any { it.contains(field) }
}

data class Notes(
    val rules: List<Rule>,
    val mine: Ticket,
    val nearby: List<Ticket>,
) {
    companion object {
        val notesPattern = """([.\s\S]*)\s\syour ticket:\s(.*)\s\snearby tickets:\s([.\s\S]*)\s""".toRegex()
        val rulePattern = """(.*): (\d+)-(\d+) or (\d+)-(\d+)""".toRegex()

        fun ofString(text: String): Notes =
            notesPattern.matchEntire(text)!!.destructured.let {
                (rules, mine, nearby) ->

                val parseTicket: (String) -> Ticket = { it.split(",").map { it.toInt() } }
                val parseRule: (String) -> Rule =
                    {
                        rulePattern.matchEntire(it)!!.destructured.let {
                            (a, b, c, d, e) ->
                            Rule(a, listOf(IntRange(b.toInt(), c.toInt()), IntRange(d.toInt(), e.toInt())))
                        }
                    }

                Notes(
                    rules = rules.lines().map(parseRule),
                    mine = parseTicket(mine),
                    nearby = nearby.lines().map(parseTicket),
                )
            }
    }
}

typealias OneToMany<A, B> = List<Pair<A, List<B>>>
typealias OneToOne<A, B> = List<Pair<A, B>>

tailrec fun <A, B> matchBipartite(
    rel: OneToMany<A, B>,
    acc: OneToOne<A, B> = emptyList()
): OneToOne<A, B> {
    if (rel.size == 0) return acc
    val (known, unknown) = rel.partition { it.second.size == 1 }

    val newMatches: OneToOne<A, B> = known.map { it.first to it.second.first() }
    val matchedTargets: List<B> = newMatches.map { it.second }

    return matchBipartite(
        acc = acc + newMatches,
        rel = unknown.map { it.first to it.second.filter { !matchedTargets.contains(it) } }
    )
}

fun main() {
    val notes = Notes.ofString(File("./input.txt").readText())

    val validFields = notes.rules.flatMap { it.valid }.fold(setOf<Int>()) { a, b -> a.union(b) }

    notes.nearby
        .flatten()
        .filter { !validFields.contains(it) }
        .sum()
        .also { println("Part 1: $it") }

    val validTickets = notes.nearby.filter { it.all { validFields.contains(it) } }

    val candidates: List<List<Rule>> =
        validTickets.fold(
            initial = List(notes.mine.size, { _ -> notes.rules }),

            // For each field of the ticket, retain only rules consistent with that field
            operation = { candidates, ticket ->
                candidates.zipWith(ticket) { rules, field ->
                rules.filter { it.isConsistentWith(field) } }
            }
        )

    matchBipartite(candidates.zipWithIndex())
        .filter { it.second.name.startsWith("departure") }
        .also { assert(it.size == 6) }
        .map { notes.mine.get(it.first) }
        .product()
        .also { println("Part 2: $it") }
}

fun <A, B, C> List<A>.zipWith(l: List<B>, f: (A, B) -> C) = this.zip(l).map { f(it.first, it.second) }
fun <T> List<T>.zipWithIndex() = List(this.size, { i -> i }).zip(this)
fun List<Int>.product() = this.map { it.toLong() }.fold(1L, { a, b -> a * b })
