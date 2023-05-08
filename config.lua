Config = Config or {}

-- MÍNIMO DE POLICÍA PARA ROBAR UN ATM
Config.MinPolice = 0

--- OBJETO QUE SE NECESITA PARA HACKEAR
Config.itemToHack = 'water_bottle'


--- TIEMPO QUE TARDA EN COGER EL DINERO DEL HACKEO EN SEGUNDOS
Config.timeToRobHack = 10 -- seconds


--- CUANTO DINERO DA EL HACKEAR ---
Config.moneyHacking = 300


--- CONFIGURAR EL MINIJUEGO PARA QUE SEA MÁS DIFICIL O MÁS FACIL
Config.ThermiteGame = {
    time = 10, -- Tiempo para terminar el minijuego
    gridSize = 5, -- Cuanto ocupa el cuadrado solo puede tener (5, 6, 7, 8, 9, 10)
    incorrectBlocks = 10, -- Cuantos bloques puede fallar
}


--- LOS BILLETES QUE TE PUEDE SOLTAR 5$ 10$ 20$ 50$ 100$ ---
Config.bills = {
    5,
    10,
    20,
    50,
    100,
}


--- TIEMPO PARA QUE SE PUEDA VOLVER A ROBAR ESE ATM
Config.resetAtm = 10 -- minutes


Config.Locales = {
    ["select_option_rob_atm"] = "¿Como quieres robar el ATM?",
    ['type_hack'] = "Hackearlo",
    ['type_break'] = "Romper el ATM",
    ["not_enough_police"] = "No hay suficiente policia",
    ["start_breaking_atm"] = 'Empieza a robar el ATM, la mejor manera sera con una palanca',
    ["no_item_to_hack"] = "No tienes el portatil",
    ["hack_failed"] = 'Has fallado el hackeo',
    ["atm_already_robbed"] = 'Parece que ya han robado este ATM',
}

Config.atmModels = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm"
}