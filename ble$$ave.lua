local encoding = require 'encoding'
local sp  = require 'lib.samp.events'
local weapons = require 'game.weapons'
local mem = require "memory"
local inicfg = require 'inicfg'
local effil = require("effil")
local vkeys = require 'vkeys'
local dlstatus = require('moonloader').download_status
local wm = require 'lib.windows.message'
local rkeys = require 'rkeys'
encoding.default = 'CP1251'
u8 = encoding.


update_state = false

local script_vers = 2
local script_vers_text = "1.05"

local update_url = "https://raw.githubusercontent.com/tedj69/blessave_scripts/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "" -- тут свою ссылку
local script_path = thisScript().path



local supportka = [[
    8-) САМЫЙ ЛУЧШИЙ ХЕЛПЕР-БИНДЕР ДЛЯ ARIZONA RP(G) 8-)

    SHIFT+F5 - Выключить скрипт

    <3 Биндеры: /lock, /armour, /time, /mask, /usedrugs 3, /anim 3, /anim 9, /style, /key, /repcar, /fillcar, /cars, /usemed, q

    Прицел на игрока + Q - Обоссать жерту рваного дюрекста

    :-D Команды:
    /calc - Калькулятор
    /flood - Информация о флудерках
    /rend - Рендер на почти всё, что есть
    /fpay - Оплата фам.квартиры
    /piss - Пописять (можно попасть в психушку)
    /fm - /fammenu
    /k [text] - /fam [text]
    /mb - /members
    /hrec - Рекконект
    /cchat - Очистить чат
    /fh [id] - /findihouse [id]
    /fbiz [id] - /findibiz [id]
    /rep [суть репорта] - Авто-отправка репорта админам
    /eathome - Покушать в доме из холодильника (нужно стоять именно в доме! не в гараже/подвале, а в доме!)
    /gcolors - Цвета машин банд
    /getcolor [id car] - Узнать цвет авто по ID (id пишется в самом начале в /dl)
    B-) Оружие:
    /de (кол-во) - Взять Desert Eagle
    /m4 (кол-во) - Взять М4A1
    /sg (кол-во) - Взять Shotgun
    /mp5 (кол-во) - Взять MP5
    /rfl (кол-во) - Взять Country Rifle
    /ak (кол-во) - Взять AK-47
    /pst (кол-во) - Взять SD Pistol

    В конфиге скрипта \\moonloader\\config\\settings.ini настройка следующая:

    О:) Секция [config]:
    После знака "=" (равно) вписывать ID клавиши!
    
    allsbiv - Сбив абсолютно любой анимации игрока 
    sbiv - Не жесткий сбив анимации 
    suicide - Суицид 
    wh - WallHack
    
    
    О:) Секция [functions]:
    После знака "=" (равно) вписывать true(включено) либо false(выключено)!
    
    hphud - Показатель HD/ARM в цифрах для обычного худа
    dotmoney - Разделять точками деньги
    dhits - Авто-дабл-хиты
    autoc - Авто-+С
    

    В биндере скрипта \\moonloader\\config\\binds.bind настройка следующая:

    Чтобы добавить биндер нужно в конце строки поставить запятую перед закрывающей квадратной скобкой и вписать:
    {"text":"МАТЬ ЕБАЛ[enter]","v":[82]}
    Здесь: текст бинда это МАТЬ ЕБАЛ ([enter] - нажмимает интер, если не писать то биндер просто введется в чате), 82 - это ID клавиши. В данном случае клавиша R.

    Чтобы добавить биндер на команду нужно ввести обратный слэш "\" перед самой командой:
    {"text":"\/mask[enter]","v":[82]}

    Возникли вопросы? 
    Разработчик @blessave всегда готов послать Вас нахуй!!! xD
]]

local file = getWorkingDirectory() .. "\\config\\binds.bind"
local tEditData = {
   id = -1,
   inputActive = false
}


local tBindList = {}
if doesFileExist(file) then
   local f = io.open(file, "r")
   if f then
      tBindList = decodeJson(f:read("a*"))
      f:close()
   end
end

local mainini = inicfg.load(nil, "settings")
local maintxt = inicfg.load(nil, "pidorasi.txt")
   -- inicfg.save(mainini, 'moonloader\\config.ini') 
----------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------
local fontt = renderCreateFont('Arial', 10, 9)

local sukazaebalmutit = 0

bike = {[481] = true, [509] = true, [510] = true}
moto = {[448] = true, [461] = true, [462] = true, [463] = true, [468] = true, [471] = true, [521] = true, [522] = true, [523] = true, [581] = true, [586] = true}

local fam = {'Family', 'Empire', 'Squad', 'Dynasty', 'Corporation', 'Crew', 'Brotherhood'}


notkey = false
local locked = false

floodon1 = false
floodon2 = false
floodon3 = false

---------------
----------



local vknotf = {
	ispaydaystate = false,
	ispaydayvalue = 0,
	ispaydaytext = '',
    chatc = false,
    chatf = false,
    dialogs = false,
}


local key, server, ts

function threadHandle(runner, url, args, resolve, reject) -- обработка effil потока без блокировок
	local t = runner(url, args)
	local r = t:get(0)
	while not r do
		r = t:get(0)
		wait(0)
	end
	local status = t:status()
	if status == 'completed' then
		local ok, result = r[1], r[2]
		if ok then resolve(result) else reject(result) end
	elseif err then
		reject(err)
	elseif status == 'canceled' then
		reject(status)
	end
	t:cancel(0)
end

function requestRunner() -- создание effil потока с функцией https запроса
	return effil.thread(function(u, a)
		local https = require 'ssl.https'
		local ok, result = pcall(https.request, u, a)
		if ok then
			return {true, result}
		else
			return {false, result}
		end
	end)
end

local function closeDialog()
	sampSetDialogClientside(true)
	sampCloseCurrentDialogWithButton(0)
	sampSetDialogClientside(false)
end

function async_http_request(url, args, resolve, reject)
	local runner = requestRunner()
	if not reject then reject = function() end end
	lua_thread.create(threadHandle,runner, url, args, resolve, reject)
end

local vkerr, vkerrsend -- сообщение с текстом ошибки, nil если все ок
function tblfromstr(str)
	local a = {}
	for b in str:gmatch('%S+') do
		a[#a+1] = b
	end
	return a
end
function longpollResolve(result)
	if result then
		if not result:sub(1,1) == '{' then
			vkerr = 'Ошибка!\nПричина: Нет соединения с VK!'
			return
		end
		local t = decodeJson(result)
		if t.failed then
			if t.failed == 1 then
				ts = t.ts
			else
				key = nil
				longpollGetKey()
			end
			return
		end
		if t.ts then
			ts = t.ts
		end
		if t.updates then
			for k, v in ipairs(t.updates) do
				if v.type == 'message_new' and tonumber(v.object.from_id) == tonumber(mainini.helper.user_id) and v.object.text then
					if v.object.payload then
						local pl = decodeJson(v.object.payload)
						if pl.button then
							if pl.button == 'getstats' then 
								getPlayerArzStats()
							elseif pl.button == 'getinfo' then
								getPlayerInfo()
                            elseif pl.button == 'support' then
                                sendvknotf(supportka)
                           elseif pl.button == 'openchest' then
								openchestrulletVK()
                            elseif pl.button == 'hungry' then
								getPlayerArzHun()
                            elseif pl.button == 'homeeat' then
								sampProcessChatInput('/eathome')
                                sendvknotf('Приятного аппетита!')
                            elseif pl.button == 'chatchat' then
								chatchatVK()
                            elseif pl.button == 'famchat' then
								famchatVK()
                            elseif pl.button == 'razgovor' then
								razgovorVK()
                            elseif pl.button == 'alldialogs' then
								alldialogsVK()
							end
						end
						return
					end
					local objsend = tblfromstr(v.object.text)
					if objsend[1] == '!getplstats' then
						getPlayerArzStats()
					elseif objsend[1] == '!recon' then
                        sendvknotf('Переподключаемся на сервер!')
                        reconnect()
					elseif objsend[1] == '!gethun' then
						getPlayerArzHun()
					elseif objsend[1] == '!' then
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampProcessChatInput(args)
							sendvknotf('Сообщение "' .. args .. '" отправлено')
						else
							sendvknotf('Неправильный аргумент! Пример: ! [text]')
						end
                    elseif objsend[1] == '.' then
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampProcessChatInput(args)
						else
							sendvknotf('Неправильный аргумент! Пример: . [text]')
						end
					end
                    local text = v.object.text .. ' ' --костыль на случай если одна команда является подстрокой другой (!d и !dc как пример)
					if text:match('^%s-%d+%s') then
							text = text:gsub(text:match('^%s-%d+%s*'), '')
					end
                    if text:match('^!d') then
						text = text:sub(1, text:len() - 1)
						local style = sampGetCurrentDialogType()
						if style == 2 or style > 3 then
							sampSendDialogResponse(sampGetCurrentDialogId(), 1, tonumber(u8:decode(text:match('^!d (%d*)'))) - 1, -1)
						elseif style == 1 or style == 3 then
							sampSendDialogResponse(sampGetCurrentDialogId(), 1, -1, u8:decode(text:match('^!d (.*)')))
						else
							sampSendDialogResponse(sampGetCurrentDialogId(), 1, -1, -1)
						end
						closeDialog()
					elseif text:match('^!dc') then
						closeDialog()
					else
						text = text:sub(1, text:len() - 1)
						sampProcessChatInput(u8:decode(text))
					end
				end
			end
		end
	end
end

function longpollGetKey()
	async_http_request('https://api.vk.com/method/groups.getLongPollServer?group_id=198601953&access_token=3544140c860f6dd414cbd45aa355e61fbd4f4010620ea75a3ec682a01bee7e6b5fb9bf01524df709b1090&v=5.80', '', function (result)
		if result then
			if not result:sub(1,1) == '{' then
				vkerr = 'Ошибка!\nПричина: Нет соединения с VK!'
				return
			end
			local t = decodeJson(result)
			if t then
				if t.error then
					vkerr = 'Ошибка!\nКод: ' .. t.error.error_code .. ' Причина: ' .. t.error.error_msg
					return
				end
				server = t.response.server
				ts = t.response.ts
				key = t.response.key
				vkerr = nil
			end
		end
	end)
end
function sendvknotf0(msg)
	host = host or sampGetCurrentServerName()
	local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) .. '['..select(2,sampGetPlayerIdByCharHandle(playerPed))..']'
	msg = msg:gsub('{......}', '')
	msg = msg
	msg = u8(msg)
	msg = url_encode(msg)
	local keyboard = vkKeyboard()
	keyboard = u8(keyboard)
	keyboard = url_encode(keyboard)
	msg = msg .. '&keyboard=' .. keyboard
	if mainini.helper.user_id ~= '' then
		async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. mainini.helper.user_id .. '&message=' .. msg .. '&access_token=3544140c860f6dd414cbd45aa355e61fbd4f4010620ea75a3ec682a01bee7e6b5fb9bf01524df709b1090&v=5.80',
		function (result)
			local t = decodeJson(result)
			if not t then
				return
			end
			if t.error then
				vkerrsend = 'Ошибка!\nКод: ' .. t.error.error_code .. ' Причина: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end
function sendvknotf(msg, host)
	host = host or sampGetCurrentServerName()
    local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) .. '['..select(2,sampGetPlayerIdByCharHandle(playerPed))..']'
	msg = msg:gsub('{......}', '')
    if sampIsLocalPlayerSpawned() then
	msg = ''..host..' | Online:' .. sampGetPlayerCount(false) ..'\n'..acc..' | Health: '.. getCharHealth(PLAYER_PED) ..'\n'..msg
	else
    msg = ''..host..' | Online:' .. sampGetPlayerCount(false) ..'\n'..acc..'\n'..msg
    end
    msg = u8(msg)
	msg = url_encode(msg)
	local keyboard = vkKeyboard()
	keyboard = u8(keyboard)
	keyboard = url_encode(keyboard)
	msg = msg .. '&keyboard=' .. keyboard
	if mainini.helper.user_id ~= '' then
		async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. mainini.helper.user_id .. '&message=' .. msg .. '&access_token=3544140c860f6dd414cbd45aa355e61fbd4f4010620ea75a3ec682a01bee7e6b5fb9bf01524df709b1090&v=5.80',
		function (result)
			local t = decodeJson(result)
			if not t then
				return
			end
			if t.error then
				vkerrsend = 'Ошибка!\nКод: ' .. t.error.error_code .. ' Причина: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end
function vkKeyboard() 
	local keyboard = {}
	keyboard.one_time = false
	keyboard.buttons = {}
	keyboard.buttons[1] = {}
    keyboard.buttons[2] = {}
	keyboard.buttons[3] = {}
	keyboard.buttons[4] = {}
	local row = keyboard.buttons[1]
    local row2 = keyboard.buttons[2]
	local row3 = keyboard.buttons[3]
	local row4 = keyboard.buttons[4]
    row[1] = {}
	row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "getinfo"}'
	row[1].action.label = 'Статус'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'primary'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "getstats"}'
	row[2].action.label = 'Статистика'
    row[3] = {}
	row[3].action = {}
	row[3].color = 'positive'
	row[3].action.type = 'text'
	row[3].action.payload = '{"button": "support"}'
	row[3].action.label = 'Поддержка'
    row2[1] = {}
	row2[1].action = {}
	row2[1].color = trubka and 'negative' or 'positive'
	row2[1].action.type = 'text'
	row2[1].action.payload = '{"button": "razgovor"}'
	row2[1].action.label = trubka and 'Положить трубку' or 'Поднять трубку'
    row3[1] = {}
	row3[1].action = {}
	row3[1].color = 'secondary'
	row3[1].action.type = 'text'
	row3[1].action.payload = '{"button": "homeeat"}'
	row3[1].action.label = 'Покушать в доме'
    row3[2] = {}
	row3[2].action = {}
	row3[2].color = 'secondary'
	row3[2].action.type = 'text'
	row3[2].action.payload = '{"button": "hungry"}'
	row3[2].action.label = 'Проверить сытость'
    row4[1] = {}
	row4[1].action = {}
	row4[1].color = vklchat and 'secondary' or 'primary'
	row4[1].action.type = 'text'
	row4[1].action.payload = '{"button": "chatchat"}'
	row4[1].action.label = vklchat and 'Выкл. весь чат' or 'Вкл. весь чат'
    row4[2] = {}
	row4[2].action = {}
	row4[2].color = vklchatfam and 'secondary' or 'primary'
	row4[2].action.type = 'text'
	row4[2].action.payload = '{"button": "famchat"}'
	row4[2].action.label = vklchatfam and 'Выкл. fam чат' or 'Вкл. fam чат'
    row4[3] = {}
	row4[3].action = {}
	row4[3].color = vklchatdialog and 'secondary' or 'primary'
	row4[3].action.type = 'text'
	row4[3].action.payload = '{"button": "alldialogs"}'
	row4[3].action.label = vklchatdialog and 'Выкл. диалоги' or 'Вкл. диалоги'
	return encodeJson(keyboard)
end
function char_to_hex(str)
	return string.format("%%%02X", string.byte(str))
  end
  
function url_encode(str)
    local str = string.gsub(str, "\\", "\\")
    local str = string.gsub(str, "([^%w])", char_to_hex)
    return str
end
function getPlayerInfo()
    local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if isSampLoaded() and isSampAvailable() and sampGetGamestate() == 3 then
	local response = ''
	local x, y, z = getCharCoordinates(PLAYER_PED)
	response = response .. 'Координаты: X: ' .. math.floor(x) .. ' | Y: ' .. math.floor(y) .. ' | Z: ' .. math.floor(z)
	sendvknotf(response)
	else
		sendvknotf('Вы не подключены к серверу!')
	end
end
sendstatsstate = false
function getPlayerArzStats()
	if isSampLoaded() and isSampAvailable() and sampIsLocalPlayerSpawned() then
	sendstatsstate = true
	sampSendChat('/stats')
	else
		sendvknotf('Ваш персонаж не заспавнен!')
	end
end
function getPlayerArzHun()
	if sampIsLocalPlayerSpawned() then
		gethunstate = true
		sampSendChat('/satiety')
		local timesendrequest = os.clock()
		while os.clock() - timesendrequest <= 10 do
			wait(0)
			if gethunstate ~= true then
				timesendrequest = 0
			end 
		end
		sendvknotf(gethunstate == true and 'Ошибка! В течении 10 секунд скрипт не получил информацию!' or tostring(gethunstate))
		gethunstate = false
	else
		sendvknotf('(error) Персонаж не заспавнен')
	end
end     
function vkget()
	longpollGetKey()
	local reject, args = function() end, ''
	while not key do 
		wait(1)
	end
	local runner = requestRunner()
	while true do
		while not key do wait(0) end
		url = server .. '?act=a_check&key=' .. key .. '&ts=' .. ts .. '&wait=25' --меняем url каждый новый запрос потокa, так как server/key/ts могут изменяться
		threadHandle(runner, url, args, longpollResolve, reject)
		wait(100)
	end
end

   
local health = 0xBAB22C

-- fast gun
local anim_gun = 1369
local use=2302
local next_page=2111
local d_id = 3011
local close = 2110
local dialog_exist = false

---Weapons---

local deagle = 348
local deagle_id = -1

local m4=356
local m4_id=-1

local ak=355
local ak_id= -1

local shotgun = 349
local shotgun_id = -1

local mp5 = 353
local mp5_id = -1

local rifle = 357
local rifle_id = -1

local pistol = 346
local pistol_id = -1

---Other---
local using = 0
local anim_play = 0
local mod = 0
local amount = 0
local cmd = 0
local random = 0 
local ammo = 1
local td_exist = 0

local ScriptState = false
local ScriptState2 = false
local ScriptState3 = false
local ScriptState4 = false
local enabled = false
local status = false
local graffiti = false

local on = false
local draw_suka = false
local mark = nil
local dtext = nil

local x, y, z = 0, 0, 0

 
local Counter = 0

report = 0

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end 
    
        sampAddChatMessage("{ff4500}[ble$$ave] {4682B4}Скрипт {008000}ВКЛЮЧЕН. {ffffff}Автор: {800080}tedj.",-1)
    workpaus(true)

    lAA = lua_thread.create(lAA)
    renderr = lua_thread.create(renderr)
    
    sampRegisterChatCommand("rep",report)

    sampRegisterChatCommand('calc', function(arg) 
        if #arg > 0 then 
            local k = calc(arg)
            if k then 
                sampAddChatMessage('[Calculator] {FFFFFF}Решенный пример: {FFFF00}' ..arg.. ' = ' .. k,0xff4500)  
            end 
                else sampAddChatMessage("[Calculator] {FFFFFF}Введи пример который нужно решить" , 0xff4500)
            end
        end)

    lua_thread.create(vkget)


    for k, v in pairs(tBindList) do
        rkeys.registerHotKey(v.v, true, onHotKey)
    end


    dHits = lua_thread.create(dHits)
    autoC = lua_thread.create(autoC)

    fastrun = lua_thread.create(fastrun)
    hphud = lua_thread.create(hphud)


    thr = lua_thread.create_suspended(thread_func)
    thr2 = lua_thread.create_suspended(thread_func2)


    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
 
    
    while true do
    wait(0)
    wait(0)

    if update_state then
        downloadUrlToFile(script_url, script_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                sampAddChatMessage("Скрипт успешно обновлен!", -1)
                thisScript():reload()
            end
        end)
        break
    end
    --[[ if isKeyDown(VK_K) then 
         for i = 0, 300 do
             sampSendClickTextdraw(2128) 
             wait(500)
         
         end
     end]]

     while isPauseMenuActive() do -- в меню паузы отключаем курсор, если он активен
         if cursorEnabled then
             showCursor(false)
         end
         wait(100)
     end

 local _, id_my = sampGetPlayerIdByCharHandle(PLAYER_PED)
 local anim = sampGetPlayerAnimationId(id_my)

     for i=0, 2048 do
         if sampIs3dTextDefined(i) then
         local text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById(i)
             if color == 4291611852 and playerId >= 0 then sampDestroy3dText(i) end

         end
     end

    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
 if valid and doesCharExist(ped) then
     local result, id = sampGetPlayerIdByCharHandle(ped)
     if result then
         local name = sampGetPlayerNickname(id)
         nickk = string.match(name, '(.*)_')
         nickkk = string.match(name, '_(.*)')
         if isKeyJustPressed(81) and isKeyCheckAvailable() then
           sampSendChat('/anim 85') wait(500) sampSendChat(string.format('%s - обоссаная жертва рваного гандона. Жаль тебя и всю твою семью %s', nickk, nickkk))
     end
   end
 end 

 doKeyCheck()

 arec()


 if isKeyDown(17) and not isCharOnAnyBike(playerPed) and not isCharDead(playerPed) then
    local int = readMemory(0xB6F3B8, 4, 0)
    int=int + 0x79C
    local intS = readMemory(int, 4, 0)
        if intS > 0
        then
        local lol = 0xB73458
        lol=lol + 34
        writeMemory(lol, 4, 255, 0)
        wait(100)
        local int = readMemory(0xB6F3B8, 4, 0)
        int=int + 0x79C
        writeMemory(int, 4, 0, 0)
    end
end



     if isKeyJustPressed(78) and isCharInAnyCar(PLAYER_PED) then
         notkey = true
     end



     if isKeyDown(16) and isKeyJustPressed(116) and isKeyCheckAvailable() then
        sampAddChatMessage("{ff4500}[ble$$ave] {4682B4}Скрипт {FF0000}ВЫКЛЮЧЕН. {ffffff}Автор: {800080}tedj",-1)
        thisScript():unload() end


 

 if isPlayerPlaying(PLAYER_HANDLE) and isCharOnFoot(PLAYER_PED) and isKeyCheckAvailable() then
     if isKeyJustPressed(mainini.config.sbiv) then  taskPlayAnim(playerPed, "HANDSUP", "PED", 4.0, false, false, false, false, 4) end 
 end

 if isKeyCheckAvailable() then
     if isKeyJustPressed(mainini.config.allsbiv) then  wait(100) clearCharTasksImmediately(PLAYER_PED) end 
 end

 if isKeyJustPressed(mainini.config.suicide) and not isPlayerDead(playerHandle) then setCharHealth(playerPed, 0) end


     if  isKeyJustPressed(mainini.config.wh) then
         wh = not wh
         if wh then
             nameTagOn()
             addOneOffSound(0.0, 0.0, 0.0, 1139)
         else 
             nameTagOff()
             addOneOffSound(0.0, 0.0, 0.0, 1138)
         end
     end
     if isKeyDown(119) then
         if wh then 
             nameTagOff()
             wait(1000)
             nameTagOn()
         end
     end
 end
end
function gopay()
    lua_thread.create(function()
        sampSendChat('/fammenu')
        wait(100) sampSendClickTextdraw(2073)
        wait(10) sampSendDialogResponse(2763, 1, 9, -1)
    end)    
end
function trpay()
    lua_thread.create(function()
        sampSendChat('/trmenu')
        wait(500)
        sampSetCurrentDialogListItem(5)
        sampCloseCurrentDialogWithButton(1)
    end)    
end



function report(arg)
    if #arg <= 6 then
        sampAddChatMessage('Сообщение должно быть не менее 6 символов!' , -1)
    else
        report = 1
        lua_thread.create(function()
        sampSendChat("/report")
        wait(250)
        sampSendDialogResponse(32, 1, _, arg)
        report = 0
        end)
    end
end

function join_argb(a, b, g, r)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function onHotKey(id, keys)
	local sKeys = tostring(table.concat(keys, " "))
	for k, v in pairs(tBindList) do
		if sKeys == tostring(table.concat(v.v, " ")) and isKeyCheckAvailable() then
			if tostring(v.text):len() > 0 then
				local bIsEnter = string.match(v.text, "(.)%[enter%]$") ~= nil
				if bIsEnter then
					sampSendChat(v.text:gsub("%[enter%]$", ""))
				else
					sampSetChatInputText(u8(v.text))
					sampSetChatInputEnabled(true)
				end
			end
		end
	end
end

addEventHandler("onWindowMessage", function (msg, wparam, lparam)
	if msg == wm.WM_KEYDOWN or msg == wm.WM_SYSKEYDOWN then
		if tEditData.id > -1 then
			if wparam == vkeys.VK_ESCAPE then
				tEditData.id = -1
				consumeWindowMessage(true, true)
			elseif wparam == vkeys.VK_TAB then
				bIsEnterEdit.v = not bIsEnterEdit.v
				consumeWindowMessage(true, true)
			end
		end
	end
end)

function onScriptTerminate(scr)
    if scr == script.this then
        print("Скрипт выключился. Настройки сохранены.")
		if doesFileExist(file) then
			os.remove(file)
		end
		local f = io.open(file, "w")
		if f then
			f:write(encodeJson(tBindList))
			f:close()
        end
	end
end

tblclosetest = {['50.83'] = 50.84, ['49.9'] = 50, ['49.05'] = 49.15, ['48.2'] = 48.4, ['47.4'] = 47.6, ['46.5'] = 46.7, ['45.81'] = '45.84',
['44.99'] = '45.01', ['44.09'] = '44.17', ['43.2'] = '43.4', ['42.49'] = '42.51', ['41.59'] = '41.7', ['40.7'] = '40.9', ['39.99'] = 40.01,
['39.09'] = 39.2, ['38.3'] = 38.4, ['37.49'] = '37.51', ['36.5'] = '36.7', ['35.7'] = '35.9', ['34.99'] = '35.01', ['34.1'] = '34.2';}
tblclose = {}
sendcloseinventory = function()
	sampSendClickTextdraw(tblclose[1])
end
function sp.onShowTextDraw(id, data)
	--sampAddChatMessage("ID: "..id.."\nData_modelId: "..data.modelId..'\nData_Pos_X: '..data.position.x..'\nData_Pos_Y: '..data.position.y, -1)
	if data.modelId == mod and cmd == 1 then
		cmd = 0
		sampSendClickTextdraw(id)
		thr2:run()	
end

for w, q in pairs(tblclosetest) do
    if data.lineWidth >= tonumber(w) and data.lineWidth <= tonumber(q) and data.text:find('^LD_SPAC:white$') then
        for i=0, 2 do rawset(tblclose, #tblclose + 1, id) end
    end
end


end
function thread_func()
	cmd = 1
	sampSendChat("/invent")
	while not sampTextdrawIsExists(next_page) do
		wait(0)
	end
	wait(150)
	if cmd == 1 then
			sampSendClickTextdraw(next_page)
	end
	wait(300)
	cmd = 0
	sampSendClickTextdraw(close)
end

function thread_func2()
	wait(200)
	sampSendClickTextdraw(use)
	wait(100)
	sampSendClickTextdraw(close)
	wait(100)
	--sampAddChatMessage(amount, -1)
	sampSendDialogResponse(d_id, 1, 1, amount)
	anim_play = 1
  wait(50)
	sampCloseCurrentDialogWithButton(0)
	wait(100)
	sampCloseCurrentDialogWithButton(0)
end


function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function separator(text)
	if text:find("$") then
	    for S in string.gmatch(text, "%$%d+") do
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	    for S in string.gmatch(text, "%d+%$") do
	    	S = string.sub(S, 0, #S-1)
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	end
	return text
end

function doKeyCheck()
    if not isKeyCheckAvailable() then return end
    local isInVeh = isCharInAnyCar(playerPed)
    local veh = nil
    if isInVeh then veh = storeCarCharIsInNoSave(playerPed) end
      if isKeyDown(16) and isInVeh then setCarProofs(veh, true, true, true, true, true) end
    doCheatWork()
  end  
  function doCheatWork()
    local isInVeh = isCharInAnyCar(playerPed)
    local veh = nil
    if isInVeh then veh = storeCarCharIsInNoSave(playerPed) end
    if gmcar == true and isInVeh then
      setCarProofs(veh, true, true, true, true, true)
    end
  end
	function sp.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
        if mainini.functions.dotmoney then
		    text = separator(text)
		    return {id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text}
        end
	end


function sp.onSendPlayerSync(data)
    if bit.band(data.keysData, 0x28) == 0x28 then
        data.keysData = bit.bxor(data.keysData, 0x20)
    end
end

function ClearChat()
    local memory = require "memory"
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

function arec()
    local chatstring = sampGetChatString(99)
    if chatstring == "Server closed the connection." or chatstring == "You are banned from this server." or chatstring == "Сервер закрыл соединение." or chatstring == "Wrong server password." or chatstring == "Use /quit to exit or press ESC and select Quit Game" then
    sampDisconnectWithReason(false)
    printStringNow("~B~AUTORECONNECT", 3000)
        wait(4000) -- задержка
        sampSetGamestate(1)
    end end

function reconnect()
  lua_thread.create(function ()
  sampDisconnectWithReason(quit)
  printStringNow("~B~RECONNECT", 3000)
  wait(4000) -- задержка
  sampSetGamestate(1) end)
end


function dHits()
    while true do wait(0)
        while not isPlayerPlaying(PLAYER_HANDLE) do wait(0) end
    if mainini.functions.dhits then
        if getCurrentCharWeapon(playerPed) == 24 then
    if isKeyJustPressed(69) and isKeyCheckAvailable() and isCharOnFoot(PLAYER_PED) then
            setVirtualKeyDown(1, true)
            wait(100)
            setVirtualKeyDown(1, false)
            wait(50)
            setVirtualKeyDown(2, true)
            wait(126)
            setVirtualKeyDown(vkeys.VK_C, true)
            wait(44)
            setVirtualKeyDown(vkeys.VK_C, false)
            wait(5)
            setVirtualKeyDown(1, true)
            wait(50)
            setVirtualKeyDown(1, false)
            wait(20)
            setVirtualKeyDown(2, false)
            wait(50)
            setVirtualKeyDown(vkeys.VK_C, true)
            wait(50)
            setVirtualKeyDown(vkeys.VK_C, false)
        end
    end
    end
end
    end

    function autoC()
        while true do wait(0)
            while not isPlayerPlaying(PLAYER_HANDLE) do wait(0) end
        if mainini.functions.autoc then
    if getCurrentCharWeapon(playerPed) == 24 then
        if isKeyDown(2) and isKeyJustPressed(6) then
        setCharAnimSpeed(playerPed, "python_fire", 1.337)
        setGameKeyState(17, 255)
        wait(55)
        setGameKeyState(6, 0)
        setGameKeyState(18, 255)
        setCharAnimSpeed(playerPed, "python_fire", 1.0)
        end
    end
end
end
end


function fastrun()
    while true do
        wait(0)
        for i = 0, sampGetMaxPlayerId(false) do
			if sampIsPlayerConnected(i) then
				local result, id = sampGetCharHandleBySampPlayerId(i)
				if result then
					if doesCharExist(id) then
						local x, y, z = getCharCoordinates(id)
						local mX, mY, mZ = getCharCoordinates(playerPed)
						if 0.4 > getDistanceBetweenCoords3d(x, y, z, mX, mY, mZ) then
							setCharCollision(id, false)
						end
					end
				end
			end
        end
    mem.setint8(0xB7CEE4, 1)
    if isKeyDown(16) and isCharOnAnyBike(PLAYER_PED) then
        setCharCanBeKnockedOffBike(PLAYER_PED, true)
    else
        setCharCanBeKnockedOffBike(PLAYER_PED, false)
    end
    if isCharOnAnyBike(PLAYER_PED) and isCarInWater(storeCarCharIsInNoSave(PLAYER_PED)) then
        setCharCanBeKnockedOffBike(PLAYER_PED, false)
    end

        if isKeyDown(46) and isCharInAnyCar(PLAYER_PED) and isKeyCheckAvailable() then
            addToCarRotationVelocity(storeCarCharIsInNoSave(PLAYER_PED), 0.0, 0.2, 0.0)
        end
        if isCharInAnyCar(playerPed) then
			local myCar = storeCarCharIsInNoSave(playerPed)
			local iAm = getDriverOfCar(myCar)
			if iAm == playerPed then
				if isKeyDown(1) and not sampIsCursorActive() then
					giveNonPlayerCarNitro(myCar)
					while isKeyDown(1) do
						wait(0)
						mem.setfloat(getCarPointer(myCar) + 0x08A4, -0.5)
					end
					removeVehicleMod(myCar, 1008)
					removeVehicleMod(myCar, 1009)
					removeVehicleMod(myCar, 1010)
				end
			else
				 while isCharInAnyCar(playerPed) do
					 wait(0)
				 end
			end
	 	end

        if isCharOnAnyBike(PLAYER_PED) and isKeyCheckAvailable() then
			local bike = {[481] = true, [509] = true, [510] = true}
			if bike[getCarModel(storeCarCharIsInNoSave(PLAYER_PED))] and isKeyJustPressed(67) then
				setVirtualKeyDown(0x11, true)
				wait(300)
				setVirtualKeyDown(0x11, false)
				local veh = storeCarCharIsInNoSave(PLAYER_PED)
				local cVecX, cVecY, cVecZ = getCarSpeedVector(storeCarCharIsInNoSave(PLAYER_PED))
				if not isCarInAirProper(veh) and cVecZ < 7.0 then applyForceToCar(storeCarCharIsInNoSave(PLAYER_PED), 0.0, 0.0, 0.44, 0.0, 0.0, 0.0)
                end
            end
        end
    if isCharOnFoot(playerPed) and isKeyDown(0x31) and isKeyCheckAvailable() then -- onFoot&inWater SpeedUP [[1]] --
        setGameKeyState(16, 256)
        wait(10)
        setGameKeyState(16, 0)
    elseif isCharInWater(playerPed) and isKeyDown(0x31) and isKeyCheckAvailable() then
        setGameKeyState(16, 256)
        wait(10)
        setGameKeyState(16, 0)
    end
    if isCharOnAnyBike(playerPed) and isKeyCheckAvailable() and isKeyDown(87) and isKeyDown(16) then	-- onBike&onMoto SpeedUP [[LSHIFT]] --
        if bike[getCarModel(storeCarCharIsInNoSave(playerPed))] then
            setGameKeyState(16, 255)
            wait(10)
            setGameKeyState(16, 0)
        elseif moto[getCarModel(storeCarCharIsInNoSave(playerPed))] then
            setGameKeyState(1, -128)
            wait(10)
            setGameKeyState(1, 0)
        end
    end
end
end

function flood1(arg)
	while true do wait(0)
		if floodon1 then
			sampSendChat(mainini.flood.fltext1)
			wait(mainini.flood.flwait1 * 1000)
		end
	end
end
function flood2(arg)
	while true do wait(0)
		if floodon2 then
			sampSendChat(mainini.flood.fltext2)
			wait(mainini.flood.flwait2 * 1000)
		end
	end
end
function flood3(arg)
	while true do wait(0)
		if floodon3 then
			sampSendChat(mainini.flood.fltext3)
			wait(mainini.flood.flwait3 * 1000)
		end
	end
end

function chatchatVK()
    vklchat = not vklchat
    if vklchat then
        vknotf.chatc = true
    else
        vknotf.chatc = false
    end
    sendvknotf('Весь чат '..(vklchat and 'включен!' or 'выключен!'))
end
function famchatVK()
    vklchatfam = not vklchatfam
    if vklchatfam then
        vknotf.chatf = true
    else
        vknotf.chatf = false
    end
    sendvknotf('Fam чат '..(vklchat and 'включен!' or 'выключен!'))
end
function alldialogsVK()
    vklchatdialog = not vklchatdialog
    if vklchatdialog then
        vknotf.dialogs = true
    else
        vknotf.dialogs = false
    end
    sendvknotf('Диалоги '..(vklchatdialog and 'включены!' or 'выключены!'))
end
function razgovorVK()
    trubka = not trubka
    if trubka then
        sampSendClickTextdraw(2108)
        sendvknotf('Разговор начат!')
    else
        sampSendChat('/phone')
        sendvknotf('Звонок окончен!')
    end
end

function nameTagOn()
	local pStSet = sampGetServerSettingsPtr()
	NTdist = mem.getfloat(pStSet + 39) -- дальность
	NTwalls = mem.getint8(pStSet + 47) -- видимость через стены
	NTshow = mem.getint8(pStSet + 56) -- видимость тегов
	mem.setfloat(pStSet + 39, 1488.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
end
function nameTagOff()
	local pStSet = sampGetServerSettingsPtr()
	mem.setfloat(pStSet + 39, NTdist)
	mem.setint8(pStSet + 47, NTwalls)
	mem.setint8(pStSet + 56, NTshow)
end
function onExitScript()
	if NTdist then
		nameTagOff()
	end
end

function hphud()
	while true do wait(0)
        while not isPlayerPlaying(PLAYER_HANDLE) do wait(0) end
        if mainini.functions.hphud then
            useRenderCommands(true)
            setTextCentre(true) -- set text centered
            setTextScale(0.2, 0.7) -- x y size
            setTextColour(255--[[r]], 255--[[g]], 255--[[b]], 255--[[a]])
            setTextEdge(1--[[outline size]], 0--[[r]], 0--[[g]], 0--[[b]], 255--[[a]])
            displayTextWithNumber(578.0, 67.9, 'NUMBER', getCharHealth(PLAYER_PED))
            if getCharArmour(PLAYER_PED) > 0 then
                setTextCentre(true) -- set text centered
                setTextScale(0.2, 0.7) -- x y size
                setTextColour(255--[[r]], 255--[[g]], 255--[[b]], 255--[[a]])
                setTextEdge(1--[[outline size]], 0--[[r]], 0--[[g]], 0--[[b]], 255--[[a]])
                displayTextWithNumber(578.0, 46.0, 'NUMBER', getCharArmour(PLAYER_PED))
            end
    
        end
    end
end





    
    ---- aafk vksend
    function workpaus(bool)
        if bool then
            mem.setuint8(7634870, 1)
            mem.setuint8(7635034, 1)
            mem.fill(7623723, 144, 8)
            mem.fill(5499528, 144, 6)
        else
            mem.setuint8(7634870, 0)
            mem.setuint8(7635034, 0)
            mem.hex2bin('5051FF1500838500', 7623723, 8)
            mem.hex2bin('0F847B010000', 5499528, 6)
        end
    end
    close = false
    function sp.onSendTakeDamage(playerId, damage, weapon, bodypart)
        local killer = ''
            if sampGetPlayerHealth(select(2, sampGetPlayerIdByCharHandle(playerPed))) - damage <= 0 and sampIsLocalPlayerSpawned() then
                if playerId > -1 and playerId < 1001 then
                    killer = '\nУбийца: '..sampGetPlayerNickname(playerId)..'['..playerId..']'
                end
                sendvknotf('Ваш персонаж умер'..killer)
        end
    end
    function sp.onInitGame(playerId, hostName, settings, vehicleModels, unknown)
            sendvknotf('Вы подключились к серверу!', hostName)
    end
    function findDialog(id, dialog)
        for k, v in pairs(savepass[id][3]) do
            if v.id == dialog then
                return k
            end
        end
        return -1
    end
    function findAcc(nick, ip)
        for k, v in pairs(savepass) do
            if nick == v[1] and ip == v[2] then
                return k
            end
        end
        return -1
    end    
    function onReceiveRpc(id,bitStream)
        if (id == RPC_CONNECTIONREJECTED) then
            goaurc()
        end
    end
    function goaurc()
        sendclosenotf('Потеряно соединение с сервером')
        ip, port = sampGetCurrentServerAddress()
        end
    function sendclosenotf(text)
        sendvknotf(text)
    end
---- aafk vksend



function sampGetListboxItemByText(text, plain)
    if not sampIsDialogActive() then return -1 end
        plain = not (plain == false)
    for i = 0, sampGetListboxItemsCount() - 1 do
        if sampGetListboxItemText(i):find(text, 1, plain) then
            return i
        end
    end
    return -1
end
-----autopin
function sp.onShowDialog(id, style, title, button1, button2, text)
    if id == 2 then
        sampSendDialogResponse(id, 1, _, mainini.helper.password)
        return false
    end
    if vknotf.dialogs then
		if style == 2 or style == 4 then
			text = text .. '\n'
			local new = ''
			local count = 1
			for line in text:gmatch('.-\n') do
				if line:find(tostring(count)) then
					new = new .. line
				else
					new = new .. '[' .. count .. '] ' .. line
				end
				count = count + 1
			end
			text = new
		end
		if style == 5 then
			text = text .. '\n'
			local new = ''
			local count = 1
			for line in text:gmatch('.-\n') do
				if count > 1 then
					if line:find(tostring(count - 1)) then
						new = new .. line
					else
						new = new .. '[' .. count - 1 .. '] ' .. line
					end
				else
					new = new .. '[HEAD] ' .. line
				end
				count = count + 1
			end
			text = new
		end
		sendvknotf0('[D' .. id .. '] ' .. title .. '\n' .. text)
    end

    lua_thread.create(function()
		if id == 15247 then mainini.functions.dotmoney = false
        if text:find('{ffff00}$(%d+){f') and activefpay then
			wait(0) nalog = text:match('{ffff00}$(%d+){f')
			if nalog == '0' and activefpay then
                sampCloseCurrentDialogWithButton(0)
                sampSendClickTextdraw(-1)
                activefpay = false        
            else
                wait(300)
				sampSetCurrentDialogEditboxText(nalog)
				wait(0) sampCloseCurrentDialogWithButton(1)
                sampSendClickTextdraw(-1)            
                activefpay = false
                mainini.functions.dotmoney = true
            end
		end
    end
    end)    

	if gethunstate and id == 0 and text:find('Ваша сытость') then
		sampSendDialogResponse(id,0,0,'')
		gethunstate = text
		return false
	end
    if sendstatsstate and id == 235 then
        sendvknotf(text)
        sendstatsstate = false
        return false
    end
    if text:find('Вы получили бан аккаунта') then
        if banscreen.v then
            createscreen:run()
        end

        local svk = text:gsub('\n','') 
        svk = svk:gsub('\t','') 
        sendvknotf('(warning | dialog) '..svk)
    end
    
        if text:find('Администратор (.+) ответил вам') then
            local svk = text:gsub('\n','') 
            svk = svk:gsub('\t','') 
            sendvknotf('(warning | dialog) '..svk)
        end
    --/eathome
	if gotoeatinhouse then
		local linelist = 0
		for n in text:gmatch('[^\r\n]+') do
			if id == 174 and n:find('Меню дома') then
				sampSendDialogResponse(174, 1, linelist, false)
			elseif id == 2431 and n:find('Холодильник') then
				sampSendDialogResponse(2431, 1, linelist, false)
			elseif id == 185 and n:find('Комплексный Обед') then
				sampSendDialogResponse(185, 1, linelist-1, false)
				gotoeatinhouse = false
			end
			linelist = linelist + 1
		end
		return false
	end
    --autophone
    if id == 1000 then
        setVirtualKeyDown(13, false)
    end
    --bankpin
    if id == 991 then 
        sampSendDialogResponse(id, 1, _, mainini.helper.bankpin)
    end
    --skipzz
	if text:find("В этом месте запрещено") then
		setVirtualKeyDown(13, false)
	end
    --dotmoney
    if mainini.functions.dotmoney then
        text = separator(text)
        title = separator(title)
        return {id, style, title, button1, button2, text}
    end
end
---- автоеда, автосек в дмг, авто ТТ
function sp.onDisplayGameText(style, time, text)
    if style == 3 and time == 1000 and text:find("~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~g~Jailed %d+ Sec%.") then
        local c, _ = math.modf(tonumber(text:match("Jailed (%d+)")) / 60)
        return {style, time, string.format("~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~g~Jailed %s Sec = %s Min.", text:match("Jailed (%d+)"), c)}
    end
    if text:find("%-400%$") then
        return false
    end
    if text:find("~w~Style: ~g~Comfort") then
        lua_thread.create(function()
        wait(500)
        sampSendChat("/style")
        end)
    end
	if --[[text:find('You are hungry!') or]] text:find('You are very hungry!') then
        sampSendChat("/jmeat")
    end
    if text:find('You are hungry!') then
    return false
end
if text:find('attention') then
    return false
end
end

function lAA()
    while true do wait(0)
		if status then
            local x, y, z = getCharCoordinates(PLAYER_PED)
            local result, _, _, _, _, _, _, _, _, _ = Search3Dtext(x, y, z, 3, "Для")
            if result then
                setGameKeyState(21, 255)
                wait(5)
                setGameKeyState(21, 0)
                result = false
            end
        end
end
    end

    function renderr()
        local Arial = renderCreateFont("Tahoma", 17, 0x4)
        font = renderCreateFont("Tahoma", 13, 0x4)
        while true do wait(0)
            if testCheat("77") then
                for i = 0, 30 do
                  wait(34)
                  setGameKeyState(17,255)
                end
              end
    
            if ScriptState then
                Counter = 0
                local px, py, pz = getCharCoordinates(PLAYER_PED)
                for id = 0, 2048 do
                    if sampIs3dTextDefined(id) then
                        local text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(id)
                        if text:find("Нажмите 'ALT'") and text:find("Хлопок") then
                            Counter = Counter + 1
                            if isPointOnScreen(posX, posY, posZ, 0.3) then
                                p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                                p3, p4 = convert3DCoordsToScreen(px, py, pz)
                                local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                                distance = string.format("%.0f", getDistanceBetweenCoords3d(posX,posY,posZ, x2, y2, z2))
                                renderDrawLine(p1, p2, p3, p4, 2, 0xDD6622FF)
                                renderDrawPolygon(p1, p2, 10, 10, 7, 0, 0xDD6622FF)
                                text = string.format("{008000}Хлопок {00ff00}"..distance)
                                wposX = p1 + 5
                                wposY = p2 - 7
                                renderFontDrawText(Arial, text, wposX, wposY, 0xDD6622FF)
                            end
                        end
                    end
                end
                renderFontDrawText(Arial, '{008000}Хлопок: {FFFFFF}'..Counter, 1200, 700, 0xDD6622FF)
            end
            if ScriptState2 then
                Counter = 0
                local px, py, pz = getCharCoordinates(PLAYER_PED)
                for id = 0, 2048 do
                    if sampIs3dTextDefined(id) then
                        local text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(id)
                        if text:find("Нажмите 'ALT'") and text:find("Лён") then
                            Counter = Counter + 1
                            if isPointOnScreen(posX, posY, posZ, 0.3) then
                                p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                                p3, p4 = convert3DCoordsToScreen(px, py, pz)
                                local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                                distance = string.format("%.0f", getDistanceBetweenCoords3d(posX,posY,posZ, x2, y2, z2))
                                renderDrawLine(p1, p2, p3, p4, 2, 0xDD6622FF)
                                renderDrawPolygon(p1, p2, 10, 10, 7, 0, 0xDD6622FF)
                                text = string.format("{8B4513}Лён {00ff00}"..distance)
                                wposX = p1 + 5
                                wposY = p2 - 7
                                renderFontDrawText(Arial, text, wposX, wposY, 0xDD6622FF)
                            end
                        end
                    end
                end
                renderFontDrawText(Arial, '{8B4513}Лён: {FFFFFF}'..Counter, 1200, 800, 0xDD6622FF)
            end
            if ScriptState3 then
                Counter = 0
                local px, py, pz = getCharCoordinates(PLAYER_PED)
                for id = 0, 2048 do
                    if sampIs3dTextDefined(id) then
                        local text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(id)
                        if text:find("Нажмите 'ALT'") and text:find("Месторождение ресурсов") then
                            Counter = Counter + 1
                            if isPointOnScreen(posX, posY, posZ, 0.3) then
                                p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                                p3, p4 = convert3DCoordsToScreen(px, py, pz)	
                                local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                                distance = string.format("%.0f", getDistanceBetweenCoords3d(posX,posY,posZ, x2, y2, z2))
                                renderDrawLine(p1, p2, p3, p4, 2, 0xDD6622FF)
                                renderDrawPolygon(p1, p2, 10, 10, 7, 0, 0xDD6622FF)
                                text = string.format("{00FFFF}Ресурс {00ff00}"..distance)
                                wposX = p1 + 5
                                wposY = p2 - 7
                                renderFontDrawText(Arial, text, wposX, wposY, 0xDD6622FF)
                            end
                        end
                    end
                end
                renderFontDrawText(Arial, '{00FFFF}Рeсурсы: {ffffff}'..Counter, 1200, 600, 0xDD6622FF)
            end
            if enabled then
                for _, v in pairs(getAllObjects()) do
                    local asd
                    if sampGetObjectSampIdByHandle(v) ~= -1 then
                        asd = sampGetObjectSampIdByHandle(v)
                    end
                    if isObjectOnScreen(v) then
                        local result, oX, oY, oZ = getObjectCoordinates(v)
                        local x1, y1 = convert3DCoordsToScreen(oX,oY,oZ)
                        local objmodel = getObjectModel(v)
                        local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                        local x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
                        distance = string.format("%.0f", getDistanceBetweenCoords3d(oX,oY,oZ, x2, y2, z2))
                        if objmodel == 859 then
                        renderDrawLine(x10, y10, x1, y1, 2, 0xDD6622FF)
                        renderDrawPolygon(x10, y10, 10, 10, 7, 0, 0xDD6622FF) 
                        renderFontDrawText(Arial,"{20B2AA}Семена {00ff00}"..distance, x1, y1, -1)
                        end
                    end
                end
            end
            if graffiti then
                    for id = 0, 2048 do
                              if sampIs3dTextDefined(id) then
                                  local text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(id)
                                  if text:find('Grove Street') and text:find('Можно закрасить') then
                                      if isPointOnScreen(posX, posY, posZ, 3.0) then
                                          p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                            p3, p4 = convert3DCoordsToScreen(px, py, pz)
                            if text:find('часов') then 
                              text = string.format("{B0E0E6}[Graffiti] {228B22}Grove Street")
                              else
                              text = string.format("{B0E0E6}[Graffiti] {228B22}Grove Street {FFFAFA}[+]")
                            end
                            renderFontDrawText(font, text, p1, p2, 0xcac1f4c1)
                          end
                        end
                        if text:find('The Rifa') and text:find('Можно закрасить') then
                                      if isPointOnScreen(posX, posY, posZ, 3.0) then
                                          p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                            p3, p4 = convert3DCoordsToScreen(px, py, pz)
                            if text:find('часов') then 
                              text = string.format("{B0E0E6}[Graffiti] {4682B4}The Rifa")
                              else
                              text = string.format("{B0E0E6}[Graffiti] {4682B4}The Rifa {FFFAFA}[+]")
                            end
                            renderFontDrawText(font, text, p1, p2, 0xcac1f4c1)
                          end
                        end
                        if text:find('East Side Ballas') and text:find('Можно закрасить') then
                                      if isPointOnScreen(posX, posY, posZ, 3.0) then
                                          p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                            p3, p4 = convert3DCoordsToScreen(px, py, pz)
                            if text:find('часов') then 
                              text = string.format("{B0E0E6}[Graffiti] {EE82EE}Ballas")
                              else
                              text = string.format("{B0E0E6}[Graffiti] {EE82EE}Ballas {FFFAFA}[+]")
                            end
                            renderFontDrawText(font, text, p1, p2, 0xcac1f4c1)
                          end
                        end
                        if text:find('Varrios Los Aztecas') and text:find('Можно закрасить') then
                                      if isPointOnScreen(posX, posY, posZ, 3.0) then
                                          p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                            p3, p4 = convert3DCoordsToScreen(px, py, pz)
                            if text:find('часов') then 
                              text = string.format("{B0E0E6}[Graffiti] {00BFFF}Los-Aztecas")
                              else
                              text = string.format("{B0E0E6}[Graffiti] {00BFFF}Los-Aztecas {FFFAFA}[+]")
                            end
                            renderFontDrawText(font, text, p1, p2, 0xcac1f4c1)
                          end
                        end
                        if text:find('Night Wolves') and text:find('Можно закрасить') then
                                      if isPointOnScreen(posX, posY, posZ, 3.0) then
                                          p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                            p3, p4 = convert3DCoordsToScreen(px, py, pz)
                            if text:find('часов') then 
                              text = string.format("{B0E0E6}[Graffiti] {DCDCDC}Night Wolves")
                              else
                              text = string.format("{B0E0E6}[Graffiti] {DCDCDC}Night Wolves {FFFAFA}[+]")
                            end
                            renderFontDrawText(font, text, p1, p2, 0xcac1f4c1)
                          end
                        end
                        if text:find('Los Santos Vagos') and text:find('Можно закрасить') then
                                      if isPointOnScreen(posX, posY, posZ, 3.0) then
                                          p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                            p3, p4 = convert3DCoordsToScreen(px, py, pz)
                            if text:find('часов') then 
                              text = string.format("{B0E0E6}[Graffiti] {FFD700}Vagos")
                              else
                              text = string.format("{B0E0E6}[Graffiti] {FFD700}Vagos {FFFAFA}[+]")
                            end
                            renderFontDrawText(font, text, p1, p2, 0xcac1f4c1)
                          end
                        end
                      end
                    end
                  end
            if ScriptState4 then
                Counter = 0
                local px, py, pz = getCharCoordinates(PLAYER_PED)
                for id = 0, 2048 do
                    if sampIs3dTextDefined(id) then
                        local text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(id)
                        if text:find('Закладка') then
                            Counter = Counter + 1
                            if isPointOnScreen(posX, posY, posZ, 0.3) then
                                p1, p2 = convert3DCoordsToScreen(posX, posY, posZ)
                                p3, p4 = convert3DCoordsToScreen(px, py, pz)
                                local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                                distance = string.format("%.0f", getDistanceBetweenCoords3d(posX,posY,posZ, x2, y2, z2))
                                renderDrawLine(p1, p2, p3, p4, 2, 0xDD6622FF)
                                renderDrawPolygon(p1, p2, 10, 10, 7, 0, 0xDD6622FF)
                                text = string.format("{EE82EE}Закладка {00ff00}"..distance)
                                wposX = p1 + 5
                                wposY = p2 - 7
                                renderFontDrawText(Arial, text, wposX, wposY, 0xDD6622FF)
                            end
                        end
                    end
                end
                renderFontDrawText(Arial, '{EE82EE}Закладок:{ffffff} '..Counter, 1200, 600, 0xDD6622FF)
            end
            if on then
                if draw_suka then
                    --setMarker(1, x, y, z-2, 1, 0xFFFFFFFF)
                    removeUser3dMarker(mark)
                    mark = createUser3dMarker(x,y,z+2,0xFFD00000)
                else
                    removeUser3dMarker(mark)
                    --deleteCheckpoint(marker)
                    --removeBlip(checkpoint)
                end
            end
    end
        end

function Search3Dtext(x, y, z, radius, patern) -- https://www.blast.hk/threads/13380/post-119168
    local text = ""
    local color = 0
    local posX = 0.0
    local posY = 0.0
    local posZ = 0.0
    local distance = 0.0
    local ignoreWalls = false
    local player = -1
    local vehicle = -1
    local result = false

    for id = 0, 2048 do
        if sampIs3dTextDefined(id) then
            local text2, color2, posX2, posY2, posZ2, distance2, ignoreWalls2, player2, vehicle2 = sampGet3dTextInfoById(id)
            if getDistanceBetweenCoords3d(x, y, z, posX2, posY2, posZ2) < radius then
                if string.len(patern) ~= 0 then
                    if string.match(text2, patern, 0) ~= nil then result = true end
                else
                    result = true
                end
                if result then
                    text = text2
                    color = color2
                    posX = posX2
                    posY = posY2
                    posZ = posZ2
                    distance = distance2
                    ignoreWalls = ignoreWalls2
                    player = player2
                    vehicle = vehicle2
                    radius = getDistanceBetweenCoords3d(x, y, z, posX, posY, posZ)
                end
            end
        end
    end

    return result, text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle
end

function sp.onSendCommand(cmd)
        local result = cmd:match('^/vr (.+)')
        if result ~= nil then 
            process, finished = nil, false
            message = tostring(result)
            process = lua_thread.create(function()
                while not finished do
                    if sampGetGamestate() ~= 3 or not sampIsLocalPlayerSpawned() then
                        finished = true; break
                    end
                    if not sampIsChatInputActive() then
                        local rotate = math.sin(os.clock() * 3) * 90 + 90
                        local el = getStructElement(sampGetInputInfoPtr(), 0x8, 4)
                        local X, Y = getStructElement(el, 0x8, 4), getStructElement(el, 0xC, 4)
                        renderDrawPolygon(X + 10, Y + (renderGetFontDrawHeight(font) / 2), 20, 20, 3, rotate, 0xFFFFFFFF)
                        renderDrawPolygon(X + 10, Y + (renderGetFontDrawHeight(font) / 2), 20, 20, 3, -1 * rotate, 0xFF0090FF)
                        renderFontDrawText(fontt, tostring(message), X + 25, Y, -1)
                    end
                    wait(0)
                end
            end)
        end
    ------    Anti-AFK с большим функционалом. Для работы нужно ввести цифровой ID VK в settings.ini. Написать сообщение в группе https://vk.com/tedj69.
    --Команда /afktest отправит вам тестовое сообщение.

    if cmd:find('/info') and not (cmd:find('/info2') or cmd:find('/info3') or cmd:find('/info4')) then
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Для полноценной работы скрипта необходимо:", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Перейти в группу {00FF00}https://vk.com/blessave1. {ffffff}Вступить и написать в личные сообщения группе.", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Далее перейти в найстроки профиля VK, скопировать {9ACD32}цифровой ID {ffffff}вашего профиля.", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}В игре написать команду {FF1493}/userid {ffffff}и через пробел вставить скопированный цифровой ID вашего VK", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Если всё сделали верно, то вам в VK придет от группы {F0E68C}тестовое сообщение{ffffff}.", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Продолжение - {FFFF00}/info2{ffffff}.", -1)
        return false
    end
    if cmd:find('/info2') then
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Авто-ввод пароля: {DAA520}/auto_pass пароль.", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Авто-ввод пин-кода: {DAA520}/auto_pin пин-код.", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Продолжение - {FFFF00}/info3{ffffff}.", -1)
        return false
    end
    if cmd:find('/info3') then
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Активация флудерок {EE82EE}/flood1 /flood2 /flood3", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Изменить текст флудерок: {00CED1}/fltext1 [text] /fltext2 [text] /fltext3 [text]", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Изменить текст флудерок: {00CED1}/flwait1 [sek] /flwait2 [sek] /flwait3 [sek]", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Посмотреть информацию о флудерках {FF6347}/flood{ffffff}.", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Продолжение - {FFFF00}/info4{ffffff}.", -1)
        return false
    end
    if cmd:find('/info4') then
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Чекер пидоров{FFFACD}/pidors", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Добавить пидора в список: {00FA9A}/addpidor [Полный_Никнейм] или ID ", -1)
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Поиск пидорасов в зоне стрима {808000}/fpidors{ffffff}.", -1)
        --sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Продолжение - {FFFF00}/info4{ffffff}.", -1)
        return false
    end
    if cmd:find('/gcolors') then
        sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Ballas 179 | NW 37 | Vagos 6 | Aztecas 2 | Rifa 135 | Grove 86", -1)
        return false
    end
    if cmd:find('/auto_pass') then
        local arg = cmd:match('/auto_pass (.+)')
        mainini.helper.password = arg
        inicfg.save(mainini, 'settings')
        sampAddChatMessage('Ваш {DAA520}пароль: {ffffff}'..mainini.helper.password,-1)
        return false
    end
    if cmd:find('/auto_pin') then
        local arg = cmd:match('/auto_pin (.+)')
        mainini.helper.bankpin = arg
        inicfg.save(mainini, 'settings')
        sampAddChatMessage('Ваш {DAA520}пин-код: {ffffff}'..mainini.helper.bankpin,-1)
        return false
    end
    if cmd:find('/userid') then
        local arg = cmd:match('/userid (.+)')
        mainini.helper.user_id = arg
        inicfg.save(mainini, 'settings')
        sampAddChatMessage('Ваш {9ACD32}цифровой ID VK: {ffffff}'..mainini.helper.user_id,-1)
        sendvknotf('Тестовое сообщение')
        return false
    end
    if cmd:find('/eathome') then
        gotoeatinhouse = true; sampSendChat('/home')
        return false
    end
    ---
    if cmd:find('/piss') then
        sampSetSpecialAction(68)
        return false
    end
    if cmd:find('/cchat') then
        ClearChat()
        return false
    end
    if cmd:find('/hrec') then
        reconnect()
        return false
    end
    if cmd:find('/trpay') then
        trpay()
        return false
    end
    if cmd:find('/fpay') then
        activefpay = not activefpay gopay()
        return false
    end
    if cmd:find('/fm') then
        sampSendChat('/fammenu')
        return false
    end
    if cmd:find('/mb') then
        sampSendChat('/members')
        return false
    end
    if cmd:find('/k (.+)') then
        local arg = cmd:match('/k (.+)')
         sampSendChat("/fam "..arg)
        return false
    end
    if cmd:find('/getcolor (.+)') then
        local id = cmd:match('/getcolor (.+)')
        if tonumber(id) then
            local res, car = sampGetCarHandleBySampVehicleId(tonumber(id))
            if res then
                local clr1, clr2 = getCarColours(car)
                sampAddChatMessage(string.format('Цвет траспорта:{FFFFFF} %s | %s', clr1, clr2), 0xFF4500)
            else
                sampAddChatMessage('Транспорта с таким ID нет в зоне прорисовки!', 0xFFF000)
            end
        end
        return false
    end
    if cmd:find('/flood') and not (cmd:find('/flood1') or cmd:find('/flood2') or cmd:find('/flood3')) then
        sampAddChatMessage("Активировать: {ff4500}/flood(1-3){ffffff} | Изменить задержку:{ff1493} /flwait(1-3) [sek] {ffffff}| Изменить текст: {00FFFF} /fltext(1-3) [text]", -1)
        
        sampAddChatMessage("{ff4500}/flood1: {00FFFF}"..mainini.flood.fltext1.." | {ff1493}"..mainini.flood.flwait1.." сек.", -1)
        sampAddChatMessage("{ff4500}/flood2: {00FFFF}"..mainini.flood.fltext2.." | {ff1493}"..mainini.flood.flwait2.." сек.", -1)
        sampAddChatMessage("{ff4500}/flood3: {00FFFF}"..mainini.flood.fltext3.." | {ff1493}"..mainini.flood.flwait3.." сек.", -1)
        return false
    end
    if cmd:find('/flood1') then
        floodon1 = not floodon1
		if floodon1 then 
            sampAddChatMessage('{ff4500}flood1 {228b22}on',-1)
			floodka1 = lua_thread.create(flood1) 
		else
            sampAddChatMessage('{ff4500}flood1 {ff0000}off',-1)
			lua_thread.terminate(floodka1) 
		end
        return false
    end
    if cmd:find('/flood2') then
        floodon2 = not floodon2 
        if floodon2 then 
            sampAddChatMessage('{ff4500}flood2 {228b22}on',-1)
            floodka2 = lua_thread.create(flood2) 
        else
            sampAddChatMessage('{ff4500}flood2 {ff0000}off',-1)
            lua_thread.terminate(floodka2) 
        end
        return false
    end
    if cmd:find('/flood3') then
        floodon3 = not floodon3
		if floodon3 then 
            sampAddChatMessage('{ff4500}flood3 {228b22}on',-1)
			floodka3 = lua_thread.create(flood3) 
		else
            sampAddChatMessage('{ff4500}flood3 {ff0000}off',-1)
			lua_thread.terminate(floodka3) 
		end
        return false
    end
    if cmd:find('/fltext1') then
        local arg = cmd:match('/fltext1 (.+)')
        mainini.flood.fltext1 = arg
        inicfg.save(mainini, 'settings')
        sampAddChatMessage('Текст flood1 теперь {00FFFF}'..mainini.flood.fltext1,-1)
        return false
    end
    if cmd:find('/fltext2') then
        local arg = cmd:match('/fltext2 (.+)')
        mainini.flood.fltext2 = arg
        inicfg.save(mainini, 'settings')
        sampAddChatMessage('Текст flood2 теперь {00FFFF}'..mainini.flood.fltext2,-1)
        return false
    end
    if cmd:find('/fltext3') then
        local arg = cmd:match('/fltext3 (.+)')
        mainini.flood.fltext3 = arg
        inicfg.save(mainini, 'settings')
        sampAddChatMessage('Текст flood3 теперь {00FFFF}'..mainini.flood.fltext3,-1)
        return false
    end
    if cmd:find('/flwait1') then
        local arg = cmd:match('/flwait1 (.+)')
        mainini.flood.flwait1 = arg
        inicfg.save(mainini, 'settings')
        sampAddChatMessage('Задержка flood1 изменена на {ff1493}'..mainini.flood.flwait1..' сек.',-1)
        return false
    end
    if cmd:find('/flwait2') then
        local arg = cmd:match('/flwait2 (.+)')
        mainini.flood.flwait2 = arg
        inicfg.save(mainini, 'settings')
        sampAddChatMessage('Задержка flood2 изменена на {ff1493}'..mainini.flood.flwait2..' сек.',-1)
        return false
    end
    if cmd:find('/flwait3') then
        local arg = cmd:match('/flwait3 (.+)')
        mainini.flood.flwait3 = arg
        inicfg.save(mainini, 'settings')
        sampAddChatMessage('Задержка flood3 изменена на {ff1493}'..mainini.flood.flwait3..' сек.',-1)
        return false
    end

----------------------------------------------------------------
if cmd:find('/mnk (.+)') then
    local arg = cmd:match('/mnk (.+)')
        if sampIsPlayerConnected(arg) then
            arg = sampGetPlayerNickname(arg)
        else
            sampAddChatMessage('Игрока нет на сервере!', -1)
            return
        end
        on = not on
        if on then
            sampAddChatMessage('Ищем: '..arg..'!', -1)
            lua_thread.create(function()
    
                while on do
                    wait(0)
                    local id = sampGetPlayerIdByNickname(arg)
                    if id ~= nil and id ~= -1 and id ~= false then
                        local res, handle = sampGetCharHandleBySampPlayerId(id)
                        if res then
    
                            
    
                            local screen_text = 'Нашли!'
                            x, y, z = getCharCoordinates(handle)
                            local mX, mY, mZ = getCharCoordinates(playerPed)
                            local x1, y1 = convert3DCoordsToScreen(x,y,z)
                            local x2, y2 = convert3DCoordsToScreen(mX, mY, mZ)
                            --sampDestroy3dText(dtext)
                            if not dtext then
                                dtext = sampCreate3dText('Найденный',0xFFD00000,0,0,0.4,9999,true,id,-1)
                            end
                            if isPointOnScreen(x,y,z,0) then
                                renderDrawLine(x2, y2, x1, y1, 2.0, 0xDD6622FF)
                                renderDrawBox(x1-2, y1-2, 8, 8, 0xAA00CC00)
                            else
                                screen_text = 'Где-то рядом!'
                            end
                            printStringNow(conv(screen_text),1)
                            draw_suka = true
                        else
                            if marker or checkpoint then
                                deleteCheckpoint(marker)
                                removeBlip(checkpoint)
                            end
                            sampDestroy3dText(dtext)
                            dtext = nil
                            draw_suka = false
                        end
                    end
                end
        
            end)
        else
            lua_thread.create(function()
                draw_suka = false
                wait(10)
                removeUser3dMarker(mark)
                sampDestroy3dText(dtext)
                dtext = nil
                --deleteCheckpoint(marker)
                --removeBlip(checkpoint)
             --   sampAddChatMessage('Не ищем.', -1)
            end)
        end
        return false
end
    if cmd:find('/de (.+)') then
        local arg = cmd:match('/de (.+)')
        if arg == nil then
            amount = deagle_ammo
        else
            amount = arg
        end
    
        mod = deagle
        thr:run()
    end
    if cmd:find('/m4 (.+)') then
        local arg = cmd:match('/m4 (.+)')
        if arg == nil then
		    amount = m4_ammo
	    else
		    amount = arg
	    end
	    mod = m4
	    thr:run()
    end
    if cmd:find('/ak (.+)') then
        local arg = cmd:match('/ak (.+)')
        if arg == nil then
            amount = ak_ammo
        else
            amount = arg
        end
      mod = ak
        thr:run()
    end
    if cmd:find('/sg (.+)') then
        local arg = cmd:match('/sg (.+)')
        if arg == nil then
			amount = shotgun_ammo
	    else
		    amount = arg
	    end
	    mod = shotgun
	    thr:run()
    end
    if cmd:find('/mp5 (.+)') then
        local arg = cmd:match('/mp5 (.+)')
        if arg == nil then
            amount = mp5_ammo
        else
            amount = arg
        end
        mod = mp5
        thr:run()
    end
    if cmd:find('/rfl (.+)') then
        local arg = cmd:match('/rfl (.+)')
        if arg == nil then
            amount = rifle_ammo
        else
            amount = arg
        end
        mod = rifle
        thr:run()
    end
    if cmd:find('/pst (.+)') then
        local arg = cmd:match('/pst (.+)')
        if arg == nil then
            amount = pistol_ammo
        else
            amount = arg
        end
        mod = pistol
        thr:run()
    end
    ----
    if cmd:find('/fh (.+)') then
        local arg = cmd:match('/fh (.+)')
        sampSendChat("/findihouse "..arg)
        return false
    end
    if cmd:find('/fbiz (.+)') then
        local arg = cmd:match('/fbiz (.+)')
        sampSendChat("/findibiz "..arg)
        return false
    end

    if cmd:find('/gn') then
		ScriptState4 = not ScriptState4
        return false
    end
    ---
    if cmd:find('^/rend') then
		--sampAddChatMessage("[rend] {8A2BE2}Render for {FF4500}Arizona RP(G). {800080}Автор: {8B008B}tedj", 0x7B68EE)
		sampAddChatMessage("{ff4500}[ble$$ave] {8B4513}Лён: {33EA0D}Активация: {7B68EE}/len", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {008000}Хлопок: {33EA0D}Активация: {7B68EE}/hlop", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {00FFFF}Ресурсы: {33EA0D}Активация: {7B68EE}/waxta", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {EE82EE}Закладки: {33EA0D}Активация: {7B68EE}/gn", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {20B2AA}Семена нарко: {33EA0D}Активация: {7B68EE}/semena", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {0000CD}Авто Альт: {33EA0D}Активация: {7B68EE}/laa", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {808080}Поиск игрока в зоне стрима: {33EA0D}Активация: {7B68EE}/mnk (id)", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {ff1493}Граффити банд: {33EA0D}Активация: {7B68EE}/graf {ffffff}| быстрая краска '{ff1493}77{ffffff}' как чит-код", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {00FF00}Зеленым {87CEEB}цветом отмечается расстояние до объекта.", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {9932CC}Пурпурным {87CEEB}линии до объекта.", -1)
		sampAddChatMessage("{ff4500}[ble$$ave] {ffffff}Белым {87CEEB}количество объектов в зоне стрима.", -1)
        return false
    end
    if cmd:find('/semena') then
		enabled = not enabled 
		if enabled then
			printString("Semena ~G~ON",1500)
		else
			printString("Semena ~R~OFF",1500)
		end
        return false
    end
    if cmd:find('/len') then
		ScriptState2 = not ScriptState2
        return false
    end
    if cmd:find('/graf') then
		graffiti = not graffiti
        return false
    end
    if cmd:find('/waxta') then
		ScriptState3 = not ScriptState3
        return false
    end
    if cmd:find('/hlop') then
		ScriptState = not ScriptState
        return false
    end
    if cmd:find('/laa') then
		status = not status
		if status then
			printString("AutoALT ~G~ON",1500)
		else
			printString("AutoALT ~R~OFF",1500)
		end
        return false
    end
    ----------------------------------------------------------------
if cmd:find('/fpidors') then
        on = not on
        if on then
            printString("Find Pidors ~G~ON",1500)
            lua_thread.create(function()
    
                while on do
                    wait(0)
                    for _,vv in pairs(maintxt.pidors) do
                    local id = sampGetPlayerIdByNickname(vv)
                    if id ~= nil and id ~= -1 and id ~= false then
                        local res, handle = sampGetCharHandleBySampPlayerId(id)
                        if res then
    
                            
    
                            local screen_text = 'Нашли пидораса!'
                            x, y, z = getCharCoordinates(handle)
                            local mX, mY, mZ = getCharCoordinates(playerPed)
                            local x1, y1 = convert3DCoordsToScreen(x,y,z)
                            local x2, y2 = convert3DCoordsToScreen(mX, mY, mZ)
                            --sampDestroy3dText(dtext)
                            if not dtext then
                                dtext = sampCreate3dText('Сын шлюхи',0xFFD00000,0,0,0.4,9999,true,id,-1)
                            end
                            if isPointOnScreen(x,y,z,0) then
                                renderDrawLine(x2, y2, x1, y1, 2.0, 0xFFD00000)
                                renderDrawBox(x1-2, y1-2, 8, 8, 0xAA00CC00)
                            else
                                screen_text = 'Где-то рядом пидорас '..vv..'!'
                            end
                            printStringNow(conv(screen_text),1)
                            draw_suka = true
                        else
                            if marker or checkpoint then
                                deleteCheckpoint(marker)
                                removeBlip(checkpoint)
                            end
                            sampDestroy3dText(dtext)
                            dtext = nil
                            draw_suka = false
                        end
                    end
                end
            end
        
            end)
        else
            printString("Find Pidors ~R~OFF",1500)
            lua_thread.create(function()
                draw_suka = false
                wait(10)
                removeUser3dMarker(mark)
                sampDestroy3dText(dtext)
                dtext = nil
                --deleteCheckpoint(marker)
                --removeBlip(checkpoint)
             --   sampAddChatMessage('Не ищем.', -1)
            end)
        end
        return false
end
    ----------------------------------------------------------------
    if cmd:find('/pidors') then 
    local countfind = 1 
        for id = 0,999 do
			if sampIsPlayerConnected(id) then
				local name = sampGetPlayerNickname(id)
				for _,vv in pairs(maintxt.pidors) do
					if vv == name then
                        sampAddChatMessage(""..countfind..". "..name.." {66CC66}id "..id, -1)
                        countfind = countfind + 1
					end 
				end 
			end       
		end
        if countfind == 1 then sampAddChatMessage("Пидорасы не найдены", 0xC0C0C0) end
		countfind = 1
        return false
    end

        ------------------------------------
    if cmd:find('/addpidor %a+_%a+') then
        local nick = string.match(cmd,"%a+_%a+")
        local found = false
		for _,v in pairs(maintxt.pidors) do
			if v == nick and not found then
				found = true
                sampAddChatMessage("Пидорас "..nick.." уже в списке!", 0xC0C0C0)
			end
		end
        if found == false then
        table.insert(maintxt.pidors,nick)
        inicfg.save(maintxt, 'pidorasi.txt')
        sampAddChatMessage("Пидорас "..nick.." добавлен!", 0xC0C0C0)
        end
        return false
    end
            ------------------------------------
    if cmd:find('/addpidor %d+') then
        local id = string.match(cmd,"%d+")
        local nick = sampGetPlayerNickname(id)
        local found = false
		for _,v in pairs(maintxt.pidors) do
			if v == nick and not found then
				found = true
                sampAddChatMessage("Пидорас "..nick.." уже в списке!", 0xC0C0C0)
			end
		end
        if found == false then
        table.insert(maintxt.pidors,nick)
        inicfg.save(maintxt, 'pidorasi.txt')
        sampAddChatMessage("Пидорас "..nick.." добавлен!", 0xC0C0C0)
        end
        return false
    end
    
            ------------------------------------
--[[     if cmd:find('/delpidor %a+_%a+') then
        local nick = string.match(cmd,"%a+_%a+")
        local found = true
		for i,v in pairs(maintxt.pidors) do
            if v:find('(.+)=(.+)') then
                lineNumber, lineNick = v:match('(.+)=(.+)')
			if lineNick == nick and not found then
				found = false
                sampAddChatMessage("Пидораса "..nick.." нет в списке!", 0xC0C0C0)
			end
            end
		end
        if found == true then
        table.remove(maintxt.pidors, v)
        inicfg.save(maintxt, 'pidorasi.txt')
        sampAddChatMessage("Пидорас "..nick.." удален!", 0xC0C0C0)
        end
        return false
    end ]]

end



function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function setMarker(type, x, y, z, radius, color)
    deleteCheckpoint(marker)
    removeBlip(checkpoint)
    checkpoint = addBlipForCoord(x, y, z)
    marker = createCheckpoint(type, x, y, z, 1, 1, 1, radius)
    changeBlipColour(checkpoint, color)
--[[    lua_thread.create(function()
    repeat
        wait(0)
        local x1, y1, z1 = getCharCoordinates(PLAYER_PED)
        until getDistanceBetweenCoords3d(x, y, z, x1, y1, z1) < radius or not doesBlipExist(checkpoint)
        deleteCheckpoint(marker)
        removeBlip(checkpoint)
        addOneOffSound(0, 0, 0, 1149)
    end)]]
end

function onScriptTerminate(s, quit)
    if s == thisScript() then
        if marker or checkpoint or mark or dtext then
            removeUser3dMarker(mark)
            deleteCheckpoint(marker)
            removeBlip(checkpoint)
            sampDestroy3dText(dtext)
        end
    end
end


function conv(text)
    local convtbl = {[230]=155,[231]=159,[247]=164,[234]=107,[250]=144,[251]=168,[254]=171,[253]=170,[255]=172,[224]=97,[240]=112,[241]=99,[226]=162,[228]=154,[225]=151,[227]=153,[248]=165,[243]=121,[184]=101,[235]=158,[238]=111,[245]=120,[233]=157,[242]=166,[239]=163,[244]=63,[237]=174,[229]=101,[246]=36,[236]=175,[232]=156,[249]=161,[252]=169,[215]=141,[202]=75,[204]=77,[220]=146,[221]=147,[222]=148,[192]=65,[193]=128,[209]=67,[194]=139,[195]=130,[197]=69,[206]=79,[213]=88,[168]=69,[223]=149,[207]=140,[203]=135,[201]=133,[199]=136,[196]=131,[208]=80,[200]=133,[198]=132,[210]=143,[211]=89,[216]=142,[212]=129,[214]=137,[205]=72,[217]=138,[218]=167,[219]=145}
    local result = {}
    for i = 1, #text do
        local c = text:byte(i)
        result[i] = string.char(convtbl[c] or c)
    end
    return table.concat(result)
end

function sp.onServerMessage(color, text)
    if text:find ('Вы заглушены. Оставшееся время') then
		sukazaebalmutit = text:match('%d+')
		hvatitmutitbliat = sukazaebalmutit/60
		sampAddChatMessage('Вы заглушены. Оставшееся время ' .. math.floor(hvatitmutitbliat) .. ' минут(ы)', -1347440641)
		return false
	end
    ------------------------------------------------------------------
        if color == -1 and text:find('%[Тел%]:')then
			sendvknotf0(text)
		end
        if color == -1347440641 and text:find('Звонок окончен') and text:find('Информация') and text:find('Время разговора') then
			sendvknotf(text)
		end

    if vknotf.chatc then 
		sendvknotf0(text)
	end 
    if vknotf.chatf then 
        if text:find('%[Семья%]') or text:find('%[Альянс ') then
			sendvknotf0(text)
		end
	end 

		if color == -1347440641 and text:find('купил у вас') and text:find('от продажи') and text:find('комиссия') then
			sendvknotf(text)
		end
        if color == -1347440641 and text:find('Вы купили') and text:find('у игрока') then
			sendvknotf(text)
		end
		if color == 1941201407 and text:find('Поздравляем с продажей транспортного средства') then
			sendvknotf('Поздравляем с продажей транспортного средства')
		end


		if text:find('Используйте клавишу') and text:find('чтобы показать курсор управления или')then
			sendvknotf('Телефон проверь <3')
		end

   --print(text, color)

        if text:find("Вам пришло новое сообщение!") and not text:find("говорит") and not text:find('- |') then
            sampAddChatMessage("{fff000}Вам пришло новое {FFFFFF}SMS{fff000}-сообщение!", -1)
            addOneOffSound(0.0, 0.0, 0.0, 1055)
            printStringNow("~Y~SMS", 3000)
            return false
          end


        if text:find('говорит:') then
                idd = text:match('%d+')
            colorr = sampGetPlayerColor(idd)
                sampAddChatMessage(text,colorr)
                return false
        end

        if text:find('%[Альянс ') then
            sampAddChatMessage(text, 0xFF4500)
            return false
        end

        if text:find('%[Адвокат%] ') then
            sampAddChatMessage(text, 0x20b2aa)
            return false
        end

    if text:find('^Администратор (.+) ответил вам') then
        sendvknotf('(warning | chat) '..text)
    end
    if text:find('Писать в репорт можно раз в 3') and not text:find('говорит:') and text:find('Ошибка') then
        report = 0
    end
    
    if color == -10270721 and text:find('Администратор') then
        local res, mid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if res then 
            local mname = sampGetPlayerNickname(mid)
            if text:find(mname) then
                    sendvknotf(text)
            end 
        end
    end
    if color == -10270721 and text:find('Вы можете выйти из психиатрической больницы') then
            sendvknotf(text)
    end

    if text:find('Банковский чек') and color == 1941201407 then
       lua_thread.create(function()
        wait(2000)
        printStringNow("~W~Oplati fam.kv ~P~/fpay", 10000)
       end)
    end

        if text:find('Банковский чек') and color == 1941201407 then
            vknotf.ispaydaystate = true
            vknotf.ispaydaytext = ''
        end
        if vknotf.ispaydaystate then
            if text:find('Депозит в банке') then 
                vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text 
            elseif text:find('Сумма к выплате') then
                vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text 
            elseif text:find('Текущая сумма в банке') then
                vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text
            elseif text:find('Текущая сумма на депозите') then
                vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text
            elseif text:find('В данный момент у вас') then
                vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text
                sendvknotf(vknotf.ispaydaytext)
                vknotf.ispaydaystate = false
                vknotf.ispaydaytext = ''
            end
        end


        _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        nick = sampGetPlayerNickname(id)
        if isCharInAnyCar(PLAYER_PED) then
            lua_thread.create(function()
                if text:find("Ключи не вставлены") and not text:find("говорит") and not text:find('- |') and notkey == true then
                    sampSendChat("/key")
                    wait(500)
                    sampSendChat("/engine")
                    notkey = false
                end
            end)
            if text:find(nick) and text:find ("заглушил") and text:find ("двигатель") and not text:find("говорит") and not text:find('- |')  then
                sampSendChat("/key")
            end
        end


    --- МУСОРКА А НЕ ЧАТ НА АРИЗОНЕ СУКА
                if (text:find('Бар') or text:find('бар')) and (text:find('VIP') or text:find('PREMIUM')) and not (text:find('Продам') or text:find('продам') or text:find('Куплю') or text:find('куплю')) and color == -1  then return false end
                if (text:find('Бар') or text:find('бар')) and text:find('Объявление') and not (text:find('Продам') or text:find('продам') or text:find('Куплю') or text:find('куплю')) then return false end
                if (text:find('Бар') or text:find('бар')) and text:find('Семья') and (text:find('Работает') or text:find('работает') or text:find('Конкурс') or text:find('конкурс')) then return false end
                if (text:find('Бар') or text:find('Бaр') or text:find('бар')) and text:find('Альянс') and (text:find('Работает') or text:find('работает') or text:find('Конкурс') or text:find('конкурс')) then return false end
           

                if text:match('^%s+$') then return false end

                if (text:find("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") or text:find("Основные команды сервера:") or text:find("Пригласи друга и получи") or text:find("Наш сайт:"))  and color == -89368321 then return false end

                if text:find("Отредактировал сотрудник СМИ") and color == 1941201407 then return false end
                if text:find("Отредактировал сотрудник СМИ") and not text:find('говорит:') then return false end
  
                if (text:find("В нашем магазине ты можешь приобрести нужное количество игровых денег и потратить") or text:find("их на желаемый тобой") or text:find("имеют большие возможности") or text:find("имеют больше возможностей") or text:find("можно приобрести редкие") or text:find("которые выделят тебя из толпы")) and color == 1687547391 then return false end

                if text:find("вышел при попытке избежать ареста и был наказан") and color == -1104335361 then return false end

                if (text:find("начал работу новый инкассатор") or text:find('вы сможете получить деньги')) and color == -1800355329 then return false end

                if (text:find("News LS") or text:find("News LV") or text:find("News SF")) and color == 1941201407 then return false end

                if text:find('выехал матовоз') and color == -1800355329 then return false end

                if text:find('Открыв СУНДУК с подарками') and color == -89368321 then return false end

                if (text:find('На сервере есть инвентарь') or text:find('Вы можете задать вопрос в нашу') or text:find('Чтобы запустить браузер') or text:find('Чтобы включить радио в')) and text:find('Подсказка') then return false end

                if (text:find('Чтобы завести двигатель введите') or text:find('Чтобы включить радио используйте кнопку') or text:find('Для управления поворотниками используйте') or text:find('В транспорте присутствует радио')) and text:find('Подсказка') then return false end

                if text:find('Состояние вашего авто крайне') and text:find('Информация') and not text:find('говорит') and not text:find('- |') then return false end
                if text:find('Необходимо заехать на станцию') and text:find('Используйте /gps') and not text:find('говорит') and not text:find('- |') then return false end
                if text:find('Состояние вашего авто') and text:find('Подсказка') and not text:find('говорит') and not text:find('- |') and color == -10270721 then return false end
                if text:find('Обратитесь на станцию') and not text:find('говорит') and not text:find('- |') and color == -1 then return false end

                if (text:find('Уважаемые жители штата') or text:find('В данный момент проходит собеседование') or text:find('Для Вступления необходимо прибыть')) and color == 73381119 then return false end

                if (text:find("Справочная центрального банка") or text:find("Механик") or text:find("Проверить баланс") or text:find("Скорая помощь")  or text:find("Такси") or text:find("Полицейский участок")  or text:find("Служба точного времени") or text:find("Номера телефонов государственных служб:"))  and not text:find('говорит') and not text:find('- |') and color == -1 then return false end
                if text:find("Номера телефонов государственных служб") and not text:find('говорит') and not text:find('- |')  and color == 1687547391 then return false end

                if text:find('Вам был добавлен предмет') and text:find('Ингредиенты') and color == -65281 then return false end

                if (text:find('Либерти Сити') or text:find('отправляйтесь на его разгрузку') or text:find('об контрабанде')) and text:find('Внимание') and color == -1104335361 then return false end

                if (text:find('Ограбление изъятых патронов и наркотиков завершено') or text:find('Если вам удалось что-то украсть') or text:find('Внимание!') or text:find('Через 10 минут состоится выгрузка изъятых патронов и наркотиков') or text:find('чтобы украсть как можно больше ящиков в порту и пополнить ими общак') or text:find('Берите фургон и направляйтесь в порт') or text:find('Берите фургон и направляйтесь в порт') or text:find('вся Армия штата сосредоточена на том')) and color == -10270721 then return false end
                if (text:find('Если вам удалось что-то украсть') or text:find('доставьте это в общак')) and color == -10270721 then return false end
                if (text:find('чтобы не дать бандитам украсть и пополнить свой общак патронами и наркотиками') or text:find('Берите технику и направляйтесь в порт для защиты груза')) and color == -10270721 then return false end
                if (text:find('В порт уже доставили изъятые патроны и наркотики с соседнего штата') or text:find('Успейте украсть как можно больше, пока их не украли другие')) and color == -10270721 then return false end

                if (text:find('арендатор концертного зала:') and text:find('проводит мероприятие') and text:find('Развлечения')) and color == 1687547391 then return false end

                if text:find("Гос.Новости:") and color == 73381119 then return false end

                if text:find('Мероприятие') and text:find('Зловещий дворец') and color ==  -1178486529 then return false end

                if (text:find('Гость') or text:find('Репортёр')) and color == -1697828097 then return false end
        
                if text:find('За дверью') and text:find('говорит:') and color == -1077886209 then return false end

                if text:find('С помощью телефона можно заказать такси') and text:find('Подсказка') and color == -170229249 then return false end

            -----------------------------------------------------ajksdhfjsdjkfhsdjkfhsdjkf

            if not finished then
                if text:find('^%[Ошибка%].*После последнего сообщения в этом чате нужно подождать') then
                    lua_thread.create(function()
                        wait(500);
                        sampSendChat('/vr ' .. message)
                    end)
                    return false
                end
        
                local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
                if text:match('%[%u+%] {%x+}[A-z0-9_]+%[' .. id .. '%]:') then
                    finished = true
                end
            end
        
            if text:find('^Вы заглушены') or text:find('Для возможности повторной отправки сообщения в этот чат') then
                finished = true
            end

            ----------------------sadlkjjasdlknmadsklasd

            if mainini.functions.dotmoney then
                text = separator(text)
                return {color, text}
            end

end

-- pадар в инте офф
function sp.onSetInterior(interior)
        if interior ~= 0 then
            lua_thread.create(function()
                displayRadar()
                return true
            end)
        end
        if interior == 0 then
            lua_thread.create(function()
                displayRadar(1)
                return true
            end)
        end
end

function calc(m) 
    local func = load('return '..tostring(m)) 
    local a = select(2, pcall(func)) 
    return type(a) == 'number' and a
end





function isKeyCheckAvailable() -- Проверка на доступность клавиши
    if not isSampfuncsLoaded() then
      return not isPauseMenuActive()
    end
    local result = not isSampfuncsConsoleActive() and not isPauseMenuActive()
    if isSampLoaded() and isSampAvailable() then
      result = result and not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsCursorActive()
    end
    return result
end