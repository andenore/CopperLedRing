# Settings only; the board remains authoritative for geometry and electrical intent.
SOURCE := board.copper
LAYERS := 2
FAB_PROFILE := generic
ASSEMBLY_LOCK := assembly.lock
CHECK_ARGS :=
ROUTE_ARGS := --candidates 1 --fanout --fanout-maze --early-plane-stitch --stitch-surface-zones --plane-stitch-radius-mm 5 --plane-contact-radius-mm 8 --plane-stitch-detour-mm 3
ACCEPTANCE_BLOCKER :=
