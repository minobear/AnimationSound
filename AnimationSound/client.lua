local commState = nil
local Peds = {}

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
	    stopClap()
    end
end)

RegisterCommand("s", function(source, args, rawCommand)
	local argh = tostring(args[1])
	if commState ~= argh then
		stopClap()
		commState = argh	
		if Config.UserCostomVolume then
			local volume = InputBox()
			startClap(volume, argh)
		else
			startClap(Config.DefaultVolume, argh)
		end
	else
		commState = nil
		stopClap()
	end
end, false)

function startClap(value, playAni)	
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local pedModel = GetHashKey("s_m_m_strpreach_01")
	local aniBase = ""
	local ani = ""
	for k,v in pairs(Config.AnimationSounds) do
		if v.command == playAni then
			aniBase = v.aniBase
			ani = v.aniName
		end
	end
	RequestAnimDict(aniBase)
	while not HasAnimDictLoaded(aniBase) do Citizen.Wait(1) end		
	RequestModel(pedModel)
	while not HasModelLoaded(pedModel) do Citizen.Wait(1) end
	if value > 10 then
		value = 100
	else
		value = value*10
	end	
	for i=1, value do
		ped = CreatePed(4, pedModel, coords.x, coords.y, coords.z+1, 3374176, true, false)
		SetEntityVisible(ped, false, false)
		FreezeEntityPosition(ped, true)
		SetEntityInvincible(ped, true)
		SetPedCanBeTargetted(ped, false)		
		SetBlockingOfNonTemporaryEvents(ped, true)
		SetEntityAsMissionEntity(ped)
		SetEntityCollision(ped, false)	
		table.insert(Peds, ped)
	end	
	TaskPlayAnim(playerPed, aniBase, ani, 8.0, 0.0, -1, 51, 0, 0, 0, 0)
	for _,ped in pairs(Peds) do
		TaskPlayAnim(ped, aniBase, ani, 8.0, 0.0, -1, 1, 0, false, false, false)
	end
	while true do
	Citizen.Wait(100)
		if commState then
			for _,ped in pairs(Peds) do
				local coords = GetEntityCoords(playerPed)
				SetEntityCoords(ped, coords.x, coords.y, coords.z+1)
			end
		else
			break
		end
	end
end

function stopClap()
	local playerPed = PlayerPedId()
	ClearPedTasksImmediately(playerPed)
	for i=#Peds, 1, -1 do
		SetPedAsNoLongerNeeded(Peds[i])
		DeletePed(Peds[i])
		table.remove(Peds, i)
	end
end

function InputBox()
	DisplayOnscreenKeyboard(1, "_", "", "", "", "", "", 30)
	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0)
		DrawText2D(Config.InputTitle,0,1,0.5,0.35,1.0,255,255,255,255)
		Wait(0)
	end
	if (GetOnscreenKeyboardResult()) then
		local result = GetOnscreenKeyboardResult()	
		return tonumber(result)
	end		
end

function DrawText2D(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(0)
	SetTextProportional(6)
	SetTextScale(scale/1.5, scale/1.5)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end