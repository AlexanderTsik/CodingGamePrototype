extends Node
## Global debug logging (autoload singleton "Dbg").
##
## Runtime diagnostics are routed through Dbg.p() instead of print() so the
## exported HTML5 build doesn't pay the cost of a synchronous console.log over
## the JS bridge on every execution step — a real source of in-game lag.
##
## Enabled automatically in the editor and debug builds; silent in exported
## release builds. Set `Dbg.enabled` at runtime to force it on or off.

var enabled: bool = OS.is_debug_build()

func p(msg) -> void:
	if enabled:
		print(msg)
