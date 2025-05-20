local enet = require 'enet'
local messagepack = require 'MessagePack'

local host
local server
local peer
local sendTimer = 0         -- Track time between sends
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
            local h_x, h_y, h_z, h_angle, h_ax, h_ay, h_az = lovr.headset.getPose("head")
            local h_rotation = lovr.math.quat(h_angle, h_ax, h_ay, h_az)
            local h_qx, h_qy, h_qz, h_qw = h_rotation:unpack()
            local h_vx, h_vy, h_vz = lovr.headset.getVelocity("head")
            local h_rvx, h_rvy, h_rvz = lovr.headset.getAngularVelocity("head")

            local l_x, l_y, l_z, l_angle, l_ax, l_ay, l_az = lovr.headset.getPose("hand/left")
            local l_rotation = lovr.math.quat(l_angle, l_ax, l_ay, l_az)
            local l_qx, l_qy, l_qz, l_qw = l_rotation:unpack()
            local l_vx, l_vy, l_vz = lovr.headset.getVelocity("hand/left")
            local l_rvx, l_rvy, l_rvz = lovr.headset.getAngularVelocity("hand/left")

            local r_x, r_y, r_z, r_angre, r_ax, r_ay, r_az = lovr.headset.getPose("hand/right")
            local r_rotation = lovr.math.quat(r_angre, r_ax, r_ay, r_az)
            local r_qx, r_qy, r_qz, r_qw = r_rotation:unpack()
            local r_vx, r_vy, r_vz = lovr.headset.getVelocity("hand/right")
            local r_rvx, r_rvy, r_rvz = lovr.headset.getAngularVelocity("hand/right")

            local data = messagepack.pack({
                h_x, h_y, h_z, h_qx, h_qy, h_qz, h_qw, h_vx, h_vy, h_vz, h_rvx, h_rvy, h_rvz,
                l_x, l_y, l_z, l_qx, l_qy, l_qz, l_qw, l_vx, l_vy, l_vz, l_rvx, l_rvy, l_rvz,
                r_x, r_y, r_z, r_qx, r_qy, r_qz, r_qw, r_vx, r_vy, r_vz, r_rvx, r_rvy, r_rvz
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
