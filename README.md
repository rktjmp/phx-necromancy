# Necromancy

Using Phoenix.LiveView inplace of classical controllers, optionally
resurrecting them from the dead.

## Reasoning

- A consistent developer experience.

All your views are constructed in the same manner, with a mount, handle_params,
etc process flow. The "template render flow" is the same.

- But not all views really need to be "live"

Some static [sic] pages have no sever state to update. These could/can just be
regular Phoenix controller actions.

- But, but some views might warrant starting dead and then *becoming* live.

## Reasons against

- Kinda weird
- Added complexity with expecting a liveview to never connect?
- Phoenix 1.7 *may* unify how templates are put together with the new
  templating engine?

## Direct usecase

All pages show content, with a "live chat/form" pop-out. The live-chat should
integrate with the current page - it should not redirect.

## Methods

- Show button, on click spawn iframe with liveview in it, let this do the fancy
  work.
  - Simpler, no hacks
  - iframes ugly?

- Dead to live
  - render view as dead-liveview, on click connect livesocket or import livesocket code
