package main

import tristripper "bindings"
import "core:fmt"

main :: proc () {
    ids := [?]tristripper.tristripper_id {
      0, 1, 2,
      3, 1, 2,
      4, 2, 3,
    }

    config := tristripper.Config {
        use_tunneling=true,
        preserve_orientation=false,
        preproc_algorithm=.STRIPIFY,
    }

    strips := tristripper.make_strips(ids[:], &config)
    defer tristripper.delete_strips(strips)

    fmt.println("strips: ", strips)
    fmt.println("strips[0]: ", strips[0].ids[:strips[0].ids_count])
}