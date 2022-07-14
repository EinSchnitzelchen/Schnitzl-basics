Config = {}

--Setting Controls
Config.Controls = {
    HandsUP = 'H',
    Point = 'B',
    Crouch = 'LCONTROL'
}

Config.Animations = {
    HandsUp = {
        animDict = 'random@mugging3',
        anim = 'handsup_standing_base'
    },
    Pointing = {
        animDict = 'anim@mp_point',
        anim = 'task_mp_pointing'
    },
    Crouch = {
        walkSet = 'move_ped_crouched'
    }
}

Config.handsup = true --set to false if you dont want the Character be able to do Handsup
Config.pointing = true --set to false if you dont want the Character be able to Point with finger
Config.crouch = true --set to false if you dont want the Character be able to Crouch



