# State Traps

- `setState` after dispose — crashes, check `if (mounted)` first
- State lost on parent rebuild — use key to preserve, or lift state up
- Key type matters — `ValueKey`, `ObjectKey`, `UniqueKey` have different equality
- Missing key in list — Flutter can't track which item changed, state mismatches
- `const` widget with state — state preserved even if you expect reset
- initState async — can't await, use `Future.microtask` or `WidgetsBinding.addPostFrameCallback`
- State in build method — recreated every build, move to field
- Late init in initState — widget.property safe, context is not