
$PLAYERS_COUNT_OFFSET = -(0xDE44)

$PLAYER_OFFSET = 0x54D8

$PLAYERNAME_OFFSET = 0x118
$PLAYERNAME_LENGTH = 15

$DIFFICULT_OFFSET = -(0xde34)

$POSSIBLE_IS_ALIVE_OFFSET = 0x115

$DUNGENON_OFFSET = 0xC

$TYPE_OFFSET = 0x138

$POS_X_OFFSET = 0x10
$POS_Y_OFFSET = 0x14

$SPELLFLAGS_OFFSET = 0xBD+23+12 # 0xE0
$SPELLS_OFFSET = 0x9A

$STAT_OFFSET = 0x140

$LEVELUP_OFFSET = 0x15C

$LVL_OFFSET = 0x190

$EXP_OFFSET = 0x194

$GOLD_OFFSET = 0x1A4

$WAYPOINT_OFFSET = -(0x5450)

$TP_OFFSET = -(0x10308)

$MONSTER_OFFSET = 0x39788
$MONSTER_SIZE = 0xE4

$ITEM_SIZE = 0x170
$INV_OFFSET = 0x354 # 0xDE0
$INV_BACKPACK_OFFSET = 0xD64

$BELT_OFFSET = 0x4701+15 # 0xDE0

$QUESTS_OFFSET = 0x158c6

$_DBG_HP = 0x682998
$_DBG_HP2 = 0x6829A0

$DBG_ROW = 0x5e769c

function GetVersionsSpecificOffset {
param (
    [String]$Type,
    [byte]$n =1,
    $DiabloSession = $Global:DiabloSession
)
    switch ($Type) {
        "Belt" {
            switch ($DiabloSession.Version) {
                'Debug 92.12.21.1' {return 0x682800}
                #'Release 1.00' {}
                'Release 1.02' {0x1066680 + $n * $ITEM_SIZE}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                #'Release 1.09' {}
                #'Release 1.09b' {}
                'Alpha 4.1.8' {return -1}
                'Alpha 4.1.9' {return -1}
                default {return $DiabloSession.StartOffset + $BELT_OFFSET + $n * $ITEM_SIZE}
            }
        }
        "Character" {
            switch ($DiabloSession.Version) {
                'Debug 92.12.21.1' {return 0x682830}
                'Release 1.00'     {return 0x5330E0}
                'Release 1.02'     {return 0xFE0760}
                'Release 1.03'     {return 0xFE0070}
                'Release 1.04'     {return 0xFD0070}
                'Release 1.05'     {return 0x6a8860}
                'Release 1.07'     {return 0x6877a0}
                'Release 1.08'     {return 0x6884C0}
                'Release 1.09'     {$DiabloSession.StartOffset + ($n-1) * $PLAYER_OFFSET}
                'Release 1.09b'    {$DiabloSession.StartOffset + ($n-1) * $PLAYER_OFFSET}
                'Alpha 4.1.8'      {return -1}
                'Alpha 4.1.9'      {return -1}
                'Beta 96.11.9.2'   {return 0x62d8B0}
                default            {return $DiabloSession.StartOffset + ($n-1) * $PLAYER_OFFSET}
            }            
        }
        "Difficulty" {
            return $DiabloSession.StartOffset + $DIFFICULT_OFFSET
        }
        "Entrance" {
            return $DiabloSession.StartOffset - $WAYPOINT_OFFSET
        }
        "Inventory" {
            return $DiabloSession.StartOffset + $INV_OFFSET + $n * $ITEM_SIZE
        }
        "ItemsOnFloor" {
            switch ($DiabloSession.Version) {
                'Debug 92.12.21.1' {return 0x5F6D94}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                #'Release 1.09' {}
                #'Release 1.09b' {return }
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return 0x5F6D94}
            }
        }
        "LevelUpPoints" {
            return $DiabloSession.StartOffset + $LEVELUP_OFFSET
        }
        "MonsterKills" {
            if ($DiabloSession.Version -like 'Release 1.09*') {
                return $DiabloSession.StartOffset - $MONSTER_OFFSET
            } else {
                return 0x526240 + 0
            }
        }
        "Pause" {
            switch ($DiabloSession.Version) {
                #'Debug 92.12.21.1' {}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x525740}
                'Release 1.09b' {return 0x525740}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return 0x525740}
            }
        }
        "PlayersCount" {
            switch ($DiabloSession.Version) {
                'Debug 92.12.21.1' {return -1}
                'Release 1.00' {return 0x5903D0}
                'Release 1.02' {return 0x606240}
                'Release 1.03' {return 0x57EDF0}
                'Release 1.04' {return 0x6066B0}
                'Release 1.05' {return 0x69AA18}
                'Release 1.07' {return 0x679958}
                'Release 1.08' {return 0x67a698}
                #'Release 1.09' {return $DiabloSession.StartOffset + $PLAYERS_COUNT_OFFSET}
                #'Release 1.09b' {return $DiabloSession.StartOffset + $PLAYERS_COUNT_OFFSET}
                'Alpha 4.1.8' {return -1}
                'Alpha 4.1.9' {return -1}
                'Beta 96.11.9.2'   {return -1}
                default {return $DiabloSession.StartOffset + $PLAYERS_COUNT_OFFSET}
            }
        }
        "Players" {
            if ($DiabloSession.Version -like 'Release 1.09*') {
                return $DiabloSession.StartOffset + $PLAYERNAME_OFFSET + ($n)*$PLAYER_OFFSET
            } elseif ($DiabloSession.Version -like 'Release 1.01') {
                return $DiabloSession.StartOffset + $PLAYERNAME_OFFSET + ($n)*$PLAYER_OFFSET
            } elseif ($DiabloSession.Version -like 'Release 1.02') {
                return $DiabloSession.StartOffset + $PLAYERNAME_OFFSET + ($n)*$PLAYER_OFFSET
            } else {
                return $DiabloSession.StartOffset + $PLAYERNAME_OFFSET + ($n)*$PLAYER_OFFSET
            }
            
        }
        "Position" {
            switch ($DiabloSession.Version) {
                'Debug 92.12.21.1' {return 0x682800}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x686440}
                'Release 1.09b' {return 0x686440}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return $DiabloSession.StartOffset - 0x30 - ($n-1) * $n}
            }            
        }
        "Quest" {
            switch ($DiabloSession.Version) {
                'Debug 92.12.21.1' {return 0x697ba0}

                'Release 1.00' {return 0x548450}
                'Release 1.02' {return 0x616ee8}
                'Release 1.03' {return 0x536d68}
                'Release 1.04' {return 0x617358}
                'Release 1.05' {return 0x6be100}
                'Release 1.07' {return 0x69d040}
                'Release 1.08' {return 0x69dd60}
                'Release 1.09' {return 0x69bd10}
                'Release 1.09b' {return 0x69bd10}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                #'Beta 96.11.9.2' {}
                default {return -1}
            }            
        }
        "Rucksack" {
            return $DiabloSession.StartOffset + $INV_BACKPACK_OFFSET + $n * $ITEM_SIZE
        }
        "Spell" {
            return $DiabloSession.StartOffset + $SPELLS_OFFSET
        }
        "Store" {
            switch ($DiabloSession.Version) {
                'Release 1.00' {return 0x558908}
                'Release 1.09' {return $DiabloSession.StartOffset + 0x18CA8}
                'Release 1.09b' {return $DiabloSession.StartOffset + 0x18CA8}
            }
        }
        "TownPortal" {
            if ($DiabloSession.Version -like 'Release 1.09*') {
                return $DiabloSession.StartOffset + $TP_OFFSET + ($n-1)*5
            } else {
                return 0x58AB98
            }
        }
        "UI_Char" {
            switch ($DiabloSession.Version) {
                #'Debug 92.12.21.1' {}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x4B896C}
                'Release 1.09b' {return 0x4B896C}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return 0x4B896C}
            }
        }
        "UI_Spellbook" {
            switch ($DiabloSession.Version) {
                #'Debug 92.12.21.1' {}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x4B8968}
                'Release 1.09b' {return 0x4B8968}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return 0x4B8968}
            }
        }
        "UI_AutoMap" {
            switch ($DiabloSession.Version) {
                #'Debug 92.12.21.1' {}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x4B7E48}
                'Release 1.09b' {return 0x4B7E48}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return 0x4B7E48}
            }
        }
        "UI_Spells" {
            switch ($DiabloSession.Version) {
                #'Debug 92.12.21.1' {}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x4B8C98}
                'Release 1.09b' {return 0x4B8C98}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return 0x4B8C98}
            }
        }
        "UI_Inventory" {
            switch ($DiabloSession.Version) {
                #'Debug 92.12.21.1' {}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x634CB8}
                'Release 1.09b' {return 0x634CB8}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return 0x634CB8}
            }
        }
        "UI_Questlog" {
            switch ($DiabloSession.Version) {
                #'Debug 92.12.21.1' {}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x69BD04}
                'Release 1.09b' {return 0x69BD04}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return 0x69BD04}
            }
        }
        "LogLine" {
            switch ($DiabloSession.Version) {
                'Debug 92.12.21.1' {return 0x5E769C}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                #'Release 1.09' {}
                #'Release 1.09b' {}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {}
            }
        }
        "monsters" {
            switch ($DiabloSession.Version) {
                'Debug 92.12.21.1' {0x4C9B90 } #0x4CBE4C}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x64D350}
                'Release 1.09b' {return 0x64D350}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {return 0x64d354}
            }
        }
        "_template_" {
            switch ($DiabloSession.Version) {
                #'Debug 92.12.21.1' {}
                #'Release 1.00'     {}
                #'Release 1.02'     {}
                #'Release 1.03'     {}
                #'Release 1.04'     {}
                #'Release 1.05'     {}
                #'Release 1.07'     {}
                #'Release 1.08'     {}
                #'Release 1.09'     {}
                #'Release 1.09b'    {}
                #'Alpha 4.1.8'      {}
                #'Alpha 4.1.9'      {}
                #'Beta 96.11.9.2'   {}
                default             {return -1}
            }
        }
    }
}