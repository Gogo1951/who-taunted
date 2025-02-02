# Who Taunted?
Addon project for World of Warcraft.

https://wow.curseforge.com/projects/who-taunted

## About
Tracks player taunts and displays who they taunted, what ability they used to taunt, and if it failed in some way.

## Issues

Please report any issues on GitHub - https://github.com/Davie3/who-taunted/issues

## Localization

Help localize on Curseforge! - http://wow.curseforge.com/addons/who-taunted/localization/

## Supported Taunts

| Class            | Dragonflight (10.0.0)                                    | Wrath (3.4.0)                                | Vanilla (1.14.3)
| ---              | ---                                                      | ---                                          | ---
| **Warrior**      | Taunt; Challenging Shout (AOE); Disrupting Shout (AOE)   | Taunt; Mocking Blow; Challenging Shout (AOE) | Taunt; Mocking Blow; Challenging Shout (AOE)
| **Paladin**      | Hand of Reckoning; Final Stand (AOE)                     | Hand of Reckoning; Righteous Defense (AOE)   | N/A
| **Druid**        | Growl                                                    | Growl; Challenging Roar (AOE)                | Growl; Challenging Roar (AOE)
| **Death Knight** | Death Grip (Blood); Dark Command                         | Death Grip (Blood); Dark Command             | N/A
| **Monk**         | Provoke; Provoke on Ox Statue (AOE)                      | N/A                                          | N/A
| **Demon Hunter** | Torment                                                  | N/A                                          | N/A
| **Hunter**       | N/A                                                      | Distracting Shot                             | N/A
| **Shaman**       | N/A                                                      | Stoneclaw Totem                              | Stoneclaw Totem
| **Warlock**      | N/A                                                      | Challenging Howl (Metamorphosis)             | N/A

## Supported Taunts (Legacy)
| Class            | Shadowlands (9.2.7)                   | TBC (2.5.4)
| ---              | ---                                   | ---
| **Warrior**      | Taunt; Challenging Shout (AOE)        | Taunt; Mocking Blow; Challenging Shout (AOE)
| **Paladin**      | Hand of Reckoning; Final Stand (AOE)  | Righteous Defense (AOE)
| **Druid**        | Growl                                 | Growl; Challenging Roar (AOE)
| **Death Knight** | Death Grip (Blood); Dark Command      | N/A
| **Monk**         | Provoke; Provoke on Ox Statue (AOE)   | N/A
| **Demon Hunter** | Torment                               | N/A
| **Hunter**       | N/A                                   | N/A
| **Shaman**       | N/A                                    | Stoneclaw Totem
| **Warlock**      | N/A                                  | N/A

## Change Log
**[v2.0.5](https://github.com/Davie3/who-taunted/releases/tag/v2.0.5)**
- 10.0.2 compatibility.
- Minor code change for Party and Raid detection.

**[v2.0.4](https://github.com/Davie3/who-taunted/releases/tag/v2.0.4)**
- Fixed a localization issue which caused options for Output types to not function correctly ([#15](https://github.com/Davie3/who-taunted/issues/15)).
- Added a new option which defaults the output to Self if any of the outputs are unavailable. For example, if you are not in a party or raid.

**[v2.0.3](https://github.com/Davie3/who-taunted/releases/tag/v2.0.3)**
- Fixed a bug that would cause "You Are Not in Party" or similar system errors ([#12](https://github.com/Davie3/who-taunted/issues/12)).

**[v2.0.2](https://github.com/Davie3/who-taunted/releases/tag/v2.0.2)**
- 10.0/Dragonflight compatibility.

**[v2.0.1](https://github.com/Davie3/who-taunted/releases/tag/v2.0.1)**
- Fixed a bug where errors were thrown in Classic when a player taunts. Some code from Mainline WoW was not compatible in Classic ([#8](https://github.com/Davie3/who-taunted/issues/8)).
- Fixed some issues with the Chat Window Options.
- Fixed a rare bug with the Taunt Output Options.

**[v2.0](https://github.com/Davie3/who-taunted/releases/tag/v2.0)**
- 9.2.7 Compatibility.
- Wrath Classic 3.4.0 Support and Compatibility.
- TBC Classic 2.5.4 Support and Compatibility (for good measure if it comes back).
- Classic Era 1.14.3 Support and Compatibility.
- Updating all Version's Taunt Lists to the best of my ability.
- Adding AOE Taunt support for Monk's casting Provoke (115546) on Black Ox Statue (61146).
- Cleaning up and re-organizing the options menu.
- Profiles are now supported in the options menu.
- Re-introducing options to change the Output of each Taunt Type.
- [Various bug fixes and improvements](https://github.com/Davie3/who-taunted/releases/tag/v2.0).

**[v1.5](https://github.com/Davie3/who-taunted/releases/tag/v1.5)**
- 9.0.1/Shadowlands compatibility.
- Removed Hunter's Distracting Shot.
- Re-added Warrior's Challenging Shout under AOE taunts
- Removed all options pertaining to changing the output of the Taunt messages. In 8.2.5, Blizzard protected the SendChatMessage function so this fixes any errors if the output type for WhoTaunted was set to anything other than "self". The default is now to display to the player (which is normal functionality). I will re-add the options if Blizzard makes any changes in the future.

**v1.4.3**
- 8.3 compatibility.

**v1.4.2**
- 8.2 compatibility.

**v1.4.1**
- 8.1 compatibility.

**v1.4**
- 8.0.1/Battle for Azeroth compatibility.
- Adjusted code for API changes.

**v1.3.3**
- 7.3 compatibility.
- Fixed issue with Chinese and Russian translations. So sorry about that!

**v1.3.2**
- 7.2 compatibility.

**v1.3**
- Support for Paladin's Final Stand talent.
- Code rework and clean-up.
- The changes should make it more flexible for the future. Let me know of any trouble!

**v1.2.1**
- 7.1 compatibility.

**v1.2**
- 7.0.3/Legion compatibility.
- Initial support for Demon Hunters.

**v1.1.11**
- 6.2 compatibility.

**v1.1.10**
- 6.1 compatibility.

**v1.1.9**
- Fixed a bug where WhoTaunted would not be disabled in battlegrounds regardless of the setting.
- Added a new option to disable WhoTaunted while in PvP zones (such as Ashran).

**v1.1.8**
- Update for patch 6.0.2.
- Bug fixes.
- Removed some taunt spells that no longer exist.
- Added Mocking Banner for Warriors.

**v1.1.7**
- Update in preparation for patch 6.0.

**v1.1.6**
- Fixed an error loading addon libraries.

**v1.1.5**
- Updated for Mists of Pandaria.
- Support for the Monk taunt Provoke.
- My thanks to Basta from Curse for updating a few lines of code for me.

**v1.1.4**
- 4.2 compatibility.

**v1.1.3**
- 4.1 compatibility.

**v1.1.2**
- 4.0 compatibility.
- Minor bug fixes.

**v1.1.1**
- Fixed a few bugs found in some of the new code.

**v1.1**
- A lot of code has been rewritten and optimized.
- Hide own taunts and failed taunts option added.
- Paladin Righteous Defense target option added.
- The ability to select the chat window for the self output has been added.
- Hide the `<WhoTaunted>` prefix option added.
- Toggle the display of the ability used to taunt option added.
- Fixed bug with the disable in battlegrounds option.