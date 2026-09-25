### v2.0.2
  - fix the display of wrong item IDs

### v2.0.0
  - complete rewrite(again) to allow usage on Retail and Foever

### v1.0.2
  - fixing missing flag in groupfinder

### v1.0.1
  - fixing lua error when comparing item stacksize

### v1.0.0
  - rebuilt the addon from scratch for the 12.1 API
  - secret-safe throughout: every value read from the game is checked before it
    is compared, concatenated or used as a key, so restricted content no longer
    produces Lua errors or silently wrong lines
  - added German localization, English is the base language
  - realm data reduced from 558 tables to per-region string lists, and only the
    player's own region is ever unpacked
  - realm names outside plain ASCII (Гордунни, Chants Éternels) now resolve to
    the right language
  - tooltip scale and health bar are applied on change instead of on every
    tooltip that is shown
  - mount tooltips now respect "Hide In Combat" like every other type
  - the group finder is hooked when it loads instead of being a dependency
  - settings from older versions are migrated where they still mean the same and
    dropped where they do not