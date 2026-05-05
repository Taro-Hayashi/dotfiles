function restoreFinder()
  local finder = hs.application.get("Finder")
  if finder then
    local wins = finder:allWindows()
    if wins[1] then
      wins[1]:setFrame(hs.geometry.rect(-1081, 30,  1080, 524))
    end
    if wins[2] then
      wins[2]:setFrame(hs.geometry.rect(-1081, 555, 1080, 519))
    end
  end

  local brave = hs.application.get("Brave Browser")
  if brave then
    local bwins = brave:allWindows()
    if bwins[1] then
      bwins[1]:setFrame(hs.geometry.rect(-1080, 1075, 1080, 845))
    end
  end
end

local watcher = hs.caffeinate.watcher.new(function(event)
    if event == hs.caffeinate.watcher.screensDidWake then
        hs.timer.doAfter(5, restoreFinder)
    end
end)
watcher:start()

-- Wake on LAN
hs.hotkey.bind({"cmd","shift"}, "W", function()
  hs.execute("/opt/homebrew/bin/wakeonlan 18:C0:4D:01:81:24")
  hs.notify.new({title="Wake on LAN", informativeText="Magic Packet送信"}):send()
end)

-- Finderウィンドウ位置を手動でも復元できるように
hs.hotkey.bind({"cmd","shift"}, "F", function()
  restoreFinder()
  hs.notify.new({title="Finder", informativeText="ウィンドウ位置を復元"}):send()
end)
