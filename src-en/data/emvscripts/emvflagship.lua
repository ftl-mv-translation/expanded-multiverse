local function vter(cvec)
    local i = -1
    local n = cvec:size()
    return function()
        i = i + 1
        if i < n then return cvec[i] end
    end
end

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    if shipManager:HasAugmentation("EMV_PERMISSION") > 0 then 
        local shipCrewCount = 0
        for crew in vter(shipManager.vCrewList) do
            if crew.iShipId == shipManager.iShipId and not crew:IsDrone() then
                shipCrewCount = shipCrewCount + 1
            end
        end

        if shipCrewCount >= 3 --[[and shipManager:HasAugmentation("EMV_PREPERATION") > 0]] then
            if shipManager:HasAugmentation("EMV_AUTOMATION") > 0 then
            shipManager:RemoveAugmentation("EMV_AUTOMATION")
            end
            if shipManager:HasAugmentation("EMV_PREPERATION") > 0 then
            shipManager:RemoveAugmentation("EMV_PREPERATION") 
            end
            if shipManager:HasAugmentation("EMV_AI_SCANNER") == 0 then
            print("LIFESIGNS RETURNED, STOPPING AUTOMATION.")
            shipManager:AddAugmentation("EMV_AI_SCANNER") 
            end
        elseif (shipCrewCount == 1 or shipCrewCount == 2) --[[and (shipManager:HasAugmentation("EMV_AI_SCANNER") > 0) or (shipManager:HasAugmentation("EMV_AUTOMATION") > 0)]] then
            if shipManager:HasAugmentation("EMV_AI_SCANNER") > 0 then
            shipManager:RemoveAugmentation("EMV_AI_SCANNER")
            end
            if shipManager:HasAugmentation("EMV_AUTOMATION") > 0 then
            shipManager:RemoveAugmentation("EMV_AUTOMATION") 
            end
            if shipManager:HasAugmentation("EMV_PREPERATION") == 0 then
            print("LIFESIGNS DECREASING, PREPARING AI ACTIVATION.")
            shipManager:AddAugmentation("EMV_PREPERATION")
            end
        elseif shipCrewCount == 0 --[[and shipManager:HasAugmentation("EMV_PREPERATION") > 0]] then
            if shipManager:HasAugmentation("EMV_AI_SCANNER") > 0 then
            shipManager:RemoveAugmentation("EMV_AI_SCANNER")
            end
            if shipManager:HasAugmentation("EMV_PREPERATION") > 0 then
            shipManager:RemoveAugmentation("EMV_PREPERATION") 
            end
            if shipManager:HasAugmentation("EMV_AUTOMATION") == 0 then
            print("LIFESIGNS LOST. ACTIVATING ADVANCED AI.")
            shipManager:AddAugmentation("EMV_AUTOMATION") 
            end
        end
    end
end)


script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
	if log_events then
		--log("SHIP_LOOP 1")
	end
	if shipManager:HasAugmentation("EMV_AUTOMATION") > 0 and shipManager:HasSystem(2) and not Hyperspace.App.menu.shipBuilder.bOpen then
		local oxygen = shipManager.oxygenSystem
		local refill = oxygen:GetRefillSpeed()

		--print("refill speed: "..tostring(refill))
		local shipGraph = Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId)
		local wipe_p = false
		if not Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame then
			wipe_p = true
		end
		if refill > 0 then
			for id = 0, shipGraph:RoomCount(), 1 do
				--local id = room.iRoomId
				--print(id)
				oxygen:ModifyRoomOxygen(id, (-1*refill) - (5*(Hyperspace.FPS.SpeedFactor/16)))
				if wipe_p then
					oxygen:EmptyOxygen(id)
				end
			end
		end
    end
end)