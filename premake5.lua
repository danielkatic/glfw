workspace "Engine"
    architecture "x86_64"
    
    configurations
    {
        "Debug",
        "Release",
        "Dist"
    }

outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"
engine_prj_name = "Engine"
sandbox_prj_name = "Sandbox"

-- Include directories relative to the root folder
IncludeDir = {}
IncludeDir["GLFW"] = engine_prj_name .. "/vendor/GLFW/include"

project "Sandbox"
    location "Sandbox"
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++17"

    targetdir ("bin/" .. outputdir .. "/" .. sandbox_prj_name)
    objdir ("bin-int/" .. outputdir .. "/" .. sandbox_prj_name)

    files
    {
        "%{prj.name}/**.h",
        "%{prj.name}/**.hpp",
        "%{prj.name}/**.cpp"
    }
    
    includedirs
    {
        "Engine/src",
        "%{wks.location}/Engine/vendor",
    }

    sysincludedirs
    {
        "Engine/vendor/spdlog/include"
    }

    links { "Engine" }

    filter "system:Windows"
        cppdialect "C++17"
        staticruntime "On"
        systemversion "latest"
        
        defines {"GE_PLATFORM_WINDOWS"}

        libdirs { "%{prj.name}/vendor/GLFW/lib-vc2019" }
    
    filter "system:macosx"
        cppdialect "C++17"
        staticruntime "On"
        
        defines "GE_PLATFORM_MACOS"
        
        links { "fmt" }
        libdirs { "/opt/homebrew/lib" }
        
    filter "configurations:Debug"
        defines ("GE_DEBUG", "GE_ENABLE_ASSERTS")
        symbols "On"
    
    filter "configurations:Release"
        defines "GE_RELEASE"
        optimize "On"

    filter "configurations:Dist"
        defines "GE_DIST"
        symbols "On"

project "Engine"
    location "Engine"
    kind "SharedLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"
    
    targetdir ("bin/" .. outputdir .. "/" .. engine_prj_name)
    objdir ("bin-int/" .. outputdir .. "/" .. engine_prj_name)

    pchheader ("src/gepch.hpp")
    pchsource (engine_prj_name .. "/src/gepch.cpp")
    
    files
    {
        "%{prj.name}/**.h",
        "%{prj.name}/**.hpp",
        "%{prj.name}/**.cpp"
    }

    removefiles 
    {
        "%{prj.name}/vendor/**"
    }

    includedirs
    {
        "%{prj.name}/src"
    }
    
    sysincludedirs
    {
        "%{prj.name}/vendor/spdlog/include",
        "%{IncludeDir.GLFW}"
    }

    links {""}

    flags { "NoPCH" }

    defines 
    {
        "_CRT_SECURE_NO_WARNINGS",
		"GLFW_INCLUDE_NONE"
    }
    
    filter "system:Windows"
        buildoptions { "-std=c11", "-lgdi32" }
        cppdialect "C++17"
        staticruntime "On"
        systemversion "latest"
        
        defines
        {
            "GE_PLATFORM_WINDOWS",
            "GE_BUILD_DLL"
        }

        links 
        {
            "opengl32.lib"
        }
        
        postbuildcommands
        {
            ("{COPY} %{cfg.buildtarget.relpath} ../bin/" .. outputdir .. "/" .. sandbox_prj_name)
        }
    
    filter "system:macosx"
        cppdialect "C++17"
        staticruntime "On"
        
        defines "GE_PLATFORM_MACOS"
        
        postbuildcommands
        {
            ("{COPY} %{cfg.buildtarget.relpath} ../bin/"..outputdir.."/"..sandbox_prj_name)
        }
        
        links {"Cocoa.framework", "OpenGL.framework", "IOKit.framework", "CoreFoundation.framework"}
        
    filter "configurations:Debug"
        defines ("GE_DEBUG", "GE_ENABLE_ASSERTS")
        buildoptions "/MTd"
        symbols "On"
    
    filter "configurations:Release"
        defines "GE_RELEASE"
        buildoptions "/MTd"
        optimize "On"

    filter "configurations:Dist"
        defines "GE_DIST"
        buildoptions "/MTd"
        symbols "On"