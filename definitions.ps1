#definitions.ps1

if ($PSVersionTable["PSVersion"] -le '3.0') {
    $PSScriptRoot2 = Split-Path $MyInvocation.MyCommand.Path -Parent
} else {
    $PSScriptRoot2 = $PSScriptRoot
}

Add-Type -path $PSScriptRoot2\cs\Serpen.Wrapper.ProcessMemory.cs
Add-Type -path $PSScriptRoot2\cs\Enums.cs, $PSScriptRoot2\cs\Character.cs, $PSScriptRoot2\cs\DiabloItem.cs, $PSScriptRoot2\cs\Spell.cs -Compiler (new-object System.CodeDom.Compiler.CompilerParameters -Property @{CompilerOptions="/unsafe"})

#$PLAYERS_COUNT_OFFSET = -(0xDE44)
#für 1.09
$PLAYERNAME_LENGTH = 15
$MONSTER_SIZE = 0xE4

$QUEST_ENUM = @(
"The Magic Rock"           
"Black Mushroom"           
"Gharbad The Weak"         
"Zhar the Mad"             
"Lachdanan"                
"Diablo"                   
"The Butcher"              
"Ogden's Sign"             
"Halls of the Blind"       
"Valor"                    
"Anvil of Fury"            
"Warlord of Blood"         
"The Curse of King Leoric" 
"Poisoned Water Supply"    
"The Chamber of Bone"      
"Archbishop Lazarus"  
)     

$QUEST_STATE= 'inactive', 'waiting', 'active', 'accomplished'

$SPELLBOX_X = 1,1,2,2,0,2,2,2,0,3,3,3,3,3,3,0,0,4,0,1,4,0,4,4,4,1,1,1,3,1,1,2,2,1,4,4
$SPELLBOX_Y = 2,5,4,6,0,2,5,7,0,1,2,4,7,6,5,0,0,1,0,7,2,0,3,4,7,1,1,1,3,3,4,1,3,6,6,5
