# Bolt's Journal

## 2026-01-12 - Initial Setup
**Learning:** Started performance optimization mission.
**Action:** Created this journal to track critical learnings.

## 2026-01-12 - List Virtualization
**Learning:** `ListView.builder` with `shrinkWrap: true` is a common anti-pattern in Flutter apps essentially defeating virtualization.
**Action:** Refactored `MainHydrationView` to use `CustomScrollView` and `SliverList`. This allows mixed content (headers + list) while maintaining O(1) layout cost for the list.
**Challenge:** Mocking complex Providers with deep dependency trees (UserProvider, HydrationProvider) for widget tests is error-prone without code generation. Manual mocks require careful maintenance of all interface methods.

## 2026-01-12 - Provider Rebuild Optimization
**Learning:** Accessing `Provider.of<T>(context)` at the top of a `build` method causes the entire widget to rebuild whenever *any* property of `T` changes. In `MainHydrationView`, `UserProvider` and `HydrationProvider` were causing full screen rebuilds even for unrelated state changes (e.g., adding a log caused header and reminder sections to rebuild unnecessarily).
**Action:** Refactored `MainHydrationView` to remove top-level provider access. Used `Selector` and `Consumer` widgets to wrap only the specific UI sections that depend on changing data.
**Impact:** Reduced rebuild scope from the entire screen to only the specific modified sections (e.g., log list or progress bar).
**Constraint:** Had to workaround pre-existing compilation errors in `SettingsScreen` and `HydrationHistoryScreen` to verify tests.
