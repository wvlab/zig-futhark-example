entry fact_sum (xs: []i32): i32 =
    xs |> map (\x -> reduce (*) 1 (1...x)) |> i32.sum
