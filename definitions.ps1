#definitions.ps1

if ($PSVersionTable["PSVersion"] -le '3.0') {
    $PSScriptRoot2 = Split-Path $MyInvocation.MyCommand.Path -Parent
} else {
    $PSScriptRoot2 = $PSScriptRoot
}

Add-Type -path $PSScriptRoot2\cs\Serpen.Wrapper.ProcessMemory.cs
Add-Type -path $PSScriptRoot2\cs\Enums.cs, $PSScriptRoot2\cs\Character.cs, $PSScriptRoot2\cs\DiabloItem.cs -Compiler (new-object System.CodeDom.Compiler.CompilerParameters -Property @{CompilerOptions="/unsafe"})

. "$PSScriptRoot2\Offsets.ps1"

## item ##

#Resources Resources Resources Resources Resources Resources Resources Resources 
$DUNGEONTYPES_ENUM = 'Town','Cathedral','Catacombs','Caves','Hell'

$QUEST_ENUM = 'THE_MAGIC_ROCK','BLACK_MUSHROOM','GHARBAD_THE_WEAK','ZHAR_THE_MAD','LACHDANAN','DIABLO','THE_BUTCHER','OGDENS_SIGN','HALLS_OF_THE_BLIND','VALOR','ANVIL_OF_FURY','WARLORD_OF_BLOOD','THE_CURSE_OF_KING_LEORIC','POISONED_WATER_SUPPLY','THE_CHAMBER_OF_BONE','ARCHBISHOP_LAZARUS'
$QUEST_STATE= 'inactive','waiting', 'active', 'accomplished'

$SPELLBOX_X = 1,1,2,2,0,2,2,2,0,3,3,3,3,3,3,0,0,4,0,1,4,0,4,4,4,1,1,1,3,1,1,2,2,1,4,4
$SPELLBOX_Y = 2,5,4,6,0,2,5,7,0,1,2,4,7,6,5,0,0,1,0,7,2,0,3,4,7,1,1,1,3,3,4,1,3,6,6,5
