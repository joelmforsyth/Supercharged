local SC = {}
SC.WHEEL_NEGATIVE_CHANCE  = 0.01

SC.MODIFIED = {
    j_baseball = true, j_runner = true, j_constellation = true, j_vampire = true,
    j_green_joker = true, j_scholar = true, j_trousers = true, j_campfire = true,
    j_castle = true, j_shoot_the_moon = true, j_red_card = true, j_madness = true,
    j_square = true, j_misprint = true, j_obelisk = true, j_satellite = true,
    j_matador = true, j_space = true, j_flower_pot = true, j_onyx_agate = true,
    j_rough_gem = true, j_throwback = true, j_ceremonial = true, j_swashbuckler = true,
    j_supernova = true, j_ride_the_bus = true, j_riff_raff = true, j_smeared = true,
    j_ancient = true,
    c_lovers = true,
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

-- ─── Config patches ─────────────────────────────────────────────────────────

local _start_run = Game.start_run

function Game:start_run(args)
    local C = G.P_CENTERS

    C.j_baseball.rarity                  = 2      -- Rare → Uncommon
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
        C.j_space.config.extra            = 3       -- 1 in 4 → 1 in 3 chance to upgrade hand
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

    if G.localization.misc and G.localization.misc.labels then
        G.localization.misc.labels['sc_buffed'] = 'Supercharged'
    end

    local J = G.localization.descriptions.Joker

    J.j_ceremonial.text = {
        "When {C:attention}Blind{} is selected,",
        "destroy Joker to the right",
        "and permanently add {C:attention}double{}",
        "its sell value as {C:red}Mult{}",
        "{C:inactive}(Works on Eternal Jokers){}",
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
            "{X:mult,C:white}X0.5{} Mult per",
            "consecutive hand played",
            "that is not your most",
            "played {C:attention}poker hand{}",
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

    if init_localization then init_localization() end

    return _start_run(self, args)
end

-- ─── Joker calculate overrides ──────────────────────────────────────────────

local _calc = Card.calculate_joker

function Card:calculate_joker(context)

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
                    if c:get_id() == 12 then queens = queens + 1 end
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

    -- Riff-Raff: Negative edition → created jokers are also Negative
    if self.ability.name == 'Riff-Raff' and context.setting_blind and not context.blueprint then
        if self.edition and self.edition.negative then
            local count = type(self.ability.extra) == 'number' and self.ability.extra or 2
            for i = 1, count do
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'rif')
                        card:set_edition({negative = true}, true)
                        card:add_to_deck()
                        G.jokers:emplace(card)
                        G.GAME.joker_buffer = 0
                        return true
                    end
                }))
            end
            return {
                message = localize('k_plus_joker'),
                colour = G.C.GREEN,
            }
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
