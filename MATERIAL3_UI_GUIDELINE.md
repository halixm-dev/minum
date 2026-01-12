Material Design 3: A Comprehensive UI Guideline
I. Introduction to Material Design 3Material Design 3 (M3) represents the latest evolution of Google's open-source design system, meticulously crafted to empower designers and developers in creating user interfaces that are not only aesthetically pleasing but also deeply functional and engaging. This document serves as a comprehensive guideline, drawing from the official Material Design 3 resources, to provide a detailed understanding of its principles, visual styling, component architecture, and implementation strategies. It aims to equip teams with the knowledge to build beautiful, adaptive, and expressive digital products.

A. Core Philosophy: Personal, Adaptive, Expressive
The foundational philosophy of Material Design 3 revolves around three key pillars: Personal, Adaptive, and Expressive. This approach signifies a departure from rigid, one-size-fits-all design systems towards a more fluid and user-centric methodology.

Personal: M3 builds upon the personalization features introduced with Material You, most notably through its dynamic color system. This allows UIs to tailor their appearance based on user preferences, such as wallpaper choices, creating experiences that feel unique and individually attuned.1 The system is designed to help users make products that are engaging and desirable by reflecting individual style.2


Adaptive: A critical aspect of M3 is its inherent adaptability. The system provides robust foundations for creating layouts that respond seamlessly to a diverse range of screen sizes, orientations, and device form factors, including large screens and foldables.1 This ensures a consistent and optimized user experience regardless of the context in which the application is used. The guidance applies to Android and the web, emphasizing layouts that scale across devices.3


Expressive: M3 encourages designs that go beyond mere functionality to convey emotion and brand identity more effectively. This is particularly amplified by the M3 Expressive update, which offers an expanded toolkit for crafting emotionally impactful user experiences through more flexible components, vibrant styles, and integrated motion.1

These three pillars are not isolated concepts but interconnected principles that should guide every design decision within the M3 framework. The system's architecture, from its color and typography systems to its component behaviors, is engineered to support these core tenets. For instance, dynamic color directly enables personalization, while canonical layouts and window size classes facilitate adaptivity. The enhanced motion system and expanded shape library contribute to more expressive interfaces. By internalizing this philosophy, design and development teams can leverage M3 to create products that are not only usable but also resonate deeply with users, fostering a stronger connection and enhancing overall satisfaction.

B. Understanding M3 Expressive: An Evolution in Design
M3 Expressive is not a separate version of Material Design but rather an expansion of the core M3 system.1 It introduces a collection of new features, updated components, and refined design tactics specifically aimed at enabling the creation of "emotionally impactful UX".1 This evolution is backed by significant user research, which indicates a preference for M3 Expressive designs across various age groups, alongside findings of improved usability.5Key enhancements introduced by M3 Expressive include:
More Flexible Components: Components like buttons now feature a wider array of shapes (round and square) and sizes (Extra Small to Extra Large), along with new functionalities such as toggle states and shape morphing when selected or pressed.6 Vibrant Styles & Emphasized Typography: The M3 type scale has been augmented with 15 new emphasized styles, providing more tools for creating visual hierarchy and drawing attention to key information.7 This allows for "stunning editorial moments" through the use of variable fonts.1
Integrated Motion Physics System: A new, simplified spring-based motion system replaces the older easing and duration model for component interactions, making transitions feel more "alive, fluid, and natural".1 Expanded Shape Library: M3 Expressive introduces 35 new shapes and integrated shape morphing capabilities, offering greater versatility in visual design and interaction feedback.1 These features provide designers with a richer palette to craft unique and engaging user experiences. The availability of M3 Expressive features may vary across platforms (Android, Flutter, Web), with Jetpack Compose often being the first to implement new additions.6 Therefore, it is advisable to consult the latest official documentation for platform-specific availability.

The introduction of M3 Expressive underscores a deliberate move towards providing designers with the tools to not just build functional interfaces, but to tell compelling brand stories and evoke specific emotional responses. The expanded options in shape, motion, and typography are not merely aesthetic additions; they are instruments for enhancing communication, guiding user attention, and creating memorable "hero moments" within the application flow.4 Thoughtful application of these expressive features can significantly elevate the user experience, making products feel more dynamic, responsive, and aligned with brand identity.

C. Purpose and Structure of These Guidelines

The purpose of these guidelines is to provide a detailed and comprehensive reference for understanding and implementing Material Design 3, based on the available information. This document aims to distill the core principles, styling systems, component specifications, and customization strategies outlined in the official M3 resources.

The structure of these guidelines mirrors the organization of the official Material.io website 1, which divides the design system into three main parts:
Design Foundations: Covering the fundamental building blocks such as accessibility, layout, interaction states, and design tokens.
Visual Style System: Detailing the systems for applying color, typography, icons, motion, and shape.
Component Guidelines: Providing specifications and usage guidance for individual UI components, from buttons to navigation elements.
Implementing and Customizing M3: Discussing the practical application of M3, including the use of design tokens, platform-specific considerations, and tools like the Material Theme Builder.
This structure is intended to provide a logical and familiar framework for users to navigate the complexities of M3, enabling them to efficiently find the information they need to design and develop high-quality applications. Developer resources for Android, Flutter, and the Web are also key aspects of the M3 ecosystem.1II. Design Foundations: The Bedrock of M3 UIs

The foundations of Material Design 3 provide the essential principles and systems for creating robust, usable, and accessible user interfaces. These elements—Layout, Interaction States, Accessibility, and Design Tokens—are not merely stylistic suggestions but core architectural components that ensure consistency, adaptability, and a high-quality user experience across all M3 applications.

A. Layout System: Structuring Adaptive Interfaces
Material Design 3's layout system is engineered to create visual structures that are both coherent and adaptable across a multitude of screen sizes and device types. It moves beyond rigid grids to embrace more flexible and context-aware approaches.1. Core Principles: Adaptability, Window Size Classes, Canonical Layouts

The M3 layout guidance applies to both Android and web platforms, emphasizing the creation of UIs that gracefully adapt to different screen sizes and orientations.3 A significant shift from previous versions is the recommendation to begin new layouts from a canonical layout rather than a layout grid.3 This approach helps ensure that designs can scale effectively across various devices and form factors.

Central to M3's adaptive strategy are window size classes, which are opinionated breakpoints. Material Design recommends creating layouts for five distinct window size classes 3:
Compact: Typically phones in portrait mode (e.g., 0-599dp width).
Medium: Larger phones in landscape, tablets in portrait (e.g., 600-839dp width).
Expanded: Tablets in landscape, larger foldables (e.g., 840dp+ width, often subdivided into 840-1199dp).
Large: Larger tablets, desktops (e.g., 1200-1599dp width).
Extra-large: Very large screens, ultra-wide monitors (e.g., 1600dp+ width).
These window size classes provide a structured framework for making informed decisions about how content and UI elements should reflow and reorganize to best suit the available screen real estate. The emphasis on canonical layouts (pre-defined common screen structures like list-detail or feed views) provides proven patterns for common UI scenarios, which can then be adapted using these window size classes.
3 This combination promotes consistency while allowing for tailored experiences on different devices. The system also considers elements like columns, margins, panes, and spacers as integral parts of the layout structure.3The move towards canonical layouts and window size classes, rather than a strict adherence to a universal grid system for all initial design, represents a more mature approach to responsive design. While grids (like the 4, 8, and 12-column grids mentioned in M2 context 16) still inform content organization within panes or regions, the primary driver for overall screen structure in M3 is the adaptation of canonical patterns across these defined window size classes. This allows for more sophisticated and contextually appropriate UIs that go beyond simple reflowing of content blocks.
2. Key Layout Elements: Panes, Regions, and Spacing
M3 layouts are constructed from several key elements that define structure and relationships within the UI:

Regions: A window is typically divided into two primary regions: the navigation region and the body region.17

Navigation Region: Houses components that help users navigate between destinations or access important actions. It's often placed near the edges of the window for easy reach (left for LTR languages, right for RTL).17
Body Region: Contains the main content of the app, such as images, text, lists, cards, and buttons. Content within the body region is organized into one or more panes.17 Panes: Panes are layout containers within the body region that house other components and elements.3 All content must reside within a pane. M3 layouts can contain 1 to 3 panes, which adapt dynamically to the window size class and user's language settings.17

Types of Panes:
Fixed: Maintain a constant width, regardless of available space.
Flexible: Respond to available space, growing and shrinking as needed. All layouts require at least one flexible pane to be responsive.17
Pane Adaptation Strategies: Panes can adapt using strategies like:
Show and Hide: Supporting panes enter or exit based on available space.
Levitate: One pane is placed on top of another (e.g., dialogs, floating panes).
Reflow: Panes change position or orientation (e.g., stacking vertically on smaller screens).17
Drag Handles: Layouts with multiple panes can be resized using a drag handle, allowing users to adjust the width of flexible panes or collapse/expand fixed panes.3
Spacing: Spacing is critical for creating visual hierarchy, grouping related elements, and ensuring comfortable readability.
Margins: The space between the edge of a window/pane and its internal content. Margin widths can change at different breakpoints, with wider margins generally used on larger screens.3 M3 defines specific margin recommendations for each window size class.19
Spacers: The space between two panes, typically measuring 24dp wide. Spacers can contain drag handles.3
Padding: The space between UI elements, measured in increments of 4dp. Padding does not need to span the entire width or height of a layout.19
Grouping: Achieved through explicit means (outlines, dividers, shadows) or implicit means (proximity, open space) to connect related elements and differentiate unrelated ones.19

The careful consideration of these layout elements and spacing guidelines is fundamental to achieving adaptive and usable interfaces. The system of panes and regions allows for complex UIs to be broken down into manageable, adaptable sections. Spacing, in turn, dictates the rhythm and clarity of the layout, guiding the user's eye and improving comprehension. The introduction of drag handles further empowers users by giving them control over the layout in multi-pane scenarios.33. Bidirectionality and Right-to-Left (RTL) Support

Material Design 3 inherently supports bidirectionality, ensuring that layouts and components adapt correctly for right-to-left (RTL) languages. This involves more than just flipping the entire UI.
Data Point: For RTL languages, navigation components are typically placed on the right side.17 Icons, symbols, and label text within components like text fields (e.g., clear icon, voice input icon, dropdown icon) also need to adjust their position based on LTR or RTL contexts.20 Side sheets, for instance, should appear on the left edge of the window with all elements reversed in RTL languages.22 Linear progress indicators should be mirrored horizontally for RTL languages, while circular ones do not require mirroring.23
Context & Importance: Proper RTL support is crucial for global applications, ensuring usability and a natural feel for users in RTL-reading regions. M3 provides the foundational considerations for this.
B. Interaction States: Communicating UI Element Status
Interaction states are visual cues that communicate the status of a component or interactive element as a user interacts with it. Consistent and clear state indication is vital for usability, providing feedback and affirming user actions.

1. Overview of Common States
Material Design 3 defines several common interaction states 24:
Enabled: The default state of an interactive component, indicating it is operable. Styling is the component's default.24
Disabled: Communicates that a component is inoperable. Visually indicated by color changes (e.g., reduced opacity, often 38% of the enabled state in M2 context 26) and potentially reduced elevation. Disabled states do not need to meet standard contrast requirements.25 They cannot be focused, dragged, or pressed.25
Hover: Indicates that a user has placed a cursor over an interactive element. Often shown with a state layer overlay.24 Hover states typically use a low-emphasis animated fade and can be combined with other states like focused or selected.25
Focused: Communicates that a user has highlighted an element, typically via keyboard (Tab key) or voice input. Often shown with a higher-emphasis surface overlay or a distinct focus indicator ring.24 This state is crucial for keyboard accessibility.
Pressed: Indicates a user tap or click. Usually signaled by a ripple overlay and can trigger a change in the component's composition. This state is high-emphasis.24
Dragged: Communicates when a user presses and moves an element.24 Applicable to components like sliders and draggable list items or cards.25
Selected: Communicates a user choice, such as a selected tab or list item.26
Activated: Communicates a highlighted destination or an "on" state for toggles.26

2. Visual Indicators and State Layers
M3 utilizes state layers as a primary mechanism for visually representing states like hover, focus, and press. These are semi-transparent overlays applied to components. The opacity of these layers varies depending on the state (e.g., hover might be a lower opacity than focus or press).26 For example, a common hover state layer opacity is 0.08, while focus and pressed states might use 0.1 or higher.29 Disabled states often use reduced opacity of the entire component.26The keyboard focus indicator is a critical accessibility feature, often appearing as a ring around the focused element, helping users understand where they are on the page when navigating via keyboard.25 The thickness and offset of this indicator are defined by tokens (e.g., md.sys.state.focus-indicator.thickness often 3dp, md.sys.state.focus-indicator.outer-offset often 2dp).29States can often be combined, for example, an item can be both selected and hovered.24 The system is designed to apply these states consistently across components, ensuring a predictable user experience.24 The use of at least two visual indicators for states is encouraged to ensure accessibility.24The systematic application of state layers provides a consistent visual language for interaction feedback. This predictability reduces cognitive load for users, as they learn to associate certain visual changes (like the subtle overlay of a hover state or the more pronounced ripple of a pressed state) with specific interactions across the entire application. This consistency is a hallmark of a well-designed system.

3. Application to Components
Different states apply to different types of components:
Action, Selection, and Input Components (e.g., Buttons, Checkboxes, Chips, Text Fields, Sliders, List Items, Radio Buttons) typically inherit enabled, disabled, hover, focused, and pressed states.25
Communication, Containment, and Navigation Components (e.g., App Bars, Badges, Dialogs, Menus, Navigation Bar/Drawer/Rail, Sheets, Tabs) often do not inherit hover or pressed states on the entire component itself, though their interactive child elements do.25 For instance, an app bar as a whole might not have a hover state, but the icon buttons within it will.25
Dragged states are typically inherited by components like Cards, Chips, List Items, and Sliders.25
Understanding which states are relevant to which components is crucial for correct implementation and for providing appropriate user feedback. For example, a purely informational dialog might not have a hover state, but a button within that dialog will. This nuanced application of states ensures that feedback is meaningful and not distracting.

C. Accessibility (A11y): Designing for Everyone
Accessibility is a core design value for Material Design 3, with the goal of enabling users with diverse abilities—including those with low vision, blindness, hearing impairments, cognitive impairments, motor impairments, or situational disabilities—to navigate, understand, and enjoy UIs.31 Accessibility standards are built into M3 components, providing a foundation for inclusive product design.321. Core Principles for Accessible DesignM3 promotes several principles for accessible design 32:
Honor Individuals: Recognize that universal default experiences rarely meet everyone's needs. Provide customizable features and choices to allow users to adapt the interface to their shifting conditions and preferences.
Learn Before, Not After: Invest time in understanding the needs of users with a wide range of abilities before defining solutions. This proactive research can reduce bias and lead to more creative and inclusive designs.
Requirements as a Starting Point: View accessibility standards like WCAG (Web Content Accessibility Guidelines) not as constraints, but as opportunities that can lead to innovative solutions benefiting a broader user base. Features like dark mode and text-to-speech originated from addressing specific access needs.
Anticipating a wide range of human experiences and disabilities from the outset helps prevent costly redesigns and reduces design and technical debt.322. Key Accessibility Considerations

Color and Contrast: Sufficient color contrast between text, icons, and their backgrounds is essential for users with low vision.

The W3C recommends contrast ratios of at least 4.5:1 for small text and 3:1 for large text (14pt bold/18pt regular and up) and graphics against their background.27
Non-text elements like button containers should also aim for a 3:1 contrast ratio against their background, especially when clustered with other elements.27
Disabled states are an exception and do not need to meet these contrast requirements.27
M3's color system is built on accessible color pairings, and color roles are designed to ensure a minimum 3:1 contrast for many pairings.34

Touch Target Size: Interactive elements must have adequately sized touch targets to be easily operable, especially for users with motor impairments or those using touchscreens in non-ideal conditions.

M3 recommends touch targets of at least 48x48 dp for most platforms.33 This typically results in a physical size of about 9mm.
Pointer targets (for mouse or stylus) should be a minimum of 44x44 dp.35
Adequate spacing between touch targets (e.g., 8dp or more) is also crucial to prevent accidental activation.33
Components like checkboxes and tabs should not have density applied by default if it reduces target sizes below these recommendations; instead, density should be a user-selectable option.36


Keyboard Navigation and Focus Management: Users who rely on keyboards or other assistive technologies must be able to navigate and interact with all interactive elements.

All interactive elements must be focusable (receive a tab stop).28
A clear visual focus indicator (e.g., a ring) must be present on the focused element.25
The tab order should be logical and predictable, often following the visual flow of the page.28
Specific keyboard interactions (e.g., Space or Enter to activate buttons or toggle checkboxes, Arrow keys for navigating menus or tabs) are defined for components.28
Focus should not be trapped within components like snackbars or tooltips; users must be able to navigate freely.39

Labels and Semantic HTML/ARIA: Clear labels and proper semantic markup are essential for assistive technologies like screen readers.

All interactive elements and meaningful content should have clear, concise, and descriptive labels.21
If an icon's meaning is not universally obvious, a text label is crucial.41 For navigation items, accessibility labels can provide more context than visible labels (e.g., visible "Library" might have an accessibility label "Music library").38
For web, using semantic HTML elements (e.g., <nav>, <button>) and ARIA (Accessible Rich Internet Applications) attributes (e.g., role="tooltip", aria-describedby) correctly conveys the purpose and state of UI elements to assistive technologies.35 M3 recommends defining landmark roles (navigation, search, main, etc.) to help users understand page structure.35
Images that are purely decorative should be hidden from screen readers.28



Motion and Animation: While motion can enhance UX, it must be implemented thoughtfully to avoid issues for users sensitive to motion or those using screen readers.

Transitions should respect user settings for reduced motion. If enabled, animations should be subtle (e.g., fades instead of intense sliding) and decorative effects like parallax or shape morphing should be disabled.44
Content that moves, scrolls, or blinks automatically for more than five seconds should be pausable or stoppable.33
Flashing content should be limited to avoid triggering seizures.33


The integration of these accessibility considerations directly into the M3 framework, from component design to theming, signifies a commitment to inclusive design. It's not an afterthought but a fundamental aspect of the system. This built-in support provides a strong starting point, but it remains the responsibility of design and development teams to test their applications with assistive technologies and real users to ensure a truly accessible experience.D. Design Tokens: The Language of StyleDesign tokens are a foundational element in Material Design 3, serving as the single source of truth for stylistic values. They replace static, hard-coded values (like hex codes for colors or pixel values for spacing) with self-explanatory, named entities. This system is crucial for maintaining consistency, enabling theming, and streamlining collaboration between design and development.1. What are Design Tokens?A design token consists of two main parts 45:
A name (often code-like, e.g., md.ref.palette.secondary90)
An associated value (e.g., #E8DEF8 for a color, Roboto for a font family, 16pt for a size, or even another token).
Tokens store style values for colors, typography (font, size, weight, line height, tracking), shape (corner radii), elevation, and even motion parameters (springs).8The importance of design tokens lies in their ability to create a shared language and a centralized repository for all design decisions.45 When both designers (in their Figma mockups, for example) and engineers (in their code) reference the same token (e.g., for "secondary container color"), they can be confident that the exact same style is being applied, eliminating discrepancies and ensuring visual consistency.45 This systematic approach makes it easier to build, maintain, and scale products using a design system. Style updates made to a token propagate consistently throughout an entire product or suite of products.452. Token Naming Convention and Hierarchy
Material Design tokens follow a structured naming convention that communicates their origin, class, and purpose. A typical token name has parts separated by periods 45:
System Name: e.g., md for Material Design.
Token Class Abbreviation:

ref for Reference Tokens
sys for System Tokens
comp for Component Tokens


Descriptive Role: Words communicating the token's specific purpose (e.g., palette.secondary90, color.on-primary, button.container.color).
Material Design utilizes three main classes of tokens, forming a hierarchy 45:
Reference Tokens: These represent the palette of available raw style options. They usually point to a static value (e.g., md.ref.palette.blue60 might be #00658F) but can also point to other reference tokens. They form the most granular level of the token system.
System Tokens: These tokens define the semantic roles that give the design system its character. They assign a purpose to a reference token within the UI (e.g., md.sys.color.primary might point to md.ref.palette.primary40). System tokens are where theming decisions are made. A crucial aspect is that system tokens can point to different reference tokens depending on the context (e.g., light theme vs. dark theme, dynamic color inputs). For example, md.sys.color.background will resolve to a light color in a light theme and a dark color in a dark theme.
Component Tokens: (Still in development for some areas, but the concept is established) These tokens define the design properties assigned to specific elements within a component (e.g., md.comp.filled-button.container.color might point to md.sys.color.primary). They should ideally point to system or reference tokens rather than hard-coded values.
This layered architecture—Reference → System → Component—is a cornerstone of M3's power and flexibility. It allows for precise control over styling at different levels of abstraction.
Changing a Reference Token directly alters a base value, which could have wide-ranging effects if that token is used by multiple System or Component tokens. This is typically done when defining a core brand palette.
Changing a System Token (e.g., redefining what md.sys.color.primary points to) implements a semantic theme change consistently across all components that use that system role. This is the primary mechanism for theming.
Changing a Component Token allows for fine-tuning the appearance of a specific component part without affecting other components or the global system roles. This offers granular control for specific UI needs.
This structured approach is fundamental to M3's scalability and maintainability. It ensures that themes can be applied globally and consistently, while still allowing for specific adjustments where necessary.Table II.D.1: M3 Design Token Classes
Token ClassDescriptionNaming Convention PrefixPrimary RoleExample Token NameExample Value (Illustrative)Reference TokensThe complete set of available style options, often static values.md.ref.Provide the raw palette of choices for the system.md.ref.palette.secondary90#E8DEF8 45System TokensSemantic decisions and roles that define the system's character (color, typography, elevation, shape).md.sys.Assign purpose to reference tokens; enable theming and contextual adaptation (e.g., light/dark themes).md.sys.color.secondary-containerPoints to a Reference TokenComponent TokensDesign properties assigned to elements within a specific component (e.g., button icon color, container shape).md.comp.Define the specific styling of individual component parts, ideally referencing System or Reference tokens.md.comp.button.label-text.colorPoints to a System Token
Data sourced from.453. Contextual Values and ThemingA powerful feature of M3's token system is its support for contextual values.45 This means a single system token can resolve to different reference tokens (and thus different actual values) based on a set of conditions or "contexts." Examples of contexts include:
Light theme vs. Dark theme
Device form factors
Dense layouts
Right-to-left writing systems
Dynamic color inputs from user wallpaper
For instance, the system token md.sys.color.background will automatically point to an appropriate light color reference token when the light theme is active, and a dark color reference token when the dark theme is active.45 This abstraction is what makes M3's dynamic color and adaptive styling so effective. Designers and developers work with semantic system tokens, and the system handles the resolution to the correct appearance based on the current context. This greatly simplifies the process of creating UIs that are both personalized and adaptive, as it obviates the need for extensive conditional styling logic in application code. Tokens are the engine driving M3's dynamic behavior.III. Visual Style System: Crafting the M3 Look and FeelThe visual style system in Material Design 3 provides a comprehensive framework for defining the aesthetic and sensory qualities of a user interface. It encompasses guidelines and tools for color, typography, shape, icons, and motion. These systems are designed to work harmoniously, enabling the creation of UIs that are not only visually appealing but also expressive, accessible, and consistent with the M3 philosophy. A key aspect of this system is its deep integration with design tokens, which allow for systematic customization and theming.48A. Color System: Dynamic, Accessible, and ExpressiveColor in M3 is a powerful tool for expressing style, communicating meaning, and ensuring usability. The system is built around dynamic color, accessibility, and a structured set of color roles.481. Dynamic Color: Personalization at its CoreDynamic color is a cornerstone of M3's personalization capabilities, particularly on Android (Android 12+ 2). It allows an application's color palette to adapt based on user settings, such as their chosen wallpaper, or even from in-app content like album art.49

How it Works:

Source Color Identification: A single source color is extracted, either from the user's wallpaper (user-generated color) or from in-app content (content-based color).49
Tonal Palette Generation: This source color is then used to generate a set of five key colors: Primary, Secondary, Tertiary, Neutral, and Neutral Variant.2 Each of these key colors relates to a tonal palette of 13 tones (and sometimes more, with values typically from 0 to 100, plus specific steps like 95, 98, 99). Lower tonal values represent darker colors.2
Color Role Assignment: Colors from these five tonal palettes are then algorithmically assigned to the 26 standard color roles (and additional ones), ensuring that the UI elements receive appropriate colors for both light and dark themes from a single set of roles.34
Hue, Chroma, Tone (HCT): The M3 color system utilizes the HCT color space. HCT defines colors using three dimensions: Hue (the color itself, e.g., red, blue), Chroma (the intensity or purity of the color), and Tone (lightness/darkness).49 A key advantage of HCT is that it allows manipulation of hue and chroma without affecting tone, which is crucial for generating accessible color schemes with predictable contrast.49 Different hues have different maximal chroma values at various tones due to physical and biological limitations.49



Choosing a Source:

User-Generated Color: Best for personalized experiences where the app should reflect the user's device theme.51
Content-Based Color: Suitable when in-app content (e.g., album art in a music player) is central, and the UI should harmonize with that content. Often used for contained screen elements adjacent to the source image.49
Multiple Sources: Possible with advanced customization, allowing parts of the UI to reflect user wallpaper and other parts to reflect in-app content.51


The dynamic color system is designed to be accessible by default, with algorithms ensuring sufficient contrast between color roles.34 Users can also control contrast levels (Standard, Medium, High).49 The Material Theme Builder is the recommended tool for designers to explore how their brand colors translate into dynamic color schemes and to generate these schemes for implementation.2This dynamic approach allows applications to feel deeply integrated with the user's personal device environment or the content they are interacting with, moving beyond static, predefined themes. It represents a significant step towards more adaptive and emotionally resonant interfaces.2. Color Roles: Semantic Application of ColorColor roles are semantic assignments that dictate how colors from the tonal palettes are applied to UI components. They are the connective tissue between the abstract color system and the concrete UI elements, ensuring consistent and meaningful color application across an app.34 There are 26 standard color roles, organized into groups, each with a specific purpose. These roles are tokenized and are used for both light and dark themes.34

Primary Roles (4 roles): Used for the most prominent components, high-emphasis buttons, and active states.

primary: High-emphasis fills, text, icons against surface.
on-primary: Text/icons against primary.
primary-container: Standout fill color against surface (e.g., FAB).
on-primary-container: Text/icons against primary container.
Example: A Floating Action Button (FAB) might use primary-container for its fill and on-primary-container for its icon.34



Secondary Roles (4 roles): Used for less prominent components that still require some emphasis, like filter chips or tonal buttons.

secondary: Less prominent fills, text, icons against surface.
on-secondary: Text/icons against secondary.
secondary-container: Less prominent fill against surface.
on-secondary-container: Text/icons against secondary container.
Example: The selected state of a navigation icon or a tonal button might use secondary roles.34 List items might use on-secondary-container for selected label text.53



Tertiary Roles (4 roles): Used for contrasting accents that balance primary and secondary colors or bring attention to elements like input fields or badges.

tertiary: Complementary fills, text, icons against surface.
on-tertiary: Text/icons against tertiary.
tertiary-container: Complementary container color against surface.
on-tertiary-container: Text/icons against tertiary container.
Example: Input fields or attention-grabbing badges might utilize tertiary colors.34



Error Roles (4 roles): Used for indicating errors or urgent situations.

error: Attention-grabbing color for fills, icons, text.
on-error: Text/icons against error.
error-container: Attention-grabbing fill against surface.
on-error-container: Text/icons against error container.34



Surface Roles (multiple roles): Used for backgrounds and large, low-emphasis areas.

surface: Default color for backgrounds.
on-surface: Text/icons against any surface or surface container.
on-surface-variant: Lower-emphasis text/icons against any surface or surface container.
surface-container, surface-container-low, surface-container-high, surface-container-highest: Provide a range of neutral background tones for different levels of emphasis or containment.29
surface-dim, surface-bright: Dimmest and brightest surface colors in themes, useful for creating nuanced backgrounds or highlighting specific areas.34
Example: A card's background might use surface-container-low (for elevated cards) or surface-container-highest (for filled cards).29 List item label text often uses on-surface.53



Outline Roles (2 roles): Used for important boundaries or decorative dividers.

outline: For significant boundaries like text field outlines.
outline-variant: For decorative elements like dividers, where other elements provide sufficient contrast.34
Example: A text field border might use outline, while a list item divider uses outline-variant.34



Inverse Roles (3 roles): Used selectively to create a contrasting effect, reversing the typical color relationships of the surrounding UI.

inverse-surface: Background fills for elements contrasting against surface.
inverse-on-surface: Text/icons against inverse-surface.
inverse-primary: Actionable elements (e.g., text buttons) against inverse-surface.
Example: Snackbars often use inverse roles for their background, text, and action button.34



Fixed and Fixed Dim Roles: These are add-on roles (e.g., primary-fixed, primary-fixed-dim) designed to provide colors that remain consistent regardless of theme changes, useful for elements that need to maintain a specific brand color or visual cue across light and dark modes.34

The consistent use of these color roles, mapped via design tokens, is crucial for achieving accessible, themable, and visually coherent UIs. They ensure that color is applied semantically, reinforcing the meaning and hierarchy of UI elements rather than being merely decorative.3. Customizing Color SchemesM3 provides robust mechanisms for customizing color schemes to align with brand identity while leveraging the power of the dynamic color system and accessibility features.

Material Theme Builder (MTB): This is the primary tool for creating custom color schemes.2

Users can input one or more brand colors (Primary is essential; Secondary, Tertiary, Error, Neutral, Neutral Variant are optional custom sources).52
The MTB then generates a full M3-compliant color scheme, including all tonal palettes and color role assignments, derived from these source colors.52
It can export these schemes as design tokens for various platforms (Jetpack Compose, Android XML, Flutter, Web, JSON) and as Figma styles.52
The MTB also allows designers to preview how their custom scheme will look with dynamic color applied from different wallpaper sources.50



Static Colors (Custom Colors): Beyond the core scheme, M3 allows for the definition of additional static colors that remain consistent even when other parts of the scheme change dynamically (e.g., a specific "success" green or "warning" yellow).56

When a custom static color is input into the MTB, it generates four derived color roles for that color (e.g., success, on-success, success-container, on-success-container), following M3 conventions.56
These static colors can be optionally "harmonized" with the dynamic scheme's primary color, meaning their hues will shift slightly to create a more cohesive overall appearance while retaining their semantic meaning.56 The M3 system already provides an "Error" color out-of-the-box.56



Defining Custom Color Roles: For advanced scenarios where existing roles or static colors don't meet specific needs, new color roles can be defined within the Material system. This involves specifying a reference palette, starting tones for light/dark themes, and contrast requirements for color pairings.56 This ensures custom roles still benefit from features like user-controlled contrast.

This flexibility in customization, facilitated by the Material Theme Builder and the underlying token system, allows brands to express their unique identity while adhering to M3's principles of accessibility and dynamic adaptation. The system encourages mapping brand colors to the M3 color roles, ensuring that even custom themes can integrate seamlessly with user preferences and platform features like dynamic color.52B. Typography System: Legible, Expressive, and Scalable TextMaterial Design 3's typography system is designed to ensure that text is not only legible and readable but also expressive and adaptable across various contexts and screen sizes. It provides a comprehensive type scale, recommends specific font families, and leverages design tokens for consistent application and customization.71. Type Scale and RolesM3 defines a type scale comprising 15 baseline styles and, with the M3 Expressive update, an additional 15 emphasized styles, totaling 30 font styles.7 Both sets follow the same scale from Display Large down to Label Small. The emphasized styles typically feature a higher weight or other minor adjustments to add more expression and are suitable for highlighting key moments, bold text, or selected elements.46These styles are grouped into five semantic roles, which are more descriptive and aid in matching the style to its use case 2:
Display (Large, Medium, Small): For very large, short, and important text or numerals.
Headline (Large, Medium, Small): Best for short, high-emphasis text.
Title (Large, Medium, Small): Smaller than headlines, typically for medium-emphasis text that remains relatively short.
Body (Large, Medium, Small): Used for longer passages of text in the application.
Label (Large, Medium, Small): For smaller, utilitarian text such as captions or button text.
Each of these 15 styles (e.g., Display Large, Body Medium, Label Small) has defined properties for font family, weight, size, and line height. Tracking (letter-spacing) is also a key property.2 Not every product will use all 30 styles; rather, teams should select the styles most appropriate for their content and hierarchy needs.2The default font sizes and line heights for the baseline M3 type scale (using Roboto) are as follows 2:Table III.B.1: M3 Default Type Scale (Roboto)M3 RoleDefault Font Size / Line Height (dp/sp)displayLarge57 / 64displayMedium45 / 52displaySmall36 / 44headlineLarge32 / 40headlineMedium28 / 36headlineSmall24 / 32titleLarge22 / 28 (Roboto Medium)titleMedium16 / 24 (Roboto Medium)titleSmall14 / 20 (Roboto Medium)bodyLarge16 / 24bodyMedium14 / 20bodySmall12 / 16labelLarge14 / 20 (Roboto Medium)labelMedium12 / 16 (Roboto Medium)labelSmall11 / 16 (Roboto Medium)Data sourced from.2 Note: "New" prefix from snippet 2 for some Roboto Medium styles indicates an update or distinction.2. Recommended Font Families and Variable Fonts
Roboto: The default typeface for Android and is used in the M3 type scale. It supports a vast number of glyphs for global language coverage.46
Roboto Flex: A highly versatile variable font that extends Roboto's capabilities with a wide range of weights, widths, and other customizable attributes (axes) like optical size and grade. It is designed to be super scalable and adaptable, especially for large-screen capabilities and fine-tuning text expression.7 While extremely powerful, Roboto Flex is not yet part of the default M3 type scale for all components but is available as a standalone font and recommended for expressive editorial treatments.7
Roboto Serif: Another variable font family designed for comfortable reading, suitable for both body text and interface elements due to its extensive set of weights and widths.7
Roboto Mono: A monospaced version of Roboto, useful for code or aligning numbers.7
Noto Sans: A global font collection used as a "fallback" font when a primary font like Roboto or Roboto Flex doesn't support specific characters or languages, ensuring text remains legible and visually consistent.57
Variable Fonts are a key feature in M3 typography, offering greater control over expression.7 Fonts like Roboto Flex have multiple axes that can be adjusted, such as 7:
Weight (wght): Stroke thickness.
Width (wdth): Horizontal space occupied by characters.
Slant (slnt): Angle of inclination.
Grade (GRAD): A finer adjustment to stroke thickness than weight, often used to match visual density with other text or icons without significantly changing the font's footprint.
Optical Size (opsz): Adjusts stroke weight and character spacing to optimize legibility at different display sizes.
Other advanced axes for fine-tuning stroke characteristics, counter widths, and character heights.57
The use of variable fonts allows for more nuanced typographic expression and can contribute to more dynamic and adaptive UIs, for example, by adjusting font weight or width in response to interaction or screen context.593. Typography TokensConsistent application of typography is achieved through design tokens. Each of the 30 type styles (15 baseline + 15 emphasized) has a single token that encapsulates all its default properties (font, size, weight, line height, tracking).7 For example, md.sys.typescale.body-large.font would specify the font family for the body large style, md.sys.typescale.body-large.size its size, and so on.60Individual properties like font family (md.ref.typeface.brand, md.ref.typeface.plain), weight (md.ref.typeface.weight-regular, md.ref.typeface.weight-medium), size, line height, and tracking also have their own tokens, allowing for greater customization if needed.46 These tokens are used across design tools (like Figma) and in code, ensuring consistency between design specifications and the final implementation.46 Typography tokens enable scalable size adaptation to devices or settings, including updates to style based on boldness requirements.7The M3 typography system, through its well-defined type scale, versatile font recommendations (especially variable fonts), and robust token system, provides a powerful toolkit for creating interfaces that are both highly legible and expressively rich.C. Shape System: Defining Surfaces and Expressing BrandThe shape system in Material Design 3 plays a crucial role in directing attention, identifying components, communicating state, and expressing brand identity.2 It includes a corner radius scale, principles for applying shape, and the concept of shape morphing, significantly enhanced in M3 Expressive.1. Corner Radius Scale and Shape TokensM3 defines container corner styles using a shape scale with ten levels of roundedness, ranging from square (None - 0dp) to fully circular (Full).2 This scale is more granular than M2's three-level system and is based on the amount of roundedness applied to corners rather than component size.61The defined styles include 9:
None: 0dp
Extra Small: 4dp
Small: 8dp
Medium: 12dp
Large: 16dp
Large Increased: 20dp (new in M3 Expressive)
Extra Large: 28dp (M3 Expressive updates this from a previous value, e.g., to 32dp in some contexts 9)
Extra Large Increased: 32dp (new in M3 Expressive)
Extra Extra Large: 48dp (new in M3 Expressive)
Full: Fully rounded corners (updated in M3 Expressive to use "full" tokenically, previously might have been 50% of component size 9).
These corner radii are applied to components using shape tokens.9 Material provides tokens for all corners of a component (e.g., md.sys.shape.corner.medium which might resolve to 12dp 29) and also individual corner-value tokens for creating asymmetrical shapes where different corners can have different radii.9 Asymmetrical shapes are used in M3 components like menus and split buttons for their "inner corners".61Components can have symmetric (all corners same radius) or asymmetric shapes.61 By default, rectangular shapes in M3 tend to be fully rounded in all corners.9 Customization can occur by changing the corner radius value for a style (e.g., making "medium" 14dp instead of 12dp) or by remapping a component to a different shape style (e.g., changing a button from "full" to "small" for less roundedness).612. Principles of Applying ShapeM3 provides several principles for applying shape effectively 4:
Harmony with Typography: Shapes in M3 are designed to echo key visual attributes of M3 typography (e.g., Google Sans Flex), promoting cohesion when used together.9
Embrace Tension: While Material historically focused on rounded shapes, M3 Expressive encourages the use of contrasting shapes (e.g., mixing round and square corners, or using unconventional shapes) to create visual tension. This can make designs more dynamic, memorable, and expressive, and can be used to convey states or draw attention.4
Versatility, Not Semantics: Shapes should generally be versatile and not tied to a single, literal meaning. For example, a waveform shape used in a loading indicator doesn't strictly symbolize progress and could be used elsewhere.9
Use Abstract Shapes Sparingly and Thoughtfully: While M3 Expressive adds 35 new abstract shapes to the library 1, they should be used intentionally for decorative flair or emphasis, without compromising UI clarity. Consider their fit within the overall composition and the value they add.9
Emphasize Aesthetic Moments: Use creative shapes for graphics, image cropping, avatar masking, and other non-interactive decorative elements.9
Shape Can Be 2.5D: When combined effectively with motion, shape can create an illusion of depth and volume, making visuals more eye-catching and natural.9
Optical Roundness: When nesting rounded objects, adjust corner radii to be proportional to each other to avoid an unbalanced look. A common calculation is: Outer Radius - Padding = Inner Radius.61
These principles guide designers to use shape not just as a container property but as an active element in communication and brand expression. The expanded shape library and the encouragement of "tension" allow for more diverse and unique visual identities within the M3 framework.3. Shape MorphingShape morphing is a significant feature, especially highlighted in M3 Expressive, allowing smooth transitions between different shapes.4 This is leveraged in standard components like button groups and loading indicators.10
Purpose: Shape morphing is used to better communicate:

Interaction states (e.g., a button changing shape when selected or pressed).6
Actions in progress (e.g., a loading indicator transforming).9
Changes in the environment (e.g., reacting to sound or time).9


Implementation: Access to shape morphing is available through platform-specific APIs (e.g., Shapes in Compose API for Android).10 Web availability for direct shape morphing APIs was noted as unavailable in some contexts 10, though the motion physics system can achieve similar effects. Shape morphing typically uses the expressive motion scheme by default.10
Application: It's encouraged to think about how shapes could react to various interactions like tapping, swiping, scrolling, etc..9 The M3 Expressive update added 35 new shapes and shape morphing to the Material Shapes Library (Figma) and Jetpack Compose.5
Shape morphing adds a layer of dynamic feedback and delight to interactions. It can make UIs feel more organic and responsive, reinforcing the connection between user actions and system responses. When combined with the expanded shape library, it offers powerful new avenues for expressive design.D. Iconography System: Visual Communication and Action CuesIcons in Material Design 3 serve as compact, easily recognizable symbols for actions, categories, and status information.48 The system emphasizes clarity, consistency, and adaptability, with Material Symbols being the new standard.1. Material Symbols: Styles and CustomizationMaterial Symbols are the new default icon set for M3, available as a variable font.41 This provides significant advantages in terms of flexibility and dynamic styling. Legacy Material Icons are still available but lack variable font capabilities.41Material Symbols are available in three primary styles 41:
Outlined: The default style, offering a clean and modern look.
Rounded: Uses a corner radius that pairs well with brands using heavier typography or curved elements.
Sharp: Features straight edges for a crisp style, legible even at smaller scales, suitable for brands not well-reflected by rounded shapes.
A key feature of Material Symbols is their variable font axes, allowing for dynamic customization of four attributes 41:
Weight: Defines the stroke thickness, ranging from thin (100) to bold (700). Regular weight is 400. Weight can also affect the overall size of the symbol.
Fill: Toggles between an unfilled (0) and filled (1) state for the icon. This is useful for indicating selection or active states (e.g., a selected navigation icon might be filled).
Grade: Affects symbol thickness with more granularity than weight, having a smaller impact on overall size. Grade can be matched between text fonts and symbols for visual harmony (e.g., if text has a -25 grade, the icon can too). Negative grades make symbols appear lighter.
Optical Size (opsz): Automatically adjusts the stroke weight as the icon size scales, ensuring the symbol looks visually consistent across different display sizes (typically ranging from 20dp to 48dp). This prevents icons from appearing too heavy or too light when resized from a single source vector.
These axes allow designers to fine-tune icons to perfectly match their typographic choices and UI context, leading to a more harmonious and polished visual experience. For example, the optical weight and size of text and icons should be matched for consistency.412. Applying Icons: Sizing, Placement, and Best Practices
Sizing and Target Size:

Standard icon size for components like buttons is often 20dp.6
Optical sizes typically range from 20dp (for dense layouts) to 48dp (for highlighting primary actions).41
Adequate space should surround icons for legibility and interaction, ensuring a minimum touch target of 48x48dp for most icons.35 Condensed measurements may be used for mouse/keyboard primary input.41


Usage with Text Labels:

Icons are often paired with text labels, especially for navigation or when the icon's meaning might be abstract.41
If icons are displayed without labels, their meaning must be unambiguous and accessible.41 For symbols below 20dp, an accompanying text label is generally needed, especially for complex icons or those representing key actions.41


Icon Buttons:

Icon buttons help users take minor actions with one tap and come in default and toggle types.42
They are available in four color styles (filled, tonal, outlined, standard) to indicate emphasis.42
Default icon buttons should generally use filled icons. Toggle icon buttons should use an outlined icon when unselected and a filled version when selected. If a filled version isn't available, increasing icon weight (semibold or bold) can indicate selection, ensuring selection is communicated through more than just color.42


Consistency: Use icons consistently. The same icon should not represent different actions or meanings within the same application.63
Accessibility and Localization:

Ensure icons have appropriate accessibility labels, especially if used without visible text labels.38
Be mindful of cultural interpretations of symbols and colors when localizing. An icon's meaning can vary significantly across cultures (e.g., an owl representing wisdom in one culture and a negative omen in another).41 Different locales might also prefer different symbols for the same concept (e.g., cart vs. bag for checkout).41
For RTL languages, icons that imply directionality (e.g., arrows) should be mirrored.20


The Material Symbols Figma plugin and the ability to copy/paste customized symbols from Google Fonts streamline the workflow for designers.62 The iconography system in M3, with its flexible Material Symbols and clear usage guidelines, empowers designers to use icons effectively for both functional clarity and visual expression.E. Motion System: Bringing UIs to LifeMaterial Design 3's motion system aims to make UIs expressive, easy to use, and feel natural.48 It helps guide users, provide feedback, and add a layer of polish and delight to interactions. M3 Expressive introduced a significant update with the motion physics system.11. Motion Physics System: Springs and SchemesThe M3 motion physics system is a spring-based system designed to make interactions and transitions feel more "alive, fluid, and natural".1 It is replacing the previous system based on easing and duration for many component interactions.5

Springs: Motion behavior is controlled by springs, defined by three attributes 8:

Stiffness: Higher stiffness resolves the motion faster.
Damping: Higher damping stops bounce faster. A damping value of 1 removes bounce completely.
Initial Velocity: Defines the spring's starting speed, influencing total duration in combination with stiffness and damping.
Springs are versatile and can apply to various situations (transitions, button effects, gestures), ensuring consistent motion feel.8



Motion Schemes: The physics system offers two preset motion schemes that define the overall feel of the product 8:

Expressive: Material's opinionated scheme, recommended for most situations, especially hero moments and key interactions. It often overshoots final values to add bounce.
Standard: Feels more functional with minimal bounce, suitable for utilitarian products or contexts.
Schemes can be switched as needed, even for specific components to emphasize key moments.8



Spring Tokens: On platforms like Jetpack Compose and MDC-Android, springs are available as tokens (e.g., md.sys.motion.spring.fast.spatial).8 These tokens are categorized by:

Movement Type:

Spatial: For animations involving on-screen movement (x/y position, rotation, size, rounded corners). These can overshoot.
Effects: For properties like color and opacity, where overshoot is generally not desired.


Speed: Default, Fast, and Slow. Most motion uses default speed; smaller elements might use fast, larger elements slow.
The exact values of these tokens can differ by device (wearable, phone, tablet) to ensure the perceived speed feels appropriate for the context.8 The scheme (Expressive/Standard) is typically called at the product level and applies to all tokens, making it easy to swap schemes globally.8 As of May 2025, 21 Material components on Jetpack Compose use this system by default.11


This physics-based approach allows for more natural and responsive animations that can handle interruptions and retargeting seamlessly, contributing to a more polished and intuitive user experience.2. Easing and Duration (Legacy System for Transitions)While the motion physics system is the future for component interactions, the easing and duration system is still used for page transitions and by teams that haven't yet updated to M3 Expressive features.64 Note: M3 transitions are expected to eventually be updated to use the motion physics system.44

Easing: In the physical world, objects don't start or stop instantaneously; they accelerate and decelerate. Easing creates more natural-looking motion compared to linear, mechanical transitions.64 M3 easing is generally more expressive than M2, with "snappy take offs and very soft landings," and slightly longer durations.64

Emphasized Easing Set: Recommended for most M3 transitions.

Emphasized: Speeds up quickly, then gentle rest (for elements beginning and ending on screen). Duration: ~500ms.
Emphasized Decelerate: Begins at peak velocity, then gentle rest (for elements entering the screen). Duration: ~400ms.
Emphasized Accelerate: Begins at rest, ends at peak velocity (for elements exiting the screen permanently). Duration: ~200ms.


Standard Easing Set: For small, utility-focused transitions needing to be quick, or as a fallback for platforms not supporting Emphasized easing (like iOS and Web for some older implementations).64 Durations are generally shorter (e.g., 200-300ms).64



Duration: Transitions should not be jarringly fast or tediously slow.64

Transition Size: Animations covering small screen areas use short durations (e.g., 200ms). Those traversing large areas use long durations (e.g., 500ms).64
Enter vs. Exit: Elements entering or remaining on screen use longer durations to help users focus on what's new. Elements exiting, dismissing, or collapsing use shorter durations as they require less attention.64 For example, an enter transition might be 500ms, while an exit is 200ms.64
Platform Considerations: Durations might be adjusted for different screen sizes (e.g., tablet durations ~30% longer than mobile, desktop transitions appear faster).66


3. Transition Patterns and PrinciplesTransitions are short animations connecting UI states or views, fundamental for guiding users and enhancing perceived quality.65

Key Principles for Transitions:

Accessibility: Respect reduced motion settings (use subtle fades, disable decorative effects like shape morphing).44
Stable Layouts: Use skeleton loaders or placeholders to prevent content from shifting or popping in abruptly, which can be disorienting.44
Coherent Spatial Model: Transitions should help users understand the app's layout and how different views relate to each other.44
Unified Direction: Elements should generally move along a primary axis, grouped logically, rather than many elements moving independently, which can be distracting.44
Clean Fades: Fully fade out old content before fading in new content to avoid messy cross-fades. If a fade is necessary during movement (e.g., a dialog appearing), it should be quick.44
Simple Style: Transitions are frequent and primarily functional; they should not be overly stylized or complex.44



Common Transition Patterns 65:

Container Transform: An element seamlessly transforms to show more detail (e.g., a card expanding to a details page). Highly effective for creating relationships, best for hero moments or shallow hierarchies.
Forward and Backward: For navigating between screens at consecutive hierarchical levels (e.g., inbox to message). Platform defaults (Android/iOS) are recommended for simplicity and consistency.
Lateral: For browsing peer content at the same hierarchical level (e.g., swiping between tabs). Uses a sliding motion without fade/parallax, hinting at swipe gestures.
Top Level: A quick fade used when navigating between top-level destinations (e.g., via a navigation bar). Motion intentionally does not create a strong relationship between unrelated screens.
Enter and Exit: For introducing or removing components like dialogs, navigation drawers, or bottom sheets. Direction is often informed by location (e.g., bottom sheet slides up).
Skeleton Loaders: UI abstractions (placeholders) that hint at where content will appear, used with other transitions to reduce perceived latency and stabilize layouts during loading. Often have a subtle pulsing animation.


The M3 motion system, with its new physics-based engine for components and established patterns for transitions, provides a comprehensive framework for creating interfaces that feel responsive, intuitive, and engaging. The emphasis on natural movement and clear communication through motion contributes significantly to the overall user experience.IV. Component Guidelines: Building Blocks of M3 UIsMaterial Design 3 offers a rich library of interactive UI components that serve as the building blocks for creating user interfaces. These components are designed with M3's core principles of personalization, adaptability, and expressiveness in mind. This section provides guidelines for some of the most commonly used components, covering their types, anatomy, states, theming considerations, and key M3 updates. For a full list of components, the official M3 documentation should be consulted.67Components are generally organized into categories based on their purpose: Actions (e.g., Buttons), Containment (e.g., Cards, Dialogs), Communication (e.g., Snackbars), Navigation (e.g., Navigation Bar, Tabs), Selection (e.g., Checkboxes, Sliders), and Text Input (e.g., Text Fields).67 Each component is available with design resources (like Figma Design Kits) and implementation code for platforms such as Flutter, Android Jetpack Compose, MDC-Android, and Web, though availability of M3 Expressive features can vary.1A. Action ComponentsAction components prompt users to achieve an aim or trigger a process.1. ButtonsButtons are fundamental UI elements that prompt most actions.6

Types & Configurations:

M3 offers five primary button color options/styles, now considered configurations: Elevated, Filled (default), Filled Tonal, Outlined, and Text.6 These provide varying levels of emphasis.
Default and Toggle (selection) types are available, with toggle functionality being an M3 Expressive update.6
Sizes: Five size recommendations: Extra Small (XS), Small (S - existing default), Medium (M), Large (L), and Extra Large (XL). XS, M, L, XL are M3 Expressive additions, often available via tokens.6
Shapes: Two shape options: Round (default, fully rounded corners) and Square (M3 Expressive addition).6 Buttons can morph shape when pressed or selected (M3 Expressive).6
Icon: Can contain an optional leading icon (standard size 20dp in M3).6
Labels: Should be concise and use sentence case.6
Padding: New padding for small buttons (16dp recommended) was introduced with M3 Expressive, deprecating the older 24dp padding.6



Anatomy (General):

Container
Label Text
Leading Icon (optional)



States: Buttons support standard M3 states: enabled, disabled, hover, focused, pressed. Visual feedback includes state layers and shape morphing for pressed/selected states in M3 Expressive versions.6 The focus indicator has a thickness (e.g., 3dp) and outer offset (e.g., 2dp) defined by tokens.30


Theming & M3 Updates:

New color mappings for dynamic color compatibility. Icons and labels now share the same color.6
Neutral text button has been deprecated.6
Default M3 buttons are taller (40dp) with fully rounded corners, compared to M2's 36dp height and slightly rounded corners.6
Shape tokens like md.sys.shape.corner.full (Circular) or md.sys.shape.corner.medium (12dp) define corner radii.30
Motion for M3 Expressive buttons uses spring tokens like md.sys.motion.spring.fast.spatial.stiffness.30



Other Button Types:

Icon Buttons: For minor, single-tap actions. Available in default and toggle types, and four color styles (Filled, Tonal, Outlined, Standard). Five sizes (XS-XL) and two shapes (round, square) are part of M3 Expressive updates.42
Segmented Buttons: Help select options, switch views, or sort elements. Organize buttons and add interactions between them.67
Floating Action Buttons (FABs): For primary actions. Available in standard FAB and Extended FAB (with text label) versions. A FAB menu can open from a FAB to display multiple related actions.67


2. ChipsChips help people enter information, make selections, filter content, or trigger actions. They appear dynamically as a group of interactive elements.67

Types: Based on purpose and author 80:

Assist Chip: Represents smart or automated actions (e.g., "Add to calendar").
Filter Chip: Represents filters for a collection (e.g., platform selectors). Choice chips from M2 are now a subset of filter chips.81
Input Chip: Represents discrete pieces of user-entered information (e.g., a contact in an email field).
Suggestion Chip: Helps narrow user intent by presenting dynamically generated suggestions (e.g., suggested chat response).



Anatomy 80:

Container
Label Text (20 characters or fewer recommended)
Leading Icon or Image (optional)
Trailing Icon (required for input chips, optional for filter chips, e.g., a close icon to remove)



States & Theming:

Support standard M3 interaction states.
M3 brought updated color mappings for dynamic color and a boxier shape with rounded corners compared to M2.81
Can be outlined or elevated (elevated when on complex backgrounds like images).80
Theming leverages M3 color roles; for example, secondary key color is used for less prominent components like filter chips.2
Design tokens govern their appearance (color, shape, typography).2



Behavior:

Should appear in a set, not as a single chip.80
Input chips can transform text based on user input and support editing.80
Can appear inline in text fields, in stacked lists, or horizontally scrollable lists.80
Assist chips can transform into modals or full-screen views.80


Chips are distinct from buttons: chips offer dynamic, contextual options for the current task, while buttons represent more persistent, linear progression actions.80B. Containment ComponentsContainment components hold information and actions, often including other components.1. CardsCards display content and actions about a single subject, acting as surfaces that are easy to scan for relevant information.67

Types & Styles:

Elevated Card: Default card, uses surface-container-low and has a slight elevation (e.g., md.sys.elevation.level1 or level2 for hovered/focused states, translating to 1dp-3dp).29
Filled Card: Higher emphasis, uses surface-container-highest.29
Outlined Card: Lower emphasis, uses an outline.
Cards can be non-actionable (container for buttons/links) or directly actionable (the card itself is the touch target). An action shouldn't be placed on an actionable surface to avoid stacking interactive elements.28



Anatomy (General) 82:

Container (required, typically with md.sys.shape.corner.medium - 12dp radius 29)
Thumbnail (optional, for avatar, logo, icon)
Header Text (optional)
Subhead (optional)
Media (optional, e.g., image, graphic)
Supporting Text (optional)
Buttons/Icons (optional, for supplemental actions, typically at the bottom)
Overflow Menu (optional, for more than two supplemental actions)



States & Theming:

Support standard states (hover, focus, pressed, dragged, disabled) with state layer overlays (e.g., hover opacity 0.08, focus/pressed 0.1, dragged 0.16).29
Theming uses M3 color roles (e.g., surface-tint using primary color, on-surface for text) and shape tokens.29
M3 cards have a default elevation (e.g., 1dp), which increases on drag (e.g., 8dp in M2 context 82). M3 specs show md.sys.elevation.level1 (1dp) for enabled elevated cards, increasing for states like hover/focus.29



Behavior & Accessibility:

Directly actionable cards show a touch ripple; non-actionable ones don't.28
For accessibility, dragging/swiping interactions need single-pointer alternatives (e.g., menu options).28
Keyboard navigation: Tab moves between actionable elements. Space/Enter activates focused items.28
All interactive elements within cards need tab stops. Directly actionable cards are tab stops; for non-actionable cards, internal actionable elements are tab stops.28
Screen readers should announce informative content. Decorative images should be hidden.28


2. DialogsDialogs provide important prompts in a user flow, requiring user interaction before proceeding. They appear above other content, typically with a scrim overlaying the background.67

Types:

Basic Dialog: Standard dialog for alerts, confirmations.
Full-Screen Dialog: For immersive tasks or when more space is needed.



Anatomy 83:

Container (typically with md.sys.shape.corner.extra-large - 28dp radius 84)
Icon (optional, at the top)
Headline (e.g., using headline-small typography 84)
Supporting Text (e.g., using body-medium typography 84)
Actions (Buttons, typically text buttons, max two recommended 83)
Divider (optional, above buttons)
Scrim (overlay on background content)



States & Theming:

Dialog container uses surface color. Text uses on-surface or on-surface-variant. Buttons follow their own theming. Scrim has a specific opacity.
Theming relies on M3 color roles and typography tokens.84



Behavior:

Dialogs are modal, retaining focus until dismissed or an action is taken.83
Should be used sparingly as they interrupt the user.83
Dismissal: via a "cancel" button, Escape key, tapping scrim (platform dependent), or system back button.83
Actions: Confirming actions (resolve the dialog, e.g., "Save", "Delete") are usually on the right. Dismissive actions (e.g., "Cancel") are to the left of confirming actions.83
Scrolling should generally be avoided; if necessary, title is pinned at the top, buttons at the bottom.83


3. Sheets (Bottom and Side)Sheets provide surfaces for displaying supplementary content or actions, anchored to an edge of the screen.

Bottom Sheets: Anchored to the bottom, useful for menus, actions, or complementary content, especially on mobile.67

Types:

Standard Bottom Sheet: Co-exists with main UI, allowing simultaneous interaction. Can display content like an audio player. Can expand to full height and include a collapse icon.85
Modal Bottom Sheet: Appears in front of app content, disabling other functionality (like a dialog). Must be interacted with or dismissed. Initial height capped at 50% of screen height to provide access to top actions.85


Anatomy 85: Container (extra-large top corners, 28dp 86), optional Drag Handle, Scrim (modal only). Content can be lists, grids, text, etc.
Theming: Uses surface-container-low for container, on-surface-variant for drag handle. Elevation level1 (1dp).86
Behavior: Can be dismissed by tapping scrim, swiping sheet down, or a close affordance. Drag handle allows cycling through preset heights or closing.85 Supports predictive back gesture.85 Spans full window width up to 640dp; above that, it gets side margins.86



Side Sheets: Anchored to the leading or trailing edge, mostly for medium to expanded window sizes (tablet/desktop).22

Types:

Standard Side Sheet: Supplementary surface co-existing with main content.
Modal Side Sheet: Blocks interaction with underlying content until dismissed.


Anatomy 22: Sheet Container, optional Divider, optional Headline, optional Close Icon Button, optional Actions, Scrim (modal only).
Theming: New color mappings for dynamic color. Modal side sheets have a 16dp corner radius.77
Behavior: Placed on an edge (usually right for LTR, to avoid navigation on left). Can be slightly inset (16dp). Vertically scrollable internally. Supports RTL (appears on left, elements reversed). Supports predictive back.22


4. Other Containment Components:
Carousel: Shows a collection of items that can be scrolled. M3 introduced layouts like multi-browse, uncontained, hero, and full-screen. Items can have dynamic widths (large, medium, small) and visuals can have parallax effects. Items can snap-scroll.67
Divider: Thin lines to group content in lists or containers. Types: Full width (separates larger, unrelated sections) and Inset (separates related content within a section). M3 adds vertical dividers and new color mappings.67
Lists: Continuous, vertical indexes of text and images. Optimized for scannability. Three M3 sizes: one-line, two-line, three-line. Standardized heights (56dp, 72dp, or 88dp) and alignment rules (middle-aligned, or top-aligned for items ≥ 88dp) are M3 updates.67
C. Communication ComponentsCommunication components provide helpful information to the user, often temporarily.1. SnackbarsSnackbars provide brief, temporary messages about app processes at the bottom of the screen. They should be unobtrusive.40

Anatomy 90:

Container (extra-small corner radius, 4dp; elevation level3, 6dp)
Supporting Text (e.g., body-medium typography)
Action (optional, text button using e.g. label-large typography)
Icon (optional close affordance)



Behavior & Accessibility:

Snackbars with actions should not auto-dismiss to allow user interaction. Those without actions can auto-dismiss (typically 4-10 seconds), but on web, this requires inline feedback as well (e.g., "Save" button changes to "Saved") or making the snackbar actionable.40
When a snackbar appears, it should announce its message (e.g., via ARIA live region with polite announcement) but not move focus or trap focus.40
On web, a documented shortcut (e.g., Alt+G) should allow users to move focus to snackbars with actions.40
Use default color mapping (inverse-surface, inverse-on-surface, inverse-primary for action) to ensure they stand out.34



Theming: Uses inverse color roles for container, text, and action button to contrast with the main surface.34 Typography tokens define text styles.90

2. TooltipsTooltips provide informative text when users hover over, focus on, or tap and hold an element. They are transient and paired nearby their associated element.43

Types 91:

Plain Tooltip: Briefly describes a UI element, best for labeling icon-only buttons or fields without existing labels.
Rich Tooltip: Provides additional context, can contain a subhead, supporting text, and up to two text buttons or hyperlinks. Best for longer explanations or definitions.



Anatomy:

Plain: Container, Label Text.
Rich 91: Container, Subhead (optional, brief), Supporting Text, Text Buttons (optional, max two, side-by-side preferred).



Behavior & Placement:

Trigger: Hover (desktop), tap-and-hold (mobile), or focus.43 Persistent rich tooltips can appear on click or page load (e.g., for new feature explanations).91
Disappear: Typically 1.5 seconds after navigating away from target region (for transient tooltips). Triggering a new tooltip closes any other.91 Persistent rich tooltips (not triggered by hover) remain until interaction with another UI element.91
Placement: Plain tooltips usually above parent element (4dp distance if visual boundary, 8dp if not). Rich tooltips default to bottom right, adjusting to avoid screen edges.91 On desktop, may appear centered below parent.91
Only one tooltip should be displayed at a time.91
Critical information should not be hidden in tooltips; use a dialog instead.91



Accessibility 39:

Tooltip container should have tooltip role.
Focus order within rich tooltips is top to bottom for interactive elements.
Avoid trapping screen reader/keyboard focus.
Tab moves focus to buttons within rich tooltip; Space/Enter activates focused element.


3. BadgesBadges show notifications, counts, or status information, typically on navigation items and icons.73

Types 73:

Small Badge: Simple circle, indicates an unread notification.
Large Badge: Contains label text (e.g., item count), width expands with content. Max four characters (including '+') recommended.



Anatomy & Placement 73:

Small badge (circle)
Large badge container + label text
Anchored inside icon's bounding box, on the ending edge. Position adjusts for RTL.
Use default error color role for high visibility. Custom colors need 3:1 contrast.



Usage with other components: Common on Navigation Bar, Navigation Rail, App Bars, Tabs.73 In navigation bars, hide badge once destination is selected.73

D. Navigation ComponentsNavigation components help users move through the UI.1. App Bars (Top)App bars (often "top app bars") provide content and actions related to the current page, like navigation, headlines, images, and 1-2 essential actions. Can also include global controls like search.93

Types (M3 Expressive updates brought changes) 93:

Search App Bar: Emphasized entry to search view, search field instead of heading.
Small: For dense layouts or scrolled pages. (Center-aligned is a configuration of Small).
Medium Flexible: Displays larger headline, collapses to Small on scroll. (Replaces deprecated Medium).
Large Flexible: Emphasizes page headline, collapses. (Replaces deprecated Large).
Deprecated: Medium and Large non-flexible app bars.



Anatomy 93:

Container
Leading Button (e.g., menu icon for nav drawer, back arrow)
Headline (brief, can wrap to 2 lines in flexible versions; don't truncate)
Subtitle (optional)
Trailing Icons (1-2 on compact, most used closest to leading edge; overflow menu if more needed)



Behavior & Theming:

Scrolling: Can remain fixed or hide/reappear. Initially same color as background, fills with contrasting color on scroll for separation.93
Actions: Primary action should alter/exit page (Send, Save). Can boost visibility of one action with filled/tonal icon button style.93
Search App Bar: Can have logo, up to two trailing icons + avatar. Search field uses surface-container by default, or surface-bright on darker backgrounds.93
Theming uses M3 color roles (e.g., surface-tint from primary, on-surface for headline, on-surface-variant for trailing icons) and typography/shape tokens.94


2. Navigation Bar (Bottom)Navigation bars (formerly "Bottom Navigation" in M2 70) allow movement between 3-5 primary, equally important destinations. Used in compact or medium window sizes. Destinations are consistent across screens.68

Anatomy 38:

Container
Navigation Items (3-5), each with:

Icon (filled for selected, outlined for unselected)
Text Label (bold for selected, medium for unselected)
Active Indicator (pill shape in contrasting color for selected state in M3)
Badge (optional)





Behavior & Theming:

M3 updates: Taller container, no shadow, new color mappings, pill-shaped active indicator.70 Active label color changed from on-surface-variant to secondary.70
Scrolling: Can hide on downward scroll, reappear on upward scroll.95
Text scaling: Bar grows vertically for larger text; labels can wrap. Full label visible up to 2x text size.38
Accessibility: Tab moves between items, Space/Enter selects. Descriptive accessibility labels are important.38



M3 Expressive Update 70: Introduced a new flexible navigation bar: shorter height, supports horizontal navigation items in medium windows. The original navigation bar is deprecated in favor of this.

3. Navigation RailNavigation rails provide ergonomic access to 3-7 destinations on medium to extra-large screens (tablets/desktops). Positioned vertically on the leading edge.68

Types (M3 Expressive updates) 96:

Collapsed Navigation Rail: Runs along leading edge, 3-7 items, should not be hidden. (Replaces deprecated "Navigation rail").
Expanded Navigation Rail: Wider, can show more item details or secondary destinations. Can be standard (beside content) or modal (overlaps content, opened from menu icon). The expanded navigation rail is now preferred over the Navigation Drawer for M3 Expressive users.98



Anatomy 96:

Container
Menu Icon (optional, to toggle between collapsed/expanded, or open modal expanded rail)
Navigation Items (Icon, Active Indicator, Label Text)
FAB (optional, anchored at top of rail)
Badges (optional, on nav items)



Behavior & Theming:

Placement: Leading edge (left for LTR). Container fill can be off (items directly on surface, ensure 3:1 contrast). Items can be top or center aligned (center for tablet reachability).97
Active Indicator shows current page.97
Theming uses M3 color roles (e.g., on-surface-variant for inactive icons/labels, on-secondary-container and secondary-container for active state) and typography tokens (label-medium for text).96 Predictive back applies to modal expanded rail.97


4. Navigation DrawerNavigation drawers provide access to destinations and app functionality, sliding from the leading edge. Recommended for apps with 5+ top-level destinations or multiple navigation hierarchy levels.63

Note: The navigation drawer is being deprecated in the M3 Expressive update. Users are advised to use an expanded navigation rail instead, which offers similar functionality and better adaptability across window sizes.98


Types (pre-deprecation) 98:

Standard Navigation Drawer: For expanded, large, extra-large window sizes. Can be permanently visible or opened/closed via menu icon.
Modal Navigation Drawer: For compact and medium window sizes. Blocks interaction with other content via a scrim. Opened by an external action (e.g., menu icon).



Anatomy 63: Essentially a list within a side sheet. Includes: Sheet container, Active Indicator, Icon, Label, optional Badge, optional Divider, optional Section Label, Scrim (modal only).


Behavior & Theming (pre-deprecation):

M3 updates included new color mappings, rounded corners at ending edge, updated selected state style.99
Modal drawers dismissible by item selection, scrim tap, or swipe.63


5. TabsTabs organize content across different screens, views, or sections, grouping them into helpful categories. Tabs are peers.68

Types 69:

Primary Tabs: Placed at the top of the screen, often under a top app bar.
Secondary Tabs: Always placed below primary tabs.



Anatomy 36:

Container
Tab Item(s), each with:

Icon (optional, use globally recognized if used alone)
Label (clear, succinct, can wrap to second line or truncate; scrollable tabs allow longer titles)
Badge (optional)
Active Indicator (underline or pill shape highlighting the selected tab)


Divider (separating tabs from content)



Behavior & Theming:

M3 updates: New color mappings, icons/labels vertically centered.69
Can horizontally scroll if tabs don't fit on screen (best for touch browsing). Avoid infinite looping scroll.36
Theming uses M3 color roles (e.g., surface-variant for container, primary for active indicator/icon/text, on-surface-variant for inactive) and typography (title-small for labels).100
Accessibility: Arrow/Tab to navigate, Space/Enter to select. Descriptive labels are key.36 Avoid applying density by default if it reduces touch targets below 48x48 CSS pixels.36


6. Search (Search Bar & Search View)Search components allow users to enter keywords to find relevant information.101

Components:

Search Bar: The input field where users type queries. Can display suggested keywords. Can include leading search/nav icon and optional trailing icons (e.g., voice search, avatar).101
Search View: Displays search results and suggestions. Can be a full-screen modal (compact sizes) or connected to the search bar (medium/expanded sizes). Typically opened by selecting a search icon or interacting with a search bar.101



Anatomy 101:

Search Bar: Container (rounded corners), Leading icon button (nav or search icon), Supporting/Hint text, Avatar or Trailing icon(s) (max two).
Search View: Container (full screen in compact), Header (leading icon, supporting text, trailing icon), Input text area, Divider, Results list.



Behavior & Theming:

M3 updates: New color mappings, lower elevation by default, "Open search bar" renamed to Search.102
Search bar can scroll with content or remain fixed. Internal elements anchor left/right as container scales.101
Search view is modal in compact sizes. Results presented in a compact list below the persistent search text field.101
Interaction states (enabled, focused, hover, pressed, disabled) apply to interactive elements within search components, governed by M3 state layer principles and color tokens.24


E. Selection ComponentsSelection components allow users to specify choices or adjust settings.1. CheckboxesCheckboxes allow users to select one or more items from a list, or turn an item on/off. They are multi-select.37

Anatomy:

Checkbox icon (box)
Checkmark or indeterminate mark (hyphen) inside the box
Adjacent text label



States & Behavior 37:

States: Selected (checked), Unselected (unchecked), Indeterminate (if some, but not all, child checkboxes in a group are checked).
Selecting an indeterminate parent checkbox checks all its children.
Users should be able to select by tapping the label or the checkbox itself.
Use when multiple, related options can be selected. For single selection, use Radio Buttons. For standalone binary settings, Switches are often preferred unless in a list of related toggles.103
Accessibility: Tab to navigate, Space to toggle. Labels are crucial.37 Avoid applying density by default if it reduces target size.37



Theming: Uses M3 color roles for selected/unselected states and text labels.

2. Radio ButtonsRadio buttons allow users to select one option from a set. Only one can be selected at a time.67

Anatomy 104:

Radio button icon (circle)
Dot inside the circle (when selected)
Adjacent text label



States & Behavior 104:

States: Selected, Unselected.
Always pair with an adjacent label. One option in a set should always be pre-selected.
Best for five or fewer options; for more, a dropdown menu might be better if space is constrained, but menus require more clicks.
Often arranged in stacked layouts.
Accessibility: Tab to navigate between radio groups, Arrow keys to navigate within a group, Space to select.



Theming 105:

Color roles: primary for selected state, on-surface-variant for unselected outline. on-surface for label text.
Supports standard M3 states (enabled, hover, focus, pressed, disabled) with state layer opacities (e.g., hover 0.08, focus/pressed 0.1).
Icon size 20dp, state layer 40dp, target size 48dp.


3. SlidersSliders allow users to make selections from a continuous or discrete range of values.12

Types (M3/M3 Expressive) 12:

Standard Slider: (Formerly "continuous slider") For a continuous range.
Centered Slider: Starts from the middle (e.g., for balance controls).
Range Slider: Allows selection of a range with two handles.
Discrete Slider: Now a "stops" configuration for Standard or Range sliders, showing tick marks for specific values.



Configurations (M3 Expressive additions) 12:

Orientation: Horizontal (default), Vertical.
Size: XS (default), S, M, L, XL (often via tokens).
Inset Icon: Optional icon at the start/end of the slider track (standard slider only).
Stop Indicators (Tick Marks): Yes/No.
Value Indicator (Tooltip): Yes/No, displays current value above handle when interacting.



Anatomy:

Track (active and inactive portions)
Handle(s)
Stop Indicators (optional)
Value Indicator (optional)
Inset Icon (optional)



States & Theming 12:

M3 updates: New shape for tracks/handles (elements change shape on selection), refreshed color mappings, handle adjusts width on selection, tracks adjust shape at edges.12
Supports standard M3 states. Handle uses primary color, track uses primary (active) and surface-variant or secondary-container (inactive). Value indicator uses inverse-surface and inverse-on-surface.106
Shape is typically corner.full (circular) for handles and track ends.106
Typography for value indicator is often label-medium.106


4. SwitchesSwitches toggle the state of a single item on or off (binary selection). Best for adjusting settings or standalone options. Effect should be immediate.67

Anatomy 107:

Track
Handle
Icon (optional, inside handle, should clearly communicate on/off state, e.g., checkmark/X)



Behavior & Placement:

Always pair with an inline label describing what the switch controls when "on." Keep labels short and direct.107
When toggled, handle slides and may change size (larger when "on").107
Use for standalone binary options. For lists of multiple related selectable items, use Checkboxes. For selecting one from a set, use Radio Buttons.107



States & Theming 71:

M3 updates: More accessible visual presentation, new color mappings for dynamic color and contrast, optional icon in handle, taller/wider track.71
Selected (on) state: Handle and track often use primary color. Icon in handle might use on-primary-container.
Unselected (off) state: Handle uses outline, track uses surface-variant. Icon might use on-surface-variant.
Shapes are corner.full (circular).108
Supports standard M3 states with state layers.


5. Date and Time PickersThese components allow users to select dates, date ranges, or specific times.

Date Pickers: Let people select a date or range of dates. Can be embedded in dialogs (mobile) or text field dropdowns (tablet/desktop).67

Types 110:

Docked Date Picker: Displays date input field by default; dropdown calendar appears on tap. Ideal for near or distant dates.
Modal Date Picker: Full-screen or large modal calendar. Swipe horizontally for months, scroll vertically for years (or tap year to open year picker).
Modal Date Input: Manual entry of dates via keyboard in a dialog.


Anatomy (varies by type) 110: Includes elements like text input field, month/year selection buttons, calendar grid (with day labels, dates, today's date indicator, selected date/range highlights), confirmation/cancel buttons, container.
Theming: Uses M3 color roles (e.g., primary for selected date container, on-primary for selected date text, surface for picker background) and typography/shape tokens (e.g., corner.large for dialog container, corner.full for date cells).110



Time Pickers: Allow selection of hours, minutes, AM/PM. Displayed in dialogs.67

Input Modes 112:

Dial Selector: Mimics a round watch face. 12-hour dial includes AM/PM. 24-hour dial has inner/outer rings for numbers.
Time Input Picker: Keyboard entry for hours/minutes. Accessible from dial picker via keyboard icon.


Anatomy 112: Container (dialog, corner.extra-large shape, elevation.level3 113), Header with time input fields (hours, minutes, AM/PM selector), Dial selector or Input fields, Toggle icon button (switch between dial/input), Text buttons (Cancel, OK).
Theming: Time input fields use primary-container for selected field background. Dial uses surface, numbers use on-surface. Selected time on dial uses primary for handle/number background, on-primary for number text.113 Typography uses display-large for time inputs, title-medium for AM/PM.113


F. Text Input ComponentsText input components allow users to enter and edit text.1. Text FieldsText fields allow users to enter text into a UI, typically in forms and dialogs.68

Types (Visual Styles) 21:

Filled Text Field: Has a background fill, often used in forms where more visual emphasis is desired or in dialogs. Rounded top corners, square bottom corners.21
Outlined Text Field: Has a container stroke, less visual emphasis. Often used in dense forms or dialogs. All corners rounded.21



Anatomy 21:

Container
Label Text (always visible, aligned with input text, can float above when input has value or focus)
Input Text (user-entered text)
Leading Icon (optional, e.g., search icon)
Trailing Icon (optional, e.g., clear icon, password visibility toggle, error icon, dropdown arrow)
Helper/Supporting Text (optional, below field, for instructions or context)
Error Text (replaces helper text on validation error, often paired with error icon)
Character Counter (optional, if there's a limit)
Activation Indicator (line at bottom, thicker/colored when focused or error)



States & Theming:

Support standard M3 states (inactive, activated/populated, focused, hover, error, disabled).114
Theming uses M3 color roles: surface-variant for filled container background, primary for focused indicator/label/icon, error for error state elements, on-surface-variant for unfocused label/icons/helper text.60
Typography: body-large for input/label text, body-small for helper/error/counter text.60



Behavior:

Labels should be short, clear, always visible, and not truncated.21
Required fields indicated by asterisk (*) next to label, with explanation.21
Can be single-line, multi-line (grows with text), or fixed-height text areas.21
Error icon strongly recommended for error state for accessibility.21
Leading/trailing icons change position for LTR/RTL.21


G. Other Notable Components

Menus: Display a list of choices on a temporary surface, appearing on interaction with an element (button, icon, input field).67

M3 simplifies M2's "Dropdown menu" and "Exposed dropdown menu" into a general "Menu" concept, differing mainly by the element that opens them.72
Anatomy: Container, List items (label, optional leading/trailing icon, keyboard command), optional Divider.115
Behavior: Positioned relative to trigger, avoids screen edges. Can scroll if items exceed height. Fade transition for entry/exit.115
Theming: Uses M3 color roles (surface-container for menu, on-surface for text, on-surface-variant for icons) and list item states.117 Typography often label-large.117



Progress Indicators: Express an unspecified wait time or display the duration of a process. Not for decoration.13

Types: Linear and Circular.13
Configurations: Determinate (known progress) or Indeterminate (unknown wait time). M3 Expressive adds configurable track thickness and shape (flat/wavy).23
Anatomy: Active indicator, Track, Stop indicator (M3 addition for accessibility).13
Theming & M3 Updates: New color roles (primary for active indicator, secondary-container or surface-variant for track) for higher contrast, rounded corners, new motion behavior.13 Wavy shape for expressive style.23



Toolbars: Display frequently used actions relevant to the current page. Can contain many actions and scale for larger windows. M3 Expressive update: Bottom App Bar deprecated in favor of Toolbars.76

Types 76:

Docked Toolbar: Spans full window width, for global actions. Shorter than old Bottom App Bar.
Floating Toolbar: Floats above content, for contextual actions. Can be horizontal or vertical.


Color Styles: Standard (low-emphasis) or Vibrant (high-emphasis, e.g., for edit mode).119
Anatomy: Container with slots for buttons, icon buttons, text fields, FABs. Docked toolbars use straight corners. Floating toolbars have elevation by default.119
Behavior: Don't show at same time as Navigation Bar. Docked toolbars at bottom of window. Floating toolbars can be horizontal (min 16dp edge margin) or vertical (min 24dp edge margin).119


This overview of M3 components highlights their structure, behavior, and evolution within the Material Design system. For detailed specifications, including all token names and precise measurements, the "Specs" section for each component on the official M3 website is the definitive resource.V. Implementing and Customizing M3Material Design 3 provides a robust framework not only for designing UIs but also for implementing them consistently and customizing them to reflect brand identity and user preferences. This section delves into the practical aspects of using design tokens, platform-specific considerations, and leveraging tools like the Material Theme Builder.A. Leveraging Design Tokens for Theming and DevelopmentDesign tokens are the cornerstone of implementing and customizing M3. They serve as the single source of truth for all stylistic values, bridging the gap between design and development and ensuring consistency across platforms and products.451. Understanding the Token Hierarchy (Recap and Elaboration)As previously outlined, M3 employs a three-tiered hierarchy of tokens: Reference, System, and Component tokens.45 This layered architecture is fundamental to M3's approach to theming and customization, offering both global control and granular specificity.

Reference Tokens (e.g., md.ref.palette.blue60 = #00658F): These represent the foundational palette of available style values. They are the most atomic level of the design system's visual language. Modifying a reference token directly changes a base value. This is typically done when defining an organization's core brand palette or a set of neutral grays. Because system and component tokens often point to reference tokens, changes at this level can have widespread (though predictable) effects across the UI.


System Tokens (e.g., md.sys.color.primary points to md.ref.palette.primary40): These tokens assign semantic meaning or roles to reference tokens. They define the character of the design system for elements like color, typography, shape, and elevation. Theming primarily occurs at this level. For example, to change the primary interactive color across an application, one would modify the reference token that md.sys.color.primary points to, or, if the system allows, directly change the mapping of md.sys.color.primary to a different reference token. System tokens are designed to adapt to different contexts, such as light/dark themes or dynamic color inputs, by pointing to different reference tokens based on these conditions.45 This contextual adaptability is a key strength of M3's theming capabilities.


Component Tokens (e.g., md.comp.filled-button.container.color points to md.sys.color.primary): These tokens define the specific design properties of individual elements within a component. They should ideally reference system tokens (or occasionally reference tokens) rather than hard-coding values. This allows components to inherit their styling from the overall system theme by default. Component tokens provide the most granular level of control, allowing for specific overrides or unique styling for a particular component part without altering the global system roles or the base reference palette. For instance, if a specific button instance needs a unique background color that doesn't align with the standard md.sys.color.primary, its md.comp.filled-button.container.color token could be made to point to a different system or reference token for that specific instance or variant.

This hierarchical structure (Reference → System → Component) is what enables M3's powerful combination of consistency and flexibility. Global theme changes are managed at the System token level, ensuring widespread coherence. Brand-specific foundational values are defined via Reference tokens. Fine-grained adjustments for specific components are handled by Component tokens. This separation of concerns simplifies maintenance and allows for scalable design systems. Designers and developers need to understand this flow to make effective styling decisions: for broad theming, target System tokens; for defining base palettes, work with Reference tokens; for component-specific deviations, utilize Component tokens.2. Practical Usage in Design Workflows and DevelopmentDesign tokens are not just abstract concepts; they are integrated into practical design and development workflows.
Design Tools: The Material Theme Builder, for example, generates Figma styles that correspond to M3 tokens.50 Designers work with these named styles (e.g., applying "Primary Container" color style in Figma) rather than raw hex codes. This ensures that design mockups are built using the same definitions that developers will use.
Development: Developers consume these tokens in their code. Exported theme files from the Material Theme Builder provide these token definitions in formats suitable for Android (Jetpack Compose, XML), Flutter, and Web.52 Instead of hard-coding #6750A4, a developer would use a token like MaterialTheme.colorScheme.primary.
Documentation: The official M3 website lists token IDs and their default baseline values in interactive modules within component and style pages, allowing quick lookup.45 These tables typically show the component style aspect (e.g., "label text color"), the token ID (e.g., md.comp.button.label-text.color), and its resolved value in a given context.45
This shared language of tokens significantly reduces ambiguity and errors during the handoff from design to development, fostering better collaboration and more consistent final products.453. Theming and Customization through TokensTokens are the fundamental mechanism for applying themes (color, typography, shape, motion) across an M3 application.
Color Theming: System color tokens (e.g., md.sys.color.primary, md.sys.color.surface) are mapped to specific reference color palette values. Changing these mappings or the underlying reference values alters the application's color scheme.45 Dynamic color works by programmatically adjusting these mappings based on user input.2
Typography Theming: System typography tokens (e.g., md.sys.typescale.body-large.font, md.sys.typescale.headline-small.size) define the font family, size, weight, etc., for each typographic role. Customizing these tokens allows for brand-specific typography.7
Shape Theming: System shape tokens (e.g., md.sys.shape.corner.medium) define the corner radii for components. Adjusting these allows for different levels of roundedness across the UI.9
Motion Theming: System motion tokens (e.g., md.sys.motion.spring.fast.spatial) define parameters for spring animations, allowing for customization of the feel of interactions.8
The abstraction provided by tokens means that when a theme changes (e.g., from light to dark mode, or when a user's dynamic color palette is applied), the UI updates automatically and consistently, provided components are correctly referencing these system tokens. This makes M3 highly adaptable and personalizable.B. Platform-Specific ConsiderationsWhile Material Design 3 aims for a cohesive design language across platforms, it's important to acknowledge that implementation details, component availability, and the rollout of M3 Expressive features can vary between Android, Web, and Flutter.
Android: Jetpack Compose is Android's modern toolkit for building native UIs and generally offers robust support for M3 and M3 Expressive features, often being the first platform to receive them.2 MDC-Android (Material Components for Android using Views) also supports M3, though the level of Expressive feature integration might differ.6 Dynamic color is a key feature on Android 12+.2
Flutter: Material Components for Flutter provide M3 support, enabling cross-platform development with a Material look and feel.1 Availability of specific M3 Expressive features should be checked against the latest Flutter Material library documentation.8
Web: M3 Web Components and tutorials are in development, with some components and features (especially Expressive ones) listed as "Unavailable" or "Compatible with Compose springs" in certain documentation snippets.1 This suggests a phased rollout for Web. The Material Theme Builder can export web-compatible themes.54
The aspiration for M3 is platform parity, but the reality is often a phased introduction of new features and capabilities. Teams developing for multiple platforms must consult the latest official M3 documentation for each target platform to understand current support levels. This is particularly true for M3 Expressive features like advanced shape morphing or specific motion tokens. It may be necessary to plan for graceful degradation or platform-specific alternatives if a desired M3 feature is not yet fully available on all targeted platforms. This proactive approach ensures that cross-platform products can still deliver a consistent core M3 experience while progressively adopting newer features as they become available.C. Utilizing the Material Theme Builder for Custom ThemesThe Material Theme Builder (MTB) is an indispensable tool provided by Google to facilitate the creation and implementation of custom M3 themes. It is available as a Figma plugin and a web tool.2
Core Functionality:

Custom Color Scheme Generation: Users can input their brand's primary color (and optionally secondary, tertiary, neutral, and error colors) into the MTB. The tool then uses M3's color algorithms (based on HCT) to generate a full, accessible, and M3-compliant color scheme. This includes the five key color tonal palettes and all the necessary color role assignments for both light and dark themes.2
Dynamic Color Preview: The MTB allows designers to preview how their custom theme will adapt to user-generated dynamic colors (e.g., from different wallpapers), providing a realistic sense of the personalized experience.50
Token Export: A key output of the MTB is the ability to export the generated theme as design tokens in various formats suitable for direct use in development:

Jetpack Compose (Kotlin code) 2
Android Views (XML resources) 54
Flutter (Dart code) 54
Web (CSS custom properties or other formats) 54
JSON / Design System Package (DSP) for broader interoperability.52


Figma Integration: The Figma plugin creates Figma styles corresponding to the generated color roles and typography tokens. It can also generate state layers and a visual color diagram of the theme within Figma.50 Designers can then "swap" the theme of M3 Design Kit components or their custom components to apply the new brand theme.50
Typography Customization: While primarily focused on color, the MTB also helps integrate typography by allowing the export of type tokens, ensuring that the typographic scale aligns with the M3 system.52


The Material Theme Builder acts as a significant accelerator for adopting M3 and integrating brand identity. It automates the complex and often error-prone process of deriving accessible tonal palettes and assigning them to semantic color roles based on a few initial brand color inputs. By providing ready-to-use code and Figma styles, it streamlines the design-to-development workflow, reduces manual effort, and ensures that custom themes are built on a solid M3 foundation. For any team looking to implement a custom M3 theme, utilizing the Material Theme Builder should be a primary step. It helps ensure that the custom theme will correctly support M3 features like dynamic color, accessibility contrast requirements, and consistent component styling.VI. Conclusion: Crafting Personal, Adaptive, and Expressive Experiences with M3Material Design 3 emerges as a sophisticated and comprehensive design system, meticulously engineered to guide the creation of modern user interfaces that are deeply personal, seamlessly adaptive, and richly expressive. Its foundations in adaptive layout, clear interaction states, inherent accessibility, and a robust design token system provide a solid framework for designers and developers. The visual style system, with its revolutionary dynamic color, versatile typography, expressive shapes, clear iconography, and natural motion, offers a rich palette for crafting unique and engaging user experiences.The extensive library of M3 components, from fundamental buttons and cards to complex navigation patterns and pickers, embodies these principles, offering pre-built solutions that are both customizable and consistent. The evolution brought by M3 Expressive further empowers creators with an expanded toolkit for achieving emotionally impactful designs, pushing the boundaries of conventional UI aesthetics and interaction.To effectively leverage Material Design 3:
Embrace the Philosophy: Internalize the core tenets of personal, adaptive, and expressive design to guide all UI/UX decisions.
Utilize Design Tokens: Fully adopt the design token system as the single source of truth for styles. This is paramount for theming, consistency, and efficient collaboration between design and development.
Leverage the Material Theme Builder: Use this tool as the starting point for any custom theming effort to ensure M3 compliance, accessibility, and seamless integration with dynamic color.
Prioritize Accessibility: Continuously apply and test for accessibility, using M3's built-in features as a strong foundation but always validating with diverse user needs in mind.
Stay Updated: Material Design is an evolving system. Regularly consult the official M3 documentation (m3.material.io) for the latest component updates, API changes, and platform-specific guidance.
**Apply Expressive Features Thoughtfully
