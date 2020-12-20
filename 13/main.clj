(defn part1 [data]
  (let [[start-time & buses] (->> data (re-seq #"\d+") (map read-string))]
    (->> buses (map #(vector (- % (mod start-time %)) %)) sort first (reduce *))))

;; Brute force search through all solutions. (No Chinese Remainder Theorem
;; because I'm not cool enough.) Given a system of congruences:
;;
;; > `∀ i ∈ [1, k]. x ≡ a_i (mod n_i)`
;;
;; and the solution for (k-1)th case, x_{k-1}, we can compute x by testing
;; successive integers in steps of `delta = LCM_{i = 0 to k-1} (n_i)`.
(defn part2 [data]
  (let [[_ & buses] (->> data (re-seq #"(\d+)|x"))
        gcd #(if (= 0 %2) %1 (recur %2 (mod %1 %2)))
        lcm #(quot (* %1 %2) (gcd %1 %2))
        congruences (keep-indexed (fn [i [_ s]] (if s (let [t (read-string s)] [t (mod (- (* t (quot i t)) i) t)]))) buses)
        extend (fn [[delta t] [n a]] (loop [t t]
                 (if (= (mod t n) a)
                   [(lcm delta n) t]
                   (recur (+ t delta)))))]
    ((reduce extend congruences) 1)))

(let [data (slurp "input.txt")]
  (println ["Part 1:" (part1 data)])
  (println ["Part 2:" (part2 data)]))
