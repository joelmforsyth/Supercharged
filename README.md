# Supercharged

A [Balatro](https://www.playbalatro.com/) mod that buffs underperforming Jokers and a few other cards so they keep up in long or high-stakes runs. Changes apply when a new run starts (existing saves pick them up on the next run).

**Dependencies:** [Steamodded](https://github.com/Steamodded/smods) (>= 1.0.0~ALPHA-1228c) and [Lovely](https://github.com/ethangreen-dev/lovely-injector) (>= 0.6).

## Installation

1. Install Steamodded and Lovely per their instructions.
2. Copy this folder into your Balatro mods directory (same place as other Steamodded mods).
3. Enable **Supercharged** in the in-game mod list and start (or restart) a run.

Buffed cards show a **Supercharged** badge in the UI.

## Optional compatibility

If **[JokerDisplay](https://github.com/nh6579/JokerDisplay)** is installed, this mod adds display definitions for Scholar, Swashbuckler, Supernova, Shoot the Moon, and Misprint so overlays match the new math.

---

## Joker changes

Unless noted, changes are **numeric buffs** to the vanilla effect. A few Jokers have **new or altered behavior**; those are called out explicitly.

| Joker                 | Change                                                                                                                                                                |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Baseball Card**     | Rarity: Rare → **Uncommon**.                                                                                                                                          |
| **Runner**            | +15 → **+25** chips per hand containing a **Straight**.                                                                                                               |
| **Constellation**     | +0.1X → **+0.25X** Mult per Planet card used this run.                                                                                                                |
| **Vampire**           | +0.1X → **+0.25X** Mult per scoring enhancement removed.                                                                                                              |
| **Green Joker**       | +1 → **+2** Mult per hand played (discard penalty stays **−1** Mult).                                                                                                 |
| **Ride the Bus**      | +1 → **+3** Mult per consecutive hand played with **no face cards** scored.                                                                                           |
| **Scholar**           | Rarity: Common → **Rare**. **Reworked:** played **Aces** give **+20** chips and **X1.5** Mult when scored (replaces vanilla Scholar scoring rules).                   |
| **Trousers**          | +2 → **+4** Mult when the played hand contains **Two Pair**.                                                                                                          |
| **Campfire**          | Gains **X0.2** Mult when **playing cards are destroyed** or when **another Joker is destroyed** (broader than vanilla’s sell-based scaling).                          |
| **Castle**            | +3 → **+5** chips per matching discarded card; suit still rotates each round.                                                                                         |
| **Shoot the Moon**    | Rarity: Common → **Uncommon**. **Reworked:** after each played hand, permanently gains **+13** Mult for each **Queen** held in hand at scoring time.                  |
| **Red Card**          | +3 → **+10** Mult per skipped Booster pack.                                                                                                                           |
| **Madness**           | +0.5X → **+1X** Mult per Blind destroyed.                                                                                                                             |
| **Square Joker**      | +4 → **+8** chips in full deck per **52** cards in deck.                                                                                                              |
| **Misprint**          | Random Mult cap **23 → 40**.                                                                                                                                          |
| **Obelisk**           | +0.2X → **+0.5X** Mult per consecutive hand that is **not** your most-played **poker hand** type.                                                                     |
| **Satellite**         | **$1 → $2** per unique Planet card used this run, end of round.                                                                                                       |
| **Matador**           | **$8 → $20** when a **Boss Blind**’s ability is triggered.                                                                                                            |
| **Space Joker**       | Upgrade chance **1 in 4 → 1 in 3** after hand played.                                                                                                                 |
| **Flower Pot**        | **X3 → X5** Mult when the played hand contains all **four** suits.                                                                                                    |
| **Onyx Agate**        | +7 → **+10** Mult per scored **Club**.                                                                                                                                |
| **Rough Gem**         | **$1 → $2** per scored **Diamond**.                                                                                                                                   |
| **Throwback**         | Per skipped Blind: **X0.25 → X2** Mult (stacks multiplicatively per skip).                                                                                            |
| **Ceremonial Dagger** | Adds **double** the destroyed Joker’s **sell value** as **Mult**. **Eternal** Jokers to the right can still be “sliced” for Mult **without** being destroyed.         |
| **Swashbuckler**      | Mult from other Jokers’ sell values is **doubled** (still based on sell value of other Jokers only).                                                                  |
| **Supernova**         | Mult from “times this **poker hand** was played” is **doubled**.                                                                                                      |
| **Riff-Raff**         | If **Riff-Raff** is **Negative**, each created **Common** Joker is also **Negative**.                                                                                 |
| **Smeared Joker**     | **Suit pairing changed:** **Hearts** and **Clubs** count as one suit; **Diamonds** and **Spades** count as one suit (vanilla pairs Hearts/Diamonds and Clubs/Spades). |
| **Ancient Joker**     | At end of round, the "ancient" suit only picks from **suits that actually appear** in deck, hand, or discard (**missing** suits from the run are excluded).           |
| **Banner**            | Rarity: Common → **Uncommon**. **Reworked:** gives **X1.5** Chips for each remaining discard.                                                                         |
| **Hack**              | Retriggers played **Aces**, **2s**, **3s**, and **4s** instead of **2s**, **3s**, **4s**, and **5s**.                                                                 |

---

## Tarot and consumable changes

| Card                     | Change                                                                                                                                                                                                                                                     |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **The Lovers**           | Can select **2** cards (vanilla: **1**) to turn into **Wild** cards.                                                                                                                                                                                       |
| **The Wheel of Fortune** | Tooltip notes a **1 in 100** chance for **Negative** on a random Joker. In code, when you use Wheel there is a **1%** roll: if it succeeds, a random Joker **with no edition** gains **Negative** (otherwise vanilla Wheel behavior applies for that use). |
| **Ouija**                | Converts all cards in hand to a single random rank, but no longer reduces hand size.                                                                                                                                                                       |
| **Ankh**                 | Copies a random Joker and destroys the others as usual, but no longer removes **Negative** from the copy.                                                                                                                                                  |

---

## Voucher changes

| Voucher         | Change                                                                                                                      |
|-----------------|-----------------------------------------------------------------------------------------------------------------------------|
| **Magic Trick** | Removed.                                                                                                                    |
| **Illusion**    | **Magic Trick** is no longer required — the prerequisite is removed so Illusion can appear in the shop like other vouchers. |

---

## Credits

- **Author:** joelmforsyth  
- **Version:** 1.1.0 (see `Supercharged.json`)

Balatro is property of LocalThunk. This mod is an independent fan work and is not affiliated with the official game.
