(ns hello)

(defn ^:export greet
  [view]
  (let [name (.name view)]
    (.updateGreeting view
     (if (> (count name) 0)
       (str "From cljs: Hello " name)
       (str "From cljs: Hello World!")))))
