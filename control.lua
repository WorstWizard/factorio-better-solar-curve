----------------
--- [ Math ] ---
----------------

---Precomputes the constants for adjusting the solar curve for the given surface
---@param surface LuaSurface
local function compute_constants(surface)
    --- Times in order: dusk, evening, morning, dawn
    --- Corresponding math constants: E, n, d, D
    --- https://www.desmos.com/calculator/peke1jt4pp
    log(string.format("Computing curve-adjustment constants for surface [%s]", surface.name))
    local constants = {}
    constants.E = surface.dusk
    constants.n = surface.evening
    constants.d = surface.morning
    constants.D = surface.dawn
    constants.pre_slope = -1.0/(constants.n - constants.E)
    constants.post_slope = 1.0/(constants.D - constants.d)
    constants.pre_mul = math.pi/(2.0*constants.n)
    constants.post_mul = math.pi/(2.0*(1.0 - constants.d))
    local power_before = (2.0+constants.E + constants.n - constants.d - constants.D)/2.0
    local power_after = 1.0/constants.pre_mul + 1.0/constants.post_mul
    constants.correction_mul = power_before/power_after

    if not storage.constants then
        localised_print("Initializing storage")
        storage.constants = {}
    end
    storage.constants[surface.name] = constants
end

---@param time float
---@param pre_mul float
---@return float
local function pre_curve(time, pre_mul)
    return math.cos(time*pre_mul)
end
---@param time float
---@param post_mul float
---@return float
local function post_curve(time, post_mul)
    return math.cos((1.0-time)*post_mul)
end

---Computes the adjusted solar_power_multiplier for a given surface for a given tick
---necessary to make the cosine shape, based on precomputed constants
---@param surface LuaSurface
---@return float
local function solar_power_adjusted_mult(surface)
    local constants = storage.constants[surface.name]
    local t = surface.daytime
    local modifier
    if t > constants.D then
        modifier = post_curve(t, constants.post_mul)
    elseif t > constants.d then
        modifier = post_curve(t, constants.post_mul)/(constants.post_slope*(t - constants.d))
    elseif t >= constants.n then
        modifier = 1.0
    elseif t >= constants.E then
        modifier = pre_curve(t, constants.pre_mul)/(constants.pre_slope*(t - constants.n))
    else
        modifier = pre_curve(t, constants.pre_mul)
    end

    return modifier * constants.correction_mul
end

--------------------------
--- [ Event Handling ] ---
--------------------------

---Compute constants whenever a new surface is created.
---Since the default surface ('nauvis') is not created, its constants are computed on init instead.
script.on_event(defines.events.on_surface_created, function (event)
    local surface = game.surfaces[event.surface_index]
    compute_constants(surface)
end)

---Compute constants for all preexisting surfaces when the mod is added
---(just 'nauvis' on a new game, more if the mod is added mid-playthrough)
script.on_init(function (event)
    for _, surface in pairs(game.surfaces) do
        compute_constants(surface)
    end
end)

---Adjust solar multiplier each tick
local function on_tick_run()
    for surface_name in pairs(game.surfaces) do
        local surface = game.surfaces[surface_name]
        surface.solar_power_multiplier = solar_power_adjusted_mult(surface)
    end
end
script.on_event(defines.events.on_tick, on_tick_run)

---Enable/disable runtime setting handling
local function reset_multipliers()
    for surface_name in pairs(game.surfaces) do
        game.surfaces[surface_name].solar_power_multiplier = 1.0
    end
end
script.on_event(defines.events.on_runtime_mod_setting_changed, function (event)
    if event.setting == "better-solar-curve-enabled" then
        if settings.global["better-solar-curve-enabled"].value then
            script.on_event(defines.events.on_tick, on_tick_run)
        else
            reset_multipliers()
            script.on_event(defines.events.on_tick, nil)
        end
    end
end)