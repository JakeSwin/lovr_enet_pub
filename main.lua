local enet = require 'enet'
local messagepack = require 'MessagePack'

local host
local server
local peer
local sendTimer = 0       -- Track time between sends
local sendInterval = 1 / 30 -- 30 packets/sec

function lovr.load()
    host = enet.host_create()
    server = host:connect('192.168.1.165:6789')
    messagepack.set_number('float')
    print("attempting to connect to: 192.168.1.165:6789")
end

function lovr.update(dt)
    local event = host:service(0)
    if event then
        if event.type == 'connect' then
            print("Successfully connected to: 192.168.1.165:6789")
            peer = event.peer
            print("Set peer variable")
        end
    end

    if peer then
        sendTimer = sendTimer + dt -- Accumulate time

        if sendTimer >= sendInterval then
            local head_x, head_y, head_z = lovr.headset.getPosition()
            local lhand_x, lhand_y, lhand_z = lovr.headset.getPosition("hand/left")
            local rhand_x, rhand_y, rhand_z = lovr.headset.getPosition("hand/right")

            local data = messagepack.pack({
                head_x, head_y, head_z,
                lhand_x, lhand_y, lhand_z,
                rhand_x, rhand_y, rhand_z
            })

            peer:send(data)
            print("Sending packet")
            sendTimer = sendTimer - sendInterval -- Reset with carryover
        end
    end
end

function lovr.draw(pass)
    for i, hand in ipairs(lovr.headset.getHands()) do
        local x, y, z = lovr.headset.getPosition(hand)
        pass:sphere(x, y, z, .1)
    end
end
