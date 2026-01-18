Adjusts the solar power curve to be cosine-shaped. In a sense this is a cosmetic mod: The total power production throughout a full day is identical to the vanilla curve, so this doesn't buff/nerf solar power, though peak output is higher and so may need more accumulators to handle the power input.

# Installing & Uninstalling
The mod is safe to add mid-playthrough and should function correctly. The mod is **not currently safe to remove mid-playthrough:** Doing so will freeze the adjustment to the curve at whichever level it was at when removed, on each planet.

# Compatibility
The mod *should* be compatible with:
- Modded planets
- Mods that change solar panels
- Mods that change the *length* of the day/night cycle
- Mods that otherwise change solar power mechanics
- *Possibly* compatible with mods that change the stages of the day/night cycle (`dusk, evening, morning, dawn`), depends on the order the mods load in.

The mod *is not* compatible with:
- Any mod that uses the [`solar_power_multiplier`](https://lua-api.factorio.com/stable/classes/LuaSurface.html#solar_power_multiplier) property.

## Details
The cosine curve effect is achieved by adjusting the `solar_power_multiplier` property of each surface on each tick, thereby transforming the trapezoidal function into a cosine curve. The mod should be compatible with any mods that don't touch this value themselves.

Curiously yet fortunately, the game doesn't seem to use this property at all to my knowledge: In Space Age, different planets achieve different levels of solar power by [multiplying the production with the `"solar-power"` surface property](https://lua-api.factorio.com/stable/prototypes/SolarPanelPrototype.html#solar_coefficient_property) defined in their prototype. Thereby, support for other planets (modded too) comes for free!

# Realism
*Note: The goal of this mod is not to model truly realistic solar power, just to do a little better than vanilla.*

Besides the delicious smooth progression from zero to max power compared to vanilla, the reason you might want to use this mod is for improved realism, so here's some notes on that:

The cosine shaped curve is what you'd expect from a (flat) static solar like those we see in-game, though not taking atmospheric effects into account. As in, it matches the expected result if you put a solar panel flat on the ground on the moon.

If we pretend that the Factorio solar panels are tracking the sun, then the vanilla power curve is actually [closer to what you'd expect](https://www.solsystems.com/wp-content/uploads/2017/09/Figure-3.png).