package tristripper

import "core:c"

when ODIN_OS == .Linux { foreign import tristripper "../build/release/librmtristripper.a" }

tristripper_id :: c.uint32_t
rm_bool :: c.bool
rm_size :: c.size_t

PreprocAlgorithm :: enum c.int {
    //Treat each triangle as an isolated strip:
	ISOLATED,

	//Try to pair up to two triangles together.
	//Prefer isolated triangles.
	PAIRS,

	//Use the stripify algorithm (identical to the "non-tunneled" version).
	STRIPIFY
}

//The tunneling process in directed by the following parameters:
//
// - "use_tunneling":              Shall we use tunneling or fall back to stripify-only?
// - "preserve_orientation":       Shall the orientation of strips be preserved? Might introduce some more degenerated triangles ...
//                                 This parameter is available for stripify and for tunneling.
//
// Everything below here is only relevant for tunneling!
//
// - "preproc_algorithm":          Which algorithm shall be used to create the initial strips that are tunneled?
// - "max_count":                  What is the maximum number of triangles that form a tunnel?
//                                 This must be >= 2 and <= UINT16_MAX and should be even.
// - "incremental":                If this is set to "false", we perform DFS with a depth of "max_count".
//                                 Otherwise, we perform incremental DFS, starting at a depth of 2, and increase it to "max_count".
// - "loop_limit":                 Do we limit the tunnel search to a maximum number of loop iterations per tunnel?
//                                 If this is set to "RM_TRISTRIPPER_NO_LOOP_LIMIT",
//                                 we loop until all DFS paths of depth "max_count" have been evaluated.
//                                 Otherwise, the behavior depends on "backtrack_after_loop_limit" (see below).
// - "backtrack_after_loop_limit": Only valid if "loop_limit" is != "RM_TRISTRIPPER_NO_LOOP_LIMIT".
//                                 If this is set to "false" and the limit is reached, we fail instantly.
//                                 Otherwise, we backtrack at the first tunnel member to change the direction.
//                                 On success, the loop count is reset and we search again.
// - "dest_count":                 Stop tunneling as soon as the specified number of strips has been reached.
//                                 Use RM_TRISTRIPPER_NO_DEST_COUNT to keep tunneling until all paths have been discovered.
Config :: struct {
    use_tunneling: rm_bool,
    preserve_orientation: rm_bool,
    preproc_algorithm: PreprocAlgorithm,
    max_count: rm_size,
    incremental: rm_bool,
    loop_limit: rm_size,
    backtrack_after_loop_limit: rm_bool,
    dest_count: rm_size,
}

Strip :: struct {
    ids_count: rm_size,
    ids: [^]tristripper_id,
}

@(default_calling_convention="c")
foreign tristripper {
    @(private)
    rm_tristripper_create_strips :: proc (ids: [^]tristripper_id, ids_count: rm_size, config: ^Config, strips: ^[^]Strip, strip_count: ^rm_size) ---
    @(private)
    rm_tristripper_dispose_strips :: proc (strips: [^]Strip, strips_count: rm_size) ---
}

make_strips :: #force_inline proc "c" (ids : []tristripper_id, config: ^Config) -> []Strip {
    count : rm_size
    strips : [^]Strip
    rm_tristripper_create_strips(raw_data(ids), len(ids), config, &strips, &count)
    return strips[:count]
}

delete_strips :: #force_inline proc "c" (strips: []Strip) {
    rm_tristripper_dispose_strips(raw_data(strips), len(strips))
}