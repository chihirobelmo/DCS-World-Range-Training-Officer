local AspectAngle = {
    Drag    = 65,
    Beam    = 115,
    Flank   = 155,
    Hot     = 180
};

local feet_per_meter = 3.28084
local feet_per_nm    = 6000
local ms_per_mach    = 343

function AAM_NULL()
    local obj = {}

    function obj:valid(shot)
        return false
    end

    function obj:hasCriteria()
        return false
    end

    function obj:isExist(shot)
        return false
    end

    function obj:getMinMach()
        return 100
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    return obj
end

function AAM_AIM120C()
    local obj = {}

    obj.RMAX     = 62
    obj.DOR      = 36
    obj.MAR      = 31
    obj.DR       = 27
    obj.STERNWEZ = 23

    obj.minMach  = 1

    function obj:valid(shot)
        if shot:shotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return true
        end
        if shot:getMissileSpeedMach() < self.minMach                                                  then
            return false
        end
        if shot:shotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return false
        end
        if shot:shotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Beam
        end
        if shot:shotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Drag
        end
    end

    function obj:hasCriteria()
        return true
    end

    function obj:isExist(shot)
        return shot:getMissileSpeedMach() > self.minMach
    end

    function obj:getMinMach()
        return self.minMach
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    return obj
end

function AAM_AIM120()
    local obj = {}

    obj.RMAX     = 58
    obj.DOR      = 34
    obj.MAR      = 29
    obj.DR       = 25
    obj.STERNWEZ = 21

    obj.minMach  = 1

    function obj:valid(shot)
        if shot:shotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return true
        end
        if shot:getMissileSpeedMach() < self.minMach                                                  then
            return false
        end
        if shot:shotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return false
        end
        if shot:shotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Beam
        end
        if shot:shotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Drag
        end
    end

    function obj:hasCriteria()
        return true
    end

    function obj:isExist(shot)
        return shot:getMissileSpeedMach() > self.minMach
    end

    function obj:getMinMach()
        return self.minMach
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    return obj
end

function AAM_SD_10()
    local obj = {}

    obj.RMAX     = 60
    obj.DOR      = 60
    obj.MAR      = 60
    obj.DR       = 60
    obj.STERNWEZ = 60

    obj.minMach  = 0.1

    function obj:valid(shot)
        if shot:shotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return true
        end
        if shot:getMissileSpeedMach() < self.minMach                                                  then
            return false
        end
        if shot:shotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return false
        end
        if shot:shotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Beam
        end
        if shot:shotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Drag
        end
    end

    function obj:hasCriteria()
        return true
    end

    function obj:isExist(shot)
        return shot:getMissileSpeedMach() > self.minMach
    end

    function obj:getMinMach()
        return self.minMach
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    return obj
end

function AAM_P_77()
    local obj = {}

    obj.RMAX     = 42
    obj.DOR      = 25
    obj.MAR      = 21
    obj.DR       = 19
    obj.STERNWEZ = 15

    obj.minMach  = 1

    function obj:valid(shot)
        if shot:shotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return true
        end
        if shot:getMissileSpeedMach() < self.minMach                                                  then
            return false
        end
        if shot:shotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return false
        end
        if shot:shotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Beam
        end
        if shot:shotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Drag
        end
    end

    function obj:hasCriteria()
        return true
    end

    function obj:isExist(shot)
        return shot:getMissileSpeedMach() > self.minMach
    end

    function obj:getMinMach()
        return self.minMach
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    return obj
end

function AAM_P_27PE()
    local obj = {}

    obj.RMAX     = 39
    obj.DOR      = 25
    obj.MAR      = 13
    obj.DR       = 15
    obj.STERNWEZ = 9

    obj.minMach  = 1

    function obj:valid(shot)
        if shot:isMissileTrackingTgt() == false then
            return false
        end
        if shot:shotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return true
        end
        if shot:getMissileSpeedMach() < self.minMach                                                  then
            return false
        end
        if shot:shotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return false
        end
        if shot:shotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Beam
        end
        if shot:shotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            return shot:getTargetAspectAngle() >= AspectAngle.Drag
        end
    end

    function obj:hasCriteria()
        return true
    end

    function obj:isExist(shot)
        return shot:getMissileSpeedMach() > self.minMach
    end

    function obj:getMinMach()
        return self.minMach
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 20000) * 3/ 10000
    end

    return obj
end

function AGM_AGM_88()
    local obj = {}

    obj.RMAX     = 60
    obj.DOR      = 25
    obj.MAR      = 13
    obj.DR       = 15
    obj.STERNWEZ = 9

    obj.minMach  = 1

    function obj:valid(shot)
        if shot:isMissileTrackingTgt() == false then
            return false
        end
        if shot:isTargetRadarActive() == false then
            return false
        end
        if shot:shotRangeNm() > self.RMAX + shot:getShotAltFactorNm() then
            return false
        end
        return true
    end

    function obj:hasCriteria()
        return true
    end

    function obj:isExist(shot)
        return timer.getTime() - shot:getShotTime() > 90
    end

    function obj:getMinMach()
        return self.minMach
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    return obj
end

function Missile(w)
    -- trigger.action.outText(w:getTypeName(), 10, true)
    if     w:getTypeName() == "AIM_120C" then
        return AAM_AIM120C()
    elseif w:getTypeName() == "AIM_120"  then
        return AAM_AIM120()
    elseif w:getTypeName() == "P_77"     then
        return AAM_P_77() 
    elseif w:getTypeName() == "SD-10"    then
        return AAM_SD_10() 
    elseif w:getTypeName() == "P_27PE"   then
        return AAM_P_27PE()
    elseif w:getTypeName() == "AGM_88"   then
        return AGM_AGM_88()
    else
        return AAM_NULL()
    end
end

function Shot(weapon,misile)
    local obj = {}

    local l  = weapon:getLauncher():getPosition().p
    local t  = weapon:getTarget():getPosition().p
    local sr = math.sqrt((l.x-t.x)^2 + (l.y-t.y)^2 + (l.z-t.z)^2) * feet_per_meter / feet_per_nm

    obj.misile = misile

    obj.weapon       = weapon
    obj.target       = weapon:getTarget()
    obj.shotPosition = weapon:getPosition().p

    obj.targetAspectAngle       = 180                   -- shot position to target aspect angle
    obj.missileFlewDistance     = 0;                    -- missile flew distance
    obj.targetAltitude          = 35000;                -- target altitude
    obj.targetToShotPosDistance = 9999;                 -- target to shot position distance
    obj.shotRange               = sr                    -- shot range
    obj.shotAltitude            = l.y * feet_per_meter  -- shot altitude
    obj.missileSpeedMach        = 100;                  -- missile mach
    obj.flagMissileBurst        = false;                -- flag burst

    obj.time = timer.getTime()

    function obj:isExist()
        if self.target == nil then
            return false
        end
        if self.misile:isExist(self) == false then
            return false
        end
        if self.weapon:isExist() then
            return self.targetToShotPosDistance >= self.missileFlewDistance
        else
            return false
        end
    end

    function obj:update()
        if self.weapon == nil then
            return
        end
        if self.target == nil then
            return
        end

        local ps = self.shotPosition             -- position    shot
        local vw = self.weapon:getVelocity()     -- velocity    weapon
        local pw = self.weapon:getPosition().p   -- position    weapon
        local pt = self.target:getPosition().p   -- position    target
        local ot = self.target:getPosition().z   -- orientation target

        self.targetAltitude   = pt.y * feet_per_meter
        self.missileSpeedMach = math.sqrt(vw.x^2 + vw.y^2 + vw.z^2) / ms_per_mach;

        -- check if missile rocket burst started
        if self.flagMissileBurst == false then
            if self.missileSpeedMach > self.misile:getMinMach() then
                self.flagMissileBurst = true;
            end
        end

        -- aspect angle from shot position to the target
        local p = {
            x = ps.x - pt.x,
            y = ps.y - pt.y,
            z = ps.z - pt.z
        }

        self.targetToShotPosDistance = math.sqrt(p.x^2 + p.y^2 + p.z^2) * feet_per_meter / feet_per_nm

        local rh =      (1 + (math.atan2(p.z,  p.x ) / math.pi)) * 180
        local oh = 90 + (1 + (math.atan2(ot.z, ot.x) / math.pi)) * 180

        if oh >= 360 then
            oh = oh - 360
        end
        
        local raa = 0
        
        if oh - rh < 180 then
            raa = - (oh - rh)
        else
            raa = 360 - (oh - rh)
        end
        
        self.targetAspectAngle = math.abs(raa)

        -- missile flew distance from shot range
        local p = {
            x = ps.x - pw.x,
            y = ps.y - pw.y,
            z = ps.z - pw.z
        }

        self.missileFlewDistance = math.sqrt(p.x^2 + p.y^2 + p.z^2) * feet_per_meter / feet_per_nm

        --trigger.action.outText("TA : " .. string.format("%.0f",self.targetAltitude) .. " AA : " .. string.format("%.0f",self.targetAspectAngle) .. " FD : " .. string.format("%.2f",self.missileFlewDistance) .. " MACH : " .. string.format("%.2f",self.missileSpeedMach),  1, true) 
    end

    function obj:isMissileTrackingTgt()
        if self.weapon == nil then
            return
        end
        return self.weapon:getTarget() ~= nil
    end

    function obj:isTargetRadarActive()
        if self.weapon == nil then
            return
        end
        if self.weapon:getTarget() == nil then
            return
        end
        b, t = self.weapon:getTarget():getRadar()
        return b
    end

    function obj:getShotTime()
        return self.time
    end

    function obj:getTargetAspectAngle()
        return self.targetAspectAngle
    end

    function obj:shotRangeNm()
        return self.shotRange
    end

    function obj:getTgtAltFactorNm()
        return self.misile:altitudeCoefficient(self.targetAltitude)
    end

    function obj:getShotAltFactorNm()
        return self.misile:altitudeCoefficient(self.shotAltitude)
    end

    function obj:getMissileSpeedMach()
        if self.flagMissileBurst == false then
            return 100
        else
            return self.missileSpeedMach
        end
    end

    function obj:valid()
        if self.target == nil then
            return
        end
        if obj.misile:valid(self) == true then
            trigger.action.explosion(self.target:getPoint(), 100)
        end
    end

    return obj
end

function RTO()
    local obj = {}
    
    obj.shot = {}

    function obj:onEvent(event)
        if event.id ~= world.event.S_EVENT_SHOT then
            return
        end
        if event.weapon == nil then
            return
        end
        if event.weapon:getLauncher() == nil then
            return
        end
        if event.weapon:getTarget() == nil then
            return
        end

        local misile = Missile(event.weapon)

        -- trigger.action.outText(event.weapon:getTypeName(),10,true)

        if misile:hasCriteria() == false then
            return
        end
        
        self.shot[#self.shot + 1] = Shot(event.weapon, misile)
    end
    
    function obj:calc()
        for i,track in pairs(self.shot) do
            if track:isExist() == true then
                self.shot[i]:update()
            else
                self.shot[i]:valid()
                table.remove(self.shot, i)
            end
        end
    end
    
    return obj
end

rto = RTO()

world.addEventHandler(rto)

--for i = 1, 100 do
--    timer.scheduleFunction(rto.calc,  rto, timer.getTime() + 0.01 * i)
--end