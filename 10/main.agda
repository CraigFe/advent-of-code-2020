module main where

import Data.Nat.Properties as ℕₚ
import Data.Nat.Show as ℕ
import Data.Tree.AVL.Sets ℕₚ.<-strictTotalOrder as Sets
open import Data.Bool.Base using (if_then_else_; false)
open import Data.List.Base as List using (List; _∷_; [])
open import Data.Maybe.Base as Maybe using (Maybe; just; nothing; fromMaybe)
open import Data.Nat.Base using (ℕ; suc; _+_; _∸_; _*_; _<ᵇ_)
open import Data.Product using (_,_; _×_; proj₂)
open import Data.String.Base as String using (String; _++_)
open import Data.Tree.AVL.Map ℕₚ.<-strictTotalOrder as Map using (Map)
open import Function.Base

partOne : List ℕ → String
partOne jolts =
  ℕ.show ones ++ " × " ++ ℕ.show threes ++ " = " ++ ℕ.show (ones * threes) where

    diffs : List ℕ → Map ℕ
    diffs (x ∷ l@(y ∷ _)) = Map.insertWith (y ∸ x) (suc ∘′ fromMaybe 0) (diffs l)
    diffs (_ ∷ []) = Map.empty
    diffs [] = Map.empty

    dfs    = diffs jolts
    ones   = fromMaybe 0 (Map.lookup 1 dfs)
    threes = fromMaybe 0 (Map.lookup 3 dfs) + 1  -- Final step of 3

partTwo : List ℕ → ℕ
partTwo []       = 0
partTwo (n ∷ ns) =
  List.foldl step (Map.singleton n 1) ns |> Map.lookup 0 |> fromMaybe 0 where

    -- Given a solution to the subproblem, compute additional paths that are
    -- possible from this (lower) joltage adapter.
    step : Map ℕ → ℕ → Map ℕ
    step m k = Map.insert k pathsFromHere m where

      pathsFromHere =
        (1 + k) ∷ (2 + k) ∷ (3 + k) ∷ []
        |> List.mapMaybe (λ k → Map.lookup k m)
        |> List.sum

open import IO
open import Data.Char.Base

read : String → ℕ
read = List.foldl (λ acc c → 10 * acc + toℕ c ∸ toℕ '0') 0 ∘′ String.toList

main = run $ do
  content ← String.lines <$> readFiniteFile "./input.txt"
  let ns = List.map read content
  let sorted = 0 ∷ Sets.toList (Sets.fromList ns)
  putStrLn $ "Part 1: " ++ partOne sorted
  putStrLn $ "Part 2: " ++ (ℕ.show $ partTwo $ List.reverse $ sorted)
