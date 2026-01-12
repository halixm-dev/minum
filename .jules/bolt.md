# Bolt's Journal

## 2026-01-12 - Initial Setup
**Learning:** Started performance optimization mission.
**Action:** Created this journal to track critical learnings.

## 2026-01-12 - List Virtualization
**Learning:** `ListView.builder` with `shrinkWrap: true` is a common anti-pattern in Flutter apps essentially defeating virtualization.
**Action:** Refactored `MainHydrationView` to use `CustomScrollView` and `SliverList`. This allows mixed content (headers + list) while maintaining O(1) layout cost for the list.
**Challenge:** Mocking complex Providers with deep dependency trees (UserProvider, HydrationProvider) for widget tests is error-prone without code generation. Manual mocks require careful maintenance of all interface methods.
