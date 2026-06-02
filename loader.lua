
if game.PlaceId == 129827112113663 then 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sadia4ek/zCM7UfZgmBSjny5Ej8tXtcqnP/refs/heads/main/prospecting.lua"))()
    else
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCore("SendNotification", {
            Title = "cats.cc",
            Text = "Unsupported game",
            Duration = 5
        })
        task.wait(5)
        game:Shutdown()
    end
