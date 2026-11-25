local URL = "wss://://onrender.com"

write("Your Nickname: ")
local nick = read()
if nick == "" then nick = "Player" end

print("connection to " .. URL .. "...")
local ws, err = http.websocket(URL)
if not ws then
    printError("Error: " .. tostring(err))
    return
end

local w, h = term.getSize()
local chatWin = window.create(term.current(), 1, 1, w, h - 1)
local inputWin = window.create(term.current(), 1, h, w, 1)

local function addMessage(text)
    local prev = term.redirect(chatWin)
    print(text)
    term.redirect(prev)
end

addMessage("=== Connected! Exit: Ctrl+T ===")
ws.send("* " .. nick .. " join the chat")

local function receiveLoop()
    while true do
        local event, url, msg = os.pullEvent()
        if event == "websocket_message" and url == URL then
            addMessage(msg)
        elseif event == "websocket_closed" and url == URL then
            addMessage("=== Connencted lost ===")
            break
        end
    end
end

local function inputLoop()
    while true do
        local prev = term.redirect(inputWin)
        term.clear()
        term.setCursorPos(1, 1)
        write("> ")
        local text = read()
        term.redirect(prev)

        if text ~= "" then
            local formatted = "<" .. nick .. "> " .. text
            addMessage(formatted)
            ws.send(formatted)
        end
    end
end

parallel.waitForAny(receiveLoop, inputLoop)
pcall(function()
    ws.send("* " .. nick .. "Left the chat ")
    ws.close()
end)
