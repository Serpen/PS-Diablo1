# PS-Diablo1

Powershell Module for Diablo 1 Memory Access / Manipulation

This Powershell Module aims to read an manupulate Diablo 1 Game Infos

Example:

- Connect-DiabloSession #Requires running Diablo Process
- Get-DiabloCharacter
- Set-D1LevelUpPoints 6

- $staff = Get-D1HeroEquipment LeftHand
- $staff.Spell = 'bloodstar'
- $staff | set-d1Item
