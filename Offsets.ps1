#$PLAYERS_COUNT_OFFSET = -(0xDE44)
#für 1.09
$PLAYER_OFFSET = 0x54D8
$PLAYERNAME_LENGTH = 15
$SPELLS_OFFSET = 0x9A
$MONSTER_SIZE = 0xE4

function GetVersionsSpecificOffset {
param (
    [String]$Type,
    [byte]$n =1,
    $D1Session = $Global:D1Session
)
    switch ($Type) {
        "Belt" {
            return $D1Session.StartOffset + $D1Session.Version.Belt -as [int] + $n * $ITEM_SIZE
        }
        "Character" {
            return $D1Session.StartOffset + ($n-1) * $PLAYER_OFFSET - 41
        }
        "Difficulty" {
            return $D1Session.StartOffset + ($D1Session.Version.difficulty -as [int])
        }
        "Entrance" {
            return $D1Session.StartOffset + $D1Session.Version.entrance -as [int]
        }
        "Inventory" { #equip
            return $D1Session.StartOffset + $D1Session.Version.equip -as [int] + $n * $ITEM_SIZE
        }
        "LevelUpPoints" {
            return $D1Session.StartOffset + $D1Session.Version.LvlUpPoints -as [int]
        }
        "ItemsOnFloor" {
            return $D1Session.Version.ItemsOnFloor -as [int]
        }
        'Debug1' {
            return $D1Session.StartOffset + $EXP_OFFSET - 4 -96 -24-4-8-4-12-7*4-68-1-(5*4+2+34*4+1+1+4*8+4)
        }
        
        "MonsterKills" {
            return $D1Session.Version.MonsterKills -as [int] + $n * 4
        }
        "Pause" {
            return $D1Session.Version.pause -as [int]
        }
        "PlayersCount" {
            return $D1Session.StartOffset + $D1Session.Version.playercount -as [int]
        }
        "Players" {
            #return $versionsMatrix[$D1Session.Version][0] + $versionsMatrix[$D1Session.Version][9] + $n * $PLAYER_OFFSET    
        }
        "Position" {
            return $D1Session.StartOffset - $D1Session.Version.pos  -as [int]       
        }
        "Quest" {
            return $D1Session.StartOffset + $D1Session.Version.quest   -as [int]        
        }
        "Rucksack" {
            return $D1Session.StartOffset + $D1Session.Version.backpack -as [int] + $n * $ITEM_SIZE
        }
        "Spell" {
            return $D1Session.StartOffset + $SPELLS_OFFSET
        }
        "Store" {
            return $D1Session.StartOffset + $D1Session.Version.store -as [int]
        }
        "TownPortal" {
            return $D1Session.StartOffset + $D1Session.Version.tp -as [int] + ($n-1)*5
        }
        "UI_Char" {
            switch ($D1Session.Version.Name) {
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
            return 0x4B8968
        }
        "UI_AutoMap" {
            return 0x4B7E48
        }
        "UI_Spells" {
            return 0x4B8C98
        }
        "UI_Inventory" {
           return 0x634CB8
        }
        "UI_Questlog" {
            return 0x69BD04
        }
        "LogLine" {
            switch ($D1Session.Version.Name) {
                'Debug 92.12.21.1' {return 0x5E769C}
                #'Release 1.00' {}
                #'Release 1.02' {}
                #'Release 1.03' {}
                #'Release 1.04' {}
                #'Release 1.05' {}
                #'Release 1.07' {}
                #'Release 1.08' {}
                'Release 1.09' {return 0x69b7d4}
                'Release 1.09b' {return 0x69b7d4}
                #'Alpha 4.1.8' {}
                #'Alpha 4.1.9' {}
                default {}
            }
        }
        "monsters" {
            return $D1Session.Version.monster + ($n-1)*0xE4
            return 0x64d354
        }
        
        "GameSettings" {
            switch ($D1Session.Version.Name) {
                #'Debug 92.12.21.1' {}
                'Release 1.00'     {0x499fc8}
                #'Release 1.02'     {}
                #'Release 1.03'     {}
                #'Release 1.04'     {}
                #'Release 1.05'     {}
                #'Release 1.07'     {}
                #'Release 1.08'     {}
                'Release 1.09'     {return 0x48e240}
                'Release 1.09b'    {return 0x48e240}
                #'Alpha 4.1.8'      {}
                #'Alpha 4.1.9'      {}
                #'Beta 96.11.9.2'   {}
                default             {return -1}
            }
        }
        "_template_" {
            switch ($D1Session.Version.Name) {
                #'Alpha 4.1.8'      {}
                #'Alpha 4.1.9'      {}
                #'Beta 96.11.9.2'   {}
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
                default             {return -1}
            }
        }
    }
}