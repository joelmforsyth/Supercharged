local SC = {}
-- Set to true for quick local testing of rare effects. False keeps normal 1% Wheel / 1-in-3 Space odds.
SC.DEV_TEST_RARE_EFFECTS = false
SC.WHEEL_NEGATIVE_CHANCE = SC.DEV_TEST_RARE_EFFECTS and 1 or 0.01

SC.MODIFIED = {
    j_baseball = true, j_runner = true, j_constellation = true, j_vampire = true,
    j_green_joker = true, j_scholar = true, j_trousers = true, j_campfire = true,
    j_castle = true, j_shoot_the_moon = true, j_red_card = true, j_madness = true,
    j_square = true, j_misprint = true, j_obelisk = true, j_satellite = true,
    j_matador = true, j_space = true, j_flower_pot = true, j_onyx_agate = true,
    j_rough_gem = true, j_throwback = true, j_ceremonial = true, j_swashbuckler = true,
    j_supernova = true, j_ride_the_bus = true, j_riff_raff = true, j_smeared = true,
    j_ancient = true, j_banner = true, j_ramen = true, j_hack = true,
    j_seeing_double = true,
    c_lovers = true, c_wheel_of_fortune = true, c_ouija = true, c_ankh = true
}

-- ─── Utility ────────────────────────────────────────────────────────────────

local function get_available_suits()
    local found = {}
    for _, area in ipairs({G.deck, G.hand, G.discard}) do
        if area and area.cards then
            for _, c in ipairs(area.cards) do
                if c.base and c.base.suit then
                    found[c.base.suit] = true
                end
            end
        end
    end
    local suits = {}
    for suit in pairs(found) do
        suits[#suits + 1] = suit
    end
    return #suits > 0 and suits or {'Hearts', 'Diamonds', 'Clubs', 'Spades'}
end

local function sc_has_any_suit(card)
    if SMODS and SMODS.has_any_suit then
        return SMODS.has_any_suit(card)
    end
    return card and card.ability and card.ability.name == 'Wild Card'
end

local function sc_seeing_double_check(scoring_hand)
    if SMODS and SMODS.seeing_double_check then
        return SMODS.seeing_double_check(scoring_hand, 'Clubs')
    end

    local suits = {Hearts = 0, Diamonds = 0, Spades = 0, Clubs = 0}
    for _, card in ipairs(scoring_hand or {}) do
        if card and not card.debuff and not sc_has_any_suit(card) then
            if card:is_suit('Clubs') then suits.Clubs = suits.Clubs + 1 end
            if card:is_suit('Diamonds') then suits.Diamonds = suits.Diamonds + 1 end
            if card:is_suit('Spades') then suits.Spades = suits.Spades + 1 end
            if card:is_suit('Hearts') then suits.Hearts = suits.Hearts + 1 end
        end
    end

    for _, card in ipairs(scoring_hand or {}) do
        if card and not card.debuff and sc_has_any_suit(card) then
            if card:is_suit('Clubs') and suits.Clubs == 0 then suits.Clubs = suits.Clubs + 1
            elseif card:is_suit('Diamonds') and suits.Diamonds == 0 then suits.Diamonds = suits.Diamonds + 1
            elseif card:is_suit('Spades') and suits.Spades == 0 then suits.Spades = suits.Spades + 1
            elseif card:is_suit('Hearts') and suits.Hearts == 0 then suits.Hearts = suits.Hearts + 1 end
        end
    end

    return suits.Clubs > 0 and (suits.Hearts > 0 or suits.Diamonds > 0 or suits.Spades > 0)
end

-- P_JOKER_RARITY_POOLS is filled at game init from each center's *original* rarity.
-- Patches in start_run that change C.j_*.rarity do not update those tables, so
-- Wraith / Rares-only effects would still use stale pools unless we re-sync.
local SC_RARITY_RESYNC = {'j_baseball', 'j_scholar', 'j_shoot_the_moon', 'j_banner'}

local function sc_remove_joker_from_rarity_pools(center)
    if not (G and G.P_JOKER_RARITY_POOLS and center and center.key) then return end
    for r = 1, 4 do
        local pool = G.P_JOKER_RARITY_POOLS[r]
        for i = #pool, 1, -1 do
            if pool[i] == center or pool[i].key == center.key then
                table.remove(pool, i)
            end
        end
    end
end

local function sc_resync_joker_rarity_pools(keys)
    for _, k in ipairs(keys) do
        local c = G.P_CENTERS and G.P_CENTERS[k]
        if c and c.set == 'Joker' and not c.demo then
            sc_remove_joker_from_rarity_pools(c)
        end
    end
    for _, k in ipairs(keys) do
        local c = G.P_CENTERS and G.P_CENTERS[k]
        local r = c and c.rarity
        if c and c.set == 'Joker' and not c.demo and r and r >= 1 and r <= 4 and G.P_JOKER_RARITY_POOLS then
            table.insert(G.P_JOKER_RARITY_POOLS[r], c)
        end
    end
    if G.P_JOKER_RARITY_POOLS then
        for i = 1, 4 do
            table.sort(G.P_JOKER_RARITY_POOLS[i], function(a, b) return a.order < b.order end)
        end
    end
end

-- ─── Config patches ─────────────────────────────────────────────────────────

local _start_run = Game.start_run

function Game:start_run(args)
    local C = G.P_CENTERS

    C.j_baseball.rarity                  = 2      -- Rare → Uncommon
    if C.j_banner then
        C.j_banner.rarity                 = 2     -- Common → Uncommon; chips per discard → X chips per discard
        C.j_banner.config.extra           = 1.5
    end
    C.j_runner.config.extra.chip_mod     = 25     -- 15 → 25 chips
    C.j_constellation.config.extra       = 0.25   -- 0.1 → 0.25x
    C.j_vampire.config.extra             = 0.25   -- 0.1 → 0.25x
    C.j_green_joker.config.extra.hand_add = 2     -- +1 → +2, discard stays −1
    C.j_ride_the_bus.config.extra        = 3      -- +1 → +3 mult per consecutive no-face hand
    C.j_scholar.rarity                   = 3      -- Common → Rare
    C.j_scholar.config.extra.chips       = 20
    C.j_scholar.config.extra.mult        = 1.5
    if C.j_trousers then
        C.j_trousers.config.extra                = 4  -- +2 → +4 mult per trigger
    end
    if C.j_campfire then
        C.j_campfire.config.extra         = 0.2    -- per card destroyed (vanilla: per card sold)
    end
    if C.j_castle then
        C.j_castle.config.extra.chip_mod = 5      -- +3 → +5 chips per discard
    end
    if C.j_shoot_the_moon then
        C.j_shoot_the_moon.rarity        = 2      -- Common → Uncommon
        C.j_shoot_the_moon.config.extra  = 0      -- accumulated mult, +13 per Queen held
    end
    if C.v_illusion then
        C.v_illusion.requires = {}                   -- skip Magic Trick prerequisite
    end
    if C.j_red_card then
        C.j_red_card.config.extra          = 10     -- +3 → +10 mult per skipped pack
    end
    if C.j_madness then
        C.j_madness.config.extra          = 1       -- 0.5 → 1x per blind
    end
    if C.j_square then
        C.j_square.config.extra.chip_mod  = 8      -- +4 → +8 chips per card in deck
    end
    if C.j_misprint then
        C.j_misprint.config.extra.max     = 40     -- max random mult 23 → 40
    end
    if C.j_obelisk then
        C.j_obelisk.config.extra          = 0.5     -- 0.2 → 0.5x per consecutive non-fav hand
    end
    if C.j_satellite then
        C.j_satellite.config.extra        = 2       -- $1 → $2 per unique Planet card used
    end
    if C.j_matador then
        C.j_matador.config.extra          = 20      -- $8 → $20 for Boss Blind ability trigger
    end
    if C.j_space then
        C.j_space.config.extra            = SC.DEV_TEST_RARE_EFFECTS and 1 or 3
        -- 3 = Supercharged 1-in-3; 1 in dev = always (vanilla roll is 1 in this number)
    end
    if C.j_flower_pot then
        C.j_flower_pot.config.extra       = 5       -- X3 → X5 Mult if all 4 suits scored
    end
    if C.j_onyx_agate then
        C.j_onyx_agate.config.extra       = 10     -- +7 → +10 Mult per Club scored
    end
    if C.j_rough_gem then
        C.j_rough_gem.config.extra        = 2      -- $1 → $2 per Diamond scored
    end
    if C.j_throwback then
        C.j_throwback.config.extra        = 2       -- X0.25 → X2 per skipped Blind
    end
    if C.c_lovers then
        C.c_lovers.config.max_highlighted = 2        -- 1 → 2 cards
    end
    if C.j_ramen then
        C.j_ramen.config.Xmult  = 5
        C.j_ramen.config.extra  = 0.5
    end

    sc_resync_joker_rarity_pools(SC_RARITY_RESYNC)

    if G.localization.misc and G.localization.misc.labels then
        G.localization.misc.labels['sc_buffed'] = 'Supercharged'
    end

    local J = G.localization.descriptions.Joker

    J.j_ceremonial.text = {
        "When {C:attention}Blind{} is selected,",
        "destroy Joker to the right",
        "and permanently add {C:attention}double{}",
        "its sell value as {C:red}Mult{}",
        "{C:inactive}(Even if Joker isn't destroyed){}",
    }

    J.j_scholar.text = {
        "Played {C:attention}Aces{} give",
        "{C:chips}+#2#{} Chips and",
        "{X:mult,C:white}X#1#{} Mult",
        "when scored",
    }

    J.j_riff_raff.text = {
        "When {C:attention}Blind{} is selected,",
        "create {C:attention}#1#{} {C:blue}Common{} Jokers",
        "{C:inactive}(Must have room){}",
        "{C:dark_edition}Negative{} creates",
        "{C:dark_edition}Negative{} Jokers",
    }

    J.j_ancient.text = {
        "Each played card with",
        "{V:1}#2#{} suit gives",
        "{X:mult,C:white}X#1#{} Mult when scored",
        "{C:inactive}(Suit changes at end of round){}",
        "{C:inactive}(Excludes missing suits){}",
    }

    J.j_green_joker.text = {
        "{C:mult}+2{} Mult per hand played",
        "{C:mult}-1{} Mult per discard",
    }

    if J.j_obelisk then
        J.j_obelisk.text = {
            "This Joker gains {X:mult,C:white}X#1#{} Mult",
            "consecutive hand played",
            "without playing your most",
            "played {C:attention}poker hand{}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}",
        }
    end

    if J.j_hack then
        J.j_hack.text = {
            "Retrigger each played",
            "{C:attention}Ace{}, {C:attention}2{}, {C:attention}3{},",
            "or {C:attention}4{}",
        }
    end

    if J.j_campfire then
        J.j_campfire.text = {
            "This Joker gains {X:mult,C:white}X0.2{} Mult",
            "when a card is destroyed",
        }
    end

    if J.j_castle then
        J.j_castle.text = {
            "This Joker gains {C:chips}+5{} Chips",
            "per discarded card, suit of",
            "card changes every round",
        }
    end

    if J.j_trousers then
        J.j_trousers.text = {
            "{C:mult}+4{} Mult if played",
            "hand contains a",
            "{C:attention}Two Pair{}",
        }
    end

    J.j_swashbuckler.text = {
        "Adds {C:mult}double{} the sell value",
        "of all other owned {C:attention}Jokers{}",
        "to Mult",
    }

    J.j_supernova.text = {
        "Adds {C:mult}double{} the number of times",
        "{C:attention}poker hand{} has been played",
        "this run to Mult",
    }

    if J.j_shoot_the_moon then
        J.j_shoot_the_moon.text = {
            "Permanently gain {C:mult}+13{} Mult",
            "for each {C:attention}Queen{} held",
            "in hand {C:attention}after{} each hand played",
        }
    end

    if J.j_banner then
        J.j_banner.text = {
            "Gains {X:chips,C:white}X#1#{} Chips for",
            "each remaining {C:attention}discard{}",
        }
    end

    if J.j_seeing_double then
        J.j_seeing_double.text = {
            "{X:chips,C:white}X#1#{} Chips if played",
            "hand has a scoring",
            "{C:clubs}Club{} card and a scoring",
            "card of any other {C:attention}suit{}",
        }
    end

    if J.j_ramen then
        J.j_ramen.text = {
            "Gains {X:mult,C:white}X#1#{} Mult,",
            "Loses {X:mult,C:white}X#2#{} Mult for each",
            "{C:attention}hand played",
            "{C:inactive}(Eaten if Mult would be X1 or below){}",
        }
    end

    if J.j_smeared then
        J.j_smeared.text = {
            "{C:hearts}Hearts{} and {C:clubs}Clubs{} count",
            "as the same suit,",
            "{C:diamonds}Diamonds{} and {C:spades}Spades{}",
            "count as the same suit",
        }
    end

    local T = G.localization.descriptions.Tarot
    if T and T.c_lovers then
        T.c_lovers.text = {
            "Enhances {C:attention}#1#{} selected",
            "cards into {C:attention}#2#s{}",
        }
    end
    if T and T.c_wheel_of_fortune then
        T.c_wheel_of_fortune.text = {
            "{C:green}#1# in #2#{} chance to add",
            "{C:attention}Foil{}, {C:attention}Holo{}, or",
            "{C:attention}Polychrome{} edition",
            "to a random {C:attention}Joker{}",
            "{C:green}1 in 100{} chance for {C:dark_edition}Negative{}",
        }
    end
    local S = G.localization.descriptions.Spectral
    if S and S.c_ouija then
        S.c_ouija.text = {
            "Converts all cards",
            "in hand to a single",
            "random {C:attention}rank{}",
        }
    end
    if S and S.c_ankh then
        S.c_ankh.text = {
            "Create a copy of a",
            "random {C:attention}Joker{}, destroy",
            "all other Jokers",
        }
    end

    if init_localization then init_localization() end

    return _start_run(self, args)
end

-- ─── Joker calculate overrides ──────────────────────────────────────────────

local _calc = Card.calculate_joker

function Card:calculate_joker(context)

    -- Ramen: X5, −0.5 x_mult per hand played (replaces per-card discard decay)
    if self.ability.name == 'Ramen' and context.discard and not context.blueprint then
        return nil, true
    end
    if self.ability.name == 'Ramen' and context.after and not context.blueprint then
        if self.debuff then return end
        local loss = self.ability.extra or 0.5
        if (self.ability.x_mult or 1) - loss <= 1 then
            SMODS.destroy_cards(self, nil, nil, true)
            return {
                card = self,
                message = localize('k_eaten_ex'),
                colour = G.C.FILTER
            }
        else
            SMODS.scale_card(self, {
                ref_table   = self.ability,
                ref_value   = 'x_mult',
                scalar_value = 'extra',
                operation   = '-',
                message_key = 'a_xmult_minus',
                colour      = G.C.RED,
                message_delay = 0.2,
            })
            return nil, true
        end
    end

    -- Banner: X1.5 Chips per remaining discard (replaces flat chips)
    if self.ability.name == 'Banner' and context.joker_main then
        if self.debuff then return end
        local n = (G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        if n > 0 then
            local per = self.ability.extra or 1.5
            local x = n * per
            return {
                xchips = x,
            }
        end
        return
    end

    -- Seeing Double: X2 Chips instead of X2 Mult
    if self.config and self.config.center and self.config.center.key == 'j_seeing_double' then
        if self.debuff then return end
        if context.joker_main and sc_seeing_double_check(context.scoring_hand) then
            return {
                xchips = self.ability.extra or 2,
                card = context.blueprint_card or self,
            }
        end
        return
    end

    -- Swashbuckler: double the sell-value mult
    if self.ability.name == 'Swashbuckler' then
        local result = _calc(self, context)
        if result and (result.mult_mod or result.mult) then
            local key = result.mult_mod and 'mult_mod' or 'mult'
            result[key] = result[key] * 2
            result.message = localize{type='variable', key='a_mult', vars={result[key]}}
        end
        return result
    end

    -- Supernova: double the mult from times played
    if self.ability.name == 'Supernova' then
        local result = _calc(self, context)
        if result and (result.mult_mod or result.mult) then
            local key = result.mult_mod and 'mult_mod' or 'mult'
            result[key] = result[key] * 2
            result.message = localize{type='variable', key='a_mult', vars={result[key]}}
        end
        return result
    end

    -- Ceremonial Dagger: gains mult from Eternal jokers too
    if self.ability.name == 'Ceremonial Dagger' then
        if self.debuff then return end

        if context.setting_blind and not self.getting_sliced and not context.blueprint then
            local my_pos
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == self then my_pos = i; break end
            end
            local target = my_pos and G.jokers.cards[my_pos + 1]
            if target and not target.getting_sliced then
                local gain = (target.sell_cost or 0) * 2
                if gain > 0 then
                    self.ability.mult = (self.ability.mult or 0) + gain
                    if not target.ability.eternal then
                        target.getting_sliced = true
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                target:start_dissolve({G.C.RED}, nil, 1.6)
                                return true
                            end
                        }))
                    end
                    return {
                        message = localize{type='variable', key='a_mult', vars={gain}},
                        colour = G.C.RED,
                    }
                end
            end
            return
        end

        if context.cardarea == G.jokers and not context.before and not context.after then
            if (self.ability.mult or 0) > 0 then
                return {
                    message = localize{type='variable', key='a_mult', vars={self.ability.mult}},
                    mult_mod = self.ability.mult,
                }
            end
        end
        return
    end

    -- Scholar: rare, +20 chips + X1.5 mult on Aces
    if self.ability.name == 'Scholar' then
        if self.debuff then return end
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other and other:get_id() == 14 then
                return {
                    chips = self.ability.extra.chips or 20,
                    Xmult = self.ability.extra.mult or 1.5,
                    card = other,
                }
            end
        end
        return
    end

    -- Hack: retrigger Aces, 2s, 3s, and 4s instead of 2s through 5s
    if self.config and self.config.center and self.config.center.key == 'j_hack'
       and context.repetition and context.cardarea == G.play and not context.repetition_only then
        if self.debuff then return end
        local other = context.other_card
        local id = other and other:get_id()
        if id == 14 or id == 2 or id == 3 or id == 4 then
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = context.blueprint_card or self,
            }
        end
        return
    end

    -- Shoot the Moon: cumulative +13 mult per Queen held in hand
    if self.ability.name == 'Shoot the Moon' then
        if self.debuff then return end

        if context.joker_main then
            if self.ability.extra > 0 then
                return {
                    message = localize{type='variable', key='a_mult', vars={self.ability.extra}},
                    mult_mod = self.ability.extra,
                }
            end
            return
        end

        if context.after and context.scoring_hand and not context.blueprint then
            local queens = 0
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c:get_id() == 12 and not c.debuff then queens = queens + 1 end
                end
            end
            if queens > 0 then
                self.ability.extra = self.ability.extra + (queens * 13)
                return {
                    message = localize{type='variable', key='a_mult', vars={queens * 13}},
                    colour = G.C.MULT,
                }
            end
            return
        end
        return
    end

    -- Riff-Raff: Negative edition -> created jokers are also Negative
    if self.config and self.config.center and self.config.center.key == 'j_riff_raff'
       and context.setting_blind and not context.blueprint and not self.debuff then
        if self.edition and self.edition.negative then
            local available = G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer)
            if available > 0 then
                local count = math.min(type(self.ability.extra) == 'number' and self.ability.extra or 2, available)
                G.GAME.joker_buffer = G.GAME.joker_buffer + count
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, count do
                            local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'rif')
                            card:set_edition({negative = true}, true)
                            card:add_to_deck()
                            G.jokers:emplace(card)
                            card:start_materialize()
                        end
                        G.GAME.joker_buffer = 0
                        return true
                    end
                }))
                return {
                    message = localize('k_plus_joker'),
                    colour = G.C.GREEN,
                }
            end
            return
        end
    end

    -- Campfire: gain X0.25 per card destroyed, no boss reset
    if self.ability.name == 'Campfire' then
        if self.debuff then return end

        local rate = self.ability.extra or 0.2

        if context.remove_playing_cards and context.removed and not context.blueprint then
            local gain = #context.removed * rate
            SMODS.scale_card(self, {
                ref_table   = self.ability,
                ref_value   = 'x_mult',
                scalar_table = { sc_gain = gain },
                scalar_value = 'sc_gain',
                message_key = 'a_xmult',
            })
            return nil, true
        end

        if context.joker_type_destroyed and not context.blueprint then
            SMODS.scale_card(self, {
                ref_table   = self.ability,
                ref_value   = 'x_mult',
                scalar_table = { sc_gain = rate },
                scalar_value = 'sc_gain',
                message_key = 'a_xmult',
            })
            return nil, true
        end

        if context.joker_main then
            if (self.ability.x_mult or 1) > 1 then
                return { Xmult = self.ability.x_mult }
            end
            return
        end

        return
    end

    -- Ancient Joker: exclude suits missing from the deck (end-of-round only)
    if self.ability.name == 'Ancient Joker' and context.end_of_round
       and not context.individual and not context.repetition and not context.blueprint then
        local suits = get_available_suits()
        local chosen = suits[math.ceil(pseudorandom('ancient_sc') * #suits)]
        if G.GAME.current_round.ancient_card then
            G.GAME.current_round.ancient_card.suit = chosen
        end
        return
    end

    return _calc(self, context)
end

-- ─── Wheel of Fortune: 1% Negative ─────────────────────────────────────────

local _use = Card.use_consumeable

function Card:use_consumeable(area, copier)
    if self.config and self.config.center and self.config.center.key == 'c_ankh' then
        local eligible = {}
        for _, j in ipairs(G.jokers.cards) do
            eligible[#eligible + 1] = j
        end
        if #eligible > 0 then
            local chosen = pseudorandom_element(eligible, pseudoseed('ankh'))
            local to_destroy = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= chosen and not (j.ability and j.ability.eternal) then
                    to_destroy[#to_destroy + 1] = j
                end
            end

            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.4,
                func = function()
                    local card = copy_card(chosen, nil, nil, nil, false)
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    card:start_materialize()
                    return true
                end
            }))

            if #to_destroy > 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        SMODS.destroy_cards(to_destroy, nil, nil, true)
                        return true
                    end
                }))
            end

            return
        end
    end

    if self.config and self.config.center and self.config.center.key == 'c_ouija' then
        local old_change_size = G.hand.change_size
        G.hand.change_size = function(hand, amount, ...)
            if amount and amount < 0 then return end
            return old_change_size(hand, amount, ...)
        end

        local ret = {pcall(_use, self, area, copier)}
        G.hand.change_size = old_change_size
        if not ret[1] then error(ret[2]) end
        return ret[2], ret[3], ret[4]
    end

    if self.ability.name == 'The Wheel of Fortune' then
        if pseudorandom('sc_wheel') < SC.WHEEL_NEGATIVE_CHANCE then
            local eligible = {}
            for _, j in ipairs(G.jokers.cards) do
                if not j.edition then eligible[#eligible + 1] = j end
            end
            if #eligible > 0 then
                local target = pseudorandom_element(eligible, pseudoseed('sc_wheel_neg'))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        target:set_edition({negative = true}, true)
                        target:juice_up(0.3, 0.5)
                        return true
                    end
                }))
                return
            end
        end
    end
    return _use(self, area, copier)
end

-- ─── Supercharged badge in joker tooltip ──────────────────────────────────

local _get_badge_colour = get_badge_colour
function get_badge_colour(key)
    if key == 'sc_buffed' then return HEX('4DF2FF') end
    return _get_badge_colour(key)
end

local _gen_card_ui = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, ...)
    if _c and _c.key and SC.MODIFIED[_c.key] and not full_UI_table then
        badges = badges or {}
        badges[#badges + 1] = 'sc_buffed'
    end
    return _gen_card_ui(_c, full_UI_table, specific_vars, card_type, badges, ...)
end

-- ─── Smeared Joker: Hearts+Clubs, Diamonds+Spades ─────────────────────────

if SMODS and SMODS.smeared_check then
    function SMODS.smeared_check(card, suit)
        if not next(find_joker('Smeared Joker')) then return false end
        local s = card.base and card.base.suit
        if (s == 'Hearts' or s == 'Clubs') and (suit == 'Hearts' or suit == 'Clubs') then
            return true
        elseif (s == 'Diamonds' or s == 'Spades') and (suit == 'Diamonds' or suit == 'Spades') then
            return true
        end
        return false
    end
end

-- ─── JokerDisplay compatibility ─────────────────────────────────────────────

if JokerDisplay then
    local defs = JokerDisplay.Definitions or {}
    defs.j_scholar = {
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS },
            { text = " X",                             colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "x_mult", colour = G.C.MULT }
        },
        reminder_text = {
            { ref_table = "card.joker_display_values", ref_value = "localized_text" }
        },
        calc_function = function(card)
            local chips, x_mult = 0, 1
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:get_id() and scoring_card:get_id() == 14 then
                        local retriggers = JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        chips = chips + (card.ability.extra.chips or 20) * retriggers
                        x_mult = x_mult * ((card.ability.extra.mult or 1.5) ^ retriggers)
                    end
                end
            end
            card.joker_display_values.chips = chips
            card.joker_display_values.x_mult = x_mult
            card.joker_display_values.localized_text = "(" .. localize("k_aces") .. ")"
        end
    }

    defs.j_swashbuckler = {
        text = {
            { text = "+" },
            { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
        },
        text_config = { colour = G.C.MULT },
        calc_function = function(card)
            card.joker_display_values.mult = (card.ability.mult or 0) * 2
        end
    }

    defs.j_supernova = {
        text = {
            { text = "+" },
            { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
        },
        text_config = { colour = G.C.MULT },
        calc_function = function(card)
            local text, _, _ = JokerDisplay.evaluate_hand()
            local base = (text ~= 'Unknown' and G.GAME.hands[text] and G.GAME.hands[text].played) or 0
            card.joker_display_values.mult = base * 2
        end
    }

    defs.j_shoot_the_moon = {
        text = {
            { text = "+" },
            { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
        },
        text_config = { colour = G.C.MULT },
        calc_function = function(card)
            if not next(G.play.cards) then
                card.joker_display_values.mult = card.ability.extra
            end
        end
    }

    defs.j_banner = {
        text = {
            { text = "X" },
            { ref_table = "card.joker_display_values", ref_value = "x_chips", colour = G.C.CHIPS, retrigger_type = "chips" }
        },
        text_config = { colour = G.C.UI.TEXT_DARK },
        calc_function = function(card)
            local n = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
            local per = (card.ability and card.ability.extra) or 1.5
            card.joker_display_values.x_chips = n > 0 and n * per or 0
        end
    }

    defs.j_seeing_double = {
        text = {
            { text = "X" },
            { ref_table = "card.joker_display_values", ref_value = "x_chips", colour = G.C.CHIPS, retrigger_type = "chips" }
        },
        text_config = { colour = G.C.UI.TEXT_DARK },
        calc_function = function(card)
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            card.joker_display_values.x_chips =
                text ~= 'Unknown' and sc_seeing_double_check(scoring_hand) and (card.ability.extra or 2) or 1
        end
    }

    local r_mult = {}
    for i = 0, 40 do r_mult[#r_mult + 1] = tostring(i) end
    defs.j_misprint = {
        text = {
            { text = "+", colour = G.C.MULT },
            {
                dynatext = {
                    string = r_mult,
                    colours = { G.C.MULT },
                    pop_in_rate = 9999999,
                    silent = true,
                    random_element = true,
                    pop_delay = 0.5,
                    scale = 0.4,
                    min_cycle_time = 0
                }
            }
        }
    }
end

print('[Supercharged] Loaded.')
