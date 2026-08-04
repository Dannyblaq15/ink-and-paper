---
name: Warm Editorial
colors:
  surface: '#fff8f4'
  surface-dim: '#e2d8d0'
  surface-bright: '#fff8f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fcf2e9'
  surface-container: '#f6ece3'
  surface-container-high: '#f1e6de'
  surface-container-highest: '#ebe1d8'
  on-surface: '#1f1b16'
  on-surface-variant: '#55433e'
  inverse-surface: '#35302a'
  inverse-on-surface: '#f9efe6'
  outline: '#88726d'
  outline-variant: '#dbc1ba'
  surface-tint: '#974730'
  primary: '#94442e'
  on-primary: '#ffffff'
  primary-container: '#b35c44'
  on-primary-container: '#fffcff'
  inverse-primary: '#ffb5a1'
  secondary: '#5f5e5b'
  on-secondary: '#ffffff'
  secondary-container: '#e5e2dd'
  on-secondary-container: '#656461'
  tertiary: '#615b58'
  on-tertiary: '#ffffff'
  tertiary-container: '#7a7470'
  on-tertiary-container: '#fffdff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbd1'
  primary-fixed-dim: '#ffb5a1'
  on-primary-fixed: '#3b0900'
  on-primary-fixed-variant: '#79301b'
  secondary-fixed: '#e5e2dd'
  secondary-fixed-dim: '#c8c6c2'
  on-secondary-fixed: '#1c1c19'
  on-secondary-fixed-variant: '#474743'
  tertiary-fixed: '#e9e1dc'
  tertiary-fixed-dim: '#cdc5c0'
  on-tertiary-fixed: '#1e1b18'
  on-tertiary-fixed-variant: '#4b4642'
  background: '#fff8f4'
  on-background: '#1f1b16'
  surface-variant: '#ebe1d8'
typography:
  display-lg:
    fontFamily: Playfair Display
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Playfair Display
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Playfair Display
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Playfair Display
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: DM Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: DM Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: DM Sans
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: DM Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.03em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  base: 8px
  container-margin-desktop: 64px
  container-margin-mobile: 20px
  gutter: 24px
  section-gap: 80px
---

## Brand & Style
The design system embodies a sophisticated, tactile aesthetic that merges high-end editorial layouts with a soft, contemporary approachability. It is designed to feel like a modern digital magazine: intellectual yet welcoming, structured yet organic. 

The style is defined by **Minimalist Editorial** principles, characterized by generous whitespace, high-contrast typography, and a "paper-like" physical presence. By utilizing extreme roundedness, the interface sheds the coldness of traditional digital grids in favor of a friendlier, more ergonomic feel. The emotional response is one of calm, curated expertise and comfort.

## Colors
This design system utilizes a palette inspired by natural fibers and earth pigments. 
- **Primary (#B35C44):** A warm, terracotta accent used for primary actions, highlights, and active states.
- **Secondary (#F9F6F1):** The "Paper" base. This off-white, warm neutral serves as the primary surface color to reduce eye strain and provide a premium, tactile feel.
- **Tertiary (#2D2926):** "Ink." Used for headings and primary text to ensure high legibility and a classic editorial contrast.
- **Neutral (#706962):** "Lead." Used for secondary text, borders, and icons to maintain a soft visual hierarchy.

## Typography
The typography strategy relies on the juxtaposition of a serif display face and a geometric sans-serif. 
- **Playfair Display** is used for all headlines and display moments. It should be typeset with tight letter-spacing to emphasize its elegant, high-contrast strokes.
- **DM Sans** provides a clean, functional counterpoint for body copy and UI labels. 
- **Hierarchy:** Use the uppercase `label-md` for category tags and small headers to inject a "magazine" feel. Ensure body text maintains a generous line height (minimum 1.5x) to facilitate long-form reading.

## Layout & Spacing
The layout follows a **Fluid Grid** model with an emphasis on oversized internal padding. 
- **Desktop:** 12-column grid with 64px side margins. Elements should feel "floated" within large white spaces.
- **Mobile:** 4-column grid with 20px side margins. 
- **Vertical Rhythm:** Use a base-8 spacing scale. Section transitions should be dramatic, using `section-gap` to separate content themes clearly.
- **The Floating Pill:** The primary navigation and search interface is a detached, floating pill-shaped bar anchored to the bottom of the viewport, maintaining consistent padding from the bottom and sides of the screen.

## Elevation & Depth
This design system avoids traditional shadows in favor of **Tonal Layers** and subtle contrast. 
- **Base Level:** The background is the `secondary_color` (Paper).
- **Raised Elements:** Content cards and containers use a slightly lighter or pure white surface to create a "stacked paper" effect. 
- **Outlines:** Use a 1px solid border in a very faint version of the `neutral_color` (10% opacity) for container definition.
- **Interactive Depth:** When a user interacts with a card or button, it should not lift with a shadow, but instead subtly scale (e.g., 98%) or shift in background tone to indicate a "pressed" physical state.

## Shapes
The shape language is defined by **Pill-Shaped Geometry**. 
- Every functional container, including cards, input fields, and the primary action bar, must utilize a minimum of `24px` or `full` corner radius. 
- Large image containers should follow the `rounded-xl` (3rem) specification to maintain consistency with the UI elements. 
- This extreme roundness creates a friendly, organic contrast against the sharp, traditional serifs of the typography.

## Components
- **Combined Search & Action Pill:** This is the centerpiece of the UI. A single, wide floating pill at the bottom of the screen. The left side contains a "Search" text field with a subtle icon, and the right side houses 2-3 primary icon actions (e.g., Home, Profile, Menu).
- **Buttons:** Always pill-shaped. Primary buttons use the Primary Color with white text. Secondary buttons are outlined or ghost-style.
- **Cards:** Utilize `rounded-xl` corners. Padding inside cards should be generous (minimum 24px) to ensure content does not feel cramped by the aggressive corner radius.
- **Chips & Tags:** Small, fully rounded pills using a light tint of the Primary Color with `label-sm` typography.
- **Input Fields:** Fully rounded (pill) containers with a background tone slightly darker than the main surface.
- **Lists:** Items are separated by thin, warm-grey dividers that stop short of the screen edges, maintaining the "contained" editorial look.