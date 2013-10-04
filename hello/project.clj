(defproject hello "0.1.0-SNAPSHOT"
  :description "hello module in ClojureScript"
  :license {:name "Public Domain"
            :url "http://unlicense.org"}
  :dependencies [[org.clojure/clojurescript "0.0-1889"]]
  :cljsbuild {:builds [{:source-paths ["src-cljs"]
                        :compiler {:output-to "js/hello.js"
                                   :optimizations :whitespace
                                   :pretty-print true}}]})
