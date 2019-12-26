#$PLAYERS_COUNT_OFFSET = -(0xDE44)
#für 1.09
$SELECTED_POS_IN_MENU = 0x63446c
$MUSIC_VOL = 0x48e240 #C=Sound, 258=GAMMA
$PLAYER_OFFSET = 0x54D8
$COLYCLE = 0x48e268 # BF=OFF, A0=ON
$PLAYERNAME_LENGTH = 15
$POSSIBLE_IS_ALIVE_OFFSET = 0x115
$SPELLFLAGS_OFFSET = 0xBD+23+12 # 0xE0
$SPELLS_OFFSET = 0x9A
#$MONSTER_OFFSET = 0x39788
$MONSTER_SIZE = 0xE4
$ITEM_SIZE = 0x170



$versionsMatrix =[System.Collections.Generic.Dictionary[[string],[int[]]]]::new(10)
                                           #base     #BELT      #verof    #Differe    entrance  eqiptm    #-lup, pause     play#     playe  pos   quest     backp  store       tp          monster
$versionsMatrix.Add('Alpha 4.1.8',       @(0x6058a7, 000000000, 0x4BC150, -(0xde34), -(0x5450), 0x533434, 0x15C, 00000000, 00000000, 0x118, 0000, 00000000, 00000, 000000000, 000000000, 000000000))
$versionsMatrix.Add('Alpha 4.1.9',       @(0x6058a7, 000000000, 0x4BC150, -(0xde34), -(0x5450), 0x533434, 0x15C, 00000000, 00000000, 0x118, 0000, 00000000, 00000, 000000000, 000000000, 000000000))
$versionsMatrix.Add('Beta 96.11.9.2',    @(0x62d8B0, 0x04BC150, 0x4C55B0, -(0xde34), -(0x5450), 0x533434, 0x15C, 00000000, 00000000, 0x118, 0000, 00000000, 00000, 000000000, 000000000, 000000000))
$versionsMatrix.Add('Debug 92.12.21.1' , @(0x682830, 0x0004710, 0x4AC150, -(0xde34), -(0x5450), 0x000354, 0x15C, 00000000, 0x05d2f0, 0x118, 0x30, 0x697ba0, 0xed4,-(0x89a38), 000000000, (0x04C9B90-32)))
                                                                                                                                                                                        
$versionsMatrix.Add('Release 1.00',      @(0x5330E0, 0x0004710, 0x499b28, 0x005d304, 0x0606254, 0x000354, 0x15C, 0x4843f8, 0x05d2f0, 0x118, 0x30, 0x015370, 0xed4, 0x0025828, 0x4b80180, 000000000))
$versionsMatrix.Add('Release 1.02',      @(0xFE0060, 0x1da4720, 0x4A2D38, 000000000, -(0x5450), 0x000354, 0x15C, 00000000, 0x606240, 0x118, 0000, 0x616ee8, 00000, 000000000, 000000000, 000000000))
$versionsMatrix.Add('Release 1.03',      @(00000000, 000000000, 0x49E020, 000000000, -(0x5450), 0x533434, 0x15C, 00000000, 0x57EDF0, 0x118, 0000, 0x536d68, 00000, 000000000, 000000000, 000000000))
$versionsMatrix.Add('Release 1.04',      @(00000000, 000000000, 0x4a2d20, 000000000, -(0x5450), 0x533434, 0x15C, 00000000, 0x6066B0, 0x118, 0000, 0x617358, 00000, 000000000, 000000000, 000000000))
$versionsMatrix.Add('Release 1.05',      @(0x6A8860, 0x0004710, 0x4B05B0, -(0xde34), -(0x5450), 0x000914, 0x15C, 00000000, 0x69AA18, 0x118, 0x30, 0x6be100, 0xD64, 000000000, 000000000, 000000000))
$versionsMatrix.Add('Release 1.07',      @(0x6877A0, 0x0004710, 0x48F5C8, -(0xde34), -(0x5450), 0x000914, 0x15C, 00000000, 0x679958, 0x118, 0x30, 0x69d040, 0xD64, 000000000, 000000000, 000000000))
$versionsMatrix.Add('Release 1.08',      @(0x6884C0, 0x0004710, 0x49052c, -(0xde34), -(0x5450), 0x000914, 0x15C, 00000000, 0x67a698, 0x118, 0x30, 0x69dd60, 0xD64, 000000000, 000000000, 000000000))
#                                                                                                                                                          , 00000, 000000000, 000000000, 000000000000
$versionsMatrix.Add('Release 1.09',      @(0x686470, 0x0004710, 0x48e58c, -(0xde34), +0x04939DC, 0x000914, 0x15C, 0x525740,+0x686436, 0x118, 0x30, 0x0158a0, 0xed4, 0x0018ca8, 0x0015828, 000000000))
#                                                                          0x5b70e4
#, 000000000


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