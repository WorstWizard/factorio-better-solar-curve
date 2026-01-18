--- Times in order: dusk, evening, morning, dawn
--- Corresponding math constants: E, n, d, D
--- https://www.desmos.com/calculator/peke1jt4pp
local function compute_constants()
    storage.const = {}
    storage.const.E = game.surfaces["nauvis"].dusk
    storage.const.n = game.surfaces["nauvis"].evening
    storage.const.d = game.surfaces["nauvis"].morning
    storage.const.D = game.surfaces["nauvis"].dawn
    storage.const.pre_slope = -1.0/(storage.const.n - storage.const.E)
    storage.const.post_slope = 1.0/(storage.const.D - storage.const.d)
    storage.const.pre_mul = math.pi/(2.0*storage.const.n)
    storage.const.post_mul = math.pi/(2.0*(1.0 - storage.const.d))
    local power_before = (2.0+storage.const.E + storage.const.n - storage.const.d - storage.const.D)/2.0
    local power_after = 1.0/storage.const.pre_mul + 1.0/storage.const.post_mul
    storage.const.correction_mul = power_before/power_after
end

local function pre_curve(time)
    return math.cos(time*storage.const.pre_mul)
end
local function post_curve(time)
    return math.cos((1.0-time)*storage.const.post_mul)
end

script.on_init(compute_constants)
script.on_event(defines.events.on_tick,
    function (event)
        local surface = game.surfaces["nauvis"]
        local c = storage.const
        local t = surface.daytime
        local modifier
        if t > c.D then
            modifier = post_curve(t)
        elseif t > c.d then
            modifier = post_curve(t)/(c.post_slope*(t - c.d))
        elseif t >= c.n then
            modifier = 1.0
        elseif t >= c.E then
            modifier = pre_curve(t)/(c.pre_slope*(t - c.n))
        else
            modifier = pre_curve(t)
        end

        surface.solar_power_multiplier = modifier * c.correction_mul
    end
)
