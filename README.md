# Anti-GroundStrafe Boost AMXX Plugin

**Plugin Name:** Anti-GroundStrafe Boost
**Version:** 2.0  
**Author:** MrShark45  
**Game:** Counter-Strike 1.6 (AMX Mod X)  

---

## Description

This plugin is designed to detect and prevent **groundstrafe exploits** on surf, kz, or bhop maps where `trigger_push` entities are used. Players who abuse velocity gain through duck-spamming or excessive trigger contacts are either slowed down or reset to normal speed.

---

## Anti-Cheat Logic

- **Velocity Monitoring:** Tracks player speed before and after touching `trigger_push`.
- **Duck Abuse Detection:** Limits duck presses during push interactions.
- **Touch Limit:** Tracks how many valid touches a player makes in a short period.
- **Speed Enforcement:** Slows players back to original velocity when cheat-like behavior is detected.

---

## Configuration Constants

All settings are defined at the top of the plugin source:

```c
#define MAX_ERROR 1.5          // Max allowed speed gain multiplier
#define MAX_TIMESPENT 0.5      // Max time considered valid for a trigger_push touch (longer touches are ignored)
#define MAX_DUCKS 2            // Max duck presses allowed during a touch
#define MAX_TOUCHES 3          // Max valid touches before penalty

#define COUNT_TOUCHES_TIME 1.0 // Time window to count touches
#define MIN_SPEED_TOUCH 0.5    // Minimum gain to count as valid touch
