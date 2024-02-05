local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEz = require(ReplicatedStorage.DevPackages.TestEz);
(TestEz.TestBootstrap :: any):run({ ReplicatedStorage.Packages.tinyFSM })
