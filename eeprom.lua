-----------------graphic init

local gpu = component.proxy(component.list("gpu")())
gpu.bind(component.list("screen")(), true)

-----------------