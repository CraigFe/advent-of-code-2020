import scala.io.Source
import scala.collection._

sealed trait Place {
  def isOccupied: Boolean = false
  def isTransparent: Boolean = false
}

case object Occupied extends Place { override def isOccupied = true }
case object Empty extends Place
case object Floor extends Place { override def isTransparent = true }

object Place {
  def ofChar: Char => Place = {
    case '#' => Occupied
    case 'L' => Empty
    case '.' => Floor
  }

  def toChar: Place => Char = {
    case Occupied => '#'
    case Empty    => 'L'
    case Floor    => '.'
  }
}

class Lounge(
    var seating: Array[Array[Place]],
    val tolerance: Int, /* Maximum permissible number of neighbers */
    val lineOfSight: Int /* Distance to look in each direction for a neighbor */
) {

  override def toString(): String = {
    this.seating
      .map(
        _.map(Place.toChar(_)).mkString
      )
      .mkString("\n")
  }

  def totalOccupied(): Int = {
    seating.foldLeft(0)((i: Int, arr: Array[Place]) => {
      arr.map(_.isOccupied).foldLeft(i)((a, b) => a + { if (b) 1 else 0 })
    })
  }

  def countAround(x: Int, y: Int): Int = {
    Array((0, 1), (0, -1), (1, 0), (1, 1), (1, -1), (-1, 0), (-1, 1), (-1, -1))
      .map({
        case (dx, dy) => {
          try {
            (1 to lineOfSight)
              .dropWhile((r) =>
                this.seating(x + r * dx)(y + r * dy).isTransparent
              )
              .headOption match {
                case Some(r) => this.seating(x + r * dx)(y + r * dy).isOccupied
                case None => false
              }
          } catch { case _: ArrayIndexOutOfBoundsException => false }
        }
      })
      .foldLeft(0)((a, b) => a + { if (b) 1 else 0 })
  }

  def update(): Boolean = {
    var changed = false
    seating = seating.zipWithIndex
      .map({
        case (row, i) =>
          row.zipWithIndex
            .map({
              case (Floor, _) => Floor
              case (elt, j) =>
                (elt, this.countAround(i, j)) match {
                  case (Occupied, n) if (n > tolerance) => {
                    changed = true; Empty
                  }
                  case (Empty, 0) => { changed = true; Occupied }
                  case (x, _)     => x
                }
            })
      })
    changed
  }

  def fixpoint(): Int = {
    while (this.update()) {}
    this.totalOccupied()
  }
}

object Main {
  def main(args: Array[String]) = {
    val state = Source
      .fromFile("./input.txt")
      .getLines()
      .map(
        _.map(Place.ofChar).toArray
      )
      .toArray

    val p1 = new Lounge(state.map(_.clone), 3, 1).fixpoint();
    println(s"Part 1: $p1")

    val p2 = new Lounge(state.map(_.clone), 4, Int.MaxValue).fixpoint();
    println(s"Part 2: $p2")
  }
}
